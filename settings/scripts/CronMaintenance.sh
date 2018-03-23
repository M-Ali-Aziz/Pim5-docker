#!/bin/bash

# Modified & updated by  ldc-rln    Wed Jul  5 10:18:06 CEST 2017

MailTo=""
######################################################
###  Script start setup 
######################################################
cmd=$1
shift
# move to homedir for the script
cd $(dirname $0)
bin="."
# if we use ./bin{-dir} the working dir is one step up
if [[ $(basename $PWD) = "bin" ]]
then
        cd ..
        bin="bin"
fi
script=$(basename $0)
masterscript=$(readlink -e ${bin}/${script})
basedir=${PWD}
# DATESTAMP=$(date +"%Y%m%d_%H%M%S")
DATESTAMP=$(date +"%Y%m%d")
LOGDIR=log
LOGFILE=${LOGDIR}/${script}_${DATESTAMP}.log
ERRFILE=${LOGDIR}/${script}_${DATESTAMP}_ERR.log
OLDLOGS="${LOGDIR}/${script}_*.log"
NoOldLogs=30


######################################################
###  Script logfile
######################################################
if [[ ! -d ${LOGDIR} ]]
then
        mkdir -p ${LOGDIR}
fi
case "${cmd}" in
        *errlog)
                exec >> $LOGFILE 2> $ERRFILE
                ;;
        *log)
                exec >> $LOGFILE 2>&1
                ;;
esac


date  +"=========== Begin of ${script} on [$(hostname --short)] %Y-%m-%d %H:%M.%S =========="
echo " Ver: $(basename ${masterscript}) $(stat --format="%.19z" ${masterscript})  #$(sum -r ${masterscript})"
echo 

######################################################
###  Clear out old logfiles from backup runs
######################################################
for oldlogs in $(ls -t ${OLDLOGS} 2>/dev/null | tail --lines=+${NoOldLogs})
do
        echo "Removes logfile -> ${oldlogs}"
        rm ${oldlogs}
done

############################################################
###  Mailing function
############################################################
function Mailing
{
    (
        printf "From: <%s@%s>\n" "$3" "$(hostname --fqdn)"
        printf "To: "
        printf "<%s>, " $2
        printf "\n"
        printf "Subject: %s\n" "$1"
        printf "Content-Type: text/html; charset="iso-8859-1"\n"
        printf "Content-Transfer-Encoding: 8bit\n"
        printf "\n"
        aha --iso 1
    ) | /usr/sbin/sendmail -t -f "$3@$(hostname --fqdn)"
}

######################################################
###  Script TheEnd function
######################################################
SERVER="[$(hostname --short)] <LADOK LW>"

function TheEnd
{
    case "$1" in
        ok|"")
            errinf=""
            xit=0;
            ;;
        dbg*|dev*)
            echo "Script Testing END"
            cmd="test_${cmd}"
            xit=1;
            ;;
        *)
            echo "ERROR exit: ($1)"
            errinf="ERROR "
            xit=0;
            ;;
    esac

    echo 
    date  +"=========== End of ${script} on [$(hostname --short)] %Y-%m-%d %H:%M.%S =========="

    case "${cmd}" in
        test*)
            echo "No Email"
            ;;
        *)
            if [[ -r $LOGFILE && -n "$MailTo" ]]
            then
                set +x
                Mailing "${subject}" "${MailTo}" "webadmin" < $LOGFILE
            fi
            ;;
    esac
    exit $xit
}

######################################################
###  Setup 
######################################################
case "${cmd}" in
        test*)
                ;;
esac

######################################################
### Run maintenance Jobet  
######################################################

umask 022

cd ../http/ehl/

# sudo -u www-data ./pimcore/cli/console.php maintenance -v --ansi --job="scheduledtasks,cleanupcache,logmaintenance,sanitycheck,cleanuplogfiles,httperrorlog,versioncleanup,versioncompress,redirectcleanup,cleanupbrokenviews,usagestatistics,downloadmaxminddb,tmpstorecleanup,imageoptimize"

for job in scheduledtasks logmaintenance cleanuplogfiles httperrorlog usagestatistics checkErrorLogsDb archiveLogEntries sanitycheck versioncleanup versioncompress redirectcleanup cleanupbrokenviews downloadmaxminddb cleanupcache tmpstorecleanup imageoptimize cleanupTmpFiles LUSyncPlugin\\Plugin Lucat\\Plugin News\\Plugin
do
    printf "\n%s === RUN job %s%s%s ===%s\n" "${LY}" "${LB}" "${job}" "${LY}" "${N}"
    sudo -u www-data ./bin/console maintenance -v --ansi --job="${job}" | sed 's/Pimcore\\\\Model\\\\Schedule\\\\Manager\\//g'
done

chown www-data:www-data ./var/config/lu-sync.php

TheEnd ok