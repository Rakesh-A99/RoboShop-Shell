#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
USER_ID=$(id -u)
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
#Function
VALIDATE(){
    #$1 --> it will receive the argument1
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}
if [ $USER_ID -ne 0 ]
then
    echo "please login with root ID for installation"
    exit 1 
fi
#The Web/Frontend is the service in RoboShop to serve the web content over Nginx.
#This will have the web page for the web application.
#Developer has chosen Nginx as a web server and thus we will install Nginx Web Server.
yum install nginx -y &>> $LOGFILE

VALIDATE $? "installed nginx" 

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enabling nginx" 

systemctl start nginx &>> $LOGFILE

VALIDATE $? "stating nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "removing html index files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE      

VALIDATE $? "downloading artifact"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moving to /usr/share/nginx/html"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping web.zip"

cp /home/centos/RoboShop-Shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copying roboshop.conf "

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarting nginx"