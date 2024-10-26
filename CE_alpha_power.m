%% CE_alpha_power
% Author: Rodrigo Gutierrez
clear variables
clc

codepath = '~/Codes/cardiac_eeg';
datapath = '~/all_data/igor_data/catEEG';

addpath(genpath(codepath))
addpath(genpath(datapath))

%cd(codepath)
cd(datapath)

%%
Archivos = dir('*.mat');  %cargar eeg px
Number_Files = size(Archivos,1);
alfas = nan(4, 600, Number_Files); %aqui va una u
relative_alfas = nan(4,304,Number_Files); %aqui va una u

params.tapers = [3 5];
params.pad = 0;
params.err = 0;
params.trialave = 0;

win = 5;                      % window length  
segave = 1;   
fq_resolution = 2*params.tapers(1)/win(1);
%%
for u = 1:Number_Files   %Revisicion px por px
    filename = Archivos(u).name;
    load(filename) %aqui va un u
    fs = hdr1.frequency(1);

    params.Fs = fs;
    params.fpass = [1 fs/2];
    
    % Cortar el EEG
    subjectID = filename(1:end-4);
    disp(['analyzing subject ' subjectID])
    filteredRows = time_table(strcmp(time_table.SubjectID, subjectID), :);

    anesthesia_start_time =  filteredRows.Seconds_Awake; 
    anesthesia_start_index = floor(anesthesia_start_time * fs);
    data = catEEG(:,anesthesia_start_index:end);

    % Datos del paciente

    window_length = 60;
    mini_window = floor(fs*10);
    minute_duration = floor(fs*60);
    eeg_duration = floor(length(data(1,:))/fs/60);
    

        % Escaneo Electrodos
    for j = 1:size(data,1)
        Electrode = data(j,:);  %Electrodo
        MnE = mean(Electrode);
        sdE = std(Electrode);
        V_fisio_max = MnE + sdE*2;
        V_fisio_min = MnE - sdE*2;
    
        for i = 1:eeg_duration  %minutos
            index_min = (fs * window_length * (i - 1));
            index_min = floor(index_min);
            for k = 1:(minute_duration - mini_window) %intervalos de 10s 
                start_index = k + (index_min);
                end_index = k + mini_window - 1 + (index_min);
                evaluated_data = Electrode(start_index:end_index);
                
                if max(evaluated_data) < V_fisio_max && min(evaluated_data) > V_fisio_min
                    %[alpha_relative_power, alpha_band_power, alpha_peak_f, alpha_peak_p] = mt_alphapower(evaluated_data, win, params, segave);
                    [alpha_relative_power, alpha_band_power, ~] = mt_alphapower(evaluated_data, win, params, segave);
    
                    alfas(j, i, u) = alpha_band_power; %aqui va una u
                    relative_alfas(j, i , u) = alpha_relative_power; %aqui va una u
                    break;
                else
                end
            end
         end
    end
end