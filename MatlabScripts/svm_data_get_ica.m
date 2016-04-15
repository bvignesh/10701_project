function [ SVMdata, SVMclass ] = svm_data_get_ica( data, chunk_size, class)
%% Return SVM Readable data 
% Takes one channel of SVM data make it svm compatible
SVMdata = [];
SVMclass = [];
for j = 1:chunk_size:size(data,2)
    start = j;
    if(size(data,2) - j < chunk_size)
        end_point = size(data,2);
        break;
    else
        end_point = start + chunk_size - 1;
    end
%     [smoothdata] = eegfilt(data(1,start:end_point),250 ,0.1, 80, 0 , 32, 0, 'fir1');
%     features = smoothdata;
    features = data(1,start:end_point); 
    SVMdata = [SVMdata; features];
    SVMclass = [SVMclass; class];
end
end

