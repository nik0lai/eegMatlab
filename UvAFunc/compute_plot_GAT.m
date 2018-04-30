function [structOut, cfg_darks] = compute_plot_GAT(cfg, cfg_darks)
% COMPUTE_PLOT_GAT is a wrap-up over adam_compute_group_MVPA and 
% adam_plot_MVPA that computes and plots GAT graphs individually. 
% Function to compute GAT matrices and to plot graphs individually.
% This is a wrap-up around adam_compute_group_MVPA and adam_plot_MVPA.

% It takes two arguments. A cfg structure object (adam_compute_group_MVPA
% and adam_plot_MVPA settings) and a cfg_darks structure object (for actual
% COMPUTE_PLOT_GAT settings).

% add cfg_darks.trialtime to structure saving and folder saving (it should
% go after cfg_darks.trial_time_label)

% Arguments:
% cfg_darks.frst_level_analysis  = description of comparison ran during
    % first level analysis.
% cfg_darks.balancing            = balanced or unbalanced trials. First
    % check if it is manually defined and if not check for "_bal_" and
    % "_unbal_" in first level analysis codename.
% cfg.mpcompcor_method           = ADAM argument
% cfg_darks.trial_time_label     = generated within the function checking
    % "trainlim", "testlim", and "timelim" cfg fields.
% cfg_darks.channelpools         = ADAM argument.
% cfg_darks.trialtime            = description of the window time defined.
    % It has to be used when more there is more than one time window with the
    % same cfg.trainlim, cfg.testlim, cfg.timelim. If non of those is
    % defined the function assumes a complete trial "compTrial".


% STRUCT
% cfg_darks.frst_level_analysis      
% L cfg_darks.balancing               
%   L cfg.mpcompcor_method           
%     L cfg_darks.trial_time_label   
%       |- cfg_darks.channelpools    
%       L cfg_darks.trialtime         
%           L cfg_darks.channelpools 

% IMG SAVE

% cfg_darks.folder_to_plot
% L cfg_darks.balancing 
%   L cfg_darks.trial_time_label 
%       |- cfg_darks.session
%       |    L cfg_darks.folder_to_plot
%       |        |- FILENAME.png
%       |        L cfg_darks.special_anal
%       |            L FILENAME.png
%       L cfg_darks.trialtime


% cfg_darks.folder_name = 
% cfg_darks.trialtime = 
% cfg_darks.trialtimeLogic =

%% check for train, test and time limits. this will be used to label the computed and graphed GAT

if isfield(cfg, 'trainlim')
    cfg_darks.trial_time_label = 'trainlim';
elseif isfield(cfg, 'testlim')
    cfg_darks.trial_time_label = 'testlim';
elseif isfield(cfg, 'timelim')
    cfg_darks.trial_time_label = 'timelim';
elseif (~isfield(cfg, 'trainlim') && ~isfield(cfg, 'testlim') && ~isfield(cfg, 'timelim'))
    cfg_darks.trial_time_label = 'compTrial';
end

%% check for balancing. this will be used in the output structure and as a part of the folder path to save the GAT matrix graph
if isfield(cfg_darks, 'balancing')
%     do nothing
elseif ~isempty(strfind(cfg_darks.folder_name, '_unbal_'))
     cfg_darks.balancing = 'unbalanced';
elseif ~isempty(strfind(cfg_darks.folder_name, '_bal_'))
     cfg_darks.balancing = 'balanced';
elseif ~isfield(cfg_darks, 'balancing') && isempty(strfind(cfg_darks.folder_name, '_unbal_')) && isempty(strfind(cfg_darks.folder_name, '_bal_'))
    error('missing argument: define cfg_darks.balancing')
end
 
