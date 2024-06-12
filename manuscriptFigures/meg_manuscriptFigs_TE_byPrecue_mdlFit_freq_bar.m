function meg_manuscriptFigs_TE_byPrecue_mdlFit_freq_bar
% function meg_manuscriptFigs_TE_byPrecue_mdlFit_freq_bar
% Plot model fits (linear+periodic) free frequency by precue (All trials,
% precue T1, precue T2) 

%% Load data 
user = 'kantian'; 
filename = sprintf('/Users/%s/Dropbox/github/ta-meg-analysis-model/model_anticipatory/ModelFit_1_freeFreq_231103.mat',user);
load(filename)

%% Figure settings 
titleVis = 0; % if title vis off, then will plot for appropriate manuscript size 
showN = 1; % show n = X annotation 
figFormat = 'svg'; % svg 
plotSubjects = 0; 
annotateMean = 0; 
annotateStats = 1; 
saveFigs = 1; 
plotStyle = 'scatter'; % bar 
cueLevel = {'all','cueT1','cueT2'}; 

% Figure directory
[figDir,dateStr,style,colors,p] = meg_manuscriptParams; 

%% Find solution w minimum fval 
for iF = 2 % just linear+periodic model 
    for iS = 1:size(data.all.(fitLevel),2) % sessions
        for iC = 1:numel(cueLevel)
            % --- Plot model fit ---
            [minVal,idx] = min(  mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).fval(:,iS)  );
            mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minSolution(iS,:) = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).solution(idx,iS,:);
        end
    end
end

%% Plot bars of fitted frequency
% --- Plot figure (bar): Fitted frequency by precue  --- 
figure
fh = subplot(1,1,1); 
hold on
meg_figureStyle
set(gcf,'Position',[100 100 200 style.height])
for iC = 1:numel(cueLevel)
    clear x y idx paramNames
    paramNames = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).paramNames;
    paramOI = 'freq';
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
    else
        ylim([0.5 2.5])
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
ylabel('Frequency (Hz)')

xlabel('Precue') % need to retain sizing?
xticks([1 2 3])
xticklabels({'All','T1','T2'})
xlim([1-style.xBuffer/1.5 3+style.xBuffer/1.5])

% Stats annotation
if annotateStats
    txt = meg_annotateStats(2.03,max(fh.YLim),'ns'); 
end

if saveFigs
    if plotSubjects
        figTitle = sprintf('meg_manuscriptFigs_TE_byPrecue_mdlFit_freq_bar_subjects');
    else
        figTitle = sprintf('meg_manuscriptFigs_TE_byPrecue_mdlFit_freq_bar');
    end
    saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
end






