function [filteredEEG] = twoFiltersOneCall(setFiles, setPath, lowPassEnd, highPassEnd, saveOrNotToSave)
% twoFiltersOneCall applies two filters separately in one call (but who you
% gonna call?).
% INPUT (* = required)
%       setFiles: a cell containing .set files names. If not supplied it
%       will looked for them within setpath.
%       *setPath: path to folder containing set files.
%       *lowPassEnd: number, lower end of filter.
%       *highPassEnd: number, higher end of filter.
%       *saveOrNotToSave: 0 to output filter eeg and 1 to save dataset.
%                         Default is to save. To output the EEG struct it
%                         is necessary to call the function with one EEG
%                         at the time (not within a for loop).
% 
%       e.g.
%       twoFiltersOneCall(setFiles, setPath, lowPassEnd, highPassEnd, saveOrNotToSave)

if isempty(saveOrNotToSave)
    saveOrNotToSave = 1;
end

if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

for i = 1:size(setFile, 2)
    currSet = setFile(i);
    
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    
    %     filtering
    %     tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd,846,1,[],0);
    tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd,1690,1,[],0); % 256
    
    %     tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd,58,0,[],0);
    tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd,114,0,[],0); % 256
    %     EDIT NAME
    tempEEG = pop_editset(tempEEG, 'setname', [tempEEG.setname 'f']);
    
    if (saveOrNotToSave == 0)
        filteredEEG = tempEEG;
    elseif (saveOrNotToSave == 1)
        pop_saveset(tempEEG, 'filename', char(currSet),'filepath', char(setPath));
    end
    
    disp([num2str(i) '/' num2str(size(setFile, 2))])
    
end

end
