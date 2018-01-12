%% About

% This script run reject components and

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Directory and file names

my_dir = '/home/niki/'; % set computer directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)

%% 0.2 Read file with file IDs and bad channels

preprocess_track = readtable('/home/niki/Documents/EEGeses/Agustiniano/preprocessing_track.xlsx'); % read csv (separate by ;) with file ID and bad channels
% preprocess_track = readtable('/home/niki/Documents/EEGeses/Agustiniano/preprocessing_track.csv', 'Delimiter', ';', 'ReadRowNames', 0); % read csv (separate by ;) with file ID and bad channels

preprocess_track = preprocess_track(:,{'ID','reject_interpol', 'all_badchan', 'all_bad_comp'}); % keep only file ID, ICA and bad channels columns

index_files_to_reject_interpol = find(cell2mat(table2cell(preprocess_track(:,'reject_interpol')))==1); % find files set to ICA

preprocess_track = preprocess_track(index_files_to_reject_interpol, :); % filter preprocess track to keep only rows of files to ICA

%% EVIL LOOP

display('Begin loop')

for i = 1:size(preprocess_track, 1)
    % i =1
    
    %% 0.1 Who is going down? (within loop)
    
    file_to_reject_inter = char(table2cell(preprocess_track(i,'ID'))); % get file ID of current loop
    
    subject_info = strsplit(file_to_reject_inter, '_'); % Extract information about participant
    
    subject_code = strcat(subject_info(1), '_', subject_info(2), '_', subject_info(3), '_', subject_info(4)); % Construct subject code
    
    %% 0.1.1 Set file name and file path
    
    set_file_name = char(strcat(file_to_reject_inter, '.set'));
    
    path_to_set_file = char(strcat(my_dir,set_dir,subject_code, '/OK/'));
    
    %% 0.2 ALL BAD THINGS BELONG TOGHETER
    
    %% 0.2.1 Bad channels
    
    bad_channels = table2array(preprocess_track(i,'all_badchan')); % get bad channels of current file
    
    bad_channels = str2num(char(bad_channels)); % conver bad channels to numbers (they come as chars)
    
    %% 0.2.2 Bad componentes
    
    bad_comps = table2array(preprocess_track(i,'all_bad_comp')); % get bad channels of current file
    
    bad_comps = str2num(char(bad_comps)); % conver bad channels to numbers (they come as chars)
    
    
    %% 1 Read files to reject and interpolate
    
    EEG = pop_loadset('filename', set_file_name, 'filepath', path_to_set_file); % load dataset
    
    
    %% 1.1 Get info about channels
    
    number_channels = EEG.nbchan; % get EEG total number of channels
    
    external_channels = 129:number_channels; % identify external channels
    
    internal_channels = setdiff(1:number_channels, external_channels); % identify internal (or channels in the head) channels
    
    %% 2 REJECT BAD COMPONENTS
    
    EEG = pop_subcomp( EEG, bad_comps, 0);
    
    %% 3 INTERPOLATE BAD CHANNELS
    
    EEG = pop_interp(EEG, bad_channels, 'spherical');
    
    %% 4 Save final (I hope) dataset
    
    %% 4.1 path to FINAL folder
    
    path_to_FINAL_folder = char(strcat(my_dir,set_dir,subject_code, '/FINAL/')); % datasets with ICA folder
    
    %% 4.2 folder for set files
    
    % Lopp to create folder
    if exist(path_to_FINAL_folder, 'dir') == 7;
        display('folder already EXISTS!');
    elseif exist(path_to_FINAL_folder, 'dir') == 0;
        mkdir(path_to_FINAL_folder);
        display('folder CREATED!');
    end;
    
    %% 4.3 ACTUALLY SAVE THE DATASET
    
    pop_saveset(EEG, 'filename', set_file_name,'filepath', path_to_FINAL_folder); % save current dataset
    
end
