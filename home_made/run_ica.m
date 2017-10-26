%% About

% This script run ICA on one dataset

%% 0.0 Prepare enviroment

eeglab; % open eeglab to lighten paths to the eeglab ways
close all; % close everything
clc; % clear command line
clear all; % clear enviroment

%% 0.1 Who is going down?

SUBJECT_TO_ICA = 3; % in the bdf folder, number of the folder to preprocess (when order by name, ascendent)

%% 0.2 Directory and file names

my_dir = '/home/niki/'; % set computer directory
set_dir = 'Documents/EEGeses/Agustiniano/set/'; % set files folder (output)

        %% 0.2.1

        set_folders = dir(strcat(my_dir,set_dir,'CH_F17*')); % get set folder names (each folder is a participant)
        
        subject_to_ica = char(set_folders(SUBJECT_TO_ICA).name); % get folder name of subject to ica
        
        set_files = dir(strcat(my_dir,set_dir,subject_to_ica, '/*.set')); % get bdf file names

%% BAD CHANNELS
% bad_channels = [29,30,31,32,16]; % define channels to exclude from ICA


%%
Participants = {
'CH_F17_CN_101_NEGATION'				[29,30,31,32,16]
'CH_F17_CN_101_INTERO'				[29,30,31,32,16]
'CH_F17_CN_101_RESTING'				[29,30,31,32,16]
'CH_F17_CN_107_SOCIAL'				[29,30,31,32,2,3,18,33,34,78,104]
'CH_F17_CN_107_NEGATION'				[29,30,31,32,2,3,18,20,100,102,114]
'CH_F17_CN_107_INTERO'				[29,30,31,32,2,3,18,20,100,102,114]
'CH_F17_CN_107_RESTING'				[29,30,31,32,2,3,18,100]
'CH_F17_AL_302_INTERO'				[29,30,31,32,18,24,111]
'CH_F17_AL_302_NEGATION'				[29,30,31,32,18,58,59]
'CH_F17_AL_302_RESTING'				[29,30,31,32,28,32,75]
'CH_F17_AL_302_SOCIAL'				[29,30,31,32,18]
};



%%
% bad_channels_social = [];
% bad_channels_negation = [29,30,31,32,16];
% bad_channels_intero = [29,30,31,32,16];
% bad_channels_resting = [29,30,31,32,16];

% strfind(set_files(1).name, 'INTERO')


%% Get info about channels
number_channels = EEG.nbchan; % get EEG total number of channels
external_channels = 129:number_channels; % identify external channels
internal_channels = setdiff(1:number_channels, external_channels); % identify internal (or channels in the head) channels

%% Read files to ICA

set_files(1).name

pop_loadset(


%% ICA

channels_to_ica = setdiff(internal_channels, bad_channels); % channels to ICA

EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', channels_to_ica); % run ica? 
% EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', do_ica) % example

    %% save ICAed dataset
    
    pop_saveset( EEG, 'filename', char(strcat(bdf_file_name_extensionless, '.set')),'filepath', char(current_setfile_path)); % save current dataset

 %% Reject components
 
 %% Interpolate channels