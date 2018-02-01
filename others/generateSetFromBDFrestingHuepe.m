%% Important shit

eeglab; % open eeglab
close all; 
clc;
clear all;
dir         = '/home/user/Documents/EEGeses/Agustiniano/bdf/TESTING';	% big files folder
% cd(dir);
eeglabpath  = '/home/user/Drive/00EEG/Tools/eeglab14_1_1b';     %eeglab's folder
minutes     = 5;
rMax        = 100;
IBIs        = struct;
PSDs        = struct;
totalCount  = 0;
resample    = 1024;
    

%% Participants and their measures
% measure = {'Close' 'Open'};
measure = {'Close'};
% measure = {'Open'};

Participants = {
% 'subject_name'	'S01'	'femme'	'eug'
% 'subject_name'	'S02'	'homme'	'vlad'
    };

%% Metadata file
tableTimes = fopen('rMSSDs.csv','w');
fprintf(tableTimes,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n',...
    'ID', 'sexe', 'state', 'orig', 'nBEATS', 'duration', 'PULSE', 'AVNN', 'SDNN', 'CVRR', 'rMSSD', 'NN50', 'pNN50', 'LF', 'HF', 'LF_HF', 'nLF', 'nHF');


strcat(dir, '/BDF/', char(state), '/', char(names(1, 1)), '_Resting_', char(state), '.bdf')

%% Generate SET file
for state = measure
    if strcmp(char(state),'Open')
        mark = 1;
    else
        mark = 2;
    end
        
    names = Participants;
    for i = 1:size(names,1)
        %% Name and info
        totalCount = totalCount + 1;
        EEG = pop_biosig(strcat(dir, '/BDF/', char(state), '/', char(names(i, 1)), '_Resting_', char(state), '.bdf'));
        %% Resample and add channels
        EEG = pop_resample(EEG, resample);
        EEG = pop_eegchanoperator( EEG, {
            'ch73 = ch71 - ch72 label ECG',...
            'ch74 = ch71 label EXG7f',...
            'ch75 = ch73 label ECGf',...
            'ch76 = 0 label IIBI'},...
            'ErrorMsg', 'popup' );
        %% Extract and filter ECGs
        EEG  = pop_basicfilter(EEG, [1:70 74 75] , 'Boundary', 'boundary', 'Cutoff',  0.1,...
            'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );

%         ECGy7f = pop_select(EEG,'channel',{'EXG7f' 'ECGf'});
%         ECGy7f = pop_eegfiltnew(ECGy7f, [], .1, [], 1,[], 0);
         
        %% Chan-Location
        EEG=pop_chanedit(EEG, 'lookup',strcat(eeglabpath, '/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'));
        for index = 1:64
            EEG.chanlocs(index).labels = char(chanes(index));
        end
        
        %% Creacion de nombre anonimo
%         newname = strcat(char(names(i, 2)), char(names(i, 3))); 
        newname = strcat(char(names(i, 2)), char(names(i, 3)), char(state)); 
        EEG     = pop_editset(EEG, 'subject', newname, 'condition', char(state),...
        'setname', newname, 'session', 1,'group', char(names(i, 4)), 'comments', '');
        
%          %% Filtrado 0.2-90 Hz
%         EEG = pop_eegfiltnew(EEG, [], 0.2, [], 1, [], 0);
%         EEG = pop_eegfiltnew(EEG, 49.5, 50.5, [], 1, [], 0);
%         EEG = pop_eegfiltnew(EEG, [], 90, [], 0, [], 0);

        %% restore ECG and caclculate heart shit
%         EEG.data(74:74,:) = ECGy7f.data(1:1,:);
%         EEG.data(75:75,:) = ECGy7f.data(2:2,:);
        
        %% first calculation
        [beatTimes, mag] = peakfinder(EEG.data(71:71,:));
        beatTimes = beatTimes * 1000 / EEG.srate;
        [rMSSD, SDNN, AVNN] = rmssd(beatTimes);
        orig = 'EXG7';

        %% detect bad shit
        if or(rMSSD>rMax, isnan(rMSSD))
            [beatTimes, mag] = peakfinder(EEG.data(73:73,:));
            beatTimes = beatTimes * 1000 / EEG.srate;
            [rMSSD, SDNN, AVNN] = rmssd(beatTimes);
            orig = 'ECG';
        end
        if or(rMSSD>rMax, isnan(rMSSD))
            [beatTimes, mag] = peakfinder(EEG.data(74:74,:));
            beatTimes = beatTimes * 1000 / EEG.srate;
            [rMSSD, SDNN, AVNN] = rmssd(beatTimes);
            orig = 'EXG7f';
        end
        if or(rMSSD>rMax, isnan(rMSSD))
            [beatTimes, mag] = peakfinder(EEG.data(75:75,:));
            beatTimes = beatTimes * 1000 / EEG.srate;
            [rMSSD, SDNN, AVNN] = rmssd(beatTimes);
            orig = 'ECGf';
        end

        %% Add 1 mark
        num = 9;
        s   = struct('type', num, 'latency', 1, 'urevent', 1);
        EEG.event = s;

        %% pongale cuchara
        if SDNN > 0
            for hb = 1:size(beatTimes, 2)
                s  = struct('type', mark,'latency', beatTimes(hb)*EEG.srate/1000, 'urevent', mag(hb));
                EEG.event(1, hb) = s;
            end
        end
        
%         %%test
%         EEE = pop_saveset( EEG, 'filename', strcat(newname, 'Full.set'), 'filepath', strcat(dir, '/SET/'));
        
        %% update
        middle    = round(EEG.xmax*EEG.srate/2)/EEG.srate;
        plusminus =  round(minutes*60*EEG.srate/2)/EEG.srate;
        EEG       = pop_select(EEG,'time', [EEG.xmin, middle + plusminus]);
        EEG       = pop_select(EEG,'time', [EEG.xmax - 2*plusminus, EEG.xmax - EEG.srate^-1]);
        [rMSSD, SDNN, AVNN, IBI, NN50, pNN50] = rmssd(EEG);
        nBeats    = size(EEG.event, 2);
        duration  = EEG.xmax / 60;
        pulse     = nBeats / duration;
        CVRR      = SDNN*100/AVNN;
        
        %% IIBI
%         IBIsec = IBI/1000;
        [LF, HF, LF_HF, nLF, nHF, powsave, frqsave, EEG] = iibipsd(EEG, IBI);

        %% Write heart shit
        fprintf(tableTimes, '%s %s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',...
            newname, char(names(i, 3)), char(state), orig, nBeats, duration, pulse, AVNN, SDNN, CVRR, rMSSD, NN50, pNN50, LF, HF, LF_HF, nLF, nHF);
        IBIs(totalCount).name  = newname;
        IBIs(totalCount).RRs   = IBI;
        PSDs(totalCount).name  = newname;
        PSDs(totalCount).freq  = frqsave;
        PSDs(totalCount).power = powsave;

        %% Save SET
%         create_subj_dir = char(strcat('mkdir', {' '}, dir, '/SET/', state,'/', newname));
%         system(create_subj_dir);
        EEG = pop_saveset( EEG, 'filename', strcat(newname, '.set'), 'filepath', strcat(dir, '/SET/'));

    end
end

%% close metadata file
fclose(tableTimes);
save('allIBIs.mat', 'IBIs')
save('allPSDs.mat', 'PSDs')

%% END
disp('yeah!');
