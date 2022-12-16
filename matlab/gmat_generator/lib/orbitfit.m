function [ utc, ecef_state ] = orbitfit( timestamps, coordinates )
%ORBITFIT Fit orbit to ECEF measurements from GPS.
%
%   References: 
%       - Tapley et al: "Statistical Orbit Determination", 2004.
%       - Dinkel: "ASEN 5070 Statistical Orbit Determination I Final
%         Project", 2012.
%
%   Parameters:
%       - times: UTC timestamps of GPS fixes
%       - coordinates: ECEF coordinates [km, km/s]
%   Returns: 
%       - utc: UTC epoch when the state vector is valid.
%       - ecef_state: Estimated ECEF state vector at epoch "utc" [km, km/s]
%

% Flip vector
coordinates = coordinates';

% Rotate from ECEF to ECI - simple rotation can be used since we are only
% dealing with measurements within short period of time; only term of 
% importance is Earth's rotation
% ecef2teme and teme2ecef are used without polar parameters.

% Use subfunction
coordinates = rotate_ecef2teme(timestamps, coordinates);

% Convert to [m, m/s]
coordinates = 1000.*coordinates;

% Calculate time differences
num_of_meas = size(coordinates, 2);
t = zeros(1, num_of_meas);
for k=2:(num_of_meas) % Leave first item as 0
    t(k) = etime(timestamps(k,1:6), timestamps(1,1:6));
end

%
%   Fit orbit using an Extended Kalman filter.
%   Sources: 
%       - Tapley p. 212
%       - https://en.wikipedia.org/wiki/Extended_Kalman_filter
%   


% Initialize at t_0
x_hat = coordinates(1:6, 1);
P = eye(6);
I = eye(6); % Identity matrix
Phi = eye(6);

options = odeset('RelTol',1e-12,'AbsTol',1e-12);

for ii = 2:(num_of_meas)
    
    % (A) Read the next observation: t_i, Y_i, R_i.
    Y = coordinates(1:6, ii);
    R = eye(6);

    % Reshape x_hat and Phi into single vector for integration    
    State_ode45 = [x_hat; Phi(1:6,1); Phi(1:6,2); Phi(1:6,3); Phi(1:6,4); Phi(1:6,5); Phi(1:6,6)];
    
    % Integrate state vector and state transition matrix from t_(i-1) to t_i
    [~, State_ode45] = ode45(@derivatives, [t(ii-1) t(ii)], State_ode45, options);
    
    % Extract last integration step
    State_ode45 = State_ode45(end, :);
    
    % Extract state vector and state transition matrix    
    Phi_ode45 = reshape(State_ode45(7:42), 6, 6);
    x_ode45 = State_ode45(1:6)';
    P_ode45 = Phi_ode45 * P * Phi_ode45';
    
    % Calculate using keplerSTM
    Phi_kepler = keplerSTM(x_hat, t(ii)-t(ii-1), 3.986004418E14);
    x_kepler = Phi_kepler*x_hat;
    P_kepler = Phi_kepler * P * Phi_kepler';  
    
    % This combination seems to provide best performance and stability.
    x = x_ode45; % New position estimate before measurement
    P = P_ode45; % New covariance estimate before measurement
    
    % Compute:
    H = eye(6); % Observation matrix (all parameters observed directly)  
    y = Y - H*x; % Observation deviation (same coords, no transform)
    K = P*H'/(H*P*H'+R); % Kalman gain
     
    % Measurement update
    P = ( I - K*H )*P;
    x_hat = x + K*y;
    
end

% Assign time of last measurement as epoch
utc = timestamps(end, 1:6); 

% Convert to [km, km/s]
x_hat = 0.001.*x_hat;

% Rotate ECI back to ECEF and return, use subfunction
ecef_state = rotate_teme2ecef(utc, x_hat);


end % END FUNCTION


