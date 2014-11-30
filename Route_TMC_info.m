%% Initialization
clear all; clc; close all;
% 
% try
%     parpool
% catch ME
%     ;
% end

global TMC_list

ini = IniConfig();
ini.ReadFile('configuration.ini');

Home_Path = ini.GetValues('Path Setting', 'HOME_PATH');
Route_Data_Path = ini.GetValues('Path Setting', 'Route_DATA_PATH');

TMC_list = {'PermanentId', 'TMCCode', 'Country Code', 'LocationTable', 'PathDirection', 'LocationCode', 'RoadDirection'};
filelist = dir(Route_Data_Path);
for i = 3:length(filelist)
    TMC_list = {'PermanentId', 'TMCCode', 'Country Code', 'LocationTable', 'PathDirection', 'LocationCode', 'RoadDirection'};
    filename = filelist(i).name;
    file_path = strcat(Route_Data_Path, '/', filename);
    theStruct = parseXML(file_path);
    % generate TMC list
    Find_TMC_List(theStruct);
    output_path = strcat(Home_Path, '/', 'route_data_output');
    mkdir_if_not_exist(output_path);
    save(strcat(output_path, '/', filename, '_TMC_list.mat'),'TMC_list');
    
    % extract unique TMC list and save them into .txt file to feed into C++
    % program
    unique_TMC = unique(TMC_list(2:end, 2), 'stable');
    fid = fopen(strcat(output_path, '/', filename, '_unique_TMC_list.txt'),'w');
    fprintf(fid,'%s\n', unique_TMC{:});
    fclose(fid);
end