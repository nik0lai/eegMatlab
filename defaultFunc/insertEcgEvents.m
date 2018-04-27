function [ecgEventEEG] = insertEcgEvents(EEG, beatTimes, ecgEventName)
% ecgEventEEG takes an EEG object, a beatTimes (output from peakfinder
% function) and a str indicating the name of ecg events
% INPUT (* = required)
%        *EEG:          EEG object (output from eeglab).
%        *beatTimes:    latency of peaks detected (output from peakfinder).
%        *ecgEventName: str indicating name for new events (e.g. '537').

tempEEG = EEG;

% Create new struct with ecg events %%%%%%%%%%%%%%%%%%%%%%%%%%
type                         = cell(size([beatTimes], 2), 1);              % empty string (same lenght of number of R peaks detected)
type(:,1)                    = {ecgEventName};                             % ecg event label
latency                      = [beatTimes]';                               % vector with latencies of events
urevent                      = zeros(size(beatTimes, 2), 1);               % vector of zeroes (same lenght of number of R peaks detected)
duration                     = zeros(size(beatTimes, 2), 1);
ecgEvents                    = table(type, latency, urevent, duration);    % taexble with type, latency, urevent, and duration

%  Get EEG event structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eegEventInfo                 = struct2table(tempEEG.event);                    % extrac event struct from EEG

%  Create new EEG event structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ecgEvents.type               = str2double(ecgEvents.type);

eegEventInfo                 = [eegEventInfo ; ecgEvents];                 % concat new rows to events as table
eegEventInfo                 = sortrows(eegEventInfo, 'latency');          % sort table by some col
eegEventInfo.urevent         = [1:size(eegEventInfo,1)]';                  % create new urevent correlative number

newEventStruct               = table2struct(eegEventInfo)';                % convert table with new event info (old + ecg) to struct
tempEEG.event                = newEventStruct;                             % insert new event struct to EEG.

ecgEventEEG = tempEEG;

end