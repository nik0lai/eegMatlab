function [] = prepEnvEeg()
% prepEnvEeg This function prepare the MATLAB enviroment for a script 
% that works with eeglab and eeg data.
% 
% This function clears the enviroment, open eeglab to lighten paths to the
% eeglab ways (without opening the grapich interface, closes everything,
% and clears the command window.

evalin('base','clear'); % clear enviroment
eeglab;     % open eeglab to lighten paths to the eeglab ways
close all;        % close everything
clc;              % clear command line

end