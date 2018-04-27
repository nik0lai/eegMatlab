function [eegFiles] = findEegFiles(path2files)


% path2files = '/home/niki/Documents/eegeses/UG_agustin/data/raw/piloting_test/set/trimmed/';

% get everything inside folder
rawFounded = dir(path2files);
cleanFounded = find([rawFounded.isdir] == 0);

% create empty cell to store folder content
foundedCell = cell(1, size(rawFounded(3:end,:), 1));

% store folder content in a cell to check for file extensions
for foundedCounter = 1:numel(foundedCell)
    foundedCell(foundedCounter) = cellstr(cleanFounded(foundedCounter,:).name);
end

% Search for bdf/set files
bdfIndex = strfind(foundedCell, 'bdf');
setIndex = strfind(foundedCell, 'set');

% search for bdf/set and store the result
if (~sum(find(not(cellfun('isempty', bdfIndex)))) == 0 && sum(find(not(cellfun('isempty', setIndex)))) == 0)
    disp('Only .bdf files detected')
    bdfExist = 1;
    setExist = 0;
    
    bdfFiles = dir(fullfile(path2files, '*.bdf')); % get bdf files
    bdfFiles = table2struct([struct2table(bdfFiles), struct2table(cell2struct(strcat(path2files, {bdfFiles.name}), 'paths'))]); % add path to each file
    
    eegFiles = bdfFiles;
elseif (sum(find(not(cellfun('isempty', bdfIndex)))) == 0 && ~sum(find(not(cellfun('isempty', setIndex)))) == 0)
    disp('Only .set files detected')
    bdfExist = 0;
    setExist = 1;
    
    setFiles = dir(fullfile(path2files, '*.set'));
    setFiles = table2struct([struct2table(setFiles), struct2table(cell2struct(strcat(path2files, {setFiles.name}), 'paths'))]); % add path to each file
    
    eegFiles = setFiles;
elseif (~sum(find(not(cellfun('isempty', bdfIndex)))) == 0 && ~sum(find(not(cellfun('isempty', setIndex)))) == 0)
    disp('.bdf and .set files detected')
    bdfExist = 1;
    setExist = 1;
    
    bdfFiles = dir(fullfile(path2files, '*.bdf'));
    setFiles = dir(fullfile(path2files, '*.bdf'));
    
    eegFiles = [bdfFiles setFiles];
    eegFiles = table2struct([struct2table(eegFiles), struct2table(cell2struct(strcat(path2files, {eegFiles.name}), 'paths'))]); % add path to each file
    
end

% sort files by date
eegFiles = table2struct(sortrows(struct2table(eegFiles), 'datenum'));
end



