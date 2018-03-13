% This script preprocess EEG data:
%     Import bdf files
%     Re-reference to mastoids
%     Re-sample
%     Import channels location
%     Filter data


%% Prepare enviroment

clear;      % clear enviroment
eeglab;     % open eeglab to lighten paths to the eeglab ways
close all;  % close everything
clc;        % clear command line

%% Parameters (user-defined)

subPreproc = 404;

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
    
    
    
%% Get participants bdf folder

bdfFolders      = dir([bdfDir 'CH_F17*']);
bdfFoldersNames = char(bdfFolders.name);
bdfFoldersNum   = str2num(bdfFoldersNames(:, end-2:end));

subPreprocIndex = zeros(1, size(subPreproc, 2));

for i = 1:size(subPreproc, 2)
    position            = find(bdfFoldersNum == subPreproc(i)); % look for the position of participants to preprocess
    subPreprocIndex(i)   = position; % store position
end

%% Get bdf files names and paths

folder2preproc = bdfFoldersNames(subPreprocIndex, :); % participant to preprocess folder
bdf2preproc    = dir([bdfDir folder2preproc '/*.bdf']);

%% bdf files info

%date
[~, bdfIx]     = sort([bdf2preproc.datenum]); % task-order

%cond, subject_number, taks
bdfName = strtok(bdf2preproc(1).name, '.bdf');
bdfInfo = strsplit(bdfName, '_');
bdfInfo = bdfInfo(1, 3:5) ;

%path
bdfPaths = strcat(bdfDir, folder2preproc, '/', {bdf2preproc.name});

%% Read file

EEG = pop_biosig(char(bdfPaths(1)));

% resample
EEG = pop_resample(EEG, newSampRate);

%% channels location

EEG = pop_editset(EEG, 'chanlocs', [my_dir channel_location_dir]); % add channels locations

%% re-reference

% How can I get the number of cap channels? 
channNumb = EEG.nbchan;                     % get EEG total number of channels
channExt  = 129:channNumb;                  % identify external channels
channInt  = setdiff(1:channNumb, channExt); % identify internal (channels in the head) channels
rerefExcl = setdiff(channExt, rerefChanns); % external channels to be exclude of rereferencing

EEG = pop_reref(EEG, [129 130], 'exclude', rerefExcl, 'keepref', 'on');

%% filter
EEG = pop_eegfiltnew(EEG, [], lowpassFilter,1690,1,[],1); % lowpass filter (what are the other parameters?)
EEG = pop_eegfiltnew(EEG, [], highpassFilter,114,0,[],1); % highpass filter (what are the other parameters?)

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

EEG = pop_eegchanoperator(EEG, {'ch137 = ch131 - ch132 label EKG'} , 'ErrorMsg', 'popup', 'Warning', 'on'); % Create EKG channel with the substraction of 131-132

%% assign data to set file
% dataset name
EEG = pop_editset(EEG, 'setname', strjoin(bdfInfo, '_')); % asign dataset name using bdf file name
% subject code
EEG = pop_editset(EEG, 'subject', subPreproc); % subject code
% session task-order
EEG = pop_editset(EEG, 'session', find(ix == i));
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
pop_saveset(EEG, 'filename', [bdfName '.set'],'filepath', currSetfilePath); % save current dataset

fprintf('\n\n**********\ndataset saved\n**********\n\n');

clear EEG; % erase saved dataset to free memmory

%% Create txt file with files preprosseced and info about the preprocessing.


























