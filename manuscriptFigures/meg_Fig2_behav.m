% TANoise manuscript figs
% scatterplots 
% Behav and slope

%% Setup 
% Read data 
dataFile = 'figData/Fig_Behav.xlsx';
T = readtable(dataFile); % subject level data 

% Figure settings 
xJitter = 0.2;
saveFigs = 1; 
subjectColor = [0.86 0.86 0.86]; 

dateStr = datetime('now','TimeZone','local','Format','yyMMdd');
figDir = sprintf('figs'); 
if ~exist(figDir, 'dir')
    mkdir(figDir)
end

p = meg_params('TANoise_ITPCsession8');
[sessionNames,subjectNames,ITPCsubject,ITPCsession] = meg_sessions('TANoise'); 
capSize = 12; % errorbar cap size 
sSize = 30; % 20 subject scatter dot size 
gSize = 40; % group average scatter dot size 

%% Set variables
variableNames = string(T.Properties.VariableNames); 
idx = find(variableNames == "subject");
subject = T(:,idx); 

%% Behav: dprime 
dprime.T1.cueT1 = table2array(T(:,variableNames == "dprime_T1_C1")); 
dprime.T1.cueT2 = table2array(T(:,variableNames == "dprime_T1_C2")); 
dprime.T2.cueT1 = table2array(T(:,variableNames == "dprime_T2_C1")); 
dprime.T2.cueT2 = table2array(T(:,variableNames == "dprime_T2_C2")); 

% dprime figure 
figure
hold on 
set(gcf,'Position',[100 100 250 400])
meg_figureStyle
% Subject lines
for i = 1:numel(subjectNames)
    s = plot([1-xJitter 1+xJitter],[dprime.T1.cueT1 dprime.T1.cueT2],'Color',subjectColor); 
end
% T1 
% valid 
x = repmat(1-xJitter,[10,1]); 
e = errorbar(x(1),mean(dprime.T1.cueT1),std(dprime.T1.cueT1)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(7,:),'MarkerEdgeColor',p.cueColors(7,:),...
    'Color',p.cueColors(7,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,dprime.T1.cueT1,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,dprime.T1.cueT1,sSize,'filled','MarkerFaceColor',p.cueColors(7,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% invalid 
x = repmat(1+xJitter,[10,1]); 
e = errorbar(x(1),mean(dprime.T1.cueT2),std(dprime.T1.cueT2)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(8,:),'MarkerEdgeColor',p.cueColors(8,:),...
    'Color',p.cueColors(8,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,dprime.T1.cueT2,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,dprime.T1.cueT2,sSize,'filled','MarkerFaceColor',p.cueColors(8,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% T2
% Subject lines
for i = 1:numel(subjectNames)
    s = plot([2-xJitter 2+xJitter],[dprime.T2.cueT2 dprime.T2.cueT1],'Color',subjectColor); 
end
% valid 
x = repmat(2-xJitter,[10,1]); 
e = errorbar(x(1),mean(dprime.T2.cueT2),std(dprime.T2.cueT2)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(7,:),'MarkerEdgeColor',p.cueColors(7,:),...
    'Color',p.cueColors(7,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,dprime.T2.cueT2,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,dprime.T2.cueT2,sSize,'filled','MarkerFaceColor',p.cueColors(7,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% invalid 
x = repmat(2+xJitter,[10,1]); 
e = errorbar(x(1),mean(dprime.T2.cueT1),std(dprime.T2.cueT1)/sqrt(10),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(8,:),'MarkerEdgeColor',p.cueColors(8,:),...
    'Color',p.cueColors(8,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,dprime.T2.cueT1,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,dprime.T2.cueT1,sSize,'filled','MarkerFaceColor',p.cueColors(8,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
xlim([0 3])
ylabel('Sensitivity (d'')') 
xticks([1 2])
xticklabels({'T1','T2'})

if saveFigs
    figTitle = 'Fig2_Behav_dPrime';
    saveas(gcf,sprintf('%s/%s.svg', figDir, figTitle))
end

%% Behav: rt
rt.T1.cueT1 = table2array(T(:,variableNames == "rt_T1_C1"));
rt.T1.cueT2 = table2array(T(:,variableNames == "rt_T1_C2")); 
rt.T2.cueT1 = table2array(T(:,variableNames == "rt_T2_C1")); 
rt.T2.cueT2 = table2array(T(:,variableNames == "rt_T2_C2")); 

% rt figure 
figure
hold on 
set(gcf,'Position',[100 100 250 400])
meg_figureStyle
% T1 
% Subject lines
for i = 1:numel(subjectNames)
    s = plot([1-xJitter 1+xJitter],[rt.T1.cueT1 rt.T1.cueT2],'Color',subjectColor); 
end
% valid 
x = repmat(1-xJitter,[10,1]); 
e = errorbar(x(1),mean(rt.T1.cueT1),std(rt.T1.cueT1)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(7,:),'MarkerEdgeColor',p.cueColors(7,:),...
    'Color',p.cueColors(7,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,rt.T1.cueT1,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,rt.T1.cueT1,sSize,'filled','MarkerFaceColor',p.cueColors(7,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% invalid 
x = repmat(1+xJitter,[10,1]); 
e = errorbar(x(1),mean(rt.T1.cueT2),std(rt.T1.cueT2)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(8,:),'MarkerEdgeColor',p.cueColors(8,:),...
    'Color',p.cueColors(8,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,rt.T1.cueT2,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,rt.T1.cueT2,sSize,'filled','MarkerFaceColor',p.cueColors(8,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% T2
for i = 1:numel(subjectNames)
    s = plot([2-xJitter 2+xJitter],[rt.T2.cueT2 rt.T2.cueT1],'Color',subjectColor); 
end
% valid 
x = repmat(2-xJitter,[10,1]); 
e = errorbar(x(1),mean(rt.T2.cueT2),std(rt.T2.cueT2)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(7,:),'MarkerEdgeColor',p.cueColors(7,:),...
    'Color',p.cueColors(7,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,rt.T2.cueT2,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,rt.T2.cueT2,sSize,'filled','MarkerFaceColor',p.cueColors(7,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
% invalid 
x = repmat(2+xJitter,[10,1]); 
e = errorbar(x(1),mean(rt.T2.cueT1),std(rt.T2.cueT1)/sqrt(10),'Marker','.','MarkerSize',gSize,'MarkerFaceColor',p.cueColors(8,:),'MarkerEdgeColor',p.cueColors(8,:),...
    'Color',p.cueColors(8,:),'LineWidth',2);
e.CapSize = capSize; 
scatter(x,rt.T2.cueT1,sSize,'filled','MarkerFaceColor','w') % plot white first
scatter(x,rt.T2.cueT1,sSize,'filled','MarkerFaceColor',p.cueColors(8,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')

xlim([0 3])
ylabel('Reaction time (s)') 
xticks([1 2])
xticklabels({'T1','T2'})
ylim([0 1.5])

if saveFigs
    figTitle = 'Fig2_Behav_rt';
    saveas(gcf,sprintf('%s/%s.svg', figDir, figTitle))
end
