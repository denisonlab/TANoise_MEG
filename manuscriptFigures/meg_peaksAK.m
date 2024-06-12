
% Relating peak to dprime 
% Hypothesis: relative difference of ITPC peaks is the key determinant of
% behavioral effects 

%% Setup 
user = 'kantian';
p = meg_params('TANoise_ITPCsession8'); 
[sessionNames,subjectNames,ITPCsubject,ITPCsession] = meg_sessions('TANoise'); 

%% Load peak data
filename = sprintf('/Users/%s/Dropbox/Data/TANoise/fromRachel/itpcNorm_TS_Peaks_N10_20211225_workspace.mat',user); 
load(filename)

% Reorganize RD data into KT subject order 
cueLevels = {'cueT1','cueT2'}; 
targets = {'T1','T2'}; 
clear sPeaks
for iT = 1:2 % target
    for iC = 1:numel(cueLevels)
        peakDataRD = squeeze(peakDataS(iC,iT,:))';
        peakDataKT = meg_subjectNames_RD2KT(peakDataRD); 
        sPeaks.(targets{iT}).(cueLevels{iC}).peaks = peakDataKT;
    end
end

%% Load DPRIME 
% by precue 
load(sprintf('/Users/%s/Dropbox/Data/TANoise/MEG/Group/mat/behavior/groupB_byPrecue.mat',user)); 

%% Peaks 
% Precue T1 trials 
uparrow = sPeaks.T1.cueT1.peaks - sPeaks.T2.cueT1.peaks; 

% Precue T2 trials 
downarrow = sPeaks.T1.cueT2.peaks - sPeaks.T2.cueT2.peaks; 

%% Accuracy 
var = 'subjectAcc'; % subjectDprime subjectAcc
% Precue T1 trials 
pT2I = groupB.T2.cueT1.(var);  
pT1V = groupB.T1.cueT1.(var); 

% Precue T2 trials 
pT2V = groupB.T2.cueT2.(var); 
pT1I = groupB.T1.cueT2.(var); 

%% Solve system of equations 
clear A
syms a k
idx = [1,2,3,4,6,7,8,9,10];
kType = 'additive'; % 'multiplicative' 'additive'
for iS = idx
    switch kType
        case 'additive'
            eqn1 = pT2I(iS) == pT1V(iS) - a * uparrow(iS) + k; % precue T1 trials
            eqn2 = pT2V(iS) == pT1I(iS) + a * downarrow(iS) + k; % precue T2 trials
        case 'multiplicative'
            eqn1 = pT2I(iS) == k * (pT1V(iS) - a * uparrow(iS) ); % precue T1 trials
            eqn2 = pT2V(iS) == k* (pT1I(iS) + a * downarrow(iS) ); % precue T2 trials
    end
    sol = solve([eqn1, eqn2], [a, k]);
    A.a(iS) = double(sol.a);
    A.k(iS) = double(sol.k);
end

%% Plot to check 
figure
meg_figureStyle
hold on 
x = ones(size(uparrow)); 
scatter(x,uparrow,100,'filled','MarkerFaceColor',p.cueColors(1,:),'MarkerFaceAlpha',0.5)
scatter(x+1,downarrow,100,'filled','MarkerFaceColor',p.cueColors(2,:),'MarkerFaceAlpha',0.5)
for iS = 1:10
    text(x(iS),uparrow(iS),subjectNames{iS})
end
yline(0,'k')
xticks([1 2])
xlim([0 3])

%% 





