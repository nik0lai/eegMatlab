%% Important shit
close all;
clc;
clear;
dir = '/mnt/A60CFBD40CFB9D8D/LABWORKS/Huepe/Resting/EEG/';
suffix = 'ICAchan';

%% Participants and their measures
measure = {'Close' 'Open'};
% measure = {'Close'};
% measure = {'Open'};

Participants = {
% 'Myriam_Cortes'	'S01'	'femme'	'Eugenio'
% 'Luis_Ramirez'	'S02'	'homme'	'Vladimir'
% 'Patricia_Caicedo'	'S03'	'femme'	'Eugenio'
% 'Beatriz_Navarrete'	'S04'	'femme'	'Vladimir'
% 'Alejandro_Sandoval'	'S06'	'homme'	'Eugenio'
% 'Claudia_Navarrete'	'S07'	'femme'	'Vladimir'
% 'Felipe_Echevarria'	'S08'	'homme'	'Eugenio'
% 'Andres_Chavez'	'S10'	'homme'	'Vladimir'
% 'Vilma_Caroca'	'S11'	'femme'	'Eugenio'
% 'Alejandra_Caceres'	'S12'	'femme'	'Eugenio'
% 'Lucia_Concha'	'S17'	'femme'	'Eugenio'
% 'Carlos_Espinoza'	'S18'	'homme'	'Eugenio'
% 'Yanete_Alvares'	'S20'	'femme'	'Vladimir'
% 'Rodolfo_Sanchez'	'S21'	'homme'	'Vladimir'
% 'Juan_Gonzales'	'S22'	'homme'	'Eugenio'
% 'Isaac_Iturriaga'	'S23'	'homme'	'Eugenio'
% 'Karina_Veliz'	'S24'	'femme'	'Eugenio'
% 'Arnaldo_Arriasa'	'S26'	'homme'	'Eugenio'
% 'Carmen_Faundez'	'S27'	'femme'	'Eugenio'
% 'Jose_Perez'	'S28'	'homme'	'Vladimir'
% 'Sandra_Valenzuela'	'S29'	'femme'	'Eugenio'
% 'Patricia_Lizama'	'S32'	'femme'	'Vladimir'
% 'Juana_Garrido'	'S33'	'femme'	'Vladimir'
% 'Carlos_Contreras'	'S34'	'homme'	'Eugenio'
% 'Marcela_Caballero'	'S35'	'femme'	'Eugenio'
% 'Claudia_Vargas'	'S36'	'femme'	'Eugenio'
% 'Diego_Contreras'	'S37'	'homme'	'Eugenio'
% 'Yurismi_Vilches'	'S38'	'femme'	'Eugenio'
% 'Manuel_Perez'	'S39'	'homme'	'Eugenio'
% 'Pamela_Fuentealba'	'S40'	'femme'	'Vladimir'
% 'Scarlet_Alarcon'	'S41'	'femme'	'Eugenio'
% 'Liliana_Guerra'	'S42'	'femme'	'Eugenio'
% 'MariaJose_Castillo'	'S43'	'femme'	'Eugenio'
% 'Juan_Gonzalez_Reyes'	'S44'	'homme'	'Eugenio'
% 'Halinka_Guerrero'	'S45'	'femme'	'Eugenio'
% 'Francisco_Sepulveda'	'S46'	'homme'	'Eugenio'
% 'Constanza_Cofre'	'S47'	'femme'	'Vladimir'
% 'Nicole_Cofre'	'S48'	'femme'	'Eugenio'
% 'MariaJose_Pena'	'S49'	'femme'	'Vladimir'
% 'Gabriela_Valdivia'	'S50'	'femme'	'Eugenio'
% 'David_Hernandez'	'S51'	'homme'	'Eugenio'
% 'Daniela_Isamit'	'S52'	'femme'	'Eugenio'
% 'Victor_Ponce'	'S53'	'homme'	'Vladimir'
% 'Paola_Candia'	'S54'	'femme'	'Vladimir'
% 'Simon_SanMartin'	'S55'	'homme'	'Eugenio'
% 'Carlos_Nunez'	'S56'	'homme'	'Vladimir'
% 'Elizabeth_Iturriaga'	'S57'	'femme'	'Vladimir'
% 'Kevin_Jara'	'S58'	'homme'	'Vladimir'
% 'Fabio_Stei'	'S59'	'homme'	'Eugenio'
% 'Alexis_Fuentes'	'S60'	'homme'	'Eugenio'
% 'Pia_Jofre'	'S61'	'femme'	'Eugenio'
% 'Gonzalo_Sanzana'	'S62'	'homme'	'Eugenio'
% 'Joan_Aravena'	'S63'	'femme'	'Eugenio'
% 'Jocelyn_Diaz'	'S64'	'femme'	'Eugenio'
% 'Krstyn_Pena'	'S65'	'femme'	'Eugenio'
% 'Barbara_Gutierrez'	'S66'	'femme'	'Vladimir'
% 'Gisela_Torres'	'S67'	'femme'	'Eugenio'
% 'Marisela_Neira'	'S68'	'femme'	'Eugenio'
% 'Matias_Jofre'	'S69'	'homme'	'Eugenio'
% 'Noelia_Mella'	'S70'	'femme'	'Eugenio'
% 'Carolina_Zamora'	'S71'	'femme'	'Eugenio'
'Jose_Villanueva'	'S72'	'homme'	'Eugenio'
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