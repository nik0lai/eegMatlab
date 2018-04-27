function [] = interactivePeakFinder(setFiles, setPath, ecgChann)
% interactivePeakFinder is an interactive wrapper around peakfinder. It
%                       allows to re-call peakfinder function adjusting how 
%                       bigger the peak must be to be considered a peak.
% INPUT (* = required)
%       setFiles:   a cell containing .set files names. If not supplied it
%                   will looked for them within setpath.
%       *setPath:   path to folder containing set files.
%       *ecgChann:  number indicating the channel number where the ecg is.
% This function requires insertEcgEvents.m to be able to insert new ecg
% events into current EEG event structure.

% possible prompt responses
y = 'yes';
n = 'no';

if isempty(setFiles) 
% get file names
setFiles = dir(fullfile(setPath, '/*.set'));
end

for i = 1:size({setFiles.name},2)
    currSet = {setFiles(i).name};
    
    tmpEEG      = pop_loadset('filename', char(currSet), 'filepath', char(setPath)); % load dataset
    ecgChannData = tmpEEG.data(ecgChann:ecgChann, :);                                    % get ecg data channel
    
    peakfinder(ecgChannData)                                                    % first call to peakfinder
    peakFinderArg = (max(ecgChannData )-min(ecgChannData ))/4;                  % default sel argument
    disp(['Starting with ' num2str((max(ecgChannData )-min(ecgChannData ))/4)]) % message to inform first sel argument
    
    doingShit = 1; % to start while
    
    while (doingShit == 1)
        
        x = input('do shit: '); % prompt message
        
        if isnumeric(x) % re-run peakfinder with passed number as sel arg
            close all;
            peakFinderArg = x;
            peakfinder(tmpEEG.data(ecgChann:ecgChann, :), peakFinderArg)
        elseif ischar(x)
            
            if (strcmp(x,'yes'))
                [beatTimes, ~] = peakfinder(tmpEEG.data(ecgChann:ecgChann, :), peakFinderArg);  % get latency and magnitudes of R peaks
                tmpEEG        = insertEcgEvents(tmpEEG, beatTimes, '537');
                
                [~, ~, ~] = mkdir(fullfile(char(setPath), 'ekaged/'));
                pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), 'ekaged/')); % save dataset
                
                doingShit = 0;
            elseif (strcmp(x,'no'))                
                doingShit = 0;
            end
        end
        
    end
    
    
    
    
end

