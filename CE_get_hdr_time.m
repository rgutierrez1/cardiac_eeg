%% CE_get_hdr_time
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
Archivos = dir('*.mat');                            % cargar eeg px
Number_Files = size(Archivos,1);

% Make N by 2 matrix of fieldname + value type
variable_names_types = [["SubjectID", "string"]; ...
			["hdr_start_time", "string"];...
            ["hdr_start_date", "string"]];

%
% Make table using fieldnames & value types from above
hdr_time = table('Size',[Number_Files,size(variable_names_types,1)],... 
	'VariableNames', variable_names_types(:,1),...
	'VariableTypes', variable_names_types(:,2));


%% Obtener Start Time from hdr
for k=1:Number_Files
    filename = Archivos(k).name;
    SubjectID = filename(1:end-4);
    hdr_time.SubjectID(k) = SubjectID;
    load(filename)
    ind_start_time = hdr1.starttime;
    hdr_time.hdr_start_time(k) = ind_start_time;
    hdr_time.hdr_start_date(k) = hdr1.startdate;
end
%%
filename2 = 'hdr_times.csv';
writetable(hdr_time,filename2);