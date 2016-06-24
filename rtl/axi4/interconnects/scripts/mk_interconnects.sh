#!/bin/sh

n_masters=1
n_slaves=1
n_masters_max=8
n_slaves_max=8

echo "" > axi4_interconnects.f

while test $n_masters -le $n_masters_max; do
	n_slaves=1;
	while test $n_slaves -le $n_slaves_max; do
		for pt in 0 1; do
			if test $pt -eq 0; then
				perl scripts/mk_interconnect.pl -f \
					-o "axi4_interconnect_${n_masters}x${n_slaves}.sv" \
					-n_masters $n_masters -n_slaves $n_slaves -default-slave-error
				echo "\${SOCBLOX}/units/interconnects/axi4/axi4_interconnect_${n_masters}x${n_slaves}.sv" >> axi4_interconnects.f
			else
				perl scripts/mk_interconnect.pl -f \
					-o "axi4_interconnect_${n_masters}x${n_slaves}_pt.sv" \
					-n_masters $n_masters -n_slaves $n_slaves -default-slave-passthrough
				echo "\${SOCBLOX}/units/interconnects/axi4/axi4_interconnect_${n_masters}x${n_slaves}_pt.sv" >> axi4_interconnects.f
			fi
		done
		n_slaves=`expr $n_slaves + 1`
	done
	n_masters=`expr $n_masters + 1`
done

	
