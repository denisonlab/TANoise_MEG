function meg_figureStyle()

% adjusts fig axis and text styling
box off
hold on 
set(gca,'TickDir','out');
ax = gca;
ax.LineWidth = 1.5;
ax.XColor = 'black';
ax.YColor = 'black';

smlFont = 14;
bigFont = 24; % 24 jumbo 

ax.FontSize = bigFont;
ax.FontName = 'Helvetica-Light'; % 'Helvetica-Light'; 
 
ax.XAxis.FontSize = smlFont;
ax.YAxis.FontSize = smlFont;

ax.LabelFontSizeMultiplier = bigFont/smlFont; 

set(0, 'DefaultFigureRenderer', 'painters')








