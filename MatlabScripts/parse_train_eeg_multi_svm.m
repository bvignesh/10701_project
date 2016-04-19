close all
clear all
warning('off', 'all')
%% File Info
path = '../../data_set';
subjects = {'/ega'};
train_files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};
% train_files = {'1ff04'};
ext = '.mat';
num_channels = 31;
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
        start = 75;
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
            Group1 = [];
            Training1 = [];  % this is for classifying between no stim and the rest
	    Group2 = [];
            Training2 = [];  % for classifying between correct target and the rest
            Group3 = [];
            Training3 = [];  % for classifying between correct distractor and the rest
	    %% Filter Stuff correct_distractor
            [ SVMdata, SVMclass ] = svm_data_get_filtered( no_stimulus, chunk_size, 1);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            Training1 = [Training1; SVMdata];
            Group1 = [Group1; SVMclass];
	    Training2 = [Training2; SVMdata];
            Group2 = [Group2; SVMclass - 1];
	    Training3 = [Training3; SVMdata];
            Group3 = [Group3; SVMclass - 1];
	    [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_target_data(i,:), chunk_size, 2);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            Training2 = [Training2; SVMdata];
            Group2 = [Group2; SVMclass];
            Training1 = [Training1; SVMdata];
            Group1 = [Group1; SVMclass - 2];
            Training3 = [Training3; SVMdata];
            Group3 = [Group3; SVMclass - 2];
            [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_distractor_data(i,:), chunk_size, 3);
            Training = [Training; SVMdata];
            Group = [Group; SVMclass];
            Training3 = [Training3; SVMdata];
            Group3 = [Group3; SVMclass];
	    Training2 = [Training2; SVMdata];
            Group2 = [Group2; SVMclass - 3];
            Training1 = [Training1; SVMdata];
            Group1 = [Group1; SVMclass - 3];
            %% Apply SVM       
            SVMStruct1 = svmtrain(Training1(1:2:end,:),Group1(1:2:end,:), 'kernel_function', 'rbf', 'rbf_sigma' , 1, 'boxconstraint', 1);
	    SVMStruct2 = svmtrain(Training2(1:2:end,:),Group2(1:2:end,:), 'kernel_function', 'rbf', 'rbf_sigma' , 1, 'boxconstraint', 1);
	    SVMStruct3 = svmtrain(Training3(1:2:end,:),Group3(1:2:end,:), 'kernel_function', 'rbf', 'rbf_sigma' , 1, 'boxconstraint', 1);
            %% Check Trained SVM on test data
            ClassifiedGroup1 = svmclassify(SVMStruct1,Training(2:2:end,:));
            ClassifiedGroup2 = svmclassify(SVMStruct2,Training(2:2:end,:));
            ClassifiedGroup3 = svmclassify(SVMStruct3,Training(2:2:end,:));
            %% Form a consensus of the output of three classifiers
            ClassifiedGroup = ClassifiedGroup1;
            for it = 1:size(ClassifiedGroup1, 1)
                if ClassifiedGroup1(i,1) == 1 && ClassifiedGroup2(i,1) == 0 && ClassifiedGroup3(i,1) == 0 
                    ClassifiedGroup(i,1) = 1;
                elseif ClassifiedGroup2(i,1) == 2 && ClassifiedGroup1(i,1) == 0 && ClassifiedGroup3(i,1) == 0
                    ClassifiedGroup(i,1) = 2;
                elseif ClassifiedGroup3(i,1) == 3 && ClassifiedGroup2(i,1) == 0 && ClassifiedGroup1(i,1) == 0
                    ClassifiedGroup(i,1) = 3;
                else
                    ClassifiedGroup(i,1) = 0;
                end
                
                
            end
            
            %% Measure Accuracy
            correct = find(ClassifiedGroup == Group(2:2:end,:));
            accuracy = (length(correct)/length(ClassifiedGroup))*100;
            classification_acc = [classification_acc, accuracy];
            class_full = [class_full, ClassifiedGroup];
            %% Check Trained SVM on training data
            %ClassifiedGroup = svmclassify(SVMStruct,Training(1:2:end,:));
            %% Measure Accuracy
            correct = find(ClassifiedGroup == Group(2:2:end,:));
            accuracy = (length(correct)/length(ClassifiedGroup))*100;
            training_acc = [training_acc, accuracy]
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
result_file = '_eeg_nostim_results100.mat';
save(strcat(subjects{1,1}(2:4), result_file), 'classification_accuracy_matrix', 'best_channels')
best_channels
            
	    
	   
