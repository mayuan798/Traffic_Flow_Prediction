%% Initialization
clear all; clc; close all;

try
    parpool
catch ME
    ;
end

ini = IniConfig();
ini.ReadFile('configuration.ini');

Home_Path = ini.GetValues('Path Setting', 'HOME_PATH');
Data_Path = ini.GetValues('Path Setting', 'DATA_PATH');

disp('Traverse .gz files in root folder.');
tic;
filelist = TraverseFolder(Data_Path, '');
toc;
disp('Finish listing all files in root folder.');

%%
parfor i = 1:length(filelist)
    % first unzip xml file
    % if exists, continue
    [pathstr,name,ext] = fileparts(char(filelist(i)));
    filename = char(filelist(i));
    if ~exist(strcat(Home_Path, pathstr, '/', name), 'file')
        sprintf('unzip .gz files %s', filename)
        gunzip(strcat(Data_Path, '/', filename), strcat(Home_Path, '/', pathstr));
    end
    sprintf('Finish .gz file %s unzip.\n', filename);
    %%
%     disp('Start Generating TMC Matrix data');
%     xml_file = strcat(Home_Path, '/', pathstr, '/', name);
%     if ~exist(strcat(Home_Path, pathstr, '/', name, '.mat'), 'file')
%         sprintf('Parser file: %s\n', xml_file)
%         tic;
%         theStruct = parseXML(xml_file);
%         toc;
%         TMC_Data_Matrix = Freeway_Data_Extraction(theStruct);
%         parsave(strcat(Home_Path, '/', pathstr, '/', name, '.mat'), TMC_Data_Matrix);
%         sprintf('Delete file (condition I): %s\n', xml_file)
%         delete(xml_file);
%         
%     elseif exist(xml_file, 'file')
%         sprintf('Delete file (condition II): %s\n', xml_file)
%         delete(xml_file);
%     end
end
disp('F Generating TMC Matrix data');
delete(gcp);