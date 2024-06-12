function meg_manuscriptFigs_TE_byPrecue_mdlFit_2Hz_pies
% function meg_manuscriptFigs_TE_byPrecue_mdlFit_2Hz_pies.m
% 2 Hz phase by attention, in fittedP structure 

%% Load data
user = 'kantian'; 
% Model fit data 
filename = sprintf('/Users/%s/Dropbox/github/ta-meg-analysis-model/model_anticipatory/ITPCfit_separate1_2Hz/231213/ModelFit_SeparatePrecueT1T2_2Hz_231213.mat',user);
% ITPC data 
load(filename)

%% Saves svgs of the pies to model folder 
mdlFitType = 'separate'; 
[group,fittedP,stats] = meg_plotPhaseHistogram(mdlFit,paramNames,figDir,mdlFitType); 

%% Check difference (rad) between precues 
val = stats.subjects.valR_avgThenDiff; 

% kappa is concentration value 
 
%% Cross correlation of ITPC TS across sessions (240524) 
figure
set(gcf,'Position',[100 100 500 800])
count = 1; 
field = 'cueT1'; 
for i = 1:2:20
    s1 = A.(field).normSession(20,2001:2001+970,i);
    s2 = A.(field).normSession(20,2001:2001+970,i+1);
    [r,lags] = xcorr(s1,s1); 
    rho(:,:,count) = corrcoef(s1,s2);

    fh = subplot(10,2,i);
    % meg_figureStyle
    hold on 
    plot(s1)
    plot(s2)
    
    txt = kt_annotateStats(50,max(fh.YLim),sprintf('r = %0.2f',rho(1,2,count)));

    subplot(10,2,i+1)
    meg_figureStyle
    stem(lags,r)

    count = count+1; 
end

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_Phase_SessionConsistency_TS_%s',...
        mdlFitType,field);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end


%% Check phase consistency across all trials 
% Model fit data 
filename = sprintf('/Users/%s/Dropbox/github/ta-meg-analysis-model/model_anticipatory/ITPCfit_separate1_2Hz/231213/ModelFit_SeparatePrecueT1T2_2Hz_231213.mat',user);
% ITPC data 
load(filename)

%% Make a null distribution of the group session to session phase consistency (Precue T1) 
% Get kappa from that null 
val = circ_dist(fittedP.linear2Hz.valR1_min(:,1),fittedP.linear2Hz.valR1_min(:,2)); % difference in fitted phase between sessions 1 and 2 
kappa = circ_kappa(val);

s1 = fittedP.linear2Hz.valR1_min(:,1); 
s2 = fittedP.linear2Hz.valR1_min(:,2); 
allPhases_cueT1 = [s1;s2]; 

%% Bootstrap differences? (Precue T1 only) 
nBoots = 1000; 
nSample = 10;
clear val_boot val_boot_diff boot_diffs
for iBoot = 1:nBoots
    for iS = 1:nSample
        idx = randperm(20,2);
        val_boot(iBoot,iS,1) = allPhases_cueT1(idx(1)); 
        val_boot(iBoot,iS,2) = allPhases_cueT1(idx(2)); 
        val_boot_diff(iBoot,iS) = circ_dist(val_boot(iBoot,iS,1),val_boot(iBoot,iS,2)); 
    end
end
boot_diffs = mean(val_boot_diff,2,'omitnan'); % average across subjects per bootstrapped sample
for iBoot = 1:nBoots
    boot_kappa(iBoot) = circ_kappa(boot_diffs(iBoot));
end

figure
set(gcf,'Position',[100 100 240 190])
edges = 0:pi/96:2*pi;
polarhistogram(boot_kappa,edges,'FaceColor',p.cueColors(1,:),'EdgeColor',p.cueColors(1,:),'FaceAlpha',1); % fitted phase histogram
hold on 
val = circ_dist(fittedP.linear2Hz.valR1_min(:,1),fittedP.linear2Hz.valR1_min(:,2)); 
kappa = circ_kappa(val);
r = circ_r(val); % mean 
r = 10; 
polarplot([kappa kappa],[0 r],'Color',p.darkColors(1,:),'LineWidth',2)

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_PhaseDifferenceByPrecue_BootstrappedKappa',...
        mdlFitType,field);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end


