function meg_Fig6b_TE_byPrecue_mdlFit_2Hz_bars
% function meg_Fig6b_TE_byPrecue_mdlFit_2Hz_bars
% Plot 2 Hz model fit 

%% Load data
% Model fit data 
filename = 'figData/ModelFit_SeparatePrecueT1T2_2Hz_session.mat';
% ITPC data 
load(filename)

% CSV settings
% csvDir = 'manuscriptFigures/figData'; 
% % If not loading .mat, load .csv
% filename = sprintf('manuscriptFigures/figData/TANoise_MdlFit_Linear2Hz.csv'); 
% load(filename)

%% Figure settings 
titleVis = 0; % if title vis off, then will plot for appropriate manuscript size 
showN = 1; % show n = X annotation 
figFormat = 'svg'; % 'svg' or 'pdf' for linked .ai; export_fig 'pdf' doesn't recognize helvetica-light
plotErrorBars = 1; % turn off for subject-level plots 
restrictYLim = 1; % turn on for group-level manuscript matching ylims 
plotPrePrecue = 0; % bar showing pre-precue baseline period
plotSubjects = 1; 
saveFigs = 1; 
annotateMean = 0; 
annotateStats = 1; 
plotStyle = 'scatter'; % bar or scatter 

% Figure directory
[figDir,dateStr,style,colors,p] = meg_manuscriptParams; 

% Data settings
cueLevel = {'cueT1','cueT2'}; 
fitLevel = 'session'; 
paramLabelNames = {'Intercept (ITPC)','Slope ','Amplitude (ITPC)','Phase'}; 
paramLabelNames{2} = sprintf('Slope (\\Delta ITPC/s)'); 

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

%% Plot bars of fitted parameter
% --- Plot figure (bar): Fitted parameter by precue  ---
for iP = 1:3
    figure
    fh = subplot(1,1,1);
    hold on
    meg_figureStyle
    set(gcf,'Position',[100 100 150 style.height])
    fh.InnerPosition = [0.4140 0.1570 0.4910 0.7680]; 
    for iC = 1:numel(cueLevel)
        clear x y idx paramNames
        paramNames = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).paramNames;
        paramOI = paramNames{iP};
        % Axes labels
        ylabel(paramLabelNames{iP})

        idx = find(contains(paramNames,paramOI));
        y = mdlFit.(fitTypes{iF}).(cueLevel{iC}).(fitLevel).minSolution(:,idx); % sessions
        y = meg_sessions2subjects(y'); % subjects
        x = iC;

        % standard error of mean
        % err = std(y)/sqrt(numel(y));

        % standard error of difference 
        y1 = mdlFit.(fitTypes{iF}).(cueLevel{1}).(fitLevel).minSolution(:,idx); 
        y1 = meg_sessions2subjects(y1'); % subjects
        y2 = mdlFit.(fitTypes{iF}).(cueLevel{2}).(fitLevel).minSolution(:,idx); 
        y2 = meg_sessions2subjects(y2'); % subjects
        err = std(y1-y2)/sqrt(numel(y)); 

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
            scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor','w')
            scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor',faceColor,'MarkerEdgeColor','w','MarkerFaceAlpha',0.5)
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
    
    if iP==1
        xlabel('Precue') % need to retain sizing?
    else 
        xlabel('')
    end
    xticks([1 2])
    xticklabels({'T1','T2'})
    xlim([1-style.xBuffer/1.5 2+style.xBuffer/1.5])

    % y axis styling
    if plotSubjects
        switch paramOI
            case 'amplitude'
                yticks(0:0.01:0.05)
                ylim([0 0.05])
            case 'intercept'
                ylim([0.12 0.55])
                yticks([0:0.1:0.55])
        end
    else
        switch paramOI
            case 'amplitude'
                yticks(0.0:0.01:0.04)
                ylim([0.0 0.035])
            case 'slope'
                yticks(0:0.02:0.085)
                ylim([0 0.085])
            case 'intercept'
                yticks(0.1:0.02:0.45)
                ylim([0.26 0.34])
        end
    end

    % Subject lines
    if plotSubjects
        % for i = 1:numel(subjectNames)
        %     s = plot([1 2],[y1(i) y2(i)],'Color',colors.lightgrey);
        % end
    end

    % Stats annotation
    if annotateStats
        txt = meg_annotateStats(1.53,max(fh.YLim),'ns');
    end

    if saveFigs
        if plotSubjects
            figTitle = sprintf('Fig6b_TE_byPrecue_mdlFit_2Hz_bar_%s_subjects',paramOI);
        else
            figTitle = sprintf('Fig6b_TE_byPrecue_mdlFit_2Hz_bar_%s',paramOI);
        end

        switch figFormat
            case 'pdf'
                export_fig(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat),'-transparent','-painters','-p10')
            otherwise 
                saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
        end
    end 
end





