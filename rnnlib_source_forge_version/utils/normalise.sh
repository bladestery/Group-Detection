#!/bin/bash
FILES=../../dotnc/*.nc
for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  sh normalise_inputs.sh $f
done
