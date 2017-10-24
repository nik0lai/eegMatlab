%% Important shit
suffix = 'ICAchan';
numchan = 64; %OJO: ACÁ DEBE IR EL NÚMERO DE CANALES QUE CORRESPONDEN EFECTIVAMENTE AL EEG (SENSU STRICTO)

%% Generate SET file
%% Load correct and save SET
name            = EEG.setname;
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
display(name);
pop_eegplot( EEG, 1, 1, 1);
title(name);


%% The End
disp('yeah!');
eeglab redraw;