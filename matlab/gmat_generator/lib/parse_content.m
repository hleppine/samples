function [ data ] = parse_content( file_content )
%PARSE_CONTENT Parse given file content to times and coordinates
%   Detailed explanation goes here

% Read and parse UTC time
data_length = length(file_content{2});
parse_vec = zeros(3,data_length);
for n=1:data_length
    parse_vec(:,n) = sscanf(file_content{2}{n}, '%d.%d.%d');
end
parse_vec = parse_vec';

year_vec = parse_vec(:,3);
month_vec = parse_vec(:,2);
day_vec = parse_vec(:,1);

parse_vec = zeros(3,data_length);
for n=1:data_length
    parse_vec(:,n) = sscanf(file_content{3}{n}, '%d:%d:%f');
end
parse_vec = parse_vec';

hour_vec = parse_vec(:,1);
minute_vec = parse_vec(:,2);
second_vec = parse_vec(:,3);

times = [year_vec month_vec day_vec hour_vec minute_vec second_vec];


% Read coordinates and convert to km and km/s
coordinates = [file_content{4} file_content{5} file_content{6} file_content{7} file_content{8} file_content{9}]*0.001;

gdops = file_content{10};

data = [times coordinates gdops];

end

