%% Preprocess UG-HEP
%% About

% This script takes a bdf file, preprocess it (add dataset info, resample, add channels locations, low and highpass filter) and save the new dataset.
% bdf files are readed within the condition folder (con, alz, ...)

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% Condition to preprocess

condition_to_preprocess = 'pruebas'; % condition to presprocess

%% 0.2 Directory and file names

my_dir = '/home/niki/'; % set computer directory
bdf_dir = strcat('Documents/EEGeses/UG_agustin/eeg_raw_INECO_folder/UG/bdf/',condition_to_preprocess, '/'); % bdf folder directory
set_dir = strcat('Documents/EEGeses/UG_agustin/eeg_raw_INECO_folder/UG/set/',condition_to_preprocess, '/'); % set files folder (output)

channel_location_dir = 'Documents/MATLAB/Toolboxeis/chanlocs/BioSemi136_10_20a.sfp'; % channels locations files directory

    %% 0.2.1

    bdf_files = dir(strcat(my_dir,bdf_dir,'*.bdf')); % get bdf folder names (each folder is a participant)
    
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

    % i = 3
    
    current_file_path = char(strcat(my_dir, bdf_dir, bdf_file_names(i))); % path to current file (LOOP CONTEXTUAL!!)
    
    current_bdf = char(bdf_file_names(i));
            
    bdf_file_name_extensionless = strtok(current_bdf, '.'); % file name without extension (LOOP CONTEXTUAL!!)

    EEG = pop_biosig(char(current_file_path)); % read bdf file
      
    display('Bdf loaded, and dataset info assigned')
    
        %% 1.2 Resample and add channels
        EEG = pop_resample(EEG, new_samplerate); % resample
                        
        display('data set downsampled and channels locations assigned')
        
        %% 1.3 Create EKG channel 
        
        %EEG = pop_eegchanoperator( EEG, {  'ch137 = ch131 - ch132 label EKG'} , 'ErrorMsg', 'popup', 'Warning', 'on' ); % Create EKG channel with the substraction of 131-132
       
        %% 1.4 Filter: lowpass, highpass
                 
        EEG = pop_eegfiltnew(EEG, [],lowpass_filter,1690,1,[],1); % lowpass filter (what are the other parameters?)
        EEG = pop_eegfiltnew(EEG, [],highpass_filter,114,0,[],1); % highpass filter (what are the other parameters?)
        
        display('dataset filtered')

%% 2. Save dataset ready for ICA

    %% assign data
    EEG = pop_editset(EEG, 'setname', bdf_file_name_extensionless); % asign dataset name using bdf file name
    %EEG = pop_editset(EEG, 'subject', char(subject_to_preprocess)); % subject code
    %EEG = pop_editset(EEG, 'session', [ix(i)]); % task order
    %EEG = pop_editset(EEG, 'condition', char(current_file_subject_info(5))); % task condition (intero, social_learning, negation, resting)
    %EEG = pop_editset(EEG, 'group', char(current_file_subject_info(3))); % subject group (control, alzhaimer, dft, parkinson?)

    current_setfile_path = strcat(my_dir, set_dir); % path to folder where set files are to be saved

    %% folder for set files 
    
    if exist(current_setfile_path, 'dir') == 7;
        display('folder already EXISTS!');
    elseif exist(current_setfile_path, 'dir') == 0;
        mkdir(current_setfile_path);
        display('folder CREATED!');
    end;
    
    %% Sace data set

pop_saveset( EEG, 'filename', char(strcat(bdf_file_name_extensionless, '.set')),'filepath', char(current_setfile_path)); % save current dataset

display('dataset saved')

clear EEG; % erase saved dataset to free memmory

display('YEAH!')

end



