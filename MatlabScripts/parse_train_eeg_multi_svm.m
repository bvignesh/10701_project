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
            Group1 = [];
            Training1 = [];  % this is for classifying between no stim and the rest
	    Group2 = [];
            Training2 = [];  % for classifying between correct target and the rest
            Group3 = [];
            Training3 = [];  % for classifying between correct distractor and the rest
	    %% Filter Stuff correct_distractor
            [ SVMdata, SVMclass ] = svm_data_get_filtered( no_stimulus, chunk_size, 1);
            Training1 = [Training1; SVMdata];
            Group1 = [Group1; SVMclass];
	    Training2 = [Training2; SVMdata];
            Group2 = [Group2; SVMclass - 1];
	    Training3 = [Training3; SVMdata];
            Group3 = [Group3; SVMclass - 1];
	    [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_target_data(i,:), chunk_size, 2);
            Training2 = [Training2; SVMdata];
            Group2 = [Group2; SVMclass];
            Training1 = [Training1; SVMdata];
            Group1 = [Group1; SVMclass - 2];
            Training3 = [Training3; SVMdata];
            Group3 = [Group3; SVMclass - 2];
            [ SVMdata, SVMclass ] = svm_data_get_filtered( correct_distractor_data(i,:), chunk_size, 3);
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
            ClassifiedGroup1 = svmclassify(SVMStruct1,Training1(2:2:end,:));
            ClassifiedGroup2 = svmclassify(SVMStruct2,Training2(2:2:end,:));
	    ClassifiedGroup3 = svmclassify(SVMStruct3,Training3(2:2:end,:));
	    %%Write to output files
	    output_filename1='svm_out1';
	    output_filename2='svm_out2';
	    output_filename3='svm_out3';
	    save(output_filename1,'SVMStruct1');
	    save(output_filename2,'SVMStruct2');
	    save(output_filename3,'SVMStruct3');
	    %%Measure Accuracy
	    correct1 = find(ClassifiedGroup1 == Group1(2:2:end,:));
	    error_rate1 = 1 - (length(correct1)/length(ClassifiedGroup1));
            correct2 = find(ClassifiedGroup2 == Group2(2:2:end,:));
	    error_rate2 = 1 - (length(correct2)/length(ClassifiedGroup2));
	    correct3 = find(ClassifiedGroup3 == Group3(2:2:end,:));
            error_rate3 = 1 - (length(correct3)/length(ClassifiedGroup3));
	end
     end
  end
