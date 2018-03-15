% This script preprocess EEG data:
%     Import bdf files
%     Re-reference to mastoids
%     Re-sample
%     Import channels location
%     Filter data

% TO NOTE: is there a way to identify which channels are the two heart
% external channels?

%% Prepare enviroment

clear;      % clear enviroment
eeglab;     % open eeglab to lighten paths to the eeglab ways
close all;  % close everything
clc;        % clear command line

%% Parameters (user-defined)

subPreproc = [404 405];

% For actual preprocessing
    % Participants
    % Filtering
        lowpassFilter = .30; % lowpass
        highpassFilter = .5; % highpass

    % Resample
    newSampRate = 256;
    % Re-reference
    rerefChanns = [129 130];

% directories
    % main eeg dir
    mainDir = '/home/niki/Documents/eegeses/fdcyt_agustin/';
    % bdf dir
    bdfDir  = [mainDir 'bdf/'];
    % set dir
    setDir  = [mainDir 'set/'];
    % chann location dir
    channel_location_dir = '/home/niki/Documents/MATLAB/eeg_resources/chanlocs/BioSemi136_10_20a.sfp';
    
    
%% Get participants bdf folder

bdfFolders      = dir([bdfDir 'CH_F17*']);
bdfFoldersNames = char(bdfFolders.name);
bdfFoldersNum   = str2num(bdfFoldersNames(:, end-2:end));

subPreprocIndex = zeros(1, size(subPreproc, 2));

for i = 1:size(subPreproc, 2)
    position            = find(bdfFoldersNum == subPreproc(i)); % look for the position of participants to preprocess
    subPreprocIndex(i)   = position; % store position
end

%% Loop through subjects to preprocess
for subCount = 1:numel(subPreprocIndex)
    
    
    %% Get bdf files names and paths
    folder2preproc = bdfFoldersNames(subPreprocIndex(subCount), :); % participant to preprocess folder
    bdf2preproc    = dir([bdfDir folder2preproc '/*.bdf']);
    
    %% bdf files info
    
    %date
    [~, bdfIx]     = sort([bdf2preproc.datenum]); % task-order
    
    %path
    bdfPaths = strcat(bdfDir, folder2preproc, '/', {bdf2preproc.name});


    %% Loop through files within a subject
    for fileCount = 1:numel(bdf2preproc)
        
        %% Read file
        
        EEG = pop_biosig(char(bdfPaths(fileCount)));
        
        %cond, subject_number, taks
        bdfName = strtok(bdf2preproc(fileCount).name, '.bdf');
        bdfInfo = strsplit(bdfName, '_');
        bdfInfo = bdfInfo(:, 3:5);
        
        %%% record %%%%%%%%%%%%%%%%%%%%%
        t.start      = datetime('now');%
        duration.pre = EEG.xmax;       %
        oldSamRate   = EEG.srate;      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % resample
        EEG = pop_resample(EEG, newSampRate);
        
        %% channels location
        
        EEG = pop_editset(EEG, 'chanlocs', channel_location_dir); % add channels locations

        %% re-reference
        
        % How can I get the number of cap channels?
        channNumb = EEG.nbchan;                     % get EEG total number of channels
        channExt  = 129:channNumb;                  % identify external channels
        channInt  = setdiff(1:channNumb, channExt); % identify internal (channels in the head) channels
        rerefExcl = setdiff(channExt, rerefChanns); % external channels to be exclude of rereferencing
        
        EEG = pop_reref(EEG, [129 130], 'exclude', rerefExcl);
        
        %% filter
        
        EEG = pop_eegfiltnew(EEG, [], highpassFilter,114,0,[],1); % highpass filter (what are the other parameters?)
        EEG = pop_eegfiltnew(EEG, [], lowpassFilter,1690,1,[],1); % lowpass filter (what are the other parameters?)

        %% cut edges
        
        if size(EEG.event, 2) == 0
            
            fprintf('\n\n**********\nCHE, no hay marcas!\n**********\n\n')
            
        elseif not(strcmp(bdfInfo(3),'RESTING'))
            % respectively, time in seconds from the data beggining and end to the
            % first and last event
            cutMargin = 3;
            
            % first event
            frstEventTimePos = (EEG.event(1).latency/EEG.srate)-cutMargin;
            % last event
            lstEventTimePos = (EEG.event(end).latency/EEG.srate)+cutMargin;
            % cut edges
            EEG = pop_select( EEG,'time',[frstEventTimePos lstEventTimePos]);
            
            fprintf('\n\n**********\nNO REST FOR THE WICKED: non-resting file\n**********\n\n')
            
        elseif strcmp(bdfInfo(3),'RESTING')
            fprintf('\n\n**********\nRESTING, KEEP RESTING\n**********\n\n')
            
        end
        
        %% create ekg channel
        % If we apply mastoid reref we end up with two lesser channels
        % so ekg is not 137 but 135
        
        EEG = pop_eegchanoperator(EEG, {[['ch' int2str(EEG.nbchan + 1)] ' = ch131 - ch132 label EKG']} , 'ErrorMsg', 'popup', 'Warning', 'on'); % Create EKG channel with the substraction of 131-132

        %% assign data to set file
        % dataset name
        EEG = pop_editset(EEG, 'setname', strjoin(bdfInfo, '_')); % asign dataset name using bdf file name
        % subject code
        EEG = pop_editset(EEG, 'subject', subPreproc); % subject code
        % session task-order
        EEG = pop_editset(EEG, 'session', find(bdfIx == i));
        % condition (task)
        EEG = pop_editset(EEG, 'condition', bdfInfo(3)); % task condition (intero, social_learning, negation, resting)
        % group (DX)
        EEG = pop_editset(EEG, 'group', bdfInfo(1)); % subject group (control, alzhaimer, dft, parkinson?)
        %% Save dataset
        
        currSetfilePath = [setDir folder2preproc '/'];
        
        if exist(currSetfilePath, 'dir') == 7
            fprintf('\n\n**********\nfolder already EXISTS!\n**********\n\n');
        elseif exist(currSetfilePath , 'dir') == 0
            mkdir(currSetfilePath);
            fprintf('\n\n**********\nfolder CREATED!\n**********\n\n');
        end
        
        % save dataset
