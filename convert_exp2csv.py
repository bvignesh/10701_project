fname = input("Enter file name(dont include extension)")
#fname = "cba1ff01"

lname = fname + ".exp"

f = open(lname,'r')

savename = fname + ".csv"

g = open(savename, 'a')

trial_no = []
classification = []
actual_output = []
trial_type = []
resp_time = []
isi_time = []		#Inter Stimulus Interval time


lines = f.readlines() 
for i in range(len(lines)):
	line = lines[i].strip()
	line = line.split("\t")

	#if (i < 3):
	#	print(line)
	
	trial_no.append(line[0])
	isi_time.append(line[len(line) - 1])
	resp_time.append(line[len(line) - 2])
	trial_type.append(line[len(line) - 3])
	actual_output.append(line[len(line) - 4])
	classification.append(line[len(line) - 5])

#print(classification[45])
#print(isi_time[45])


#time to save things into a csv file

for i in range(len(lines)):
	g.write(trial_no[i] + "," + classification[i] + "," + actual_output[i] + "," + trial_type[i] \
	+ "," + resp_time[i] + "," + isi_time[i]);
	g.write("\n")
