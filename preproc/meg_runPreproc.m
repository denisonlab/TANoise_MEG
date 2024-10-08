function meg_runPreproc(sessionDir)
% meg_runMEGPreproc.m

%% setup
% exptDir = '/Volumes/DRIVE1/DATA/rachel/MEG/TADetectDiscrim/MEG';
% exptDir = '/Local/Users/denison/Data/TANoise/MEG';
% exptDir = '/Local/Users/denison/Data/TA2/MEG';
% exptDir = pathToTA2('MEG');
% exptDir = '/Users/kantian/Dropbox/Data/TA2/MEG';
% exptDir = pathToTANoise('MEG');
exptDir = '/Users/kantian/Dropbox/Data/TA2/MEG';

% sessionDir = 'R0817_20171213';
fileBase = meg_sessionDirToFileBase(sessionDir,'TA2'); 
% fileBase = 'R0890_TA2_11.21.18';

% sessionDir = 'R0817_20171213';
% fileBase = 'R0817_TANoise_7.12.17';

renameFiles = false;
runsToRename = 1:12; %runs

segmentDataFile = false;

preprocStr = 'ebi2'; % 'biet_f1Hz_p'; % desired analyses % bie 

dataDir = sprintf('%s/%s', exptDir, sessionDir);
preprocDir = sprintf('%s/preproc_%s', dataDir, preprocStr);
figDir = sprintf('%s/%s/%s', preprocDir, 'figures');

inspectData = false;

%% rename files if needed
if renameFiles
    renameRunFiles(sessionDir, runsToRename) 
end

%% make the preproc dir if it doesn't exist
if ~exist(preprocDir,'dir')
    mkdir(preprocDir)
end

%% segment only if needed
runFiles = dir(sprintf('%s/%s*.sqd', preprocDir, fileBase));
if isempty(runFiles)
    if segmentDataFile
        %% segment original sqd into runs
        dataFile = sprintf('%s/%s.sqd', dataDir, fileBase);
        
        % check settings in rd_segmentSqd before running!
        nRuns = rd_segmentSqd(dataFile);
        runs = 1:nRuns
    end
    
    %% move run files into preproc directory
    runFiles = dir(sprintf('%s/*run*.sqd', dataDir));
    nRuns = numel(runFiles);
    runs = 1:nRuns
    
    for iRun = 1:nRuns
        movefile(sprintf('%s/%s', dataDir, runFiles(iRun).name), preprocDir)
    end
else
    % we have done preprocessing before, so find the number of runs
%     runTag = rd_getTag(runFiles(end).name,'run');
%     nRuns = str2num(runTag(3:4));
    nRuns = numel(runFiles);
    runs = 1:nRuns
end

%% view data
if inspectData
    % % just from run 1
    run1Data = sqdread(sprintf('%s/%s', preprocDir, runFiles(1).name));
    run1Data  = run1Data(:,1:157)';
    
    srate = 1000;
    windowSize = [1 5 2560 1392];
    eegplot(run1Data,'srate',srate,'winlength',20,'dispchans',80,'position',windowSize);
end

%% manually set bad channels

load(sprintf('%s/prep/channels_rejected.mat',dataDir));

if ~isempty(channels_rejected)
    chRejChar = char(channels_rejected); % cell to char array
    chRejChar = chRejChar(:,end-2:end); % extract ch numbers in last three char
    chRej = [];
    for iC = 1:size(chRejChar,1)
        chRej(iC) = str2double([chRejChar(iC,1) chRejChar(iC,2) chRejChar(iC,3)]); % to double
    end
    % chRej = chRej'; % TA2
    
    badChannels = [chRej];
else
    badChannels = [];
end

%% run preproc for each run
for iRun = 1:12 % nRuns
    run = runs(iRun);
%     runFile = sprintf('%s/%s_run%02d.sqd', preprocDir, fileBase, run);
    runFile = sprintf('%s/%s', preprocDir, runFiles(iRun).name);
    preprocFileName = meg_preproc(runFile, figDir, badChannels); % preproc script 
end

%% combine run files into preprocessed sqd
analStr = rd_getTag(preprocFileName);
outFileName = sprintf('%s_%s.sqd', fileBase, analStr);
outfile = rd_combineSqd(preprocDir, outFileName, analStr)

%% if combining sqd after preprocessing already done
% outfile = rd_combineSqd(preprocDir, outFileName, '')

%% view triggers for the combined file
rd_checkTriggers(outfile);

%% move original run files back to the session directory
for iRun = 1:nRuns
    movefile(sprintf('%s/%s', preprocDir, runFiles(iRun).name), dataDir)
end

end


