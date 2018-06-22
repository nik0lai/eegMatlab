function [] = createEKG(setFiles, setPath, chann1, chann2)
% createEKG creates a new ekg channel substracting chann2 to chann1.
% INPUT (* = required)
%       setFiles: a cell containing .set files names. If not supplied it
%       will looked for them within setpath.
%       *setPath: path to folder containing set files.
%       *chann1 & chann2: number indicating chann number.
%
%       e.g.
%       createEKG(setFiles, setPath, chann1, chann2)

% if no set files received, look for them.
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

% loop through set files, load dataset, create ekg channel, save dataset.
for i = 1:size(setFile, 2)
    currSet = setFile(i);
    
    %     Load dataset
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    
    %     Check if EKG already exists
    channNames = {tempEEG.chanlocs.labels};
    
    if sum(strcmp(channNames, 'EKG')) > 1
        disp('************************************************')
        disp([tempEEG.setname ' has more than one EKG channel.'])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
    elseif sum(strcmp(channNames, 'EKG')) == 1
        disp('************************************************')
        disp([tempEEG.setname ' already has an EKG channel.'])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
    elseif sum(strcmp(channNames, 'EKG')) == 0
        disp('************************************************')
        disp(['Creating EKG channel on channel ' num2str(tempEEG.nbchan+1)])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
        %     Create EKG chann
        tempEEG = pop_eegchanoperator(tempEEG, {[['ch' int2str(tempEEG .nbchan + 1)] ' = ch' num2str(chann1) ' - ch' num2str(chann2) ' label EKG']} , 'ErrorMsg', 'popup', 'Warning', 'on');
        %     Save dataset
        pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
    end 
    
    
end
end