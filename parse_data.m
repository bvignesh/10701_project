close all
clear all
%% Read file
path = 'C:\Users\sande_000\Downloads\CMU\Courses\Sem2\10701-Machine Learning\Project\Data';
subject = '\cba';
file = '1ff01';
ext = '.mat';
filename = sprintf('%s%s%s%s%s', path, subject, subject, file, ext);
load(filename);
%% Parse File
data = EEG.data;
clear EEG;
%% Types of Data by class
correct_distractor_data = [];      % Corresponds to C
missed_distractor_data  = [];      % Corresponds to P
correct_target_data     = [];      % Corresponds to R
missed_target_data      = [];      % Corresponds to M
%% Allot chunks of data
chunk_size = 200;                  % in ms
index = C{1,1}(:,:);
intervals = C{1,8}(:,:);
types = C{1,4}(:,:);
start = 1;
for i = 1:length(index)
    if types{i,1} == 'C'
        correct_distractor_data = [correct_distractor_data, data(1:size(data,1), start:start+chunk_size)];    
    elseif types{i,1} == 'P'
        missed_distractor_data = [missed_distractor_data, data(1:size(data,1), start:start+chunk_size)];    
    elseif types{i,1} == 'R'
        correct_target_data = [correct_target_data, data(1:size(data,1), start:start+chunk_size)];    
    elseif(types{i,1} == 'M')
        missed_target_data = [missed_target_data, data(1:size(data,1), start:start+chunk_size)];
    end
    start = start + intervals(i,1);
end
            
            
        