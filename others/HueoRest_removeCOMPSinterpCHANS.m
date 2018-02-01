%% Important shit
close all;
clc;
clear;
dir = '/mnt/A60CFBD40CFB9D8D/LABWORKS/USER/Resting/EEG/';
suffix = 'ICAchan';

%% Participants and their measures
measure = {'Close' 'Open'};
% measure = {'Close'};
% measure = {'Open'};

Participants = {
% 'Myr'	'S01'	'femme'	'eug'
% 'Lui'	'S02'	'homme'	'vlad'

    };
numchan = 64;       % Numero de canales

%% Generate SET file
for state = measure
    names = Participants;
    for i = 1:size(names,1)
        %% Load correct and save SET
        name            = strcat(char(names(i, 2)), char(names(i, 3)), char(state));
        EEG             = pop_loadset('filename', strcat(name, '.set'), 'filepath',strcat(dir, 'SET/OK/'));
%         numchan         = EEG.nbchan;                               % Numero de canales
        chanica         = EEG.icachansind;                          % Canales usados en ICA
        numica          = size(chanica, 2);                            % Numero de componentes
        rejcomps        = EEG.reject.gcompreject;                   % Componentes rechazados (unos y ceros)
        rejnumbers      = times(1:numica, rejcomps);             % Componentes rechazados (indices y ceros)
        rejlist         = rejnumbers(rejnumbers~=0);                % Lista de componentes rechazados
        defect_chans	= setdiff(1:numchan, chanica);              % Canales defectuosos
        EEG             = pop_subcomp(EEG, rejlist, 0);                         % Eliminar componentes artefactuales
        EEG             = pop_editset(EEG, 'setname', strcat(name, suffix));	% renombrar set de datos
        EEG             = pop_interp(EEG, defect_chans, 'spherical');           % Interpolar canales defectuosos
        EEG             = pop_saveset(EEG, 'filename', strcat(name, suffix, '.set'), 'filepath', strcat(dir, 'SET/ICA/'));
        display(name);
        pop_eegplot( EEG, 1, 1, 1);
        title(name);
    end
end


%% The End
disp('yeah!');
clear; eeglab;