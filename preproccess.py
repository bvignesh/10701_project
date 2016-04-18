import sys

#fname = input('enter file name (extension): ')

fname = str(sys.argv[1])
print(fname)

fread = fname 
f = open(fread,'r')

## creating file to write relevant data into ##
fwrite = 'p_'+fname
g = open(fwrite,'w')

lines = f.readlines()

for i in range(len(lines)):
	if i == 7:
		print(lines[i])
	if i > 7:
		g.write(lines[i])

f.close()
g.close()
