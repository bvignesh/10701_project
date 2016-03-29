a = load('cba1ff01.mat' ); 
eeg_data = zeros(size(a.EEG.data)(1,1),size(a.EEG.data)(1,2));

for i = 1:(size(a.EEG.data))(1,1)
  i
  for j = 1:(size(a.EEG.data))(1,2) 
 
    eeg_data(i,j) = a.EEG.data(i,j);
  endfor
endfor

