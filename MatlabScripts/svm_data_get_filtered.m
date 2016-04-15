function [ SVMdata, SVMclass ] = svm_data_get_filtered( data, chunk_size, class)
%% Return SVM Readable data 
% Takes one channel of SVM data and filters it in the range 0.1 to 80 Hz,
% then downsamples it
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
%    [smoothdata] = eegfilt(data(1,start:end_point),1000 ,0.1, 80, 0 , 128, 0, 'fir1');
   smoothdata = data(1,start:end_point);
   features = downsample(smoothdata, 4); 
   SVMdata = [SVMdata; features];
   SVMclass = [SVMclass; class];
end
end

