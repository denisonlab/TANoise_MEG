function meg_Fig4c_ITPCbyITI_TS
% function meg_Fig4c_ITPCbyITI_TS

%% Load data
load('figData/ITPC_byITI.mat')

%% Figure settings 
titleVis = 0; % if title vis off, then will plot for appropriate manuscript size 
showN = 0; % show n = X annotation 
figFormat = 'svg'; % svg 
annotateMean = 0; 
annotateStats = 1; 
saveFigs = 1; 
cueLevel = {'all'}; 
showLegend = 1; 
[style, colors] = meg_manuscriptStyle;

% Figure directory 
dateStr = datetime('now','TimeZone','local','Format','yyMMdd');
figDir = 'figs'; 
if ~exist(figDir, 'dir')
    mkdir(figDir)
end

%% Data settings 
p = meg_params('TANoise_ITPCsession8'); 
toi = -2000:5000; 

tIdx = (0:970) + abs(p.tstart); % anticipatory tIdx 

colorITI = p.cueColors; % colors.purpleGradient 

%% Plot group ITPC by ITI
figure
set(gcf,'Position',[100 100 600 300]) 
fh = subplot(1,1,1); 
meg_figureStyle
hold on
fields = fieldnames(groupITPC_ITI.group);
for iField = 1:numel(fields)
    pLine(iField) = plot(toi,groupITPC_ITI.group.(fields{iField})(foi,:),'Color',[colorITI(iField,:) 0.8],'LineWidth',2,...
        'DisplayName',fields{iField});
end

xlim([-1600 2500])
xlabel('Time (ms)')
ylabel('ITPC')
ylim([0 0.4])
yticks(0:0.1:0.4)

% --- Plot event lines ---
p.eventNamesCap = {'Precue','T1','T2','Response cue'};
for i = 1:numel(p.eventTimes)
    xh = xline(p.eventTimes(i),'Color',[0.5 0.5 0.5],'LineWidth',1,'HandleVisibility','off');
    meg_sendToBack(xh)
    hold on
    % --- Plot event names ---
    if i==1 % Color the precue
        % Precue (all trials)
        ySet = max(fh.YLim)+(diff(fh.YLim)*0.01);
        txt = text(p.eventTimes(i),ySet,p.eventNamesCap{i},'EdgeColor','none',...
            'FontSize',14,'HorizontalAlignment','left','VerticalAlignment','Bottom');
        txt.Color = 'k';
    elseif i==4 % Response cue
        text(p.eventTimes(i),ySet,p.eventNamesCap{i},'EdgeColor','none',...
            'FontSize',14,'HorizontalAlignment','right','VerticalAlignment','Bottom');
    else
        text(p.eventTimes(i),ySet,p.eventNamesCap{i},'EdgeColor','none',...
            'FontSize',14,'HorizontalAlignment','center','VerticalAlignment','Bottom');
    end
end

if showN
    % --- Add n annotation ---
    nStr = sprintf('n = 10 x 2 sessions');
    nStrTxt = text(0.945*xl(2),yl(1)+0.003,nStr,'HorizontalAlignment','right','VerticalAlignment','bottom');
    nStrTxt.FontSize = 12;
    nStrTxt.FontName = 'Helvetica-Light';
end

if showLegend
    legendNames = {'500','700','900','1100','1300','1500'}; 
    lgd = legend([pLine(1) pLine(2) pLine(3) pLine(4) pLine(5) pLine(6)],legendNames); 
    lgd.Location = 'southeast'; 
    lgd.NumColumns = 1; 
    lgd.Box = 'off'; 
    lgd.FontSize = 12; 
    lgd.Position(1) = 0.7;
    if showN
        lgd.Position(2) = 0.25;
    else
        lgd.Position(2) = 0.22;
    end
    % --- Legend title --- 
    lgd.Title.String = 'Jitters (ms)'; 
    lgd.Title.FontSize = 12; 
    lgd.Title.FontWeight = 'light'; 
end

for iEv = 1:numel(fields) % plot ITI times
    ITIs = [-500,-700,-900,-1100,-1300,-1500];
    xline(ITIs(iEv),'-','Color',colorITI(iEv,:),'LineWidth',1,'HandleVisibility','off');
end

% --- Plot shaded baseline window ---
xl = xlim;
yl = ylim;
x = [p.t(tIdx(1)) p.t(tIdx(end)) p.t(tIdx(end)) p.t(tIdx(1))];
yScale = yl(2)-yl(1);
ySize = (0.02*0.15)*(yScale/0.15);
y = [yl(1) yl(1) yl(1)+ySize yl(1)+ySize]; % [yl(1) yl(1) yl(2) yl(2)]
patch(x,y,colors.mediumgrey,'EdgeColor',colors.mediumgrey,'HandleVisibility','off')

% --- Save fig ---
if saveFigs
    figTitle = sprintf('Fig4c_ITPCbyITI_TS');
    saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
end
