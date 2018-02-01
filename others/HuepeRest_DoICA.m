%% Important shit
close all;
clc;
clear;
dir = '/mnt/A60CFBD40CFB9D8D/LABWORKS/Huepe/Resting/EEG/';

%% Participants and their measures
measure = {'Close' 'Open'};
% measure = {'Close'};
% measure = {'Open'};

Participants = {
% 'carl'	'S56'	'homme'	'vlad' [15,53] [15,52]
% 'eliz'	'S57'	'femme'	'vlaf' [18,22,24] [15,22,24]

    };
numchan = 64;       % Numero de canales

%% Generate SET file
for state = measure
    if strcmp(char(state),'Close')
        icaindex = 5;
    else
        icaindex = 6;
    end
    names = Participants;
    for i = 1:size(names,1)
        %% Load correct and save SET
        name        = strcat(char(names(i, 2)), char(names(i, 3)), char(state));
        EEG         = pop_loadset('filename', strcat(name, '.set'), 'filepath',strcat(dir, 'SET/OK/'));
%         numchan     = EEG.nbchan;                               % Numero de canales
        not_chanica	= names(i, icaindex);                          % Canales no usados en ICA
        do_ica      = setdiff(1:numchan, cell2mat(not_chanica));              % Canales a usar en ICA
        EEG         = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', do_ica); %ICA
        EEG         = pop_saveset( EEG, 'filename', strcat(name, '.set'), 'filepath',strcat(dir, 'SET/OK/'));
    end
end


%% The End
disp('yeah!');
clear; eeglab;