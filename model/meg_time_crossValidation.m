function [mdlFit, A4] = meg_time_crossValidation(expt, sessionDir, user)
% function meg_time_crossValidation(expt, sessionDir, user)
% split half cross validation per session by time (first half v second
% half) 

% Inputs:
%   expt: 'TANoise'
%   sessionDir: eg: 'R0817_20171212', 'test' will create simulated data
%   user = 'karen' 'scc' 

% Outputs: 
%   mdlFit: strucutre of fitted model parameters 
%   A4: structure of model fit rsquares per permuted split half 

%% Setup 
switch user 
    case 'scc'
        cluster = 1; 
    otherwise 
        cluster = 0; % displays messages of run status if not cluster 
end

exptDir = meg_pathToTAMEG(expt, user);

[sessionNames,subjectNames,ITPCsubject,ITPCsession] = meg_sessions(expt); 

if strcmp(sessionDir,'test')
    sessionIdx = 1; 
    % simulate sine data 
    Fs = 1000;
    freq = 2;
    % --- Data 1 params ---
    intercept1 = 0.3;
    slope1 = 1; % 0.0001; % 0.0001 more reflects actual data
    amplitude1 = 0.1;
    phase1 = 0; % change here
    % --- Simulate data (in trial-relative time) ---
    clear dummyData
    dummyData = ((slope1/1000 * p.t) + intercept1)  + ( amplitude1 * sin( (freq*pi/(Fs/2)) * (p.t + phase1 * 100 )) ); 
else
    sessionIdx = find(strcmp(sessionNames,sessionDir));
    % loads single trial ITPC data 
    dataFile = sprintf('%s/Group/mat/singleTrialPower_allTrials_s20.mat', exptDir); 
end
load(dataFile) % groupA (20 Hz filtered data), groupB (behavior)  

condNames = {'all'}; 
nChannels = 5; 

% --- Figures --- 
figFormat = 'png';

dateStr = datetime('now','TimeZone','local','Format','yyMMdd');
figDir = sprintf('%s/Group/figures/crossValidation/%s', exptDir, dateStr);
if ~exist(figDir, 'dir')
    mkdir(figDir)
end

analDir = sprintf('%s/analysis/crossValidation/%s', pwd, dateStr);
if ~exist(analDir,'dir')
    mkdir(analDir)
end
filename = sprintf('%s/%s_crossValidation.mat',analDir,sessionDir); % analysis file name

%% Analysis settings 
% --- Cross validation split half setttings ---
nPermCV = 1; % 10, 100 
% --- Model fit start coefficient perms ---
nPerms = 100; % 10, 100

% --- MEG settings --- 
p = meg_params('TANoise_ITPCsession8');

% --- Timing and ITPC settings --- 
tT = p.tstart:p.tstop;

% taper          = 'hanning';
% foi            = 20; % 100;
% t_ftimwin      = 10 ./ foi;
% toiT            = p.tstart/1000:0.01:p.tstop/1000; % toi for (T)rial 
% tfAmps = []; tfAmpsAvg = [];
% tfPows = []; tfPowsAvg = [];

% padTotal = ceil(p.trialTime/p.fSample);
% padPre = ceil((padTotal*p.fSample-p.trialTime)/2);
% padPost = floor((padTotal*p.fSample-p.trialTime)/2);
% toiPad = (p.tstart-padPre)/1000:0.01:(p.tstop+padPost)/1000;
% tPad = p.tstart-padPre:p.tstop+padPost;
% xtick = 1:80:numel(toiPad);
% ytick = 10:10:numel(foi);
% xlims = [size(toiT,1),size(toiT,2)];
% Fsample = p.fSample;
% width = 8;

% --- Model fitting settings 
freq = 2; % Hz, fixed frequency for model fit 
fitLevel = 'session'; 
% anticipatory toi 
paddingBefore = 80; % ms before T1 
toi = abs(p.tstart)+p.eventTimes(1):abs(p.tstart)+p.eventTimes(2); % preCue:T1
toi = toi(1):toi(end)-paddingBefore;
tIdx = toi+1; % time index
t = p.t(tIdx)+1; % trial relative time 
Fs = 1000; 

baselineToi = abs(p.tstart)+p.eventTimes(1)-100:abs(p.tstart)+p.eventTimes(1); 

%% --- Fit settings --- 
paramNames = {'intercept','slope','amplitude','phase'};
nVars = numel(paramNames); 

% === SETTINGS ===
fitLevel = 'session'; % 'session' 'group'
cueLevel = {'all'}; % 'cueT1','cueT2' 'all'
fitTypes = {'linear','linear2Hz'}; % 'linear2Hz' 'linear'
o_bads = 1; % if 1, uses bads, otherwise uses fmincon
randCoeffs = 1; % uses random starting coefficients from the search space, otherwise uses hardcoded intial coefs
% ================

