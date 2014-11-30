% systemCommand = ['python D:/Programming/Github/ISL_project_MTC/pygmaps_code/draw_trip.py ', '-d C:/Users/mayuan/Desktop/ProjectFiles/Route1Data/'];
% system(systemCommand);
% % web('D:\Programming\Github\ISL_project_MTC\test_data\output\trips\yuanma_2013 Fusion HEV 2014-02-03 06-43-16-377638 Partition 0.map.draw.html', '-browser');

% filename = 'D:\Programming\Github\Deep_Learning_Project_Traffilc_Flow_Prediction_data\RealtimeFlowA0108_2011_09_01_00_01_48_DST.xml';
% xmlStruct = parseXML(filename);
% save('xmlStruct.mat', 'filename', 'xmlStruct');

function [ TMC_Data_Matrix ] = Freeway_Data_Extraction(theStruct)
global TMC_data_Sheet name_index data_index
global flag current current_flow
TMC_data_Sheet = {};
name_index = 0;
data_index = 1;
flag	= 0;
current_flow = {'current', 'freeflow'};
current = 1;

struct_parseChildNodes(theStruct);

%% post_processing (fill in the blank cell)
% find empty index
ind = find(~cellfun(@isempty, TMC_data_Sheet(:, 5)));
for i = 2:length(ind)-1
    for k = ind(i)+1:ind(i+1)-1
        TMC_data_Sheet(k, 5:7) = TMC_data_Sheet(ind(i), 5:7);
    end
end

for k = ind(end)+1:length(TMC_data_Sheet)
    TMC_data_Sheet(k, 5:7) = TMC_data_Sheet(ind(end), 5:7);
end

for k = 3:length(TMC_data_Sheet)
    TMC_data_Sheet(k, 1:4) = TMC_data_Sheet(2, 1:4);
end

TMC_Data_Matrix = TMC_data_Sheet;
