%
%   DESCRIPTION
%
%   Generate GMAT scenario from TLE file
%   Hannu Leppinen, August 2015
%
%   This script downloads cubesat.txt from Celestrak, extracts TLE data
%   from it, and converts it to ECEF state vector with UTC time. A GMAT
%   script file is then generated based on the UTC time and ECEF state.
%


%
%   PARAMETERS
%

% Add folders containing functions
addpath('./lib');
addpath('./lib/sgp4');

% Which satellite to extract from TLE
search_string = 'ESTCUBE';

% Set long format for numbers
format long;

template_name = 'template/gmat_template.script';
out_file = 'output/aalto1_tle.script';


%
%   EXECUTABLE PART
%

disp(' ');
fprintf('Searching %s from TLE file\n', search_string);

% Read TLE and extract ECEF state and UTC time
[utc, ecef_state] = tle2ecef(search_string);

disp(' ');
fprintf('TLE Epoch, UTC: %s\n', datestr(utc, 'dd mmm yyyy HH:MM:SS.FFF'));
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
