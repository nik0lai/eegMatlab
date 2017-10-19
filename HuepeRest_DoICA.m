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
% 'Liliana_Guerra'	'S42'	'femme'	'Eugenio' [19,34,48,56] [48,56]
% 'MariaJose_Castillo'	'S43'	'femme'	'Eugenio' [64] [1,2,7,45,59,64]
% 'Juan_Gonzalez_Reyes'	'S44'	'homme'	'Eugenio' [] []
% 'Halinka_Guerrero'	'S45'	'femme'	'Eugenio' [33,52,53] [51,52,53,60]
% 'Francisco_Sepulveda'	'S46'	'homme'	'Eugenio' [5] [5,24]
% 'Constanza_Cofre'	'S47'	'femme'	'Vladimir' [7,43] [7]
% 'Nicole_Cofre'	'S48'	'femme'	'Eugenio' [3,8,9,15] [3]
% 'MariaJose_Pena'	'S49'	'femme'	'Vladimir' [15,57] [15,52,57]
% 'Gabriela_Valdivia'	'S50'	'femme'	'Eugenio' [45] [45]
% 'David_Hernandez'	'S51'	'homme'	'Eugenio' [2,3,16] [3]
% 'Daniela_Isamit'	'S52'	'femme'	'Eugenio' [9,57] [57]
% 'Victor_Ponce'	'S53'	'homme'	'Vladimir' [] []
% 'Paola_Candia'	'S54'	'femme'	'Vladimir' [36] [37]
% 'Simon_SanMartin'	'S55'	'homme'	'Eugenio' [34] []
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
        do_ica      = setdiff(1:numchan, cell2mat(not_chanica));              % Canales a no usar en ICA
        EEG         = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', do_ica); %ICA
        EEG         = pop_saveset( EEG, 'filename', strcat(name, '.set'), 'filepath',strcat(dir, 'SET/OK/'));
    end
end


%% The End
disp('yeah!');
clear; eeglab;