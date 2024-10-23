%% CE_visual_inspection
clear variables
clc

codepath = '~/Codes/cardiac_eeg';
datapath = '~/all_data/igor_data/catEEG';
addpath(genpath("~/Codes/Chronux_2_11"))
addpath(genpath("~/Codes/eeg_general"))

addpath(genpath(codepath))
addpath(genpath(datapath))

%cd(codepath)
cd(datapath)

%%
subjectID = 1;
file_id = sprintf('%03d', subjectID);
prefix = 'CPND-';
sufix = '_all_EGG.mat';
filename = strcat(prefix,file_id,sufix);
load(filename)

%% EEG preprocessing
%%%%%% EEG PART  %%%%%%%%%%%%
original_Fs = Firsthdr.frequency(1);
Fs = 70;

%%%%Step 1: Filter the entire time series
hpFilt = designfilt('highpassiir','FilterOrder',8, ...
    'PassbandFrequency',0.1,'PassbandRipple',0.05, ...
    'SampleRate',original_Fs);
        
lpFilt = designfilt('lowpassiir',...
  'PassbandFrequency',50,'StopbandFrequency',55,'PassbandRipple',0.5, ...
  'SampleRate',original_Fs);
        
pad = ones(1, 60*floor(original_Fs)); % pad 1min
        
[d, n] = rat(original_Fs/Fs);

resampled_data = zeros(size(catEEG,1),ceil(size(catEEG,2)/d*n));
for kk=1:4
    data = catEEG(kk,:);
    hp_data = filtfilt(hpFilt, [pad.*data(1), data, pad.*data(end)]); % highpass filter first
    hp_data = hp_data(length(pad)+1:end-length(pad)); % remove padding
    filtered_data = filtfilt(lpFilt, [pad.*hp_data(1), hp_data, pad.*hp_data(end)]); % then lowpass filter
    filtered_data = filtered_data(length(pad)+1:end-length(pad)); % remove padding
  % Step 2: Resample the entire time series into new sampling rate 
   resampled_data(kk,:) = resample(filtered_data,n,d,500);
end 
record = detrend(resampled_data);

%% MT Parameters
Fs = 70;

params.tapers = [3 5];        % [TW K] Time(T) = 3 segs, Bandwith(W) = 1 Hz, Tapers(K) = 2TW-1 = 5
params.pad = 0;               % Padding factor; -1 no padding; 0 to the next power of 2
params.Fs = Fs;
params.fpass = [0.1 Fs/2];        
params.err = 0;               % Error calculation; 1: theorical; 2: Jackniffe
params.trialave = 0;          % A verage over trial

win = [10 5]; %1 0.5
fq_resolution = 2*params.tapers(1)/win(1);

EEG = record(2,:);             % Fp2
[S,t,f]= mtspecgramc(EEG,win,params);

%% Plot
fig = figure;
ax = figdesign(2,1);
fig.Units = 'pixels';
set(fig, 'Position', [fig.Position(1), fig.Position(2), 1300, 700])


axes(ax(1))                                                 % Raw data
raw_vec = (0:length(EEG)-1)/Fs/60;
plot(raw_vec, EEG, 'Color',[17 17 17]/255)
ylim([-300 300])
% label = {'EEG start','Anesthesia start','Procedure start','Procedure End'};
% xline([t1,t2,t3,t4],'-r',label,'LineWidth',4)
xlabel('Time (min)','FontSize',14,'FontWeight','bold')
ylabel('Voltage (\muV)','FontSize',14,'FontWeight','bold')
grid on

axes(ax(2))                                                 % Spectrogram
imagesc(t/60, f, 10 * log10(S'))
hold on
axis xy
shading('interp')
colormap ('jet')
climscale;
h1=colorbar;
h1.Location = 'east';
lim1 = h1.Limits;
ylim([1 Fs/2]) 
% xline([t1,t2,t3,t4], 'LineWidth',4, 'Color',"#7E2F8E")
xlabel('Time (m)','FontSize',14,'FontWeight','bold')
ylabel('Frequency (Hz)','FontSize',14,'FontWeight','bold')
set(get(h1,'title'),'string','dB','FontSize',12,'FontWeight','bold','Color','w');
h1.Visible = "on";
hold off

% linkaxes(ax, 'x') %Link x axes
% if raw_vec(end) > t4
%     xlim('tight')
%     h1.Label.Color = 'white';
%     h1.Color = "w";
% else
%     xlim([0 (t4+10)])
% end
% Set title
axes(ax(1))
title(subjectID,'FontSize',18,'FontWeight','bold')

% filename2 = strcat(subjectID,'.jpg');
% saveas(gcf,filename2)