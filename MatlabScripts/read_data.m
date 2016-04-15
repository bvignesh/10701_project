close all
clear all
%% Read cnt file
path = 'C:\Users\sande_000\Downloads\CMU\Courses\Sem2\10701-Machine Learning\Project\Data';
subjects = {'\ega'};
files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};
ext1 = '.cnt';
ext2 = '.exp';
ext3 = '.mat';
for i = 1:length(subjects)
    for j = 1:length(files)
        clear EEG
        clear C
        %% Read the EXP file
        filename_exp = sprintf('%s%s%s%s%s%s', path, subjects{1,i}, subjects{1,i}, subjects{1,i}, files{1,j}, ext2);
        fileID = fopen(filename_exp, 'r');
        formatSpec = '%f %s %f %s %f %f %f %f';
        C = textscan(fileID, formatSpec, 'Delimiter', '\t');
        fclose(fileID);
        %% Read the CNT file
        filename_cnt = sprintf('%s%s%s%s%s%s', path, subjects{1,i}, subjects{1,i}, subjects{1,i}, files{1,j}, ext1);
        EEG = pop_loadcnt(filename_cnt);
        filename_out = sprintf('%s%s%s%s%s', path, subjects{1,i}, subjects{1,i}, files{1,j}, ext3);
        save(filename_out, 'EEG', 'C');
    end
end
        
        