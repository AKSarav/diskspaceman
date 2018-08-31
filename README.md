# DiskSpaceMan
An Automation for Logrotation, LogPurging and Compressing For weblogic and tomcat Standard Installations

# Overview
DiskSpaceMan is a Shell script,  designed in bash with various modules. It was initially designed for Log Rotation and further expanded to acheive
the following tasks under a single window.

  - Log Rotation
  - Log Purging
    - Removal of Old Logs based on the Retention Period
    - Compressing the Uncompressed Rotated log files
    
 # How To Execute
 
 **Step1:** Download the All in one ZIP file `diskspaceman.zip` from the repository
 
 **Step2:** Uncompress/Unzip the downloaded zip file
 
 **Step3:** Execute the script as a valid user, Either ```tomcat``` or ```weblogic``` along with the desired **retentionperiod**
 
 ```shell
 ./diskspaceman.sh --retentionperiod=30days
 ```
 
 # BuiltIn Features
 
 ### :point_right: Efficient Logging
    
 The script is designed with an efficient and **Debug level** logging functionality. All messages to **STDOUT** is properly formatted 
 with time stamp. Take a look at the sample given below
    
 ```java
    weblogic@testserver> ./diskspaceman.sh --retentionperiod=100days
    22-08-18 14:57:27  **** DISKSPACEMAN - PROCESS STARTED ****
    22-08-18 14:57:27 LIST OF DIRECTORIES FOUND: [ /opt/weblogic/domains/test_domain/servers/AdminServer/logs,/opt/weblogic/domains/test_domain/servers/wls_PegaServer1/logs,/opt/weblogic/logs/pega ]
    22-08-18 14:57:27
    22-08-18 14:57:27
    22-08-18 14:57:27 ===========================================================
    22-08-18 14:57:27 PROCESSING DIRECTORY: /opt/weblogic/domains/test_domain/servers/AdminServer/logs
    22-08-18 14:57:27
    22-08-18 14:57:27 LIST OF FILES FOUND FOR LOGROTATION: [ access.log,AdminServer.log,test_domain.log ]
    22-08-18 14:57:27 -- LOGROTATION COMPLETED SUCCESSFULLY FOR /opt/weblogic/domains/test_domain/servers/AdminServer/logs/access.log
    22-08-18 14:57:27 -- LOGROTATION COMPLETED SUCCESSFULLY FOR /opt/weblogic/domains/test_domain/servers/AdminServer/logs/AdminServer.log
    22-08-18 14:57:27 -- LOGROTATION COMPLETED SUCCESSFULLY FOR /opt/weblogic/domains/test_domain/servers/AdminServer/logs/test_domain.log
    22-08-18 14:57:27
    22-08-18 14:57:27 PURGING PROCESS STARTED
    22-08-18 14:57:27 REMOVING THE 100 DAYS OLD FILES
    22-08-18 14:57:27 LIST OF FILES GOING TO BE REMOVED: [  ]
    22-08-18 14:57:27
    22-08-18 14:57:27 G-ZIPPING THE OTHER AVAILABLE LOGS
    ./test_domain.log06787:  97.1% -- replaced with ./test_domain.log06787.gz
    ./logrotate-out.conf:     0.0% -- replaced with ./logrotate-out.conf.gz
    ./test_domain.log06835:  96.9% -- replaced with ./test_domain.log06835.gz
    ./test_domain.log06808:  97.1% -- replaced with ./test_domain.log06808.gz
    ./test_domain.log06826:  97.0% -- replaced with ./test_domain.log06826.gz
    ./test_domain.log06878:  97.1% -- replaced with ./test_domain.log06878.gz
    22-08-18 14:57:27 PURGING PROCESS COMPLETED
    22-08-18 14:57:27 ===========================================================
 ```
    
 Here you could notice that all userful information is getting printed including the file name and the directory the script is processing 
    
It can help to understand the working prinicple of this script and it comes handy for troubleshooting in case of any issues in future.
    

### :point_right: Runtime Validations

The script performs multiple level of validation to make sure **nothing goes wrong**

#### Validation1: Username validation

The script will try to validate the `username` as it is being invoked, to determine the correct **workspace** _The Log directories_
Script is designed to dynamically switch the log directories based on the user of execution. This is to avoid an accidental execution
of script as an invalid user like `root` , which would end up in messing up the logs and eventually result it application downtime

**_weblogic_**

If the script has been started as a `weblogic` user, the script will consider the following directories as a workspace

  ```
   /apps/weblogic/domains/*/*/*/logs 
   /opt/weblogic/domains/*/*/*/logs 
   /opt/weblogic/logs/* 
   /apps/weblogic/logs/*            
  ``` 

**_tomcat_**

If the script has been started as a `tomcat` user, the script will consider the following directories as a workspace

  ```
   /apps/tomcat/instances/*/logs 
   /opt/tomcat/instances/*/logs
   /opt/tomcat/logs/* 
   /apps/tomcat/logs/*            
  ```
  
 If the script is started as any other user, the script would print an error message and exit. Sample execution shown below
 
 ```java
  root@testserver# whoami
  root
  root@testserver# ./diskspaceman.sh --retentionperiod=100days
  Correct the Errors before proceeding

  ERROR: Invalid User to run the script
  Valid Users are
           1) tomcat
           2) weblogic

  root@testserver#
  ```
 #### Validation2: Startup Argument Validation
 
 The script gets the `retentionperiod` as a startup arguement, Attempt of execution without the startup arguement would yield the following result
 
 ```shell
 
  #Tried with no startup argument
  weblogic@testserver> ./diskspaceman.sh
  Please execute the script correctly
  ./diskspaceman.sh --retentionperiod=400days

  #Tried with wrong or invalid startup argument
  weblogic@testserver> ./diskspaceman.sh --asdfasdf
  Please execute the script correctly
  ./diskspaceman.sh --retentionperiod=400days

  #Spelling mistake in Startup argument
  weblogic@testserver> ./diskspaceman.sh --retentionpariod=300
  Please execute the script correctly
  ./diskspaceman.sh --retentionperiod=400days
  weblogic@testserver>

 ```
 
 ## Risk Assesement
 
  :snowflake: Script does not use `rm` or `mv` command to prevent accidential log overwriting or deletion
  
  :snowflake: It uses the Native **logrotate** command instead of manually copying and performing the log rotation
  
  :snowflake: It leave no log file (or) foot print in the file system as the output is directly printed to STDOUT, If you would liketo save the output to a file 
  you can use runtime redirection using `> logfilename 2>&1`
  
  :snowflake: CPU load and memory load of this script has been tested and proven to be Efficient and not having any issues.
  
 ## Additional Notes 
 
  - Complete Test Execution Session Output is in the repository for your reference
  - This Script can be scheduled to run everyday using **crontab** for efficient server management and housekeeping.
  

 
  
