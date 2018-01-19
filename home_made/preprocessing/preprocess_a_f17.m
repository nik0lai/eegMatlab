%% About

% This script takes a bdf file,
% preprocess it (add dataset info, resample, add channels locations, low and highpass filter)
% and save the new dataset.

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% PARAMETERS FOR PREPROCESSING (USER DEPENDENT)

% Subject to preprocess

SUBJECT_TO_PREPROCESS = [114]; % participant number (1xx = control, 3xx = alzheimer, 4xx = parkinson). Can take more than one.

% Parameters for preprocessing
    
    % filtering
    new_samplerate = 256; % new sample rate
    lowpass_filter = 0.5; % lowpass filter
    highpass_filter = 30; % highpass filter
    
     % re-reference  
    ref_chann = [129 130]; % channels to use as reference (mastoids)

%% 0.2 Paths to files and folders

my_dir = '/home/niki/'; % set computer directory
main_eeg_dir = 'Documents/EEGeses/fdcyt_agustin/'; % folder with bdf and set files
bdf_char = 'bdf/';
set_char = 'set/';

bdf_dir = 'Documents/EEGeses/fdcyt_agustin/bdf/'; % bdf folder directory
set_dir = 'Documents/EEGeses/fdcyt_agustin/set/'; % set files folder (output)

channel_location_dir = 'Documents/MATLAB/Toolboxeis/chanlocs/BioSemi136_10_20a.sfp'; % channels locations files directory

%% 0.2.1 BDF folders, names, and numbers

bdf_folders = dir([my_dir main_eeg_dir bdf_char 'CH_F17*']); % get folder names of each participant

bdf_folders_names = char(bdf_folders.name); % folder names as character

bdf_folders_names_num = str2num(bdf_folders_names(:, end-2:end)); %#ok<ST2NM> % keep numbers of participants (as numbers)

participant_to_preprocess_index = zeros(1, size(SUBJECT_TO_PREPROCESS, 2)); % vector with spaces to fill with participants to preprocess number


%% 0.2.2 This loop looks for the position of the participants to preprocess in the bdf folder

for i = 1:size(SUBJECT_TO_PREPROCESS, 2)
    position                         = find(bdf_folders_names_num == SUBJECT_TO_PREPROCESS(i)); % look for the position of participants to preprocess
    participant_to_preprocess_index(i) = position; % store position
end

fprintf('\n\n**********\nparticipants to preprocess. READY\n**********\n\n');

%% 1 Big loop that moves along participants set to be preprocessed

fprintf('\n\n**********\nBegin EVIL loop between participants\n**********\n\n');

files_preprocessed = []; % vector filled with preprocessed files names

