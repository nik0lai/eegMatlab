% Put ECG trigger events to EEG dataset

chan_ecg                     = 137 ;                                       % define ecg channel index
[beatTimes, mag]             = peakfinder(EEG.data(chan_ecg:chan_ecg,:));  % get latency and magnitudes of R peaks
ecgEventName                 ='666';                                      % ecg's R peak event label
   
% Create new struct with ecg events %%%%%%%%%%%%%%%%%%%%%%%%%%

type                         = cell(size([beatTimes], 2), 1)               % empty string (same lenght of number of R peaks detected)
type(:,1)                    = {'666'}                                     % ecg event label
latency                      = [beatTimes]';                               % vector with latencies of events
urevent                      = zeros(size(beatTimes, 2), 1);               % vector of zeroes (same lenght of number of R peaks detected)
duration                     = zeros(size(beatTimes, 2), 1);               % vector of zeroes (same lenght of number of R peaks detected)
ecgEvents                    = table(type, latency, urevent, duration);    % table with type, latency, urevent, and duration
      
%  Get EEG event structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eegEventInfo                 = struct2table(EEG.event);                    % extrac event struct from EEG
   
%  Create new EEG event structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%

eegEventInfo                 = [eegEventInfo ; ecgEvents];                 % concat new rows to events as table
eegEventInfo                 = sortrows(eegEventInfo, 'latency');          % sort table by some col
eegEventInfo.urevent         = [1:size(eegEventInfo,1)]';                  % create new urevent correlative number

newEventStruct               = table2struct(eegEventInfo)'                 % convert table with new event info (old + ecg) to struct
EEG.event                    = newEventStruct                            % insert new event struct to EEG.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%