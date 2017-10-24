%% About

% This script takes a bdf file, preprocess it (add dataset info, resample, add channels locations, low and highpass filter) and save the new dataset.

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Who is going down?

SUBJECT_TO_PREPROCESS = 2; % in the bdf folder, number of the folder to preprocess (when order by name, ascendent)

%% 0.2 Directory and file names

my_dir = '/home/niki/'; % set computer directory
bdf_dir = 'Documents/EEGeses/Agustiniano/bdf/'; % bdf folder directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)

channel_location_dir = 'Documents/MATLAB/Toolboxeis/chanlocs/BioSemi136_10_20a.sfp'; % channels locations files directory

    %% 0.2.1

    bdf_folders = dir(strcat(my_dir,bdf_dir,'CH_F17*')); % get bdf folder names (each folder is a participant)

    subject_to_preprocess = char(bdf_folders(SUBJECT_TO_PREPROCESS).name); % Participant to preprocess

    bdf_files = dir(strcat(my_dir,bdf_dir,subject_to_preprocess, '/*.bdf')); % get bdf file names

    
    bdf_files_date = [bdf_files.datenum]; % get files date
    
    [~, ix] = sort(bdf_files_date); % order files by date and store that order on "ix"
    
    bdf_file_names = {bdf_files.name}; % convert names to characters

    display('Directory and file names set');
    
%% 0.3 Parameters for preprocessing

new_samplerate = 256; % new sample rate
lowpass_filter = 0.5; % lowpass filter
highpass_filter = 30; % highpass filter

display('Parameters for preprocessing set')

%% 1. Evil for loop

display('Begin loop')

for i = 1:size(bdf_file_names, 2)

    %% 1.1 Read .bdf files, assign dataset name, subject code, condition task, subject group

    % i = 1
    
    current_file_path = char(strcat(my_dir, bdf_dir, subject_to_preprocess, '/', bdf_file_names(i))); % path to current file (LOOP CONTEXTUAL!!)

    bdf_file_name_extensionless = char(strtok(bdf_file_names(i), '.bdf')); % file name without extension (LOOP CONTEXTUAL!!)

    current_file_subject_info = strsplit(bdf_file_name_extensionless, '_'); % current subject info (country, fondecyt_ano, condition, id_number, task(ifany))

    % current_subject_code = strcat(current_file_subject_info(1), '_',  current_file_subject_info(2), '_', current_file_subject_info(3), '_', current_file_subject_info(4)); % subject code without task


    EEG = pop_biosig(char(current_file_path)); % read bdf file
      
    display('Bdf loaded, and dataset info assigned')
    
        %% 1.2 Resample and add channels
        EEG = pop_resample(EEG, new_samplerate); % resample
                       
        EEG = pop_editset(EEG, 'chanlocs', char(strcat(my_dir, channel_location_dir))); % add channels locations
        
        display('data set downsampled and channels locations assigned')
        
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
    EEG = pop_editset(EEG, 'session', [ix(i)]); % task order
    EEG = pop_editset(EEG, 'condition', char(current_file_subject_info(5))); % task condition (intero, social_learning, negation, resting)
    EEG = pop_editset(EEG, 'group', char(current_file_subject_info(3))); % subject group (control, alzhaimer, dft, parkinson?)


current_setfile_path = strcat(my_dir, set_dir, subject_to_preprocess, '/'); % path to folder where set files are to be saved

pop_saveset( EEG, 'filename', char(strcat(bdf_file_name_extensionless, '.set')),'filepath', char(current_setfile_path)); % save current dataset

display('dataset saved')

clear EEG; % erase saved dataset to free memmory

display('YEAH!')

end