% Helper function: rotate TEME to ECEF
function [ecef_state] = rotate_teme2ecef(times, eci_state)
    data_len = length(eci_state(1,:));
    ecef_state = zeros(6,data_len);
    for n=1:data_len
        utc_time = times(n,1:6);
        [~, ~, jdut1, ~, ~, ~, ttt, ~, ~, ~, ~ ] ...
        = convtime ( utc_time(1), utc_time(2), utc_time(3), utc_time(4), utc_time(5), utc_time(6), 0, 0, 0 );
        eci_vec = eci_state(:,n);
        [ecef_vec(1:3), ecef_vec(4:6), ~] = teme2ecef(eci_vec(1:3), eci_vec(4:6), [0 0 0]', ttt, jdut1, 0, 0, 0);
        ecef_state(:,n) = ecef_vec;
    end
end


% Helper function: rotate ECEF to TEME
function [eci_state] = rotate_ecef2teme(times, ecef_state)
    data_len = length(ecef_state(1,:));
    eci_state = zeros(6,data_len);
    for n=1:data_len
        utc_time = times(n,1:6);
        [~, ~, jdut1, ~, ~, ~, ttt, ~, ~, ~, ~ ] ...
        = convtime ( utc_time(1), utc_time(2), utc_time(3), utc_time(4), utc_time(5), utc_time(6), 0, 0, 0 );
        ecef_vec = ecef_state(:,n);
        [eci_vec(1:3), eci_vec(4:6), ~] = ecef2teme(ecef_vec(1:3), ecef_vec(4:6), [0 0 0]', ttt, jdut1, 0, 0, 0);
        eci_state(:,n) = eci_vec;
    end
end


function [ dX ] = derivatives( t, X0 )

% Define constants to be used in integration
constants.MU = 3.986004418E14; % Standard gravitational parameter [m^3/s^2]
constants.J2 = 1.081874E-3;%1.082626925638815E-3; % J2 coefficient
constants.R_e = 6378137; % Equatorial radius of Earth [m]
constants.C_D = 2.0; % Drag coefficient
constants.A = 0; % Disable drag 0.03; % Drag area [m^2]
constants.m = 4; % Mass [kg]
constants.H = 88667.0; % Scale parameter [m]
constants.rho0 = 3.614E-13; % Density at reference altitude 700 km [kg/m^3]
constants.r_zero = 700000 + constants.R_e; % Reference radius [m]
constants.thetad = 7.292115E-5; % Rotation rate of earth [rad/s]

% Extract a local version of our state:
X = X0(1:6); % Position and velocity

% Extract the current STM:
Phi = reshape(X0(7:42), 6,6);

% Integrate Acceleration and Velocity:
dX = zeros(length(X0),1);
dX(1:6) = eqns_of_motion(X, constants);

% Integrate the state transition matrix:
dPhi = a_matrix(X, constants)*Phi;

% Place dPhi elements to output vector
dX(7:42) = reshape(dPhi, numel(dPhi), 1);

end


function [ dX ] = eqns_of_motion( X, constants )
%EQNS_OF_MOTION 

x = X(1);
y = X(2);
z = X(3);
xd = X(4);
yd = X(5);
zd = X(6);

% Constants
MU = constants.MU;
J2 = constants.J2;
R_e = constants.R_e;
C_D = constants.C_D;
A = constants.A;
m = constants.m;
H = constants.H;
rho0 = constants.rho0;
r_zero = constants.r_zero;
thetad = constants.thetad;

% Solve for position magnitude:
r = norm(X(1:3));

% Initialize:
dX = zeros(6,1); % Initialize derivative vector

% Integrate velocity to find position:
% X = int[dx/dt = U], Y = int[dy/dt = V]
dX(1:3) = X(4:6);

% Integrate acceleration to find velocity (J2 effect included):
ZFAC = 5*(z/r)^2;
JFAC = (3/2)*J2*(R_e/r)^2;

MUFAC = -MU/r^3;
dX(4) = MUFAC*x*(1-JFAC*(ZFAC-1));
dX(5) = y/x*dX(4);
dX(6) = MUFAC*z*(1-JFAC*(ZFAC-3));

% Calculate density and velocity of drag:
rho_A = rho0 * exp(-(r - r_zero)/H);
V_A = [xd + thetad*y; yd - thetad*x; zd];

% Add drag to acceleration terms:
dX(4:6) = dX(4:6) - 0.5*C_D*A/m*rho_A*norm(V_A)*V_A;

end


function [ AMat ] = a_matrix( X, constants )
%A_MATRIX Formulate A matrix for state transition matrix integration

x = X(1);
y = X(2);
z = X(3);
xd = X(4);
yd = X(5);
zd = X(6);

% Constants
MU = constants.MU;
J2 = constants.J2;
R_e = constants.R_e;
C_D = constants.C_D;
A = constants.A;
m = constants.m;
H = constants.H;
rho0 = constants.rho0;
r_zero = constants.r_zero;
thetad = constants.thetad;

% Solve for position magnitude:
r = norm(X(1:3));

% Calculate density and velocity of drag:
rho_A = rho0 * exp(-(r - r_zero)/H);
V_A = norm([xd + thetad*y; yd - thetad*x; zd]);

% Calculate common J2 terms:
JFAC = J2*(R_e/r)^2;
ZFAC = (z/r)^2;
DIAG = -MU/r^3 * (1 - 3/2*JFAC*(5*ZFAC - 1));
ZDIAG = -MU/r^3 * (1 - 3/2*JFAC*(5*ZFAC - 3));
COMP = 3*MU/r^5 * (1 - 5/2*JFAC*(7*ZFAC-1));
ZCOMP = 3*MU*z/r^5 * (1 - 5/2*JFAC*(7*ZFAC-3));
ZZCOMP = 3*MU*z^2/r^5 * (1 - 5/2*JFAC*(7*ZFAC-5));

% Allocate space for matrix parts:
dR_dot_dR = zeros(3);
dR_dot_dV = eye(3);

% Calculate dV dot/dR:
du_dot_dx = DIAG + x^2*COMP;
du_dot_dy = x*y*COMP;
du_dot_dz = x*ZCOMP;

dv_dot_dx = du_dot_dy;
dv_dot_dy = DIAG + y^2*COMP;
dv_dot_dz = y*ZCOMP;

dw_dot_dx = du_dot_dz;
dw_dot_dy = dv_dot_dz;
dw_dot_dz = ZDIAG + ZZCOMP;

dV_dot_dRJ2 = ...
[ du_dot_dx, du_dot_dy, du_dot_dz;
  dv_dot_dx, dv_dot_dy, dv_dot_dz;
  dw_dot_dx, dw_dot_dy, dw_dot_dz ];

% % Calculate common Drag terms:
DR = 0.5*C_D*(A/m)*rho_A;
C1 = DR*V_A;
C2 = DR/V_A;
XTY = xd + thetad*y;
YTX = yd - thetad*x;
D = r*H;
C1D = C1/D;
 
% % Calculate dV dot/dR:
du_dot_dx = C1D*x*XTY - C2*thetad*-YTX*XTY;
du_dot_dy = C1D*y*XTY - C2*thetad*XTY*XTY - C1*thetad;
du_dot_dz = C1D*z*XTY;
 
dv_dot_dx = C1D*x*YTX - C2*thetad*-YTX*YTX + C1*thetad;
dv_dot_dy = C1D*y*YTX - C2*thetad*XTY*YTX;
dv_dot_dz = C1D*z*YTX;
 
dw_dot_dx = C1D*x*zd - C2*zd*thetad*-YTX;
dw_dot_dy = C1D*y*zd - C2*zd*thetad*XTY;
dw_dot_dz = C1D*z*zd;
 
dV_dot_dRDrag = ...
[ du_dot_dx, du_dot_dy, du_dot_dz;
  dv_dot_dx, dv_dot_dy, dv_dot_dz;
  dw_dot_dx, dw_dot_dy, dw_dot_dz ];

% Calculate dV_dot/dV:
du_dot_du = -C2*XTY^2 - C1;
du_dot_dv = -C2*YTX*XTY;
du_dot_dw = -C2*XTY*zd;

dv_dot_du = du_dot_dv;
dv_dot_dv = -C2*YTX^2 - C1;
dv_dot_dw = -C2*YTX*zd;

dw_dot_du = du_dot_dw;
dw_dot_dv = dv_dot_dw;
dw_dot_dw = -C2*zd^2 - C1;

dV_dot_dV = ...
[ du_dot_du, du_dot_dv, du_dot_dw;
dv_dot_du, dv_dot_dv, dv_dot_dw;
dw_dot_du, dw_dot_dv, dw_dot_dw ];

dV_dot_dR = dV_dot_dRJ2 + dV_dot_dRDrag;

AMat = ...
[ dR_dot_dR, dR_dot_dV; 
  dV_dot_dR, dV_dot_dV];

end

