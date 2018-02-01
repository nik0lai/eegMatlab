%% Important shit
close all;
clc;
clear;
mydir       = '/mnt/A60CFBD40CFB9D8D/LABWORKS/dir/Resting/EEG/';
setdir      = 'SET/MERGED/';
allfiles	= dir(strcat(mydir,setdir,'*.set'));
filelist	= {allfiles.name};

%% Generate SET file
for i   = 1:size(filelist, 2)
    setname = filelist(i);
    EEG = pop_loadset('filename', setname, 'filepath', strcat(mydir, setdir));
    display(setname)
    EEG = pop_basicfilter(EEG,  1:64 , 'Boundary',  -99, 'Cutoff', 40,...
        'Design', 'butter', 'Filter', 'lowpass', 'Order',  2, 'RemoveDC', 'on');
    EEG = pop_reref(EEG, [16 53] ,'exclude',[65:76] ,'keepref','on');
    EEG = pop_binlister(EEG , 'BDF', '/home/neurobot/Drive/00EEG/Proyectos/dir/Resting/Heart/binsRestingHEP.txt',...
        'IndexEL',  1, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG');
    EEG = pop_epochbin(EEG, [-200.0  600.0],  [ -200 -50]);
    erpname = char(setname);
    erpname = erpname(1:end-4);
    ERP = pop_averager(EEG, 'Criterion', 'good', 'DSindex', 1, 'ExcludeBoundary', 'on', 'SEM', 'on', 'Warning', 'off');
    ERP = pop_savemyerp(ERP, 'erpname', erpname,...
        'filename', strcat(mydir, 'ERP/', erpname, '.erp'));
%     ERP = pop_ploterps( ERP, [ 1 2],1:64 , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', '-200 -50', 'Box', [ 8 8],...
%         'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom',...
%         'Linespec', {'k-' , 'r-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', [ 103.667 29.6154 106.833 31.9231],...
%         'Style', 'Topo', 'Tag', 'ERP_figure', 'Transparency',0, 'xscale', [ -200.0 598.0 -200:100:500 ],...
%         'YDir', 'normal', 'yscale', [ -10.0 5.0 -10:2.5:-5 -2.6:2.6:2.6 5:2.5:10 ] );

end

%% The End
disp('yeah!');
% clear; eeglab;