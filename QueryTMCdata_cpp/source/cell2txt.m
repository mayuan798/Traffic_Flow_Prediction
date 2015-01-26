filename = 'TMCnames-southfield-ns';
load(strcat(filename, '.mat'));
output_file = strcat(filename, '.txt');

fid = fopen(output_file, 'w');
for row = 1:length(TMCnames)
    fprintf(fid, '%s\n', TMCnames{row,:});
end
fclose(fid);