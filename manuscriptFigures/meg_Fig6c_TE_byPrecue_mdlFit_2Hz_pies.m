function meg_Fig6c_TE_byPrecue_mdlFit_2Hz_pies
% function meg_Fig6c_TE_byPrecue_mdlFit_2Hz_pies.m
% 2 Hz phase by attention, in fittedP structure 

%% Load data
% Model fit data 
filename = 'ModelFit_SeparatePrecueT1T2_2Hz_session.mat';
load(filename)

% Figure directory
[figDir,dateStr,style,colors,p] = meg_manuscriptParams; 
saveFigs = 1; 

%% Saves svgs of the pies to model folder 
% mdlFitType = 'separate'; 
% [group,fittedP,stats] = meg_plotPhaseHistogram(mdlFit,paramNames,figDir,mdlFitType); 
% 
% save('figData/ModelFit_SeparatePrecueT1T2_2Hz_session_fittedP.mat','group','fittedP','stats')

% Load fitted parameters
filename = 'figData/ModelFit_SeparatePrecueT1T2_2Hz_session_fittedP.mat';
load(filename)

edges = 0:pi/24:2*pi;

%% Check difference (rad) between precues
% kappa is concentration value
val = stats.subjects.valR_avgThenDiff; 

%% Plot precue T1 phase distribution 95% CI
figure
set(gcf,'Position',[100 100 240 190])

% --- Plot precue T1 ---
val = circ_mean(fittedP.linear2Hz.valR1_min,[],2); % average sessions  
polarhistogram(val,edges,'FaceColor',p.cueColors(1,:),'EdgeColor',p.cueColors(1,:),'FaceAlpha',1); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); 
polarplot([mu mu],[0 r],'Color',p.darkColors(1,:),'LineWidth',2)
radius = 2;
th = ll:0.01:ul;
polarplot(th,radius+zeros(size(th)),'Color',p.darkColors(1,:),'LineWidth',2)
pax = gca;
pax.ThetaAxisUnits = 'radians';

% --- Plot precue T2 ---
val = circ_mean(fittedP.linear2Hz.valR2_min,[],2); % average sessions  
polarhistogram(val,edges,'FaceColor',p.cueColors(2,:),'EdgeColor',p.cueColors(2,:),'FaceAlpha',1); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); 
polarplot([mu mu],[0 r],'Color',p.darkColors(2,:),'LineWidth',2) 
th = ll:0.01:ul;
polarplot(th,radius+zeros(size(th)),'Color',p.darkColors(2,:),'LineWidth',2)
pax = gca;

pax.FontSize = 16;
pax.FontName = 'Helvetica-Light';
rticks([1,2])
rlim([0 2])
pax.ThetaAxisUnits = 'degrees'; 
thetaticks(0:360/8:360)

if saveFigs
    figTitle = 'Fig6c_2HzPhasePrecueT1_pie';
    saveas(gcf,sprintf('%s/%s.svg', figDir, figTitle))
end

%% Plot precue T1 and precue T2 DIFFERENCE phase distribution 95% CI
figure
set(gcf,'Position',[100 100 240 190])

% --- Plot precue T1 - precue T2 ---
val = fittedP.linear2Hz.valR_avgThenDiff; % average sessions  
polarhistogram(val,edges,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.7); % fitted phase histogram
hold on 
[mu ul ll] = circ_mean(val); 
r = circ_r(val); 
polarplot([mu mu],[0 r],'Color','k','LineWidth',2)
radius = 2;
th = ll:0.01:ul;
polarplot(th,radius+zeros(size(th)),'Color','k','LineWidth',2)
pax = gca;

pax.ThetaAxisUnits = 'radians'; % 'radians'
pax.FontSize = 16;
pax.FontName = 'Helvetica-Light';
rticks([1,2])
rlim([0 2])
pax.ThetaAxisUnits = 'degrees'; 
thetaticks(0:360/8:360)

if saveFigs
    figTitle = 'Fig6c_2HzPhaseDifferenceBetweenPrecues_pie';
    saveas(gcf,sprintf('%s/%s.svg', figDir, figTitle))
end





