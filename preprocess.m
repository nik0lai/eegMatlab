%% About

% This script takes a bdf file, preprocess it (add dataset info, resample, add channels locations, low and highpass filter) and save the new dataset.



%% 0.1 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.2 Directory and file names

my_dir = '/home/niki/'; % set computer directory
bdf_dir = 'Documents/EEGeses/Agustiniano/bdf/TESTING/'; % bdf folder directory
set_dir = 'Documents/EEGeses/Agustiniano/set/';

channel_location_dir = 'Documents/MATLAB/Toolboxeis/chanlocs/BioSemi136_10_20a.sfp'; % channels locations files directory

bdf_files = dir(strcat(my_dir,bdf_dir,'*.bdf')); % get bdf file names
bdf_file_names = {bdf_files.name}; % convert names to characters

strcat('Directory and file names set')
%% 0.3 Parameters for preprocessing

new_samplerate = 256; % new sample rate
lowpass_filter = 0.5; % lowpass filter
highpass_filter = 30; % highpass filter

strcat('Parameters for preprocessing set')
%% 1. Evil for loop

strcat('Begin loop')
for i = 1:length(bdf_file_names)

    %% 1.1 Read .bdf files, assign dataset name, subject code, condition task, subject group

    %char(strcat(my_dir, bdf_dir, bdf_file_names(1)))
    %char(strtok(bdf_file_names(1), '.bdf'))

    current_file_path = char(strcat(my_dir, bdf_dir, bdf_file_names(i))) % path to current file (LOOP CONTEXTUAL!!)

    bdf_file_name_extensionless = char(strtok(bdf_file_names(i), '.bdf')) % file name without extension (LOOP CONTEXTUAL!!)

    current_file_subject_info = strsplit(bdf_file_name_extensionless, '_') % current subject info (country, fondecyt_ano, condition, id_number, task(ifany))

    current_subject_code = strcat(current_file_subject_info(1), '_',  current_file_subject_info(2), '_', current_file_subject_info(3), '_', current_file_subject_info(4)) % subject code without task


    EEG = pop_biosig(current_file_path); % read bdf file
    
    EEG = pop_editset(EEG, 'setname', bdf_file_name_extensionless); % asign dataset name using bdf file name
    EEG = pop_editset(EEG, 'subject', char(current_subject_code));
    EEG = pop_editset(EEG, 'condition', char(current_file_subject_info(5))); % task condition (intero, social_learning, negation, resting)
    EEG = pop_editset(EEG, 'group', char(current_file_subject_info(3))); % subject group (control, alzhaimer, dft, parkinson?)
    strcat('Bdf loaded, and dataset info assigned')
        %% 1.2 Resample and add channels
        EEG = pop_resample(EEG, new_samplerate); % resample
        
        %char(strcat(my_dir, channel_location_dir))
        
        EEG = pop_editset(EEG, 'chanlocs', char(strcat(my_dir, channel_location_dir))); % add channels locations
        strcat('data set downsampled and channels locations assigned')
        %% 1.3 Filter: lowpass, highpass
        
        EEG = pop_eegfiltnew(EEG, [],lowpass_filter,6760,1,[],1); % lowpass filter (what are the other parameters?)
        EEG = pop_eegfiltnew(EEG, [],highpass_filter,452,0,[],1); % highpass filter (what are the other parameters?)
        strcat('dataset filtered')

%% 2. Save dataset ready for ICA

%char(strcat(bdf_file_name_extensionless, '.set'))

current_setfile_path = strcat(my_dir, set_dir, current_subject_code, '/'); 

EEG = pop_saveset( EEG, 'filename', char(strcat(bdf_file_name_extensionless, '.set')),'filepath', char(current_setfile_path)); % save current dataset
strcat('dataset saved')

clear EEG; % erase saved dataset to free memmory

strcat('YEAH!')
end




