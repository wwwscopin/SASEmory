#!/bin/ksh
export PATH="$PATH/opt/sas8"
# Initializing variables
date1=`date +%m/%d/%y`
# Remove Previous output files
# Starting code execution
echo 'Starting to run the sas Job' > sas_job.log
echo Start Date: $date1 >> sas_job.log
sas run.sas -noterminal
echo 'Finished running the sas Job' >> sas_job.log
date2=`date +%m/%d/%y`
echo End Date: $date2 >> sas_job.log
# Sending Log File via email
uuencode run.log run.log | mailx -s "LOG FILES" bwu2@emory.edu
# Sending MS files via email
(uuencode stat.xls) | mailx -s "EXCEL FILES" bwu2@emory.edu
exit 0
