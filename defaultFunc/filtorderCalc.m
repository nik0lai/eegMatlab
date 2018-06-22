function [filtorder] = filtorderCalc(sRate, lowEND, highEND)
% FILTERORDERCALC calculates eeg filter order. This is usually calculated
% internally by eeglab. The following lines were taken from
% 'pop_eegfiltnew.m' (eeglab script).
%
% INPUT (* = required)
%       sRate: EEG sampling rate
%       lowEnd & highEnd: number indicating lower and higher end of filter.
%       at least one has to be defined.
%
%       e.g.
%       filtorderCalc(256, .5, 30)

edgeArray = [lowEND highEND];

if isempty(lowEND) && ~isempty(highEND)
    revfilt = 0;
elseif ~isempty(lowEND) && isempty(highEND)
    revfilt = 1;
end

TRANSWIDTHRATIO = 0.25;
fNyquist = sRate / 2;

maxTBWArray = edgeArray;
if revfilt == 0 % lowpass
    maxTBWArray = fNyquist - edgeArray;
end
maxDf = maxTBWArray;

% Default filter order heuristic
if revfilt == 1 % Highpass
    df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
else % Lowpass
    df = min([max([edgeArray * TRANSWIDTHRATIO 2]) maxDf]);
end

filtorder = 3.3 / (df / sRate); % Hamming window
filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.

end