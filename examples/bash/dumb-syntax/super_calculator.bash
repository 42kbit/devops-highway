#! /bin/bash

# get byte size of file with filename specified in first argument
# get first word, with default delimiter (space)
file1_size=`du -b $1 | cut -f1`
file2_size=`du -b $2 | cut -f1`

echo "$file1_size ($1) + $file2_size ($2) = $(($file1_size + $file2_size))"