function [faceColor,erColor,sColor] = meg_manuscriptStyleCue(cueLevel)  
% function meg_manuscriptStyleCue(cueLevel)
% returns colors for group level plots by precue 
% marker face color, errorbar color, subject color

[style, colors] = meg_manuscriptStyle; 

colorMode = 'medium'; % light, medium color palette 

switch cueLevel
    case 'all'
        switch colorMode
            case 'dark'
                faceColor = colors.darkPurple;
                erColor = colors.lightPurple;
                sColor = colors.mediumPurple;
            case 'light'
                faceColor = colors.lightPurple;
                erColor = colors.darkPurple;
                sColor = colors.lightPurple; 
            case 'medium'
                faceColor = colors.mediumPurple;
                erColor = colors.mediumPurple;
                sColor = colors.mediumPurple;
        end
    case 'cueT1'
        switch colorMode
            case 'dark'
                faceColor = colors.darkBlue;
                erColor = colors.lightBlue;
                sColor = colors.precueBlue;
            case 'light'
                faceColor = colors.lightBlue;
                erColor = colors.darkestBlue;
                sColor = colors.lightBlue; 
            case 'medium'
                faceColor = colors.mediumBlue;
                erColor = colors.darkBlue;
                sColor = colors.mediumBlue; 
        end
    case 'cueT2'
        switch colorMode
            case 'dark'
                faceColor = colors.darkRed;
                erColor = colors.lightRed;
                sColor = colors.precueRed;
            case 'light'
                faceColor = colors.lightRed;
                erColor = colors.darkestRed;
                sColor = colors.lightRed; 
            case 'medium'
                faceColor = colors.mediumRed;
                erColor = colors.darkRed;
                sColor = colors.mediumRed; 
        end
end