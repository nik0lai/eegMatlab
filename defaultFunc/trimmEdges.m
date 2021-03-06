function [trackTable] = trimmEdges(setFiles, setPath, firstEvent, lastEvent, edgesMargins, trimmDir)
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

% set new folder for trimmed files
if isempty(trimmDir)
    newDir = 'trimmed';
    disp(['exporting trimmed datasets to: /' newDir])
elseif strcmp(trimmDir, 'plizdont')
    newDir = '';
    disp(['exporting trimmed datasets to: /' newDir])
elseif ~isempty(trimmDir) && ~strcmp(trimmDir, 'plizdont')
    newDir = trimmDir;
    disp(['exporting trimmed datasets to: /' newDir])
end

% struct to keep track of changes
% % duration
% % firstEvent
% % lastEvent
% % newDuration
% % durationDiff

trackTable = zeros(size(setFiles, 2), 5);
    date = cell(size(setFiles, 2), 1);

for i = 1:size(setFiles, 2)
    currSet = setFiles(i);
    
    %     Progress indicator
    disp('***********************************')
    disp([num2str(i) '/' num2str(size(setFiles, 2))])
    disp('***********************************')
    %     load dataset
    tmpEEG = pop_loadset('filename', char(currSet), 'filepath', char(setPath));
    
    % original eeg duration
    trackTable(i, 1) = tmpEEG.xmax;
    
    if isempty(firstEvent) && isempty(lastEvent)
        
        % Get labels of first and last event
        firstEdgeType = tmpEEG.event(1).type;     
        lastEdgeType  = tmpEEG.event(size(tmpEEG.event, 2)).type;  
        % Get latencies of first and last event
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate) - edgesMargins(1);                      % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate) + edgesMargins(2);  % last event latency
        
        %         Actual trimming
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    elseif ~isempty(firstEvent) && isempty(lastEvent)
        
        % first event index         
        isFirst = cellfun(@(x)isequal(x,firstEvent), {tmpEEG.event.type});
        firstTriggI = find(isFirst);
        
        % labels         
        firstEdgeType = tmpEEG.event(firstTriggI(1)).type;
        lastEdgeType  = tmpEEG.event(size(tmpEEG.event, 2)).type; 
        
        % latencies        
        firstEdgeSec = (tmpEEG.event(firstTriggI(1)).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate)+edgesMargins(2);  % last event latency
        
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    elseif isempty(firstEvent) && ~isempty(lastEvent)
        
        % last event index         
        isLast = cellfun(@(x)isequal(x,lastEvent), {tmpEEG.event.type});
        lastTriggI   = find(isLast);
        
        % labels
        firstEdgeType = tmpEEG.event(1).type;     
        lastEdgeType  = tmpEEG.event(lastTriggI(size(lastTriggI, 2))).type;
        
        % latencies
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency (227)
        lastEdgeSec  = (tmpEEG.event(lastTriggI(size(lastTriggI, 2))).latency/tmpEEG.srate)+(2);  % last event latency
        
        tmpEEG       = pop_select( tmpEEG,'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
        
        [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
        pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
        
    end
    
    
    %     if event labels are char, convert to num
    if isnumeric(firstEdgeType)
        a = firstEdgeType;
    elseif ischar(firstEdgeType)
        a = str2num(firstEdgeType);
    end
    
    if isnumeric(lastEdgeType)
        b = lastEdgeType;
    elseif ischar(lastEdgeType)
        b = str2num(lastEdgeType);
    end
    
    % set information of trackTable
    trackTable(i, 2) = a; % first event label
    trackTable(i, 3) = b; % last event label
    trackTable(i, 4) = tmpEEG.xmax; % new EEG duration
    trackTable(i, 5) = trackTable(i, 1) - trackTable(i, 4); % difference betwen
    date(i, 1)        = {char(datetime)};     % date
    
    % if last loop, convert array to table
    if (i == size(setFiles, 2))
        trackTable = array2table(trackTable, 'VariableNames', {'origDur', 'firstEvent', 'lastEvent', 'newDur', 'durDiff'});
        trackTable = [table(setFiles', 'VariableNames', {'name'}) trackTable];
    end
    
    
end

trackTable = [trackTable table(date)];

end

