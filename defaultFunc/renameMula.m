function [] = renameMula(setFiles, setPath)
% putChanns add channel location to EEG dataset.
% INPUT (* = required)
%       setFiles: a cell containing .set files names. If not supplied it
%       will looked for them within setpath.
%       *setPath: path to folder containing set files.
%
%       e.g.
%       renameMula(setFiles, setPath)

% if setFiles are not feeded, look for them
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

for i = 1:size(setFile, 2)
    currSet = setFile(i);
    %     Load dataset
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    %     Create new name
    newName = strrep(tempEEG.setname, ' resampled', '_s');
    %     Replace old with new name
    tempEEG = pop_editset(tempEEG, 'setname', newName);
    %         Save dataset
    pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
    
    %     Progress indicator
    disp([num2str(i) '/' num2str(size(setFile, 2))])
    
end


end