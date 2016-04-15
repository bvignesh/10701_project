close all
clear all
warning('off', 'all')
%% Types of Data by class
correct_distractor_data = [];      % Corresponds to C
missed_distractor_data  = [];      % Corresponds to P
correct_target_data     = [];      % Corresponds to R
missed_target_data      = [];      % Corresponds to M
no_stimulus = [];
%% File Info
path = 'C:\Users\sande_000\Downloads\CMU\Courses\Sem2\10701-Machine Learning\Project\Data';
subjects = {'\ega'};
train_files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};
% train_files = {'1ff04'};
ext = '.mat';
num_channels = 31;
best_channels = [];
classification_accuracy_matrix = [];
%% Read files
for k = 1:length(subjects)
    for j = 1:length(train_files)
        %% Data params
        chunk_size = 500;                  % in ms
        %% Read Mat files
        filename = sprintf('%s%s%s%s%s', path, subjects{1,k}, subjects{1,k}, train_files{1,j}, ext);
        fprintf('%s\n', filename);
        load(filename);
        %% Filter  channels (0.1 Hz to 80 Hz)
        for i = 1:size(EEG.data, 1)
            EEG.data(i,:) = eegfilt(EEG.data(i,:), 1000 ,0.1, 80, 0, 128, 0, 'fir1');
        end
        %% Parse File
        data = EEG.data;
%         clear EEG;
        %% Allot chunks of data
        index = C{1,1}(:,:);
        intervals = C{1,8}(:,:);
        types = C{1,4}(:,:);
        start = 1;
        num_channels = size(data,1);
        for i = 1:length(index)
            if types{i,1} == 'C'
                correct_distractor_data = [correct_distractor_data, data(1:size(data,1), start:start+chunk_size-1)];    
            elseif types{i,1} == 'P'
                missed_distractor_data = [missed_distractor_data, data(1:size(data,1), start:start+chunk_size-1)];    
            elseif types{i,1} == 'R'
                correct_target_data = [correct_target_data, data(1:size(data,1), start:start+chunk_size-1)];    
            elseif(types{i,1} == 'M')
                missed_target_data = [missed_target_data, data(1:size(data,1), start:start+chunk_size-1)];
            end
            if i < length(index)
                no_stimulus = [no_stimulus, data(1:size(data,1), start+1000:start+1000+chunk_size-1)];
            end
            start = start + intervals(i,1);
        end
        %% Train a separate classifier on each channel
        training_acc = [];
        classification_acc = [];
        class_full = [];
        for i = 1:size(data,1)
            %% SVM Variables
            Group = [];
            Training = [];
            %% Filter Stuff correct_distractor
            [ SVMdata, SVMclass ] = svm_data_get_filtered( no_stimulus, chunk_size, 0);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_target_data(i,:), chunk_size, 1);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_distractor_data(i,:), chunk_size, 1);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            %% Apply SVM       
            SVMStruct = svmtrain(Training(1:2:end,:),Group(1:2:end,:), 'kernel_function', 'rbf', 'rbf_sigma' , 1, 'boxconstraint', 1);
            %% Check Trained SVM on test data
            ClassifiedGroup = svmclassify(SVMStruct,Training(2:2:end,:));
            %% Measure Accuracy
            correct = find(ClassifiedGroup == Group(2:2:end,:));
            accuracy = (length(correct)/length(ClassifiedGroup))*100;
            classification_acc = [classification_acc, accuracy];
            class_full = [class_full, ClassifiedGroup];
            %% Check Trained SVM on training data
            ClassifiedGroup = svmclassify(SVMStruct,Training(1:2:end,:));
            %% Measure Accuracy
            correct = find(ClassifiedGroup == Group(1:2:end,:));
            accuracy = (length(correct)/length(ClassifiedGroup))*100;
            training_acc = [training_acc, accuracy];
        end
        classification_acc
        [max_classification_acc, channel] = max(classification_acc);
        min_classification_acc = min(classification_acc);
        mean_classification_acc = mean(classification_acc);
        best_channels = [best_channels, channel];
        classification_accuracy_matrix = [classification_accuracy_matrix; classification_acc];
%         pause
        % %% Ensemble Learning
        % sum_classified = sum(class_full, 2);
        % ensemble_classification = zeros(size(class_full,1),1);
        % for i = 1:size(sum_classified, 1)
        %     if(sum_classified(i,1) > (num_channels/2))
        %         ensemble_classification = 1;
        %     else
        %         ensemble_classification = 0;
        %     end
        % end
        % correct = find(ensemble_classification == Group(2:2:end,:));
        % ensemble_accuracy = (length(correct)/size(class_full,1))*100
        % classification_acc
        % training_acc
    end
end
result_file = '_eeg_nostim_results_cumulative.mat';
save(strcat(subjects{1,1}(2:4), result_file), 'classification_accuracy_matrix', 'best_channels')
best_channels


    