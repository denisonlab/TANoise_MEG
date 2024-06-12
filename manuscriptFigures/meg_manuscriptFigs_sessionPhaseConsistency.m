function meg_manuscriptFigs_sessionPhaseConsistency

% Polar plot of the fitted phase difference by precue
% Session 1 v Session 2
% Mean phase difference ± 1 SEM 
% 
% thetaregion requires Matlab R2024a or above 

%% Load data
user = 'kantian'; 
% Model fit data 
filename = sprintf('/Users/%s/Dropbox/github/ta-meg-analysis-model/model_anticipatory/ITPCfit_separate1_2Hz/231213/ModelFit_SeparatePrecueT1T2_2Hz_231213.mat',user);
% ITPC data 
load(filename)

%% Figure settings
showN = 0; % show n = X annotation 
figFormat = 'svg'; % svg 
plotSubjects = 0; % plots subject histogram if on 
saveFigs = 1; 

edges = 0:pi/24:2*pi;
linewidth = 2.4; 

[style, colors] = meg_manuscriptStyle; 

% Figure directory 
dateStr = datetime('now','TimeZone','local','Format','yyMMdd');
figDir = sprintf('/Users/%s/Dropbox/github/ta-meg-analysis2/manuscriptFigures/figs',user); 
if ~exist(figDir, 'dir')
    mkdir(figDir)
end

%% Precue T1 Phase - Precue T2 Phase for S1 v S2
session = 1; 
s1 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 
session = 2; 
s2 = circ_dist(fittedP.linear2Hz.valR1_min(:,session),fittedP.linear2Hz.valR2_min(:,session)); 

stats.s1 = circ_stats(s1);
stats.s2 = circ_stats(s2); 

% Parametric Watson-Williams multi-tsample test for equal means 
[stats.sDiff.pval stats.sDiff.table] = circ_wwtest(s1,s2);

% Kuiper two-sample test for significant differences in mean, location,
% dsipersion
[stats.sDiffKuiper.pval stats.sDiffKuiper.k stats.sDiffKuiper.K] = circ_kuipertest(s1,s2);

s1dummy = rand(1,10)+1;
s2dummy = rand(1,10)+0;
[testp testk testK] = circ_kuipertest(s1dummy,s2dummy);

% Circular correlation coefficient for two circular random variables 
% [rho pval] = circ_corrcc(s1,s2); 

% Watson's U test on difference? 
sDiff = circ_dist(s1,s2);
[pval z] = circ_rtest(sDiff); 

% circ v test 
[pval v] = circ_mtest(sDiff,0); 

% circ v test 
[pval v] = circ_vtest(sDiff,0); 

% circ h test Hotelling paired sample ttest 
[pval F] = circ_htest(s1,s2); 

%% Mean phase ±1 SEM S1 v S2 
figure
set(gcf,'Position',[100 100 240 190])

% --- Plot precue T1 - precue T2 phase differnce - session 1  ---
val = s1; 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([stats.s1.mean stats.s1.mean],[0 r],'Color','k','LineWidth',linewidth)
hold on 
radius = 1;
sem = stats.s1.std0/sqrt(10);
th = mu-sem:0.01:mu+sem;
kappa = circ_kappa(val);
% shaded wedge (mean ± 1 SEM)
polarplot(th,radius+zeros(size(th)),'Color','k','LineWidth',linewidth)
polarregion([th(1),th(end)],[0 radius],'FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.5)

if plotSubjects
    polarhistogram(val,edges,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5); % fitted phase histogram
end

% --- Plot precue T1 - precue T2 phase difference - session 2  ---
val = s2; 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); % mean 
polarplot([stats.s2.mean stats.s2.mean],[0 r],'Color',p.cueColors(7,:),'LineWidth',linewidth)
radius = 0.95;
sem = stats.s2.std0/sqrt(10);
th = mu-sem:0.01:mu+sem;
kappa = circ_kappa(val);
polarplot(th,radius+zeros(size(th)),'Color',p.cueColors(7,:),'LineWidth',linewidth)
polarregion([th(1),th(end)],[0 radius],'FaceColor',p.cueColors(7,:),'FaceAlpha',0.3)

if plotSubjects
    polarhistogram(val,edges,'FaceColor',p.cueColors(7,:),'EdgeColor',p.cueColors(7,:),'FaceAlpha',0.3); % fitted phase histogram
end

pax = gca;
pax.FontSize = 16;
pax.FontName = 'Helvetica-Light';
rticks([1,2])
rlim([0 1])
pax.ThetaAxisUnits = 'degrees'; 
thetaticks(0:360/8:360)

if saveFigs
    figTitle = sprintf('meg_manuscriptFigs_sessionPhaseConsistency_%s',...
        dateStr);
    saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
end

