clear all
subjects = {'\ega'};
result_file = '_ica_stim_results100.mat';
load(strcat(subjects{1,1}(2:4), result_file));
ica_best_channels = best_channels;
ica_class_matrix = max(classification_accuracy_matrix');
channel_sum = sum(classification_accuracy_matrix);
[b, index] = max(channel_sum);
index
%% Load EEG
result_file = '_eeg_stim_results100.mat';
load(strcat(subjects{1,1}(2:4), result_file));
eeg_best_channels = best_channels;
eeg_class_matrix = max(classification_accuracy_matrix');
channel_sum = sum(classification_accuracy_matrix);
[b, index] = max(channel_sum);
index
train_files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};

double_hash = '\\';
fprintf('%s ', subjects{1,1}(2:4));
for i = 1:length(train_files)
    fprintf('&%s &%3.2f &%d &%3.2f &%d %s\n', train_files{1,i}, eeg_class_matrix(1,i), eeg_best_channels(1,i), ica_class_matrix(1,i), ica_best_channels(1,i), double_hash );
end
channel_sum = sum(classification_accuracy_matrix);
[b, index] = max(channel_sum);
