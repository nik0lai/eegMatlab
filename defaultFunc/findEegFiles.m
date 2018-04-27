function [eegFiles] = findEegFiles(path2files)
% eegFiles receives a path and looks for .set and .bdf diles.
% INPUT
%       path2files: string indicating path to folder where eeg files are.



% path2files = '/home/niki/Documents/eegeses/UG_agustin/data/raw/piloting_test/set/ICA/rejectInterpoled';

% get everything inside folder
rawFounded    = dir(path2files);
cleanFounded  = rawFounded([rawFounded.isdir] == 0);

if (~isempty(cell2mat(strfind({cleanFounded.name}, 'bdf'))) && isempty(cell2mat(strfind({cleanFounded.name}, 'set'))))
    disp('Only .bdf files detected')    
    eegFiles = dir(fullfile(path2files, '*.bdf')); % get bdf files    
elseif (~isempty(cell2mat(strfind({cleanFounded.name}, 'set'))) && isempty(cell2mat(strfind({cleanFounded.name}, 'bdf'))))
    disp('Only .set files detected')
    eegFiles = dir(fullfile(path2files, '*.set'));
elseif (~isempty(cell2mat(strfind({cleanFounded.name}, 'set'))) && ~isempty(cell2mat(strfind({cleanFounded.name}, 'bdf'))))
    disp('.bdf and .set files detected')
    bdfFiles = dir(fullfile(path2files, '*.bdf'));
    setFiles = dir(fullfile(path2files, '*.set'));
    eegFiles = [bdfFiles setFiles];
end

end



