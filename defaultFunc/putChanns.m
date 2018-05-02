function [] = putChanns(setFiles, setPath, channsPath)
% putChanns add channel location to EEG dataset.
% INPUT (* = required)
%       setFiles: a cell containing .set files names. If not supplied it
%       will looked for them within setpath.
%       *setPath: path to folder containing set files.
%       *channsPath: path to channels locations file
% 
%       e.g.
%       putChanns(setFiles, setPath, channsPath)

% if setFiles are not feeded, look for them
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

for i = 1:size(setFile, 2)
    currSet = setFile(i);
    
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    
    tempEEG = pop_editset(tempEEG, 'chanlocs', channsPath);    
    
    pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
    disp([num2str(i) '/' num2str(size(setFile, 2))])

    
end


end