%         pop_saveset(EEG, 'filename', [bdfName '.set'],'filepath', currSetfilePath); % save current dataset
        
        fprintf('\n\n**********\ndataset saved\n**********\n\n');

        %% Create txt file with files preprosseced and info about the preprocessing.
        
        % this part should check if a txt file with information exists and, if
        % exists, append the new information to that file.
        
        % information that I want to have recorded.
        table_names = {'subject', 'tasK', 'taskOrder', 'taskDurOrig', 'taskDurFinal', 'oldSmpRate', 'newSmpRate', 'lwpassFilt', 'hghpassFilt', 'newRef', 'preprocStart', 'preprocEnd', 'taskDate', 'channLocFile', 'origDir', 'destDir', 'file'};
        
        subject      = folder2preproc;
        task         = bdfInfo(3);
        taskOrder    = bdfIx(1);
        taskDurOrig  = duration.pre/60;
        taskDurFinal = EEG.xmax/60;
        % oldSamRate   = oldSamRate;
        newSamRate   = EEG.srate;
        lwpassFilt   = lowpassFilter;
        hghpassFilt  = highpassFilter;
        newRef       = rerefChanns;
        preprocStart = t.start;
        preprocEnd   = datetime('now');
        taskDate     = datetime(bdf2preproc(fileCount).datenum, 'ConvertFrom', 'datenum');
        channLocFile = extractAfter(channel_location_dir, max(strfind(channel_location_dir, '/')));
        origDir      = bdfPaths(fileCount);
        destDir      = currSetfilePath;
        file         = bdf2preproc(fileCount).name;
        
        cxcell      = cell(1,numel(table_names)); % empty cell to be fill with record information
        
        cxcell(1,1) = {subject};
        cxcell(1,2) = task;
        cxcell(1,3) = {taskOrder};
        cxcell(1,4) = {taskDurOrig};
        cxcell(1,5) = {taskDurFinal};
        cxcell(1,6) = {oldSamRate};
        cxcell(1,7) = {newSamRate};
        cxcell(1,8) = {lwpassFilt};
        cxcell(1,9) = {hghpassFilt};
        cxcell(1,10) = {int2str(newRef)};
        cxcell(1,11) = {preprocStart};
        cxcell(1,12) = {preprocEnd};
        cxcell(1,13) = {taskDate};
        cxcell(1,14) = {channLocFile};
        cxcell(1,15) = {origDir};
        cxcell(1,16) = {destDir};
        cxcell(1,17) = {file};
        
        recordTable = cell2table(cxcell, 'VariableNames', table_names);
        
        if exist([mainDir 'automaticRecordTable.csv'], 'file') == 2
            oldRecordTable = readtable([mainDir 'automaticRecordTable.csv']);
            newRecordTable = [oldRecordTable; recordTable];
            writetable(newRecordTable , [mainDir 'automaticRecordTable.csv']);
            
        elseif exist([mainDir 'automaticRecordTable.csv'], 'file') == 0
            disp(['no previous record of preprocessing in ' mainDir '. new file created'])
            writetable(recordTable, [mainDir 'automaticRecordTable.csv'])
        end
        
        %%
        clear EEG; % erase saved dataset to free memmory
        
    end
end