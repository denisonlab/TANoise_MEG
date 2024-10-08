function [style, colors] = meg_manuscriptStyle

% parameters for reproducing manuscript figures 

style.widthTS = 470; 
style.widthScatter = 300; 
style.height = 300; 

style.ebLineWidth = 0.2; % line width of shaded error bar edges 

% scatterplots 
style.xBuffer = 1; 
style.xBufferSml = 0.2; 
style.scatter.MarkerSize = 40; % group average scatter dot size 
style.scatter.MarkerSizeS = 30; % subject scatter dot size 
style.scatter.errCapSize = 15; % errorbar cap size 15 for behav
style.scatter.errCapSizeS = 10; % for model fits 

%% Colors 
colors.lightgrey = [1 1 1]*0.86; % for patch
colors.mediumgrey = [1 1 1]*0.5; 

% All trials 
colors.darkPurple = [73 36 98]/255; % [101 70 118]/255;
colors.mediumPurple = [162 129 178]/255; % [169 128 182]/255;
colors.primaryPurple = [135 24 224]/255;
colors.lightPurple = [228 226 232]/255; % [228 226 232]/255; % [223,217,229]/255;

% Precue T1 
colors.darkBlue = [2 46 145]/255; 
colors.lightBlue = [162 180 229]/255; 
colors.darkestBlue = [1 36 114]/255; 
colors.mediumBlue = [126 139 188]/255; % [2,46,145]/255;
colors.precueBlue = [122 142 194]/255; 


% Precue T2 
colors.darkRed = [162 40 10]/255; 
colors.lightRed = [237 206 200]/255; 
colors.darkestRed = [146 35 0]/255; 
colors.mediumRed = [210 127 100]/255; % [162,40,10]/255;
colors.precueRed = [225 124 96]/255; 

% 
colors.green = [53,128,55]/255; 

colors.eventLines = [0.5 0.5 0.5]; 

% Purple gradient 
colors.purpleGradient = [73 36 98; % darkest
    102 79 124; 
    149 129 160;
    176 165 186; 
    201 194 208; 
    227 225 230]/255; % lightest 

%% Text size 
style.txtSize_Annotation = 10; 
style.txtSize_Legend = 14; % 14; 



