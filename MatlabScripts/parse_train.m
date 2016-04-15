close all
clear all
%% Types of Data by class
correct_distractor_data = [];      % Corresponds to C
missed_distractor_data  = [];      % Corresponds to P
correct_target_data     = [];      % Corresponds to R
missed_target_data      = [];      % Corresponds to M
%% Data params
chunk_size = 500;                  % in ms
%% File Info
path = 'C:\Users\sande_000\Downloads\CMU\Courses\Sem2\10701-Machine Learning\Project\Data';
subjects = {'\cba'};
train_files = {'1ff01','1ff04','1ff07','1ff10','1ff13', '2ff01','2ff04','2ff07','2ff10','2ff12'};
ext = '.mat';
%% Read files
for k = 1:length(subjects)
    for j = 1:length(train_files)
        filename = sprintf('%s%s%s%s%s', path, subjects{1,k}, subjects{1,k}, train_files{1,j}, ext);
        load(filename);
        %% Parse File
        data = EEG.data;
        clear EEG;
        %% Allot chunks of data
        index = C{1,1}(:,:);
        intervals = C{1,8}(:,:);
        types = C{1,4}(:,:);
        start = 1;
        num_channels = size(data,1);
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
    end
end
%% SVM Variables
Group = [];
Training = [];
%% Filter Stuff correct_distractor
[ SVMdata, SVMclass ] = svm_data_get( correct_distractor_data, chunk_size, 0, num_channels);
Training = [Training; SVMdata];
Group = [Group; SVMclass];
[ SVMdata, SVMclass ] = svm_data_get( correct_target_data, chunk_size, 1, num_channels);
Training = [Training; SVMdata];
Group = [Group; SVMclass];
% [ SVMdata, SVMclass ] = svm_data_get( data, chunk_size, class)
% [ SVMdata, SVMclass ] = svm_data_get( data, chunk_size, class)
%% Apply SVM       
SVMStruct = svmtrain(Training(1:2:end,:),Group(1:2:end,:));
%% Check Trained SVM
ClassifiedGroup = svmclassify(SVMStruct,Training(2:2:end,:));
%% Write to output file
output_filename = 'svm_cba';
save(output_filename, 'SVMStruct');
%% Measure Accuracy
correct = find(ClassifiedGroup == Group(2:2:end,:));
error_rate = 1 - (length(correct)/length(ClassifiedGroup));
%% Plotting
% class1 = [];
% class2 = [];
% for i = 1:size(Training,1)
%     if(Group(1,i) == 1)
%         class1 = [class1; Training(i, 1:2)];
%     else
%         class2 = [class2; Training(i, 1:2)];
%     end
% end
% figure(4)
% plot(class1(:,1), class1(:,2), 'b*');
% hold on
% plot(class2(:,1), class2(:,2), 'r*');