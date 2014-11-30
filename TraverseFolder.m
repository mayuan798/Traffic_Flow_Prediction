function [filelist] = TraverseFolder(root, inputfolder)
filelist = {};
dirlist = dir(strcat(root, '/', inputfolder));
for i = 3:length(dirlist)
    current_file = strcat(inputfolder, '/', dirlist(i).name);
    sprintf('%s', current_file)
    handle = strcat(root, '/', current_file);
    INCIDENT_format = '\w*Incident';
    if isdir(handle)
        if ~isempty(regexp(handle, INCIDENT_format, 'match'))
            continue;
        else
            temp = TraverseFolder(root, current_file);
            if ~isempty(temp) 
                filelist(end+1:end+length(temp), 1) = temp(:, 1);
            end
        end
    else
        filename = strcat(inputfolder, '/', dirlist(i).name);
        gz_format = '\w*.gz';
        if ~isempty(regexp(filename, gz_format, 'match'))
            try
                filelist{end+1, 1} = filename;
            catch ME
                ;
            end
        end
    end
end
end