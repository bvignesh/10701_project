close all
clear all
warning('off', 'all')
%% File Info
path = 'C:\Users\sande_000\Downloads\CMU\Courses\Sem2\10701-Machine Learning\Project\Data';
subjects = {'\cba'};
train_files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};
% train_files = {'1ff04'};
ext = '.mat';
best_channels = [];
classification_accuracy_matrix = [];
%% Read files
for k = 1:length(subjects)
    for j = 1:length(train_files)
        %% Types of Data by class
        correct_distractor_data = [];      % Corresponds to C
        missed_distractor_data  = [];      % Corresponds to P
        correct_target_data     = [];      % Corresponds to R
        missed_target_data      = [];      % Corresponds to M
        no_stimulus = [];
        %% Data params
        chunk_size = 100;                  % in ms
        %% Read Data from Mat file
        filename = sprintf('%s%s%s%s%s', path, subjects{1,k}, subjects{1,k}, train_files{1,j}, ext);
        fprintf('%s\n', filename);
        load(filename);
        %% Filter and Downsample channels (0.1 Hz to 80 Hz, Downsample from 1000 Hz to 250 Hz)
        epochs_num = floor(size(EEG.data, 2)/chunk_size);
        EEG.data = (detrend(EEG.data','constant'))';
        for i = 1:size(EEG.data, 1)
            EEG.data(i,:) = eegfilt(EEG.data(i,:), 1000 ,0.1, 80, 0, 128, 0, 'fir1');
        end
        EEG_down = pop_resample(EEG, 250);
        chunk_size = floor(chunk_size/4);                  % in ms
        %% Parse File and Run ICA
        EEG_ICA = pop_runica(EEG_down, 'icatype', 'runica')
        data = EEG_ICA.icaweights*EEG_ICA.icasphere*EEG_ICA.data;
%         clear EEG;
%         clear EEG_ICA;
        %% Allot chunks of data
        index = C{1,1}(:,:);
        intervals = floor(C{1,8}(:,:)/4);
        types = C{1,4}(:,:);
        start = floor(75/4);
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
                no_stimulus = [no_stimulus, data(1:size(data,1), start+250:start+250+chunk_size-1)];
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
%             [ SVMdata, SVMclass ] = svm_data_get_ica( no_stimulus(i,:), chunk_size, 0);
%             Training = [Training; SVMdata];
%             Group = [Group; SVMclass];
            [ SVMdata, SVMclass ] = svm_data_get_ica( correct_distractor_data(i,:), chunk_size, 0);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            [ SVMdata, SVMclass ] = svm_data_get_ica( correct_target_data(i,:), chunk_size, 1);
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
        [max_classification_acc, channel] = max(classification_acc)
        min_classification_acc = min(classification_acc);
        mean_classification_acc = mean(classification_acc);
        best_channels = [best_channels, channel];
        classification_accuracy_matrix = [classification_accuracy_matrix; classification_acc];
    end
end
result_file = '_ica_stim_results100.mat';
save(strcat(subjects{1,1}(2:4), result_file), 'classification_accuracy_matrix', 'best_channels');
best_channels
