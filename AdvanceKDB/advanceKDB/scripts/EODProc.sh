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
    echo " EODProc.sh [FP]"
	echo " "
    echo " FP: HOME/advanceKDB/log/<log>"
	echo 
}

function main(){

if [[ $# -eq 1 ]] ; then
   $Q $common_dir/EODProc.q $1
else 
	usage
fi

}

main $1
