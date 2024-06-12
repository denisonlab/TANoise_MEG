
% Single trial spectrograms: Load: group_TF_wholeTrial.mat
%% inputs
expt = 'TANoise'; % TANoise 
user = 'kantian'; % for file path to save figures ß
saveFigs = 1; % saves .svg to current directory 
plotSubjects = 0; 

%% setup
[sessionNames,subjectNames,ITPCsubject,ITPCsession]  = meg_sessions(expt); 
targets = {'T1','T2'}; 
p = meg_params(sprintf('%s_Analysis',expt)); 

% Load data 
load('/Users/kantian/Dropbox/Data/TANoise/MEG/Group/figures/singleTrial_spectrogram_pow/groupTFspectrogram_singleTrial_pow.mat')

%% Test plot spectrogram of one subject
cond = 'all'; 
figure

subplot 211 
meg_figureStyle 
hold on
units = 10e-13;

val = A.group; 
val = val/units^2; 

imagesc(val) 
xlims = [0 701];
xlim([(2000+-100)/10 (2000+2400)/10])
ylim([1 50])
xlabel('Time (s)')
ylabel('Frequency (Hz)')
colorbar
ax = gca; 
ax.CLim(1) = 0.0005; 
ax.CLim(2) = 0.0048; % 0.0049
% clim([0 0.0100])

toi = -2000:10:5000; 
foi = 1:50; 
xtick = toi(1):500:toi(end);
set(gca,'XTick',xtick/10)
set(gca,'XTickLabel',xtick-2000)

ytick = [1,10,20,30,40,50];
set(gca,'YTick',ytick)
set(gca,'YTickLabel',foi(ytick))

for iEv = 1:numel(p.eventTimes)
    xline((p.eventTimes(iEv)+2000)/10,'k','LineWidth',2);
end


subplot 212 % just pull out around stimulation frequency 
meg_figureStyle 
hold on
imagesc(val) 
xlims = [0 701];
xlim([(2000+-100)/10 (2000+2400)/10])
ylim([17 23])
xlabel('Time (s)')
ylabel('Frequency (Hz)')

colorbar
ax = gca; 
ax.CLim(1) = 0.0008; 
ax.CLim(2) = 0.0016; % 0.0049

toi = -2000:10:5000; 
foi = 1:50; 
xtick = toi(1):500:toi(end);
set(gca,'XTick',xtick/10)
set(gca,'XTickLabel',xtick-2000)

ytick = 17:23;
set(gca,'YTick',ytick)
set(gca,'YTickLabel',foi(ytick))

for iEv = 1:numel(p.eventTimes)
    xline((p.eventTimes(iEv)+2100)/10,'k','LineWidth',2);
end

%% Load all the As
% TF whole trial seems to be single trials 
for i = 2 % :5 % :20
    filename = sprintf('/Users/%s/Dropbox/Data/TANoise/MEG/%s/mat/TF_wholeTrial.mat','kantian',sessionNames{i});
    load(filename)
    clear val 
    val = mean(A.all.tfPows,1,'omitnan'); 
    singleTrialPower(i,:,:) = val; 

    cond = 'all';
    figure
    hold on
    units = 10e-13; 
    toims = -2000:5000; 
    toiPlotms = -100:2400; 

    val = mean(spec.sessions,1,'omitnan'); 
    % val = squeeze(singleTrialPower(i,:,:)) / units^2; 
    imagesc(squeeze(val))
    % xlims = [0 701];
    xlims = [(2000+-100)/10 (2000+2400)/10]; 
    xlim(xlims)
    ylim([1 50])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    colorbar

    toi = toims/10;
    foi = 1:50;
    xtick = (toi(1):50:toi(end))+201;
    ytick = [1,10,20,30,40,50];
    meg_timeFreqPlotLabels(toi,foi,xtick,ytick,(p.eventTimes+2001)/10);
    title(und2space(sessionNames{i}))
end

%% Single trial spectrograms: Load: group_TF_wholeTrial.mat
% this seems to be trial average power 
for i = 1:20
    spec.sessions(i,:,:) = group_TF_wholeTrial{i}.all.normPows; 
end









