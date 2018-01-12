%% About

% TODO: read which files are ready to identify bad channels, or
% componentes, open the first data set and open the corresponding scrolls
% and spectra maps.

% This script plot channels data as scroll,
    % creates an EEG file without external channels (EEG_128)
        % and plots an spectra graph with a 55 and 30 limit.

%% To identify bad channels after preprocessing

clear EEG_128; % clear 128-channels stored EEG (if any)

EEG_128 = pop_select( EEG,'nochannel',{'EKG', 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7' 'EXG8'}); % create EEG without external channels to plot spectra plot

pop_eegplot( EEG_128, 1, 1, 1); title(EEG.setname) % plot scroll to inspect EEG
% pop_eegplot( EEG, 1, 1, 1); title(EEG.setname) % plot scroll to inspect EEG

figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 55],'electrodes','off'); title(EEG.setname) % spectra plot up to 55 Hz to check if lowpass filter worked
figure; pop_spectopo(EEG_128, 1, [0      EEG_128.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 30],'electrodes','off'); title(EEG.setname) % spectra plot up to 30 Hz to check channel deviation

%% To identify bad components

clear EEG_no_bad; % clear EEG without bad channels (if any)

EEG_no_bad = pop_select( EEG,'channel',[EEG.icachansind]); % EEG without bad channels
pop_eegplot( EEG_no_bad, 1, 1, 1); title(EEG.setname); % plot scroll to inspect EEG without bad channels
figure; pop_spectopo(EEG_no_bad, 1, [0      EEG_no_bad.xmax*1000], 'EEG' , 'freq', [8 10 12], 'freqrange',[1 30],'electrodes','off'); title(EEG.setname) % spectra plot up to 30 Hz to check channel deviation

figure; pop_spectopo(EEG, 0, [0      1598996.0938], 'EEG' , 'freq', [10], 'plotchan', 0, 'percent', 20, 'icacomps', [1:32], 'nicamaps', 5, 'freqrange',[2 25],'electrodes','off'); title(EEG.setname) % spectra
%figure; pop_spectopo(EEG, 0, [0      1598996.0938], 'EEG' , 'freq', [10], 'plotchan', 0, 'icacomps', [1:32], 'nicamaps', 5, 'freqrange',[2 50],'electrodes','off'); title(EEG.setname) % spectra

pop_eegplot( EEG, 0, 1, 1); title(EEG.setname) % plot components scroll
pop_selectcomps(EEG, [1:50] ); title(EEG.setname) % plot components


% EEG.icachansind
% length(EEG.icachansind)