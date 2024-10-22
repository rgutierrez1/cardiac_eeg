% This script is intended to read EDFs files from PEUMA Sedline
% files. 
clear variables
close all
clc

EDFpath = '~/all_data/igor_data';
addpath(genpath('~/Codes/eeg_general'))
addpath(genpath(EDFpath))
% Paths (change accordingly)
% CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
% SCTGpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/SPECTG';

cd (EDFpath);
%% Find folders with EDFs inside
Finfo = dir;                            %Directory information
SubF = find ([Finfo.isdir] == 1);       %Find SubFolders
RealF = {Finfo(SubF).name};             %Folders Names
IndexSA = strmatch('CPND-',RealF)';        %Indices of Folders named 'SF'
SDataF = RealF(IndexSA)';               %Names of all Folders name containing 'SF'

%% Find EDF files for each subject folder

for SFindex = 1:length (SDataF)
    %         hasedf(1,SFindex) = any(size(dir([[EDFpath '/' SDataF{SFindex}] '**/*.edf' ]),1));
    filelist(SFindex).files = dir(fullfile([EDFpath '/' SDataF{SFindex}], '**/*.edf'));
end

%%

for NumSubj = 26:length(filelist)
    catEEG = [];
    
    %APSSubj = APSpos(NumSubj); %replacing by subjects in APS's list
    
    currSubj = char(SDataF(NumSubj));
    %tt = char(currSubj);
    currPath = filelist(NumSubj).files.folder;
    %currDel = DelTrue(NumSubj);     % Delirium. Yes = 1, No = 0.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Concatenating all files for the same subject    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for NumSFile = 1:length(filelist(NumSubj).files)
        currFile = filelist(NumSubj).files(NumSFile).name;
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
    datafilename = [currSubj '_all_EEG.mat'];
    cd '~/all_data/igor_data' % Destination folder
    save (datafilename, 'catEEG', 'Firsthdr');
end