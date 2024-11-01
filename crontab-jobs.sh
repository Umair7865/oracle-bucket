# These are crontab JOBs which will take backup at 6:00 PM daily 

0 18 * * * /usr/bin/mysqldump -u root -p'root123' database1  > /home/opc/MySQL/database1/database1_$(date +\%F__\%H_hour-\%M_min).sql

0 18 * * * /usr/bin/mysqldump -u root -p'root123' database2  > /home/opc/MySQL/database2/database2_$(date +\%F__\%H_hour-\%M_min).sql

