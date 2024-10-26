%% CE_alpha_power
% Author: Rodrigo Gutierrez
clear variables
clc

codepath = '~/Codes/cardiac_eeg';
datapath = '~/all_data/igor_data/catEEG';

addpath(genpath(codepath))
addpath(genpath(datapath))
addpath(genpath('~/Codes/eeg_general'))
addpath(genpath("~/Codes/Chronux_2_11"))
%cd(codepath)
cd(datapath)

%%
Archivos = dir('*.mat');  %cargar eeg px
number_files = size(Archivos,1);

params.tapers = [3 5];
params.pad = 0;
params.err = 0;
params.trialave = 0;

win = 5;                      % window length  
segave = 1;   
fq_resolution = 2*params.tapers(1)/win(1);
%%
% Make N by 2 matrix of fieldname + value type
variable_names_types = [["SubjectID", "string"]; ...
			["minute", "double"]; ...
            ["alpha_power", "double"]; ...
			["delta_power", "double"]];

% Make table using fieldnames & value types from above
EEG_results = table('Size',[number_files,size(variable_names_types,1)],... 
	'VariableNames', variable_names_types(:,1),...
	'VariableTypes', variable_names_types(:,2));


%%
kk=1;
for k = 1:Number_Files                      % Patient 
    filename = Archivos(k).name;
    load(filename) 
    fs = Firsthdr.frequency(1);

    params.Fs = Firsthdr.frequency(1);
    params.fpass = [1 fs/2];
    
    % Cortar el EEG
    subjectID = filename(1:end-12);
    disp(['analyzing subject ' subjectID])
    
    % Datos del paciente
    data = catEEG(2,:);             % We define the second electrode (Fp2)
    window_length = 60;
    mini_window = floor(fs*10);
    minute_duration = floor(fs*60);
    eeg_duration = floor(length(data(1,:))/fs/60);
    
    MnE = mean(data);
    sdE = std(data);
    V_fisio_max = MnE + sdE*2;
    V_fisio_min = MnE - sdE*2;
    
    
    for i = 1:eeg_duration  %minutos
        index_min = (fs * window_length * (i - 1));
        index_min = floor(index_min);
        for j = 1:(minute_duration - mini_window) %intervalos de 10s 
            start_index = j + (index_min);
            end_index = j + mini_window - 1 + (index_min);
            evaluated_data = data(start_index:end_index);
            
            if max(evaluated_data) < V_fisio_max && min(evaluated_data) > V_fisio_min
                [alpha_relative_power, alpha_band_power, ~] = mt_alphapower(evaluated_data, win, params, segave);
                [delta_relative_power, delta_band_power] = mt_deltapower(evaluated_data, win, params, segave);
               
                EEG_results.SubjectID(kk) = subjectID;
                EEG_results.minute(kk) =  i;
                EEG_results.alpha_power(kk) =  alpha_band_power;
                EEG_results.delta_power(kk) =  delta_band_power;
                kk = kk+1;
                break;
            else
            end
        end
     end
end
%%
filename2 = 'cardiac_eeg_results.csv';
writetable(EEG_results,filename2);