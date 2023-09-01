#!/bin/bash
DATE=$(date +%F)
LOG_DIR=$tmp
SCRIPT_NAME=$0
LOGFILE=$LOG_DIR/$0-$DATE.log
USERID=$(id -u)
USER_NAME=$roboshop
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
if [$USERID -ne 0]; 
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "downloading nodejs script"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodeJS"

if [ id $USER_NAME -ne 0 ]; 
then
    echo -e "$R $USER_NAME is available"
else    
    useradd roboshop &>> $LOGFILE
    echo -e "$G $USER_NAME in added"
fi
if [-d "/app"];
then 
    echo "/app directory exists"
else     
    mkdir /app &>> $LOGFILE
    VALIDATE $? "/app diectory is created"
fi    
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue artifact"

cd /app &>> $LOGFILE

VALIDATE $? "moving to app directory"

unzip /tmp/catalogue.zip&>> $LOGFILE

VALIDATE $? "unzippig catalogue"

npm install &>> $LOGFILE

VALIDATE $? "installing npm"

cp /home/centos/RoboShop-Shell/catalogue.service /etc/systemd/system/catalogue.service&>> $LOGFILE

VALIDATE $? "copying the catalogue.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reload the daemon"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/RoboShop-Shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying the mongo.repo to /etc/yum.repos.d/mongo.repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongoclient"

mongo --host 172.31.86.31 < /app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "connecting to mongo db" 


