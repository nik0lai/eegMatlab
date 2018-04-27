function [] = trimmEdges(setFiles, setPath, firstEvent, lastEvent, edgesMargins, trimmDir)
%TRIMMEDGES remove edges from EEG data (wrapper around pop_select).
% INPUT (* = required)
%       setFiles: a cell containing .set files names. If not supplied it
%       will looked for them within setpath.
%       *setPath: path to folder containing set files.
%       firstEvent: a number indicating event to be used as onset.
%       secondEvent: a number indicating event to be used as offset.
%       *edgesMargins: time (seconds) to be substracted from first event latency, and
%                      to be add to last event latency [1 10].
%       trimmDir: if empty, default new dir is setPath + /trimmed/. if
%       plizdont, uses setPath (overwritte), if any other string, creates a
%       new folder within setaPath using string as name.

% if set files names are not passed they're looked for within setPath
if isempty(setFiles)
    setFiles = dir(fullfile(setPath, '*.set'));
    setFiles = {setFiles.name};
end

if isempty(trimmDir)
    newDir = 'trimmed';
elseif strcmp(trimmDir, 'plizdont')
    newDir = '';
elseif ~isempty(trimmDir) && ~strcmp(trimmDir, 'plizdont')
    newDir = trimmDir;
end

for i = 1:size(setFiles, 2)
    currSet = setFiles(i);
    
    %     load dataset
    tmpEEG = pop_loadset('filename', char(currSet), 'filepath', char(setPath));
    
    if isempty(firstEvent) && isempty(lastEvent)
        
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate) - edgesMargins(1);     % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate) + edgesMargins(2);  % last event latency
        
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    elseif ~isempty(firstEvent) && isempty(lastEvent)
        
        isFirst = cellfun(@(x)isequal(x,firstEvent), {tmpEEG.event.type});
        firstTriggI = find(isFirst);
        
        firstEdgeSec = (tmpEEG.event(firstTriggI(1)).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate)+edgesMargins(2);  % last event latency
        
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    elseif isempty(firstEvent) && ~isempty(lastEvent)
        
        isLast = cellfun(@(x)isequal(x,lastEvent), {tmpEEG.event.type});
        lastTriggI   = find(isLast);
        
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(lastTriggI(size(lastTriggI, 2))).latency/tmpEEG.srate)+(2);  % last event latency
        
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    end
    
end


end