clear mdlFit lb ub 
mdlFit.A = []; % equality contraints
mdlFit.b = []; 
mdlFit.Aeq = []; % inequality contraints
mdlFit.beq = []; 

% === Define upper and lower bounds ===

% --- Intercept ---
idx = find(contains(paramNames,'intercept')); 
lb(idx) = 0; 
ub(idx) = 1; 

% --- Slope --- 
idx = find(contains(paramNames,'slope')); 
lb(idx) = -2; 
ub(idx) = 2; % 0.001; % arbitrarily large, for the scaling? 

% --- Amplitude --- 
idx = find(contains(paramNames,'amplitude')); 
lb(idx) = 0; 
ub(idx) = 1; 

% --- Phase shift ---
idx = find(contains(paramNames,'phase')); 
lb(idx) = 0; 
ub(idx) = 2*pi; % 500 
if o_bads
    optionsBads = bads('defaults');
    optionsBads.PeriodicVars = idx;
    lb(idx) = -pi; 
    ub(idx) = pi;
end

mdlFit.lb = lb; 
mdlFit.ub = ub; 

mdlFit.hardlb = mdlFit.lb;
mdlFit.hardub = mdlFit.ub;

% --- Nonlinear constraints --- 
nonlcon = []; 

% --- Options --- 
% options = optimoptions('fmincon','Display','iter'); 

%% Calculate ITPC from split training testing data
phaseAngle = squeeze(groupA(sessionIdx).all.phaseAngle); % trials (384) x ch (5) x time (7001) 
itpc = groupA(sessionIdx).all.ITPCMean(tIdx); 
nTrials = size(phaseAngle,1);
nChannels = size(phaseAngle,2); 