%% check for trialtime (what's the use of this?)
if ~isfield(cfg_darks, 'trialtime')
    cfg_darks.trialtimeLogic = 0;
elseif isfield(cfg_darks, 'trialtime')
    cfg_darks.trialtimeLogic = 1;
end

%% FIRST HALF: ACTUALLY COMPUTE GAT MATRICES
for countChann = 1:numel(cfg_darks.channelpools);
    currChann  = cfg_darks.channelpools{countChann};    % channel pool
    
    cfg.channelpool = currChann; % set channel pool
    if (cfg_darks.trialtimeLogic == 1)
        structOut.(cfg_darks.frst_level_analysis).(cfg_darks.balancing).(cfg.mpcompcor_method).(cfg_darks.trial_time_label).(cfg_darks.trialtime).(currChann) = adam_compute_group_MVPA(cfg, cfg_darks.folder_name); % compute stats
    elseif (cfg_darks.trialtimeLogic == 0)
        structOut.(cfg_darks.frst_level_analysis).(cfg_darks.balancing).(cfg.mpcompcor_method).(cfg_darks.trial_time_label).(currChann) = adam_compute_group_MVPA(cfg, cfg_darks.folder_name); % compute stats
    end
    
end

%% SECOND HALF: Plot each channpool separately (and save them)

% folder to plot graph
if (cfg_darks.trialtimeLogic == 1)
    cfg_darks.folder_to_plot  = fullfile(cfg_darks.folder_to_plot, cfg_darks.balancing, cfg_darks.trial_time_label, cfg_darks.trialtime);
elseif (cfg_darks.trialtimeLogic == 0)
    cfg_darks.folder_to_plot  = fullfile(cfg_darks.folder_to_plot, cfg_darks.balancing, cfg_darks.trial_time_label);
end

% struct to get into loop
if (cfg_darks.trialtimeLogic == 1)
    str2loop = structOut.(cfg_darks.frst_level_analysis).(cfg_darks.balancing).(cfg.mpcompcor_method).(cfg_darks.trial_time_label).(cfg_darks.trialtime);
elseif (cfg_darks.trialtimeLogic == 0)
    str2loop = structOut.(cfg_darks.frst_level_analysis).(cfg_darks.balancing).(cfg.mpcompcor_method).(cfg_darks.trial_time_label);
end


for countChann = 1:numel(cfg_darks.channelpools);     % counter
    currChann  = cfg_darks.channelpools{countChann};  % current channel pool

    adam_plot_MVPA(cfg, str2loop.(currChann));                                              % plot
          title([strrep(str2loop.(currChann).condname, '_', ' ') ' ' currChann ' channs']); % change title (get rid of underscores)
    
    %%%%% pause to allow graphic to resize                 
    pause(1);
    %%%%%
       
    % save gat matrices
    if (isfield(cfg_darks, 'special_anal'))
        [~,~,~] = mkdir(fullfile(cfg_darks.plots_folder_path, cfg_darks.session, cfg_darks.folder_to_plot, cfg_darks.special_anal));
        
        saveas(gcf, fullfile(cfg_darks.plots_folder_path, ...
                     cfg_darks.session, ...
                     cfg_darks.folder_to_plot, ...
                     cfg_darks.special_anal, ...
                     [cfg_darks.frst_level_analysis  '_' currChann '_' cfg_darks.balancing '_' cfg.mpcompcor_method '.png'])); % save graph
                 
    elseif (~isfield(cfg_darks, 'special_anal'))
        [~,~,~] = mkdir(fullfile(cfg_darks.plots_folder_path, cfg_darks.session, cfg_darks.folder_to_plot));
        
        saveas(gcf, fullfile(cfg_darks.plots_folder_path, ...
                     cfg_darks.session, ...
                     cfg_darks.folder_to_plot, ...
                     [cfg_darks.frst_level_analysis  '_' currChann '_' cfg_darks.balancing '_' cfg.mpcompcor_method '.png'])); % save graph
    end
    
    %%%%% pause to allow graphs to be closed
    pause(1);
    %%%%%
    
    % try to close graphs again     
    close(gcf); 
    
    % DELETE TRASH
    % if last iteration of plotting and saving, delete str2loop     
    if countChann == size(cfg_darks.channelpools, 2); %detele var with struct
        clear str2loop
    end
        
end

% LAST DESPERATE ATTEMPT TO CLOSE GRAPHS.
close(gcf); 
close all; 