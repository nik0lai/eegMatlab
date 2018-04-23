%% find R peaks
chan_ecg  = 137;
[beatTimes, mag] = peakfinder(EEG.data(chan_ecg:chan_ecg,:));
beatTimes = beatTimes * 1000 / EEG.srate;

%% Add 1 mark
num       = 9;
s         = struct('type', num, 'latency', 1, 'urevent', 1);
EEG.event = s;

%% pongale cuchara
mark = 9;
for hb = 1:size(beatTimes, 2)
    s  = struct('type', mark,'latency', beatTimes(hb)*EEG.srate/1000, 'urevent', mag(hb));
    EEG.event(1, hb) = s;
end

EEG.event
