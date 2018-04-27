function [] = reRefEEG(setFiles, setPath, reRefChann, excludeChann)
% reRef change reference channels
% INPUT (* = required)
%       setFiles:       a cell containing .set files names. If not supplied 
%                       it will looked for them within setpath.
%       *setPath:       path to folder containing set files.
%       *reRefChann:    vector of numbers. channels to rereference data.
%                       (e.g. [129 130])
%       *excludeChann:  vector of numbers. channels to exclude from reref 
%                       process. (e.g. [131:136])
% 
%       e.g.
%       reRef(setFiles, setPath, reRefChann, excludeChann)

% if setFiles are not feeded, look for them
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

for i = 1:size(setFile, 2)
    currSet = setFile(i);
    
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    
    tempEEG  = pop_reref(tempEEG, reRefChann, 'exclude', excludeChann);
    
    pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
    
    
end


end