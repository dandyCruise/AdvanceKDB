#!/bin/bash -f

parent_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
common_dir=${parent_dir}/common

source ${common_dir}/env.sh

##########################################################################################
#
# Print the usage
#
##########################################################################################
function usage(){
    echo
    echo " loadCSV.sh [FP][Table][Header]"
	echo " "
    echo " FP: HOME/advanceKDB/files/trade.csv"
    echo " Table: trade | quote "
    echo " Header: CSV have header 1 | 0"
	echo 
}

function main(){

if [[ $# -eq 3 ]] ; then
   $Q ${parent_dir}/common/CSVLoad.q $1 $2 $3
else 
	usage
fi

}

main $1 $2 $3 
