%
%   DESCRIPTION
%
%   Generate GMAT scenario from GPS measurements
%   Hannu Leppinen, August 2015
%
%   This script processes GPS measurements produced by the Aalto-1 GPS receiver,
%   fits an orbit to the measurements, and writes the resulting UTC time and
%   ECEF state vector to a GMAT script.
%


%
%   PARAMETERS
%

% Add folders containing functions
addpath('./lib');
addpath('./lib/sgp4');
addpath('./lib/keplerstm');

% Set long format for numbers
format long;

template_name = 'template/gmat_template.script';
out_file = 'output/aalto1_gps.script';

% NOTE: this is a simulated GPS log generated from data from 2012 SSF GPS
% tests. This state is the "real" solution toward which the GPS orbit fit
% should approach.
%   [-4732317.34827511  628682.337097997    5225895.50081693
%     5622.92669853793  1203.67391008670    4947.04593147192]
% GDOP in these fixes was between 4 and 9, thus poor quality fixes.
% Also the SSF model was Keplerian, vs realistic orbit data from GMAT.
% These issues probably explain the errors.
filename = 'input/fix.log';


%
%   EXECUTABLE PART
%

disp(' ');
fprintf('Analyzing GPS data file %s\n', filename);

% Read GPS file and fit orbit, output ECEF state and UTC time
[utc, ecef_state] = gps2ecef(filename);

disp(' ');
fprintf('GPS Epoch, UTC: %s\n', datestr(utc, 'dd mmm yyyy HH:MM:SS.FFF'));
disp(' ');
disp('WGS84 ECEF coordinates:');
fprintf('x: %f km\n', ecef_state(1));
fprintf('y: %f km\n', ecef_state(2)); 
fprintf('z: %f km\n', ecef_state(3)); 
fprintf('vx: %f km/s\n', ecef_state(4)); 
fprintf('vy: %f km/s\n', ecef_state(5)); 
fprintf('vz: %f km/s\n', ecef_state(6));

disp(' ');
disp('Writing UTC and ECEF to script...');
% Output ECEF state and UTC time to GMAT script using the given template
state2script(utc, ecef_state, out_file, template_name);
fprintf('Wrote to file: %s\n', out_file);
