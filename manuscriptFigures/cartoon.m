% ITPC cartoon

figure
set(gcf,'Position',[100 100 300 400]) 

grey = cmocean('-gray',14); 
lineWidth = 1.5; 
lineWidthAvg = 2; 
xli = [-3.5*pi 3.5*pi]; 
clear y

subplot 211
figureStyle
hold on 
ylabel('Power')
xlabel('Time')
yticks('')
xticks('')
xlim(xli)
ylim([-1 1])
x = -8*pi:0.1:8*pi; 
y0 = sin(x); 
yScale = [1.7 1]; 
yAmps = [0.24 0.4 0.2 0.13 0.46]; 
for iS = 1:2
    for i = 1:numel(yAmps)
        y(iS,i,:) = y0*yAmps(i)*yScale(iS); 
    end
end
for iS = 1
    for i = 1:numel(yAmps)
    plot(x,squeeze(y(iS,i,:)),'Color',grey(i+1,:),'LineWidth',lineWidth)
    end
end
plot(x,squeeze(mean(y(iS,:,:),2)),'Color','k','LineWidth',lineWidthAvg)

subplot 212
figureStyle
hold on 
yticks('')
xticks('')
xlim(xli)
ylim([-1 1])
for iS = 2
    for i = 1:numel(yAmps)
    plot(x,squeeze(y(iS,i,:)),'Color',grey(i+1,:),'LineWidth',lineWidth)
    end
end
plot(x,squeeze(mean(y(iS,:,:),2)),'Color','k','LineWidth',lineWidthAvg)

%% Phase consistency 

figure
set(gcf,'Position',[100 100 300 400]) 

grey = cmocean('-gray',14); 
lineWidth = 1.5; 
lineWidthAvg = 2; 
clear y

subplot 211
figureStyle
hold on 
yticks('')
xticks('')
xlim(xli)
ylim([-1 1])
x = -8*pi:0.1:8*pi; 

yScale = [3 9]; 
yPhase = [0 0.6 1.4 2.5 4]; 
for iS = 1:2
    for i = 1:numel(yAmps)
        y0 = sin(x + yAmps(i)*yScale(iS)); 
        y(iS,i,:) = y0*0.6; 
    end
end
for iS = 1
    for i = 1:numel(yAmps)
    plot(x,squeeze(y(iS,i,:)),'Color',grey(i+1,:),'LineWidth',lineWidth)
    end
end
plot(x,squeeze(mean(y(iS,:,:),2)),'Color','k','LineWidth',lineWidthAvg)

subplot 212
figureStyle
hold on 
yticks('')
xticks('')
xlim(xli)
ylim([-1 1])
for iS = 2
    for i = 1:numel(yAmps)
    plot(x,squeeze(y(iS,i,:)),'Color',grey(i+1,:),'LineWidth',lineWidth)
    end
end
plot(x,squeeze(mean(y(iS,:,:),2)),'Color','k','LineWidth',lineWidthAvg)


