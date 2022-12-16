function [ utc, ecef_state ] = gps2ecef( filename )
%GPS2ECEF Read GPS "fix.log" file and produce time and state estimate


% Open and read in the file assuming format produced by Aalto-1 GPS program
fileID = fopen(filename);
file_content = textscan(fileID, '%f %s %s %f %f %f %f %f %f %f');
fclose(fileID);

[times, coordinates] = parse_content(file_content);

% Fit orbit to measurements
[utc, ecef_state] = orbitfit(times, coordinates);

end
