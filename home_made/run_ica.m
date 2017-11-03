%% About

% This script run ICA on one dataset

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Directory and file names

my_dir = '/home/niki/'; % set computer directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)


%% 0.0.0 Participants   bad_channels

participants = {
'CH_F17_CN_101_NEGATION'			[29,30,31,32,16]
'CH_F17_CN_101_INTERO'				[29,30,31,32,16]
'CH_F17_CN_101_RESTING'				[29,30,31,32,16]
'CH_F17_CN_107_SOCIAL'				[29,30,31,32,2,3,18,33,34,78,104]
'CH_F17_CN_107_NEGATION'			[29,30,31,32,2,3,18,20,100,102,114]
'CH_F17_CN_107_INTERO'				[29,30,31,32,2,3,18,20,100,102,114]
'CH_F17_CN_107_RESTING'				[29,30,31,32,2,3,18,100]
'CH_F17_AL_302_INTERO'				[29,30,31,32,18,24,111]
'CH_F17_AL_302_NEGATION'			[29,30,31,32,18,58,59]
'CH_F17_AL_302_RESTING'				[29,30,31,32,28,32,75]
'CH_F17_AL_302_SOCIAL'				[29,30,31,32,18]
};

%% EVIL LOOP

display('Begin loop')

for i = 1:size(participants, 1)


%% 0.1 Who is going down? (within loop)

SUBJECT_TO_ICA = char(participants(i)); % LOOP sensitive: dataset to ICA

subject_info = strsplit(SUBJECT_TO_ICA, '_'); % Extract information about participant

subject_code = strcat(subject_info(1), '_', subject_info(2), '_', subject_info(3), '_', subject_info(4)); % Construct subject code


        %% 0.1.1
            
        set_file_name = char(strcat(SUBJECT_TO_ICA, '.set'));
        
        path_to_set_file = char(strcat(my_dir,set_dir,subject_code, '/'));
        
%% BAD CHANNELS

bad_channels = cell2mat(participants(1,2)); % get bad channels

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
           
    pop_saveset( EEG, 'filename', set_file_name,'filepath', path_to_OK_folder); % save current dataset
        
end