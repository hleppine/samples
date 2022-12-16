%
%   ADD PATHS
%

addpath('./sgp4');
addpath('./keplerstm');
format long;

%
%   READ IN TEST DATA
%

fileID = fopen('../input/gps_test_input_ecef.txt');
gps_test_input_ecef = textscan(fileID, '%s %f %f %f %f %f %f');
fclose(fileID);

fileID = fopen('../input/gps_test_input_eci.txt');
gps_test_input_eci = textscan(fileID, '%s %f %f %f %f %f %f');
fclose(fileID);

% Read clock data
data_length = length(gps_test_input_ecef{1});
parse_vec = zeros(data_length,6);
for n=1:data_length
    parse_vec(n,:) = sscanf(gps_test_input_ecef{1}{n}, '%d-%d-%dT%d:%d:%f');
end
test_utc_ecef = parse_vec;

data_length = length(gps_test_input_eci{1});
parse_vec = zeros(data_length,6);
for n=1:data_length
    parse_vec(n,:) = sscanf(gps_test_input_eci{1}{n}, '%d-%d-%dT%d:%d:%f');
end
test_utc_eci = parse_vec;

test_coord_eci  = [gps_test_input_eci{2} gps_test_input_eci{3} ...
                   gps_test_input_eci{4} gps_test_input_eci{5} ...
                   gps_test_input_eci{6} gps_test_input_eci{7}];

test_coord_ecef = [gps_test_input_ecef{2} gps_test_input_ecef{3} ...
                   gps_test_input_ecef{4} gps_test_input_ecef{5} ...
                   gps_test_input_ecef{6} gps_test_input_ecef{7}];

% Clean up variables
clear data_length fileID n parse_vec ...
      gps_test_input_ecef gps_test_input_eci;
  
%  
%   RUN TESTS  
%  




num_of_meas = 500; % Number of measurements to be used in fit
pos_error_factor = 0.1; % km
vel_error_factor = 0.02; % km/s

for n=1:100

% Select test data source
% If ECI is selected, coordinate rotation needs to be disabled from
% orbitfit.m
test_coord = test_coord_ecef;
test_utc = test_utc_ecef;

% Get state to be compared with;
init_state = test_coord(1,1:6);
final_state = test_coord(num_of_meas,1:6);
comparison_state = final_state;

% Add noise to position and velocity (100m, 20m/s Gaussian)
data_len = length(test_coord(:,1));
test_coord = test_coord + [pos_error_factor*randn(data_len, 3) ...
                           vel_error_factor*randn(data_len, 3)];

utc_time = test_utc(end, 1:6);
ecef_vec = test_coord_ecef(end,1:6); % Note: use ECEF here on purpose
[~, ~, jdut1, ~, ~, ~, ttt, ~, ~, ~, ~ ] ...
    = convtime ( utc_time(1), utc_time(2), utc_time(3), ...
                 utc_time(4), utc_time(5), utc_time(6), 0, 0, 0 );
[eci_vec(1:3), eci_vec(4:6), ~] = ecef2teme(ecef_vec(1:3)', ecef_vec(4:6)', [0 0 0]', ttt, jdut1, 0, 0, 0);

[utc, out_state] = orbitfit(test_utc(1:num_of_meas,:), test_coord(1:num_of_meas,:));
 
difs = abs(out_state-final_state');
 
% fprintf('X True: %f km Estimated: %f km Error: %f m\n', comparison_state(1), out_state(1), 1e3*difs(1));
% fprintf('Y True: %f km Estimated: %f km Error: %f m\n', comparison_state(2), out_state(2), 1e3*difs(2));
% fprintf('Z True: %f km Estimated: %f km Error: %f m\n', comparison_state(3), out_state(3), 1e3*difs(3));
% fprintf('VX True: %f km/s Estimated: %f km Error: %f m/s\n', comparison_state(4), out_state(4), 1e3*difs(4));
% fprintf('VY True: %f km/s Estimated: %f km Error: %f m/s\n', comparison_state(5), out_state(5), 1e3*difs(5));
% fprintf('VZ True: %f km/s Estimated: %f km Error: %f m/s\n', comparison_state(6), out_state(6), 1e3*difs(6));
fprintf('Position error magnitude: %f m Velocity error magnitude: %f m/s\n', 1e3*norm(difs(1:3)), 1e3*norm(difs(4:6)));

end