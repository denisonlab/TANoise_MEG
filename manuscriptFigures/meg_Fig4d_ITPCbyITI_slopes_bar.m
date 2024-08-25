function meg_Fig4d_ITPCbyITI_slopes_bar
% function meg_Fig4d_ITPCbyITI_slopes_bar
% load groupITPC_ITI
% and run kt_ITPCbyITI for the model fits by jitter 

%% Load data
load('figData/ITPC_byITI.mat')

%% Settings 
plotSubjects = 0; 
saveFigs = 1; 
annotateStats = 1; 
figFormat = 'svg'; 

% Figure directory
[figDir,dateStr,style,colors,p] = meg_manuscriptParams; 

%% --- Figure (fitted slopes bars by jitter) ---
figure
set(gcf,'Position',[100 100 300 style.height])

fh = subplot(1,1,1);
hold on 
meg_figureStyle

ITIs = 500:200:1500; 
for i = 1:numel(ITIs)
    fieldname = sprintf('ITI%d',ITIs(i));
    y = A.(fieldname).slopes' * 1000;
end

xITI = 1:6;

colorITI = p.cueColors; % p.cueColors; colors.purpleGradient
for i = 1:numel(ITIs)
    fieldname = sprintf('ITI%d',ITIs(i));
    y = A.(fieldname).slopes' * 1000;
    y = meg_sessions2subjects(y'); 

    ste = std(y)/sqrt(10);
    meany = mean(y);

    e = errorbar(xITI(i),meany,ste,'Marker','.','MarkerSize',style.scatter.MarkerSize,'MarkerFaceColor',colorITI(i,:),'MarkerEdgeColor',colorITI(i,:),...
        'Color',colorITI(i,:),'LineWidth',2);
    e.CapSize = style.scatter.errCapSizeS;  

    if plotSubjects
        x = repmat(xITI(i),[1,10]);
        scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor','w','MarkerFaceAlpha',1)
        scatter(x,y,style.scatter.MarkerSizeS,'filled','MarkerFaceColor',colorITI(i,:),'MarkerFaceAlpha',0.5,'MarkerEdgeColor','w')
    else
        ylim([0 0.1])
    end

end
xlim([0 7])
xticks(xITI)
xticklabels({'500','700','900','1100','1300','1500'})
ylabel(sprintf('Slope (\\Delta ITPC/s)'))
xlabel('Jitter (ms)')

% Stats annotation
if annotateStats
    txt = meg_annotateStats( (max(fh.XLim)-min(fh.XLim))/2, max(fh.YLim),'ns');
end

if saveFigs
    if plotSubjects
        figTitle = sprintf('Fig4d_ITPCbyITI_slopes_bar_subjects');
    else
        figTitle = sprintf('Fig4d_ITPCbyITI_slopes_bar');
    end
    saveas(gcf,sprintf('%s/%s.%s', figDir, figTitle, figFormat))
end
