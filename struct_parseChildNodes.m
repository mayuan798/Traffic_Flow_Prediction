% ----- Local function PARSECHILDNODES -----
function children = struct_parseChildNodes(theNode)
global TMC_data_Sheet name_index data_index
global flag current current_flow
% Recurse over node children.
if strcmp(theNode.Name, 'TRAFFICML_REALTIME')
    data_index  = data_index + 1;
    flag = 0;
end

%% deal with attributes
for i = 1:length(theNode.Attributes)
    if strcmp(theNode.Name, 'TRAVEL_TIME')
        name = strcat(theNode.Name,'-',theNode.Attributes(i).Name, '_', current_flow{current});
    else
        name = strcat(theNode.Name,'-', theNode.Attributes(i).Name);
    end        
    
    if isempty(TMC_data_Sheet)
        TMC_data_Sheet{1,1} = name;
        name_index = name_index + 1;
    elseif ~ismember(name, TMC_data_Sheet(1,:))
        name_index = name_index + 1;
        TMC_data_Sheet{1, name_index} = name;
    end
    ind = find(strcmp(TMC_data_Sheet(1,:), name), 1);
    TMC_data_Sheet{data_index, ind} = theNode.Attributes(i).Value;
end

%% deal with data
children = theNode.Children;
if strcmp(theNode.Name, 'FLOW_ITEM')
    if 0 == flag
        flag = 1;
    else
         data_index  = data_index + 1;
    end
end

if 1 == length(children) && strcmp(children.Name, '#text')
    if (strcmp(theNode.Name, 'DURATION'))
        theNode.Name = strcat(theNode.Name, '_', current_flow{current});
    elseif (strcmp(theNode.Name, 'AVERAGE_SPEED'))
        theNode.Name = strcat(theNode.Name, '_', current_flow{current});
        current = 3 - current;  %(2 -> 1, 1 -> 2);
    end
    
    if isempty(find(strcmp(TMC_data_Sheet(1,:), theNode.Name), 1))
        name_index = name_index + 1;
        TMC_data_Sheet{1, name_index} = theNode.Name;
    end
    
    ind = find(strcmp(TMC_data_Sheet(1,:), theNode.Name), 1);
    TMC_data_Sheet{data_index, ind} = children.Data;
else
    for k = 1:length(children)
        struct_parseChildNodes(children(k));
    end 
end
