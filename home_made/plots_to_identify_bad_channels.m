%% About

% This script plot channels data as scroll,
    % creates an EEG file without external channels (EEG_128)
        % and plots an spectra graph with a 55 and 30 limit.

%%

clear EEG_128; % clear 128-channels stored EEG (if any)

pop_eegplot( EEG, 1, 1, 1); title(EEG.setname) % plot scroll to inspect EEG

EEG_128 = pop_select( EEG,'nochannel',{'EKG', 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7' 'EXG8'}); % create EEG without external channels to plot spectra plot

figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 55],'electrodes','off'); title(EEG.setname) % spectra plot up to 55 Hz to check if lowpass filter worked
figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 30],'electrodes','off'); title(EEG.setname) % spectra plot up to 30 Hz to check channel deviation

