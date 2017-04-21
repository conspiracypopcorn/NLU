#!/bin/bash

smoothing_methods="witten_bell absolute katz kneser_ney presmoothed unsmoothed"

for method in ${smoothing_methods[@]}
do
	for order in {1..5}
	do
		echo "$method\t$order"
	done
done
