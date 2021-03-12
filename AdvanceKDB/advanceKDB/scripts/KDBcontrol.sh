#!/bin/bash

home_dir=$( cd  "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )
source ${home_dir}/common/env.sh

function usage(){
    echo
    echo " Please enter the correct arguments"
    echo " Summary given below:"
    echo
    echo " ./KDBcontrol.sh [command][instance]"
    echo " Command : start/stop"
    echo " instance:"
    echo "			all"
    echo "			TP"
    echo "			RDB"
    echo "			RDB2"
    echo "			FH"
    echo "			CEP"
    echo ""
	echo " OR For Running component details"
	echo " ./KDBcontrol.sh test"
	echo

}

function main(){

case $1 in 
	start)
    
	case $2 in
        	all)
           		start_q TP tick.q
            		sleep 3
         		start_q CEP cep.q
        		sleep 3
            		start_q RDB r.q
            		sleep 3
            		start_q RDB2 2r.q
            		sleep 3
            		start_q FH fh.q
            		sleep 3
        		;;
        	TP )
           		start_q $2 tick.q
           		sleep 3
            		;;
        	RDB )
           		start_q $2 r.q
            		sleep 3
            		;;
        	FH )
        		start_q $2 fh.q 
            		sleep 3
            		;;
		RDB2 )
                	start_q $2 2r.q
                	sleep 3
                	;;
		CEP )
                	start_q $2 cep.q
                	sleep 3
                	;;
        	* )
            		usage
   		esac;;
	stop)
	
	case $2 in 
		all)
		 	stop_process_by_log ${home_dir}/SRC/TP/log/TP.log
		 	sleep 2
		 	stop_process_by_log ${home_dir}/SRC/RDB/log/RDB.log
                 	sleep 2
		 	stop_process_by_log ${home_dir}/SRC/RDB2/log/RDB2.log
                 	sleep 2
		 	stop_process_by_log ${home_dir}/SRC/FH/log/FH.log
                 	sleep 2
		 	stop_process_by_log ${home_dir}/SRC/CEP/log/CEP.log
                 	sleep 2
			;;
	
		TP|RDB|RDB2|CEP|FH)

			echo "This will terminate the *["$2"]* process. Are you sure you want to proceed? [Y/N] "
                	read proceed

               		 if [[ "${proceed}" != "Y" && "${proceed}" != "y" ]]; then
                	echo "exiting..."
               		 exit 0
               		 fi
			stop_process_by_log ${home_dir}/SRC/$2/log/${2}.log
			;;
		*)
			usage
		esac;;
	
	test)
		pid_test ${home_dir}/SRC/TP/log/TP.log ${home_dir}/SRC/RDB/log/RDB.log ${home_dir}/SRC/FH/log/FH.log ${home_dir}/SRC/RDB2/log/RDB2.log ${home_dir}/SRC/CEP/log/CEP.log
		;;
	*)
		usage
	esac
}


################################################################
#
# starts here ....
#
################################################################

function pid_test(){
	echo "Running Processes: LogFile/PID/USER "
	/sbin/fuser -u $1 $2 $3 $4 $5 
}

function start_q(){
  echo "Starting Kdb+ process for $1"
  echo "Log: ${home_dir}/SRC/$1/log/${1}.log"
  nohup ${Q} ${home_dir}/SRC/$1/q/$2 >> ${home_dir}/SRC/$1/log/${1}.log 2>&1 &
  echo "Done."
}


function stop_process_by_log(){
  pid=`/sbin/fuser ${1}| awk '{FS==" ";print $1}'`
  `kill ${pid}`
  sleep 2
  ct=`ps ${pid}|wc -l`

  if [ "${ct}" -ne "1" ]; then
    `kill -9 ${pid}`
  fi
}


function stop_q(){
  echo "Stoping Kdb+ process for $1"
  stop_process_by_log $home_dir/SRC/logs/$1
  echo "Done."
}

### start services

main ${1} ${2}



