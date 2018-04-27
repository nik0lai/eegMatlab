function [] = icaTheWorld(trackTable, setPath, outputPath)
% icaTheWorld takes a table with file names and run ICA over those files.
% INPUT (* = required)
%       *trackTable:    path to table that contains a "subject" column
%                       (without ".set"), a "toICA" column with 0 and 1 
%                       indicating which files to run ICA over, and a 
%                       "badChanns" column indicating in a string the 
%                       number of bad channels to be left out 
%                       (e.g. 1,2,3,4,5).
%       *setPath:       path to folder containing set files.
%       *outputPat:     path to folder where files with ICA will be
%                       written, if empty, setPath folder is used and files 
%                       are replaced.

% get preproc track
preprocTablePath = trackTable;
preprocTrack     = table2struct(readtable(preprocTablePath));

% index and subs to ICA
toIcaI = find([preprocTrack.toICA]);
subToIca = {preprocTrack(toIcaI).subject};

if isempty(outputPath)
    outputPath = setPath;
elseif ~isempty(outputPath)
    % folder to export ICAed dataset
    [~,~,~] = mkdir(outputPath);
end

for i = 1:size(subToIca, 2)
    currSub = char(subToIca(i));
    currBad = preprocTrack(strcmp({preprocTrack.subject}, currSub)).badChanns;
    
    %     load dataset
    EEG = pop_loadset('filename', [currSub '.set'], 'filepath', setPath);
    
    %     chann info
    nChann = EEG.nbchan;
    extChann = 129:nChann;
    intChann = setdiff(1:nChann, extChann);
    chann2ICA = setdiff(intChann, currBad);
    
    %     run ICA
    EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'chanind', chann2ICA);
    %     indicate ICA on name
    EEG = pop_editset(EEG, 'setname', strcat(currSub, '_ICA')); % asign dataset name using bdf file name
    
    %     export ICAed dataset
    pop_saveset(EEG, 'filename', currSub,'filepath', outputPath); % save current dataset
    
    clear EEG;
    
end

end