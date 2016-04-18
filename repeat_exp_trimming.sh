#!/bin/bash

echo "enter the subject name (three letters - same as folder name) "
read val

for f in $val*.exp 
do
	python ../../ML_project_github/preproccess.py $f
done
	
