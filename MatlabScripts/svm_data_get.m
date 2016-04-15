function [ SVMdata, SVMclass ] = svm_data_get( data, chunk_size, class, num_channels)
%% Return SVM Readable data
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
    features = [];
    for i = 1:num_channels
        [smoothdata] = eegfilt(data(i,start:end_point),1000 ,7.5,12.5, 0 , 128);
        [psd, f] = periodogram(smoothdata, rectwin(length(smoothdata)), 256, 1000);
%         subplot(4,8,i)
%         stem(f(2:12),psd(2:12));
%         pause
        features = [features, psd(3:5)'];
    end
    SVMdata = [SVMdata; features];
    SVMclass = [SVMclass; class];
end
end