%% Bootstrap differences? (Precue T1 only) 
nBoots = 1000; 
nSample = 10;
clear val_boot val_boot_diff boot_diffs
for iBoot = 1:nBoots
    for iS = 1:nSample
        idx = randperm(20,2);
        val_boot(iBoot,iS,1) = allPhases_cueT1(idx(1)); 
        val_boot(iBoot,iS,2) = allPhases_cueT1(idx(2)); 
        val_boot_diff(iBoot,iS) = circ_dist(val_boot(iBoot,iS,1),val_boot(iBoot,iS,2)); 
    end
end
boot_diffs = mean(val_boot_diff,2,'omitnan'); % average across subjects per bootstrapped sample
for iBoot = 1:nBoots
    boot_kappa(iBoot) = circ_kappa(boot_diffs(iBoot));
end

figure
set(gcf,'Position',[100 100 240 190])
edges = 0:pi/96:2*pi;
polarhistogram(boot_diffs,edges,'FaceColor',p.cueColors(1,:),'EdgeColor',p.cueColors(1,:),'FaceAlpha',1); % fitted phase histogram
hold on 
val = circ_dist(fittedP.linear2Hz.valR1_min(:,1),fittedP.linear2Hz.valR1_min(:,2)); 
kappa = circ_kappa(val);
r = circ_r(val); % mean 
r = 10; 
polarplot([kappa kappa],[0 r],'Color',p.darkColors(1,:),'LineWidth',2)

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_PhaseDifferenceByPrecue_BootstrappedKappa',...
        mdlFitType,field);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end

%% Session 1 PrecueT1-PrecueT2 Phase
figure
set(gcf,'Position',[100 100 240 190])

edges = 0:pi/24:2*pi;
session = 2; 

% --- Plot precue T1 - precue T2 phase session 1 - 2 ---
val = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); % difference in fitted phase between sessions 1 and 2 
polarhistogram(val,edges,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.7); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([mu mu],[0 r],'Color','k','LineWidth',2)
radius = 2;
th = ll:0.01:ul;
kappa = circ_kappa(val);
polarplot(th,radius+zeros(size(th)),'Color',p.darkColors(1,:),'LineWidth',2)
pax = gca;
pax.ThetaAxisUnits = 'radians';

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_PhaseDifferenceByPrecue_Session%d',...
        mdlFitType,field,session);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end

%% Watson's U test comparing two independent samples of circular data 
session = 1; 
s1 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 
session = 2; 
s2 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 
[pval table] = circ_wwtest(s1,s2);

% Circular correlation between s1 and s2 difference? 

%% Difference between the two sessions
figure
set(gcf,'Position',[100 100 240 190])

edges = 0:pi/24:2*pi;
session = 2; 

% --- Plot precue T1 - precue T2 phase session 1 - 2 ---
val = circ_dist(s1,s2); % difference in fitted phase between sessions 1 and 2 
polarhistogram(val,edges,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.7); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([mu mu],[0 r],'Color','k','LineWidth',2)
radius = 2;
th = ll:0.01:ul;
kappa = circ_kappa(val);
polarplot(th,radius+zeros(size(th)),'Color',p.darkColors(1,:),'LineWidth',2)
pax = gca;
pax.ThetaAxisUnits = 'radians';

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_PhaseDifferenceByPrecue_Session%d',...
        mdlFitType,field,session);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end

%% Circular correlations (s1 v s2) 
% Precue T1 - Precue T2 
session = 1; 
s1 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 
session = 2; 
s2 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 

[rho pval] = circ_corrcc(s1, s2);

%% Circular correlations (s1 v s2) 
% Precue T1 only 
session = 1; 
s1 = fittedP.linear2Hz.valR1_min(:,session); 
session = 2; 
s2 = fittedP.linear2Hz.valR1_min(:,session); 

[rho pval] = circ_corrcc(s1, s2);

