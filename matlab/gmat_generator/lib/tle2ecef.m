function [ utc, ecef_state ] = tle2ecef( cubesat_name )
%TLE2TEME TLE data to ECEF coordinate frame using Vallado's functions.
% 
% From http://www.celestrak.com/publications/AIAA/2006-6753/faq.asp:
%
% "How can I create a Cartesian position and velocity ephemeris from a TLE?
% The general algorithm is (MATLAB filenames are used):
% - Read in the data file (TLE information)
% - Convert the TLE information (twoline2rv.m)
% - Initialize SGP4 (sgp4.m with 0.0 time)
% - Loop through the desired time period:
% 	* Call SGP4 and obtain the position and velocity vectors in TEME (sgp4.m)
% 	* Write out the relevant parameters: time since epoch, TEME pos and vel
% - End loop
% The file testmat.m accomplishes these tasks."
% 
% "How can I convert a TEME ephemeris to an Earth Fixed ephemeris?
% teme2ecef.m will convert a TEME vector to Earth fixed (ECEF).
% The general algorithm is (MATLAB filenames are used):
% - Read in data file (TEME ephemeris information)
% - Loop through all the data or the desired time period:
% 	* Convert the position and velocity vectors from TEME to ECEF (teme2ecef.m)
% 	* Write out the relevant parameters: time since epoch, ECEF pos and vel
% - End loop"
%
% Paper that discusses TLE (TEME) frame conversion to "pseudo"-ECEF (PEF):
% https://celestrak.com/publications/AIAA/2006-6753/AIAA-2006-6753.pdf
%


% Where to download TLE file
url = 'http://www.celestrak.com/NORAD/elements/cubesat.txt';


% Read TLE and find correct satellite
cubesat_txt = webread(url);
temp = textscan(cubesat_txt, '%s', 'delimiter', '\n');
cubesat_lines = temp{1};
index = find_index(cubesat_lines, cubesat_name);


% Extract TLE lines
%2017-036M



            
%line1 = '1 42774U 17036K   17179.80163037 +.00001049 +00000-0 +52103-4 0  9993';
%line2 = '2 42774 097.4496 239.4942 0013908 215.6033 144.4275 15.19807516000795';

%line1 = '1 42774U 17036K   17179.80163037 +.00001049 +00000-0 +52103-4 0  9993';
%line2 = '2 42774 097.4496 239.4942 0013908 215.6033 144.4275 15.19807516000795';

%line1 = '1 42776U 17036M   17179.80106334 +.00000741 +00000-0 +37583-4 0  9995';
%line2 = '2 42776 097.4497 239.4953 0013394 214.9281 145.1076 15.19959749000801';

line1 = '1 42775U 17036L   17179.80120039 +.00000798 +00000-0 +40306-4 0  9991';
line2 = '2 42775 097.4496 239.4947 0013524 214.7122 145.3232 15.19922965000805';

%line1 = '1 42775U 17036L   17183.55378403  .00000858  00000-0  43040-4 0  9993';
%line2 = '2 42775  97.4493 243.2000 0013862 200.8305 159.2366 15.19929546  1376';

%line1 = cubesat_lines{index+1};
%line2 = strcat(cubesat_lines{index+2});


% Extract date
tle_date = line1(19:32);


% Save parameters
year = 2000 + str2double(tle_date(1:2));
day_tle = str2double(tle_date(3:5));
frac_tle = str2double(tle_date(6:end));


%  Calculate month and day
date_str = datestr(datenum(year,1,0) + day_tle, 'mmdd');
month = str2double(date_str(1:2));
day = str2double(date_str(3:4));


% Calculate hour, minute, second
day_frac = 86400*frac_tle;
hour = floor(day_frac/3600);
minute = floor(mod(day_frac, 3600)/60);
second = day_frac-hour*3600-minute*60;


% Download Earth Orientation Parameters (EOP)
disp('Downloading Earth Orientation Parameters (EOP)...');
url = 'http://maia.usno.navy.mil/ser7/finals.data';
eop_txt = webread(url);
temp = textscan(eop_txt, '%s', 'delimiter', '\n');
eop_lines = temp{1};


% Formulate search string to find correct data line
year_2 = year - 2000;
search_string = sprintf('%d%2d%2d', year_2, month, day);


% Strip everything except first 6 chars from lines for search
data_len = length(eop_lines);
first_6_chars = cell(data_len,1);
for n=1:data_len
    first_6_chars{n} = eop_lines{n}(1:6);
end

index = find_index(first_6_chars, search_string);


% Get polar parameters, dut1, and lod
marcsec_to_rad = (1/3600)*(pi/180);
x_p = marcsec_to_rad*str2double(eop_lines{index}(19:27));
y_p = marcsec_to_rad*str2double(eop_lines{index}(38:46));
delta_ut1_to_utc = str2double(eop_lines{index}(59:68));
lod = 0.001*str2double(eop_lines{index}(80:86));
if (isnan(lod)) 
    lod = 0; % Check that LOD is valid, otherwise use 0
end


% Initialize SGP4 with WGS72. 'c' for 'catalog mode'.
satrec = twoline2rv(72, line1, line2, 'c');


% Propagate 0 minutes to get position and velocity in TEME frame
[~, pos_teme, vel_teme] = sgp4(satrec, 0.0);


% Assign epoch of TLE as UTC return value
utc = [year month day hour minute second];


% Convert date for teme2ecef conversion. It seems "timezone" and "dat"
% can be zero without effect on jdut1 and ttdt.
[~, ~, jdut1, ~, ~, ~, ttdt, ~, ~, ~, ~, ~, ~, ~] = ...
    convtime(utc(1), utc(2), utc(3), utc(4), utc(5), utc(6), 0, delta_ut1_to_utc, 0);

disp(' ');
disp('TEME coordinates:');
fprintf('x: %f km\n', pos_teme(1));
fprintf('y: %f km\n', pos_teme(2)); 
fprintf('z: %f km\n', pos_teme(3)); 
fprintf('vx: %f km/s\n', vel_teme(1)); 
fprintf('vy: %f km/s\n', vel_teme(2)); 
fprintf('vz: %f km/s\n', vel_teme(3));

% Convert TEME state to ECEF state and assign return value   
pos_teme = pos_teme';
vel_teme = vel_teme';
acc_teme = [0; 0; 0]; % Acceleration not needed
[pos_ecef, vel_ecef, ~] = ...
    teme2ecef(pos_teme, vel_teme, acc_teme, ttdt, jdut1, lod, x_p, y_p);
    
ecef_state = [pos_ecef' vel_ecef'];


end


% Subfunction for finding index of a search_string in a cell array
function [index] = find_index( filecontents, search_string )
    strfind_result = strfind(filecontents, search_string);
    for n=1:length(strfind_result)
        if (strfind_result{n} == 1)
            break
        end
    end
    index = n;
end
