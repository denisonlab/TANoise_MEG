function meg_Fig4b_TE_allTrials_mdlFit_slope_bar
% meg_Fig4b_allTrials_mdlFit_slope_bar
% Plot linear model slope (All trials) 

%% Load data 
filename = 'figData/ModelFit_SeparatePrecueT1T2_2Hz_session.mat'; 
load(filename)

%% Figure settings 
titleVis = 0; % if title vis off, then will plot for appropriate manuscript size 
showN = 1; % show n = X annotation 
figFormat = 'svg'; % svg 
plotSubjects = 0; 
annotateMean = 0; 
annotateStats = 1; 
saveFigs = 1; 
cueLevel = {'all'}; 
plotStyle = 'scatter'; % bar or scatter 

% Figure directory
[figDir,dateStr,style,colors,p] = meg_manuscriptParams; 

%% Find solution w minimum fval 
for iF = 1 % only linear model 
    for iS = 1:size(mdlFit.linear.all.session.solution,2) % sessions
        for iC = 1:numel(cueLevel)
            % --- Plot model fit ---
            [minVal,idx] = min(  mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).fval(:,iS)  );
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minSolution(iS,:) = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).solution(idx,iS,:);
        end
    end
end

%% Plot bar of fitted slope (linear only model) 
figure
fh = subplot(1,1,1); 
hold on
meg_figureStyle
set(gcf,'Position',[100 100 130 style.height])
iF = 1; % linear model 
for iC = 1:numel(cueLevel)
    clear x y idx paramNames
    paramNames = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).paramNames;
    paramOI = 'slope';
    idx = find(contains(paramNames,paramOI));
    y = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minSolution(:,idx); % sessions
    y = meg_sessions2subjects(y'); % subjects
    x = iC;
    % standard error of mean
    err = std(y)/sqrt(numel(y));

    [faceColor,erColor,sColor] = meg_manuscriptStyleCue(cueLevel{iC});

    switch plotStyle
        case 'bar'
            pBar = bar(x,mean(y,'omitnan'));
            pBar.BarWidth = 0.85;
            er = errorbar(x,mean(y,'omitnan'),err,err);
            er.LineWidth = 2;
            er.CapSize = 0;
            er.LineStyle = 'none';
            er.Color = erColor;
            pBar.FaceColor = faceColor;
            pBar.EdgeColor = pBar.FaceColor;      
        case 'scatter'
            e = errorbar(x,mean(y,'omitnan'),err,'Marker','.','MarkerSize',style.scatter.MarkerSize,'MarkerFaceColor',faceColor,'MarkerEdgeColor',faceColor,...
        'Color',faceColor,'LineWidth',2);
            e.CapSize = style.scatter.errCapSizeS;  
    end

    % Plot subjects scatter points
    if plotSubjects
        scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor','w','MarkerFaceAlpha',1)
        scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor',sColor,'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
        yline(0,'color',colors.mediumgrey)
    else
        ylim([0 0.1])
    end

    % Mean annotation
    if annotateMean 
        lbl = sprintf('%0.2f',mean(y,'omitnan'));
        txt = text(x, 0, lbl, 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
        txt.Color = [1 1 1];
        txt.FontSize = style.txtSize_Annotation;
        txt.FontName = 'Helvetica-Oblique';
    end
end

% Axes labels
ylabel(sprintf('Slope (\\Delta ITPC/s)'))

xlabel('Precue') % need to retain sizing?
xticks([1])
xticklabels({'All'})
xlim([1-style.xBuffer/1.5 1+style.xBuffer/1.5])

% Stats annotation
if annotateStats
    txt = meg_annotateStats(1,max(fh.YLim)*0.97,'**'); 
end

if saveFigs
    if plotSubjects
        figTitle = sprintf('Fig4b_TE_allTrials_mdlFit_slope_bar_subjects');
    else
        figTitle = sprintf('Fig4b_TE_allTrials_mdlFit_slope_bar');
    end
    saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
end

%% ttest
% Average to subjects
for iV = 1:2
    mdlFit.linear.all.session.minSolutionSubjects(:,iV) = meg_sessions2subjects(mdlFit.linear.all.session.minSolution(:,iV)'); 
end

[test.h test.p test.ci test.stats] = ttest(mdlFit.linear.all.session.minSolutionSubjects(:,2));

