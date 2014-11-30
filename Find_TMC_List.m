function Find_TMC_List(root)
global TMC_list
for m = 1:length(root)
    theNode = root(m);
    if strcmp(char(theNode.Name), 'item')
        childNodes = theNode.Children;     % 14 children
        % define the structure
        for i = 1:length(childNodes)
            childNode = childNodes(i);
            if strcmp(childNode.Name, 'PermanentId')
                PermanentId = char(childNode.Children(1).Data);
            elseif strcmp(childNode.Name, 'TMCCode')
                for k = 1:length(childNode.Children)  % ignore the last attribute
                    if strcmp('CountryCode', char(childNode.Children(k).Name))
                        Country_Code = char(childNode.Children(k).Children.Data);
                    elseif strcmp('LocationTable', char(childNode.Children(k).Name))
                        if 1 == length(childNode.Children(k).Children.Data)
                            LocationTable = strcat('0', char(childNode.Children(k).Children.Data));
                        else
                            LocationTable = char(childNode.Children(k).Children.Data);
                        end
                    elseif strcmp('PathDirection', char(childNode.Children(k).Name))
                        if strcmp('N', char(childNode.Children(k).Children.Data))
                            PathDirection = '-';
                        elseif strcmp('P', char(childNode.Children(k).Children.Data))
                            PathDirection = '-';
                        else
                            PathDirection = char(childNode.Children(k).Children.Data);
                        end
                    elseif strcmp('LocationCode', char(childNode.Children(k).Name))
                        if 4 == length(childNode.Children(k).Children.Data)
                            LocationCode = strcat('0', char(childNode.Children(k).Children.Data));
                        else
                            LocationCode = char(childNode.Children(k).Children.Data);
                        end
                    else
                        RoadDirection = char(childNode.Children(k).Children.Data);
                    end
                end
                TMCCode = [Country_Code, LocationTable, PathDirection, LocationCode];
            else
                continue;
            end
        end
        TMC_list(end+1, :) = {PermanentId, TMCCode, Country_Code, LocationTable, ...
            PathDirection, LocationCode, RoadDirection};
        return;
    elseif isempty(theNode.Children)
        continue;
    else
        for i = 1:length(theNode.Children)
            Find_TMC_List(theNode.Children(i))
        end
    end        
end
end