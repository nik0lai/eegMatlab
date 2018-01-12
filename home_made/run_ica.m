%% About

% This script run ICA on one dataset
% TODO: CHECK IF BAD CHANS CORRESPOND TO FILE IN CURRENT LOOP

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Directory and file names

my_dir = '/home/niki/'; % set computer directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)

%% 0.0 Read file with file IDs and bad channels

preprocess_track= readtable('/home/niki/Documents/EEGeses/Agustiniano/preprocessing_track.xlsx');
% preprocess_track = readtable('/home/niki/Documents/EEGeses/Agustiniano/preprocessing_track.csv', 'Delimiter', ';', 'ReadRowNames', 0); % read csv (separate by ;) with file ID and bad channels

preprocess_track = preprocess_track(:,{'ID','ICA','all_badchan'}); % keep only file ID, ICA and bad channels columns

index_files_to_ICA = find(cell2mat(table2cell(preprocess_track(:,'ICA')))==1); % find files set to ICA

preprocess_track = preprocess_track(index_files_to_ICA, :); % filter preprocess track to keep only rows of files to ICA


%% Which rows should be ICAed (for now, by row index)

% cell2mat(preprocess_track)
% 
% preprocess_track(:,'ICA')
% 
% 
% %%
% fil_nam = char(preprocess_track.Properties.RowNames);
% 
% file_by_sub_no = str2num(fil_nam(:, 11:13));
% 
% files_to_ICA_index = []; % empty something
% 
% %% 0.2.2 This loop looks for the position of the participants to preprocess in the bdf folder
% 
% for i = 1:size(SUBJECT_TO_ICA,2)
%     position      = find(file_by_sub_no==SUBJECT_TO_ICA(i));
%     files_to_ICA_index  = [files_to_ICA_index position];
% end



%% EVIL LOOP

display('Begin loop')

% preprocess_track = preprocess_track(files_to_ICA_index,:);

for i = 1:size(preprocess_track, 1)
    % i=1
    
    %% 0.1 Who is going down? (within loop)
   
    SUBJECT_TO_ICA = char(table2cell(preprocess_track(i,'ID'))); % get file ID of current loop
    % SUBJECT_TO_ICA = char(preprocess_track(i,:).Properties.RowNames); % get file ID of current loop
    % SUBJECT_TO_ICA = char(participants(i)); % LOOP sensitive: dataset to ICA
    
    subject_info = strsplit(SUBJECT_TO_ICA, '_'); % Extract information about participant
    
    subject_code = strcat(subject_info(1), '_', subject_info(2), '_', subject_info(3), '_', subject_info(4)); % Construct subject code
    
    
    %% 0.1.1
    
    set_file_name = char(strcat(SUBJECT_TO_ICA, '.set'));
    
    path_to_set_file = char(strcat(my_dir,set_dir,subject_code, '/'));
    
    %% BAD CHANNELS
    
    bad_channels = table2array(preprocess_track(i,'all_badchan')); % get bad channels of current file
    %bad_channels = table2array(preprocess_track({SUBJECT_TO_ICA},{'all_badchan'})); % get bad channels of current file
       
    bad_channels = str2num(char(bad_channels)); % conver bad channels to numbers (they come as chars)
    % bad_channels = cell2mat(participants(i,2)); % get bad channels
    
    %% Read files to ICA
    
    EEG = pop_loadset('filename', set_file_name, 'filepath', path_to_set_file); % load dataset
    
    
    %% Get info about channels
    
    number_channels = EEG.nbchan; % get EEG total number of channels
    external_channels = 129:number_channels; % identify external channels
    internal_channels = setdiff(1:number_channels, external_channels); % identify internal (or channels in the head) channels
    
    %% ICA
    
    channels_to_ica = setdiff(internal_channels, bad_channels); % channels to ICA
    
    EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', channels_to_ica); % run ICA
    
    EEG = pop_editset(EEG, 'setname', strcat(SUBJECT_TO_ICA, '_ICA')); % asign dataset name using bdf file name
    
    %% save ICAed dataset
    
    path_to_OK_folder = strcat(path_to_set_file, 'OK/'); % datasets with ICA folder
    
    %% folder for set files
    
    %current_setfile_path = strcat(my_dir, set_dir, subject_to_preprocess, '/'); % path to folder where set files are to be saved
    
    % Lopp to create folder
    if exist(path_to_OK_folder, 'dir') == 7;
        display('folder already EXISTS!');
    elseif exist(path_to_OK_folder, 'dir') == 0;
        mkdir(path_to_OK_folder);
        display('folder CREATED!');
    end;
    
    
    pop_saveset( EEG, 'filename', set_file_name,'filepath', path_to_OK_folder); % save current dataset
    
end