for iPerm = 1:nPermCV % permute splits for cross validation
    fprintf('Cross validation split %d of %d...',iPerm,nPermCV);

    % Split half by time 
    idxTraining = 1:floor(numel(tIdx)/2); % skips one time step 486 
    idxTesting = ceil(numel(tIdx)/2)+1:numel(tIdx); 
    
    % Calculate R2 of training and testing splits
    y1 = itpc(idxTraining)'; 
    y2 = itpc(idxTesting)'; 
    [rsq rsq2] = calculateRSQ(y1,y2,1);
    [rsq_uncorr rsq_uncorr2] = calculateRSQ(y1,y2,0);

    %% --- Define initial search array ---
    nGrain = 100;
    clear x0s
    x0s = NaN([nVars,nGrain]);
    paramNames = {'intercept','slope','amplitude','phase'};
    for iStart = 1:nVars
        x0s(iStart ,:) = linspace(mdlFit.lb(iStart),mdlFit.ub(iStart),nGrain); % initial coefficients for search
    end

    %% Both model fits (linear, linear+2Hz)
    clear x0 x0Perm
    for iC = 1:numel(cueLevel)
        clear dataFit dataTest
        dataFit = y1;
        dataTest = y2;

        for iF = 1:numel(fitTypes)
            for iP = 1:nPerms % iP is optimization permutation start grid
                if ~cluster
                    fprintf('Fitting %s, permutation %d of %d...',sessionDir,iP,nPerms);
                end
                % --- Randomly pick starting coefficients from search grid ---
                for iV = 1:nVars
                    vals = randperm(nGrain);
                    idx(iV) = vals(1);
                    x0(iV) = x0s(iV,idx(iV));
                end

                switch fitTypes{iF}
                    case 'linear2Hz'
                        if ~cluster
                            disp('Fitting linear + 2Hz ...')
                        end
                        paramNames = {'intercept','slope','amplitude','phase'};
                        % --- Define objective function ---
                        clear fun
                        fun = @(x)meg_objectiveFunction1(x,dataFit,idxTraining,Fs,paramNames,fitTypes{iF},freq);
                        % --- Do fit ---
                        if o_bads
                            [solution,fval,exitflag,output] = bads(fun, x0, mdlFit.hardlb, mdlFit.hardub, mdlFit.lb, mdlFit.ub,[],optionsBads);
                        else
                            [solution,fval,exitflag,output] = fmincon(fun, x0, mdlFit.A, mdlFit.b, mdlFit.Aeq, mdlFit.beq, mdlFit.lb, mdlFit.ub);
                        end
                    case 'linear'
                        if ~cluster
                            disp('Fitting linear ...')
                        end
                        x0L = x0(1:2);
                        paramNames = {'intercept','slope'};
                        % --- Define objective function ---
                        clear fun
                        fun = @(x)meg_objectiveFunction1(x,dataFit,idxTraining,Fs,paramNames,fitTypes{iF});
                        idx = 1:numel(paramNames);
                        % --- Do fit ---
                        if o_bads
                            [solution,fval,exitflag,output] = bads(fun, x0L, [], [], mdlFit.lb(1:2), mdlFit.ub(1:2));
                        else
                            [solution,fval,exitflag,output] = fmincon(fun, x0L, mdlFit.A, mdlFit.b, mdlFit.Aeq, mdlFit.beq, mdlFit.lb(idx), mdlFit.ub(idx));
                        end
                end
                % --- Save parameter names ---
                % mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).paramNames = paramNames;
                % -- Save fixed freq ---
                % mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).fixedFreq = freq; % hz
                % --- Save fitted parameters ---
                mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).solution(iP,:) = solution;
                % --- Save error ---
                mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).fval(iP) = fval;
                % --- Calculate r squared --- 
                clear E yhat rsq
                [E,yhat] = meg_objectiveFunction1(solution,dataTest,idxTesting,Fs,paramNames,fitTypes{iF});

                rsq = calculateRSQ(dataTest,yhat,1);
                mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).rsq(iP) = rsq;
                % --- Save predicted y ---
                % mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).yhat(iP,iS,:) = yhat;
                % -- Save data ---
                mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).dataFit = dataFit;
                mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).dataTest = dataTest;
            end % end the search permutation

            % --- Find permutation with minimum fval --- 
            [minVal,idx] = min(  mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).fval(:)  );
            fittedX = squeeze(mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).solution(idx,:));
            % --- Save min fitted params per permutation of starting coefficients
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minSolution = fittedX;
            % --- Calculate R^2 ---
            %of fitted model on the test data
            switch fitTypes{iF}
                case 'linear2Hz' 
                    paramNames = {'intercept','slope','amplitude','phase'};
                case 'linear'
                    paramNames = {'intercept','slope'};
            end
            % --- Save yhat --- 
            [E,yhat] = meg_objectiveFunction1(fittedX,dataFit,idxTraining,Fs,paramNames,fitTypes{iF},freq);
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).yhat = yhat;
            % --- Save R^2 ---
            [rsq rsq2 y_fit_meanCorrected] = calculateRSQ(dataTest,yhat,1);
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minRsq = rsq;
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minRsq2 = rsq2;
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).y_fit_meanCorrected = y_fit_meanCorrected;
            [rsq_uncorr rsq2_uncorr] = calculateRSQ(dataTest,yhat,0);
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minRsq_uncorr = rsq_uncorr;
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minRsq2_uncorr = rsq2_uncorr;
            % rsq = calculateRSQ(dataFit,yhat,1);
            % txt = sprintf('Rsq = %0.2f...',rsq);
            % disp(txt)
            
            %% Check fit on test partition --> R^2
            % clear rsq
            % rsq = calculateRSQ(dataTest,yhat,1);

            %% Save all
            A4.(fitTypes{iF}).(cueLevel{iC}).rsq(iPerm) = rsq;
            A4.(fitTypes{iF}).(cueLevel{iC}).rsq_uncorr(iPerm) = rsq_uncorr;
        end
    end
    %% Save analyses into temp file 
    newTempFile = sprintf('%s/%s_temporalCrossValidation_perms%d.mat',analDir,sessionDir,iPerm);
    save(newTempFile,'mdlFit','A4','-v7.3')
    if iPerm>1
        tempFile = sprintf('%s/%s_crossValidation_perms%d.mat',analDir,sessionDir,iPerm-1);
        delete(tempFile)
    end
end % end CV splits 

%% Plot histogram
figure
set(gcf,'Position',[100 100 400 370])
sgtitle(und2space(sessionDir))

edges = -1:0.1:1; 
subplot 121
hold on
meg_figureStyle
histogram(A4.linear.all.rsq,edges)
histogram(A4.linear2Hz.all.rsq,edges)
xlabel('R squared')
ylabel('Count')
l = legend('Linear','Linear + 2Hz');
l.FontSize = 9;

subplot 122
hold on
meg_figureStyle
bar(1,mean(A4.linear.all.rsq),'FaceColor',[0 0.4470 0.7410])
errorbar(1,mean(A4.linear.all.rsq), std(A4.linear.all.rsq)/sqrt(20),'CapSize',0,'Color','k','LineWidth',1.5)
bar(2,mean(A4.linear2Hz.all.rsq),'FaceColor',[0.8500 0.3250 0.0980])
errorbar(2,mean(A4.linear2Hz.all.rsq), std(A4.linear2Hz.all.rsq)/sqrt(20),'CapSize',0,'Color','k','LineWidth',1.5)
xlim([0 3])
xticks([1 2])
xticklabels({'Linear','Linear + 2Hz'})
ylabel('R squared')

% --- Save fig ---
figTitle = sprintf('%s_TANoise_TemporalCrossValidation',sessionDir);
saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))


%% Save A4
save(filename,'mdlFit','A4','-v7.3')
fprintf('Saved! %s', sessionDir)





