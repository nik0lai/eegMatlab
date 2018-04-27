function [] = rejectInterpol(trackTable, setPath)
% rejectInterpol takes a table with file names, reject components, and
% interpolate bad channels.
% INPUT (* = required)
%       *trackTable:    path to table that contains a "subject" column
%                       (without ".set"), a "rejectInterpol" column with 0 
%                       and 1 indicating which files to run ICA over, a 
%                       "badChanns" column indicating in a string the 
%                       number of bad channels to be left out 
%                       (e.g. 1,2,3,4,5), and a "badComp" column indicating 
%                       in a string the number of bad components to be
%                       rejected (e.g. 1,2,3,4,5).
%       *setPath:       path to folder containing set files.


% get preproc track
preprocTablePath = trackTable;
preprocTrack     = table2struct(readtable(preprocTablePath));

% index and subs to reject components and interpolate channels
toRejI   = find([preprocTrack.rejectInterpol]);
subToRej = {preprocTrack(toRejI).subject};


% folder to export ICAed dataset
rejSetPath = fullfile(setPath, 'rejectInterpoled');
[~,~,~] = mkdir(rejSetPath);

for i = 1:size(subToRej, 2)
    currSub = char(subToRej(i));
    
    %     bad channels
    if (ischar(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badChanns))
        if (isnumeric(unique(str2num(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badChanns))))
            currBadChann = unique(str2num(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badChanns));
        else
            warning(['bad channels string not convertible to numeric on ' currSub])
        end
    elseif (isnan(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badChanns))
        currBadChann = [];
    end
    
    %     bad components
    if (ischar(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badComp))        
        if (isnumeric(unique(str2num(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badComp))))
            currBadComp = unique(str2num(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badComp));
        else
            warning(['bad components string not convertible to numeric on ' currSub])
        end        
    elseif (isnan(preprocTrack(strcmp({preprocTrack.subject}, currSub)).badComp))
        currBadComp = [];
    end
    
    %     load dataset
    EEG = pop_loadset('filename', [currSub '.set'], 'filepath', setPath);    
    
    %     Reject components if components to reject
    if ~isempty(currBadComp)
        EEG = pop_subcomp(EEG, currBadComp, 0);
    elseif isempty(currBadComp)
        warning(['no bad components to reject on ' currSub])
    end
    %      Interpolate bad channels if bad channels to interpolate
    if ~isempty(currBadChann)
        % interpolate bad channels
        EEG = pop_interp( EEG, currBadChann, 'spherical');
    elseif isempty(currBadChann)
        warning(['no bad channels to interpolate on ' currSub])
    end
    
    %     export ICAed dataset
    pop_saveset(EEG, 'filename', currSub,'filepath', rejSetPath); % save current dataset
    
    clear EEG;
            
end