%
y1 = dlmread('cba1ff01.csv',',');
%eeg_strips = cell(size(y1)(1,1),size(eeg_data)(1,1));  %rows = number of trials  and col = number of eeg channels
curr_time = 0;
iter = 1;
while (iter <= size(y1)(1,1))
  resp_t = y1(iter,5);
  isi_t = y1(iter,6);
  for i = 1:size(eeg_data)(1,1)
    eeg_strips{iter,i} = eeg_data(i,(curr_time+1):(curr_time+1+resp_t));
  endfor
  curr_time += isi_t
  iter +=1
endwhile

