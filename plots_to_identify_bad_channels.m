%% About

% This script plot channels data as scroll,
    % creates an EEG file without external channels (EEG_128)
        % and plots an spectra graph with a 55 and 30 limit.

%%

clear EEG_128;

pop_eegplot( EEG, 1, 1, 1); title(EEG.setname)

EEG_128 = pop_select( EEG,'nochannel',{'EKG', 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7' 'EXG8'}); 

figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 55],'electrodes','off'); title(EEG.setname)
figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 30],'electrodes','off'); title(EEG.setname)

