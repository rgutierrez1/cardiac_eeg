% This script is intended to read EDFs files from PEUMA Sedline
% files. 
clear all
close all
clc

% Paths (change accordingly)
EDFpath = '~/all_data/igor_data';
CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
SCTGpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/SPECTG';

cd (EDFpath);
%% Find folders with EDFs inside
Finfo = dir;                            %Directory information
SubF = find ([Finfo.isdir] == 1);       %Find SubFolders
RealF = {Finfo(SubF).name};             %Folders Names
IndexSA = strmatch('SF',RealF)';        %Indices of Folders named 'SF'
SDataF = RealF(IndexSA)';               %Names of all Folders name containing 'SF'

%% Find EDF files for each subject folder

for SFindex = 1:length (SDataF)
    %         hasedf(1,SFindex) = any(size(dir([[EDFpath '/' SDataF{SFindex}] '**/*.edf' ]),1));
    filelist(SFindex).files = dir(fullfile([EDFpath '/' SDataF{SFindex}], '**/*.edf'));
end
%% Read Time data from CSV
cd (CSVpath);
TAPS = readtable('times_APS.csv');
APSSubj = table2cell(TAPS(:,1));                    %Subjects by APS
TAPS.AlphaRelativePow = zeros(size(TAPS,1),1);
TAPS.AlphaPeakFreq = zeros(size(TAPS,1),1);
%% Finding APS subjects
[APSval,APSpos]=intersect(SDataF,APSSubj);          % coincidences
[APSdifval,APSdifpos] = setdiff(SDataF,APSSubj);    % differences
tAPS = cell2mat(table2cell(TAPS(:,2:3)));           % Times by APS
tAPS = rmmissing(tAPS);
DelTrue = cell2mat(table2cell(TAPS(:,4)));          % Delirium = 1
%%
% Delirium/No Delirium counters
% NonDel = 0;
% YesDel = 0;
% Main Loop
for NumSubj = 1%:length(APSval)
    catEEG = [];
    
    APSSubj = APSpos(NumSubj); %replacing by subjects in APS's list
    
    currSubj = char(SDataF(APSSubj))
    tt = char(currSubj);
    currPath = filelist(APSSubj).files.folder;
    currDel = DelTrue(NumSubj);     % Delirium. Yes = 1, No = 0.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Concatenating all files for the same subject    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for NumSFile = 1:length(filelist(APSSubj).files)
        currFile = filelist(APSSubj).files(NumSFile).name;
        f2r = [currPath '/' currFile];
        [hdr, record] = edfreadUntilDone(f2r);
        %         File exchange function edfreadUntilDone
        %         https://www.mathworks.com/matlabcentral/fileexchange/66088-edfreaduntildone-fname-varargin
        catEEG = cat(2,catEEG,record);
        
        % Rescuing first header
        if NumSFile == 1
            Firsthdr = hdr;
        end
    end
    datafilename = [currSubj '_all_EGG.mat'];
    cd '/Users/jiegana/Desktop' % Destination folder
    save (datafilename, 'catEEG', 'Firsthdr');
end