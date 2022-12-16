% Test Vallado's functions
% 1) TLE to TEME
% 2) TEME to ECEF

% Test TLE to TEME conversion and propagation
% Values from:
% Vallado et al. - Revisiting Spacetrack Report #3, AIAA 2006-6753, p. 33

addpath('./sgp4');

format long;

line1 = '1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753';
line2 = '2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667';

% Initialize SGP4
satrec = twoline2rv(72, line1, line2, 'c');

% Propagate 3 days (3*24*60 minutes)
[~, pos_teme, vel_teme] = sgp4(satrec, 4320);

expval = [-9060.47373569 4658.70952502 813.68673153 -2.232832783 -4.110453490 -3.157345433];
difs = [abs(expval(1)-pos_teme(1)), ...
        abs(expval(2)-pos_teme(2)), ...
        abs(expval(3)-pos_teme(3)), ...
        abs(expval(4)-vel_teme(1)), ...
        abs(expval(5)-vel_teme(2)), ...
        abs(expval(6)-vel_teme(3))];

disp(' ');
disp('Test TLE to TEME:');
fprintf('X  - Expected: %.8f Calc: %.8f Err: %.8f\n', expval(1), pos_teme(1), difs(1));
fprintf('Y  - Expected: %.8f Calc: %.8f Err: %.8f\n', expval(2), pos_teme(2), difs(2));
fprintf('Z  - Expected: %.8f Calc: %.8f Err: %.8f\n', expval(3), pos_teme(3), difs(3));
fprintf('VX - Expected: %.9f Calc: %.9f Err: %.9f\n', expval(4), vel_teme(1), difs(4));
fprintf('VY - Expected: %.9f Calc: %.9f Err: %.9f\n', expval(5), vel_teme(2), difs(5));
fprintf('VZ - Expected: %.9f Calc: %.9f Err: %.9f\n', expval(6), vel_teme(3), difs(6));

% Vallado:
% Following coordinates match on June 28, 2000, 15:08:51.655 UTC
% TEME: -3961.0035498 6010.7511740 4619.3009301 -5.315109069 3.963813071 1.752758562
% PEF: 298.8036328 -7192.3146229 4619.3015310 6.105014271 -0.131824177 1.752759802

% Parameters can be fetched online http://maia.usno.navy.mil/ser7/finals.all

% Convert date for teme2ecef conversion

year = 2000;
month = 6;
day = 28;
utc = [2000 06 28 15 08 51.655];

marcsec_to_rad = (1/3600)*(pi/180);

x_p = marcsec_to_rad*0.098700;
y_p = marcsec_to_rad*0.286000;

lod = 0;
delta_tai_to_utc = 21;% Value doesn't seem to matter, can be zero
delta_ut1_to_utc = 0.162360;

[~, ~, jdut1, ~, ~, ~, ttdt, ~, ~, ~, ~, ~, ~, ~] = ...
    convtime(utc(1), utc(2), utc(3), utc(4), utc(5), utc(6), 0, delta_ut1_to_utc, delta_tai_to_utc);

jdut1_ref = 2451724.13115529340;
ttdt_ref = 0.004904360547;

pos_teme = [3961.0035498; 6010.7511740; 4619.3009301];
vel_teme = [-5.315109069; 3.963813071; 1.752758562];
acc_teme = [0; 0; 0]; % Acceleration not needed

[pos_ecef, vel_ecef, ~] = ...
    teme2ecef(pos_teme, vel_teme, acc_teme, ttdt, jdut1, lod, x_p, y_p);

exp_coord = [298.8036328 -7192.3146229 4619.3015310 6.105014271 -0.131824177 1.752759802];

difs = [abs(exp_coord(1)-pos_ecef(1)), ...
        abs(exp_coord(2)-pos_ecef(2)), ...
        abs(exp_coord(3)-pos_ecef(3)), ...
        abs(exp_coord(4)-vel_ecef(1)), ...
        abs(exp_coord(5)-vel_ecef(2)), ...
        abs(exp_coord(6)-vel_ecef(3))];

disp(' ');
disp('Test TEME to ECEF:');
fprintf('X  - Expected: %.8f Calc: %.8f Err: %.8f km\n', exp_coord(1), pos_ecef(1), difs(1));
fprintf('Y  - Expected: %.8f Calc: %.8f Err: %.8f km\n', exp_coord(2), pos_ecef(2), difs(2));
fprintf('Z  - Expected: %.8f Calc: %.8f Err: %.8f km\n', exp_coord(3), pos_ecef(3), difs(3));
fprintf('VX - Expected: %.9f Calc: %.9f Err: %.9f km/s\n', exp_coord(4), vel_ecef(1), difs(4));
fprintf('VY - Expected: %.9f Calc: %.9f Err: %.9f km/s\n', exp_coord(5), vel_ecef(2), difs(5));
fprintf('VZ - Expected: %.9f Calc: %.9f Err: %.9f km/s\n', exp_coord(6), vel_ecef(3), difs(6));