%% Circular correlations (s1 v s2) 
% Precue T2 only 
session = 1; 
s1 = fittedP.linear2Hz.valR2_min(:,session); 
session = 2; 
s2 = fittedP.linear2Hz.valR2_min(:,session); 

[rho pval] = circ_corrcc(s1, s2);

%% Time series by precue for S1 and S2
s1Idx = 1:2:20; 
s2Idx = 2:2:20; 
t = -2000:5000; 
tIdx = 2000:2000+970; 

figure
meg_figureStyle
hold on 
% S1 
y = mean(squeeze(A.cueT1.session(20,tIdx,s1Idx)),2,'omitnan'); 
plot(t(tIdx),y,'Color',p.cueColors(1,:),'LineStyle','--','LineWidth',2)
y = mean(squeeze(A.cueT2.session(20,tIdx,s1Idx)),2,'omitnan'); 
plot(t(tIdx),y,'Color',p.cueColors(2,:),'LineStyle','--','LineWidth',2)
% S2
y = mean(squeeze(A.cueT1.session(20,tIdx,s2Idx)),2,'omitnan'); 
plot(t(tIdx),y,'Color',p.cueColors(1,:),'LineWidth',2)
y = mean(squeeze(A.cueT2.session(20,tIdx,s2Idx)),2,'omitnan'); 
plot(t(tIdx),y,'Color',p.cueColors(2,:),'LineWidth',2)
xlabel('Time (ms)')
ylabel('ITPC')

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_TS_Session%d',...
        mdlFitType,field,session);
    saveas(gcf,sprintf('%s/%s.png', figDir, figTitle))
end

%% Precue T1 Phase - Precue T2 Phase for S1 v S2
session = 1; 
s1 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 
session = 2; 
s2 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 

stats.s1 = circ_stats(s1);
stats.s2 = circ_stats(s2); 

%% Mean phase ±1 SEM S1 v S2 
figure
set(gcf,'Position',[100 100 240 190])

edges = 0:pi/24:2*pi;

linewidth = 2.4; 

% --- Plot precue T1 - precue T2 phase session 1  ---
val = s1; 
polarhistogram(val,edges,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([stats.s1.mean stats.s1.mean],[0 r],'Color','k','LineWidth',linewidth)
polarplot([stats.s1.median stats.s1.median],[0 r],'Color','k','LineWidth',linewidth,'LineStyle',':')
radius = 1;
sem = stats.s1.std0/sqrt(10);
th = mu-sem:0.01:mu+sem;
kappa = circ_kappa(val);
polarplot(th,radius+zeros(size(th)),'Color','k','LineWidth',linewidth)
pax = gca;
pax.ThetaAxisUnits = 'radians';


% --- Plot precue T1 - precue T2 phase session 2  ---
val = s2; 
polarhistogram(val,edges,'FaceColor',p.cueColors(7,:),'EdgeColor',p.cueColors(7,:),'FaceAlpha',0.3); % fitted phase histogram
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([stats.s2.mean stats.s2.mean],[0 r],'Color',p.cueColors(7,:),'LineWidth',linewidth)
polarplot([stats.s2.median stats.s2.median],[0 r],'Color',p.cueColors(7,:),'LineWidth',linewidth,'LineStyle',':')
radius = 0.95;
sem = stats.s2.std0/sqrt(10);
th = mu-sem:0.01:mu+sem;
kappa = circ_kappa(val);
polarplot(th,radius+zeros(size(th)),'Color',p.cueColors(7,:),'LineWidth',linewidth)
pax = gca;
% pax.ThetaAxisUnits = 'radians';

pax.FontSize = 16;
pax.FontName = 'Helvetica-Light';
rticks([1,2])
rlim([0 1])
pax.ThetaAxisUnits = 'degrees'; 
thetaticks(0:360/8:360)

if saveFigs
    figTitle = sprintf('TANoise_ITPCFit_DataPrecue_%s_Linear2Hz_sessionDifference_mean±SEM',...
        mdlFitType);
    saveas(gcf,sprintf('%s/%s.svg', figDir, figTitle))
end


