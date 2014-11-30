function [TMCdata_list] = RouteTMCdata_Generation(routeTMC_list, Daily_TMCdata_folder)
load(routeTMC_list);
[uniqVals,uniqIndx] = unique(TMC_list(2:end, 6)); % find Unique TMC names
dirlist = dir(Daily_TMCdata_folder);
TMCdata_list = {};
mat_pattern = '\w*.mat';
for i = 3:length(dirlist)
   filename = strcat(Daily_TMCdata_folder, '/', dirlist(i).name);
   if ~isempty(regexp(filename, mat_pattern, 'match'))
       load(filename); % load
       if isempty(TMCdata_list)
           TMCdata_list = TMC_Data_Matrix(1, :);
       end
       ind = find(ismember(TMC_Data_Matrix(2:end, 11), uniqVals));
       TMCdata_list(end+1:end+length(ind), :) = TMC_Data_Matrix(ind, :);
   else
       continue;
   end
end
[pathstr, name, ext] = fileparts(routeTMC_list);
save(strcat(Daily_TMCdata_folder, '/', name, 'TMCdata_list.mat'), 'TMCdata_list')
end