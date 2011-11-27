#!/bin/bash

for i in {0..9}
do
    offset=$[$i*64]
    index=$[$i+1]
    convert -crop "64x439+$offset" $1 "$index.jpg"
done
