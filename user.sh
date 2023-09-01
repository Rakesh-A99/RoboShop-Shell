#!/bin/bash
DATE=$(date +%F)
LOG_DIR=$tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
USER_NAME=$roboshop
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
if [ $USERID -ne 0]; then
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

VALIDATE $? "download nodeJS"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodeJS"

if [ id roboshopx -ne 0 ]; 
then
    echo -e "$R $USER_NAME is available"
else    
    useradd roboshop &>> $LOGFILE
    echo -e "$G $USER_NAME in added"
fi
if [ -d "/app" ];
then
    echo "Directory /app already exists."
 else
    mkdir /app &>> $LOGFILE
fi
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user artifact"

cd /app &>> $LOGFILE

VALIDATE $? "moving to app directory"

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping the user artifact"

npm install &>> $LOGFILE

VALIDATE $? "installing npm"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload "

systemctl enable user &>> $LOGFILE

VALIDATE $? "enabling the user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/RoboShop-Shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "moving the mongo.repo to /etc/yum.repos.d/mongo.repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host mongodb.myroboshop.site </app/schema/user.js &>> $LOGFILE

VALIDATE $? "connection mongo db"