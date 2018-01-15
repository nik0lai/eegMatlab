%% About

% This script takes a bdf file,
% preprocess it (add dataset info, resample, add channels locations, low and highpass filter)
% and save the new dataset.

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Who is going down?

SUBJECT_TO_PREPROCESS = [114]; % in the bdf folder, number of the folder to preprocess (when order by name, ascendent)

%% 0.2 Paths to files and folders

my_dir = '/home/niki/'; % set computer directory
bdf_dir = 'Documents/EEGeses/Agustiniano/bdf/'; % bdf folder directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)
channel_location_dir = 'Documents/MATLAB/Toolboxeis/chanlocs/BioSemi136_10_20a.sfp'; % channels locations files directory

%% 0.2.1 BDF folders, names, and numbers

bdf_folders = dir(strcat(my_dir,bdf_dir,'CH_F17*')); % get bdf folder names (each folder is a participant)
bdf_folders_names = char(bdf_folders.name); % folder names as character
bdf_folders_names_num = str2num(bdf_folders_names(:, end-2:end)); % keep only numbers of participants
participant_to_preprocess_index = []; % empty something


%% 0.2.2 This loop looks for the position of the participants to preprocess in the bdf folder

for i = 1:size(SUBJECT_TO_PREPROCESS,2)
    position                         = find(bdf_folders_names_num==SUBJECT_TO_PREPROCESS(i));
    participant_to_preprocess_index  = [participant_to_preprocess_index position];
end

display('participants to preprocess. READY');
%% 1 Big loop that moves along participants set to be preprocessed

display('Begin EVIL loop between participants')

for z = 1:size(participant_to_preprocess_index, 2);
    %z=1
    
    %% Get name of participant to preprocess
    subject_to_preprocess = char(bdf_folders(participant_to_preprocess_index(z)).name); % PARTICIPANT TO PREPROCESS
    
    bdf_files = dir(strcat(my_dir,bdf_dir,subject_to_preprocess, '/*.bdf')); % get bdf file names
    
    %% Reorder files according to paradigm order. This will be used to assign task order in the dataset information
    
    bdf_files_date = [bdf_files.datenum]; % get files date
    
    [~, ix] = sort(bdf_files_date); % order files by date and store that order on "ix"
    
    bdf_file_names = {bdf_files.name}; % convert names to characters
    
    display('path to current participant. READY');
    
    %% 0.3 Parameters for preprocessing
    
    new_samplerate = 256; % new sample rate
    lowpass_filter = 0.5; % lowpass filter
    highpass_filter = 30; % highpass filter
    
    display('parameters for preprocessing. READY')
    
    %% 1. Evil for loop
    
    display('Begin EVIL loop within participant')
    
    for i = 1:size(bdf_file_names, 2)
        
        %% 1.1 Read .bdf files, assign dataset name, subject code, condition task, subject group
        % i = 1
        
        %% path to file, file name and file info
        current_file_path = char(strcat(my_dir, bdf_dir, subject_to_preprocess, '/', bdf_file_names(i))); % path to current file (LOOP CONTEXTUAL!!)
        
        bdf_file_name_extensionless = char(strtok(bdf_file_names(i), '.bdf')); % file name without extension (LOOP CONTEXTUAL!!)
        
        current_file_subject_info = strsplit(bdf_file_name_extensionless, '_'); % current subject info (country, fondecyt_ano, condition, id_number, task(ifany))
        
        display(bdf_file_name_extensionless);
        
        %% READ FILE
        EEG = pop_biosig(char(current_file_path)); % read bdf file
        
        display('Bdf loaded')
        
        %% Channel locations
        
        EEG = pop_editset(EEG, 'chanlocs', char(strcat(my_dir, channel_location_dir))); % add channels locations
                
        %% 1.2 Re-reference to mastoids
        
        %% 1.2.1 Get info about channels
            
        number_channels = EEG.nbchan; % get EEG total number of channels
        external_channels = 129:number_channels; % identify external channels
        internal_channels = setdiff(1:number_channels, external_channels); % identify internal (or channels in the head) channels
               
        %% 1.2.2 info to re-reference
        
        ref_chann = [129 130]; % channels to use as reference (mastoids)
        ref_exclude_chann = setdiff(external_channels, ref_chann); % channels to exclude (all non-head channels except mastoids)
        
        %% 1.2.3 re-reference        
        
        EEG = pop_reref( EEG, ref_chann,'exclude', ref_exclude_chann ,'keepref','on');
                
        %% 1.3 Resample
        
        EEG = pop_resample(EEG, new_samplerate); % resample
              
        display('data set downsampled and channels locations assigned')
        
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
            
            fprintf('\n\n**********\nNO REST FOR THE WICKED\n**********\n\n')
            
        elseif strcmp(current_file_subject_info(5),'RESTING')
            fprintf('\n\n**********\nRESTING, KEEP RESTING\n**********\n\n')
            
        end
        
        %% 1.3 Create EKG channel
                
        EEG = pop_eegchanoperator( EEG, {  'ch137 = ch131 - ch132 label EKG'} , 'ErrorMsg', 'popup', 'Warning', 'on' ); % Create EKG channel with the substraction of 131-132
        
        %% 1.4 Filter: lowpass, highpass
        
        EEG = pop_eegfiltnew(EEG, [],lowpass_filter,1690,1,[],1); % lowpass filter (what are the other parameters?)
        EEG = pop_eegfiltnew(EEG, [],highpass_filter,114,0,[],1); % highpass filter (what are the other parameters?)
        
        display('dataset filtered')
        
        %% 2. Save dataset ready for ICA
        
        
        %% assign data
        EEG = pop_editset(EEG, 'setname', bdf_file_name_extensionless); % asign dataset name using bdf file name
        EEG = pop_editset(EEG, 'subject', char(subject_to_preprocess)); % subject code
        EEG = pop_editset(EEG, 'session', [ix(i)]); % task order % FIX THIS.
        EEG = pop_editset(EEG, 'condition', char(current_file_subject_info(5))); % task condition (intero, social_learning, negation, resting)
        EEG = pop_editset(EEG, 'group', char(current_file_subject_info(3))); % subject group (control, alzhaimer, dft, parkinson?)
        
        %% folder for set files
        
        current_setfile_path = strcat(my_dir, set_dir, subject_to_preprocess, '/'); % path to folder where set files are to be saved
        
        % Lopp to create folder
        if exist(current_setfile_path, 'dir') == 7;
            display('folder already EXISTS!');
        elseif exist(current_setfile_path, 'dir') == 0;
            mkdir(current_setfile_path);
            display('folder CREATED!');
        end;
        
        %%
        pop_saveset( EEG, 'filename', char(strcat(bdf_file_name_extensionless, '.set')),'filepath', char(current_setfile_path)); % save current dataset
        
        display('dataset saved')
        
        clear EEG; % erase saved dataset to free memmory
        
        display('YEAH!')
        
    end
    
end