for z = 1:size(participant_to_preprocess_index, 2);
    % z=1
    
    %% Get name of participant to preprocess
        
    subject_to_preprocess = bdf_folders(participant_to_preprocess_index(z)).name; % PARTICIPANT TO PREPROCESS
   
    bdf_files = dir([my_dir main_eeg_dir bdf_char subject_to_preprocess '/*.bdf']); % get bdf file names of current participant
    
    %% Reorder files according to paradigm order. This will be used to assign task order in the dataset information
    
    bdf_files_date = [bdf_files.datenum]; % get files date
    
    [~, ix] = sort(bdf_files_date); % order files by date and store that order on "ix"
    
    bdf_file_names = {bdf_files.name}; % convert names to characters
        
    %% 1. Evil for loop
    
    fprintf('\n\n**********\nBegin EVIL loop within participant\n**********\n\n');
    
    for i = 1:size(bdf_file_names, 2)
        
        %% 1.1 Read .bdf files, assign dataset name, subject code, condition task, subject group
        % i = 1
        
        %% path to file, file name and file info
        current_file_path = [my_dir main_eeg_dir bdf_char subject_to_preprocess '/' char(bdf_file_names(i))]; % path to current file (LOOP CONTEXTUAL!!)
                
        bdf_file_name_extensionless = char(strtok(bdf_file_names(i), '.bdf')); % file name without extension (LOOP CONTEXTUAL!!)
        
        current_file_subject_info = strsplit(bdf_file_name_extensionless, '_'); % current subject info (country, fondecyt_ano, condition, id_number, task(ifany))
        
        display(bdf_file_name_extensionless);
        
        %% READ FILE
        EEG = pop_biosig(char(current_file_path)); % read bdf file
                
        fprintf('\n\n**********\nBdf loaded\n**********\n\n');
        
        %% Channel locations
        
        EEG = pop_editset(EEG, 'chanlocs', [my_dir channel_location_dir]); % add channels locations
                
        %% 1.2 Re-reference to mastoids
        
        %% 1.2.1 Get info about channels
            
        number_channels = EEG.nbchan; % get EEG total number of channels
        external_channels = 129:number_channels; % identify external channels
        internal_channels = setdiff(1:number_channels, external_channels); % identify internal (channels in the head) channels
               
        %% 1.2.2 info to re-reference
        
        ref_exclude_chann = setdiff(external_channels, ref_chann); % channels to exclude (all non-head channels except mastoids)
        
        %% 1.2.3 re-reference (keeping references)
        
        EEG = pop_reref(EEG, ref_chann,'exclude', ref_exclude_chann ,'keepref','on');
                
        %% 1.3 Resample
        
        EEG = pop_resample(EEG, new_samplerate); % resample
                
        fprintf('\n\n**********\ndata set downsampled and channels locations assigned\n**********\n\n');
        
        %% Cut edges
        
        if size(EEG.event, 2) == 0
                        
            fprintf('\n\n**********\nCHE, no hay marcas!\n**********\n\n')
            
        elseif not(strcmp(current_file_subject_info(5),'RESTING'))
            
            % time from edges to first and last events (seconds)
            margin = 3;
            
            % first event
            first_event_pos_time = EEG.event(1).latency/EEG.srate-margin;
            % last event
            last_event_pos_time = EEG.event(end).latency/EEG.srate+margin;
            % cut edges
            EEG = pop_select( EEG,'time',[first_event_pos_time last_event_pos_time]);
            
            fprintf('\n\n**********\nNO REST FOR THE WICKED: non-resting file\n**********\n\n')
            
        elseif strcmp(current_file_subject_info(5),'RESTING file')
            fprintf('\n\n**********\nRESTING, KEEP RESTING\n**********\n\n')
            
        end
        
        %% 1.3 Create EKG channel
                
        EEG = pop_eegchanoperator(EEG, {'ch137 = ch131 - ch132 label EKG'} , 'ErrorMsg', 'popup', 'Warning', 'on'); % Create EKG channel with the substraction of 131-132
        
        %% 1.4 Filter: lowpass, highpass
        
        EEG = pop_eegfiltnew(EEG, [], lowpass_filter,1690,1,[],1); % lowpass filter (what are the other parameters?)
        EEG = pop_eegfiltnew(EEG, [], highpass_filter,114,0,[],1); % highpass filter (what are the other parameters?)
                
        fprintf('\n\n**********\ndataset filtered\n**********\n\n')
        
        %% 2. Save dataset ready for ICA
        
        % assign data
        EEG = pop_editset(EEG, 'setname', bdf_file_name_extensionless); % asign dataset name using bdf file name
        EEG = pop_editset(EEG, 'subject', subject_to_preprocess); % subject code
        EEG = pop_editset(EEG, 'session', find(ix == i)); % task order % FIX THIS.
        EEG = pop_editset(EEG, 'condition', current_file_subject_info(5)); % task condition (intero, social_learning, negation, resting)
        EEG = pop_editset(EEG, 'group', current_file_subject_info(3)); % subject group (control, alzhaimer, dft, parkinson?)
        
              
        current_setfile_path = [my_dir set_dir subject_to_preprocess '/']; % path to folder where set files are to be saved
        
        % Lopp to create folder
        if exist(current_setfile_path, 'dir') == 7;
            fprintf('\n\n**********\nfolder already EXISTS!\n**********\n\n');
        elseif exist(current_setfile_path, 'dir') == 0;
            mkdir(current_setfile_path);
            fprintf('\n\n**********\nfolder CREATED!\n**********\n\n');
        end;
        
        % save dataset
        pop_saveset( EEG, 'filename', [bdf_file_name_extensionless '.set'],'filepath', current_setfile_path); % save current dataset
                
        fprintf('\n\n**********\ndataset saved\n**********\n\n');
        
        clear EEG; % erase saved dataset to free memmory
        
        display('YEAH!')
        
    end

    % store 
    files_preprocessed = [files_preprocessed {bdf_files.name}];
     
            
end


%% PRINT PROCESSED FILE NAMES

fprintf('\n\nPREPROCESSED FILES\n**********\n**********\n')
display(char(files_preprocessed))
fprintf('**********\n**********\n\n')




