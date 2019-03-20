#!/bin/bash
# Author: Sarav - aksarav@middlewareinventory.com
# Purpose: LogRotation&LogPurging
# Name: diskspaceman.sh
#

# DECLARATIONS
BASEDIR=`dirname $0`
FILEDATE=`date +%d%m%y%H%M%S`
LOGDATE=`date +%d-%m-%y' '%H':'%M':'%S`

#Determine the username
if [ `whoami` == "weblogic" ]
then
        DIRTOSEARCH="/apps/weblogic/domains/*/servers/*/logs /opt/weblogic/domains/*/servers/*/logs /opt/weblogic/logs/* /apps/weblogic/logs/*"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`
elif [ `whoami` == "tomcat" ]
then
        DIRTOSEARCH="/opt/tomcat/instances/*/logs /apps/tomcat/instances/*/logs /opt/tomcat/logs/* /apps/tomcat/logs/*"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`
elif [ `whoami` == "artifactory" ]
then
        DIRTOSEARCH="/opt/jfrog/artifactory/tomcat/logs"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`   
elif [ `whoami` == "anthill" ]
then
        DIRTOSEARCH="/opt/artifactory/logs"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null` 
elif [ `whoami` == "domain" ]
then
        DIRTOSEARCH="/opt/np/domain/tomcat/logs"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`
elif [ `whoami` == "gym" ]
then
        DIRTOSEARCH="/opt/np/gym/tomcat/logs"
        LOGSDIRS=`ls -d $DIRTOSEARCH 2>/dev/null`        
else
        echo -e "Correct the Errors before proceeding\n"
        echo -e "ERROR: Invalid User to run the script"
        echo -e "Valid Users are \n\t 1) tomcat \n\t 2) weblogic\n\t 3) artificatory"
        exit 3
fi

#Determine the Directory
if [ $BASEDIR == "." ]
then
        #Change BASEDIR to Full Path
        BASEDIR=`pwd`
fi

#Determine the number of inputs
if [ $# -ne 1 ]
then
        echo -e "Please execute the script correctly"
        echo "./diskspaceman.sh --retentionperiod=400days"
        exit
fi

#Check for the Proper Startup Argument
if [ `echo $1|cut -d "=" -f1` == "--retentionperiod" ]
then
        RETENTION=`echo $1|cut -d "=" -f2|awk -F "days" '{print $1}'`
else
        echo -e "Please execute the script correctly"
        echo "./diskspaceman.sh --retentionperiod=400days"
        exit
fi

LOG()
{
        echo -e "$LOGDATE $@"
}

LOGROTATE()
{
        for OUTFILE in $@
        do
                sed "s/REPLACELOGFILE/`echo $OUTFILE|sed -f $BASEDIR/front2back.sed`/g" $BASEDIR/logrotate-out.conf-template  > $BASEDIR/logrotate-out.conf
                /usr/sbin/logrotate -s /tmp/diskspaceman-lgrt-statusfile -f $BASEDIR/logrotate-out.conf

                if [ $? -eq 0 ]
                then
                        LOG "-- LOGROTATION COMPLETED SUCCESSFULLY FOR $OUTFILE"
                else
                        LOG "-- LOGROTATION FAILED FOR $OUTFILE"
                fi
        done
}


PURGE()
{
        FILETOREMOVE=`find $DIR -type f -mtime +$RETENTION -name "*.gz$"`
        LOG "REMOVING THE $RETENTION DAYS OLD FILES WITH GZ EXTENSION"
        LOG "LIST OF FILES GOING TO BE REMOVED: [ `echo $FILETOREMOVE|sed 's/ /,/g' ` ]"
        find $DIR -type f -mtime +$RETENTION -name "*.gz$" -exec rm -vf {} \;
        LOG
                LOG "G-ZIPPING THE OTHER AVAILABLE LOGS OLDER THAN 5 DAYS"
                                # PURGING THE LOG FILES OLDER THAN TWO DAYS
                if [ `find $DIR -type f -mtime +5|egrep -v  "*.gz$|*.cfg$|*.pid$"|wc -l` -gt 0 ]
                then
                        #find . -type f -mtime +5|egrep -v  "*.gz$|*.cfg$|*.pid$"|xargs gzip -v
                        find . -type f -mtime +5 -not -name "*.gz" -not -name "*.cfg" -not -name "*.pid" -exec  gzip -v --suffix $(date +".%m-%d-%Y.gz") {} \;
                else
                        LOG "NO LOGS FOUND FOR COMPRESS (GZIP)..SKIPPING"
                fi

}

#MAIN - START

LOG " **** DISKSPACEMAN - PROCESS STARTED ****"

LOG "LIST OF DIRECTORIES FOUND: [ `echo $LOGSDIRS|sed 's/ /,/g' ` ]"
for DIR in $LOGSDIRS
do
        LOG
        LOG
        LOG "==========================================================="
                # INTO THE DIRECTORY
        LOG "PROCESSING DIRECTORY: $DIR"
        LOG
                # Consider only the files modified today
        LISTOFFILES=`find $DIR -mtime -1 -name "*.log" -o -mtime -1 -name "*.out"`
        cd $DIR
        LOG "LIST OF FILES FOUND FOR LOGROTATION: [ `echo $LISTOFFILES|sed 's/ /,/g' ` ]"

        #Initiate Log Rotation for these files
        LOGROTATE $LISTOFFILES

                #PURGING PROCESS STARTS
                LOG
                LOG "PURGING PROCESS STARTED  "
                PURGE $DIR
                LOG "PURGING PROCESS COMPLETED"

                # OUT OF THE DIRECTORY
                cd $BASEDIR
        LOG "==========================================================="
done

LOG
LOG " **** DISKSPACEMAN - PROCESS COMPLETED ****"
