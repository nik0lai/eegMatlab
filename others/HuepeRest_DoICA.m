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
% 'Carlos_Nunez'	'S56'	'homme'	'Vladimir' [15,53] [15,52]
% 'Elizabeth_Iturriaga'	'S57'	'femme'	'Vladimir' [18,22,24] [15,22,24]
% 'Kevin_Jara'	'S58'	'homme'	'Vladimir' [41,44,46] [21]
% 'Fabio_Stei'	'S59'	'homme'	'Eugenio' [20] [20,58]
% 'Alexis_Fuentes'	'S60'	'homme'	'Eugenio' [] []
% 'Pia_Jofre'	'S61'	'femme'	'Eugenio' [1,18,34,38] [38,42,59]
% 'Gonzalo_Sanzana'	'S62'	'homme'	'Eugenio' [15,31] []
% 'Joan_Aravena'	'S63'	'femme'	'Eugenio' [1,9,53] [1,9]
% 'Jocelyn_Diaz'	'S64'	'femme'	'Eugenio' [34,53,64] [15,8,53,54]
% 'Krstyn_Pena'	'S65'	'femme'	'Eugenio' [31] [43,44,51,52]
% 'Barbara_Gutierrez'	'S66'	'femme'	'Vladimir' [14,57] [14,57]
% 'Gisela_Torres'	'S67'	'femme'	'Eugenio' [54,57,62,64] [54,57]
% 'Marisela_Neira'	'S68'	'femme'	'Eugenio' [20,57] [20,57]
% 'Matias_Jofre'	'S69'	'homme'	'Eugenio' [42] [45]
% 'Noelia_Mella'	'S70'	'femme'	'Eugenio' [53,61] [53,61]
% 'Carolina_Zamora'	'S71'	'femme'	'Eugenio' [18,39] [18,39]
'Jose_Villanueva'	'S72'	'homme'	'Eugenio' [32,40] [40,62]
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