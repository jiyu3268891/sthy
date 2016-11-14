#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
import  socket
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
#from email.header import Header

hostName = socket.gethostname()
mail_host="smtp.eu.jnj.com"


sender = 'ADF_BACKUP_MANAGER'
receivers = ['yji23@ITS.JNJ.com','zzang3@ITS.JNJ.com','wsun26@ITS.JNJ.com','wfang7@ITS.JNJ.com']

message = MIMEMultipart()
message['From'] = sender
message['To'] = "yji23@ITS.JNJ.com, zzang3@ITS.JNJ.com, wsun26@ITS.JNJ.com, wfang7@ITS.JNJ.com"
message['Subject'] = "Bakregions failed - " + hostName + " , please check!!! "
#text = "Bakregions failed, please check the backregions logs in the following host: \n " + "Backup server:" + hostName

html = """\
<html>
  <head></head>
  <body>
    <p>Hello All,<br>
    <br>
    Bakregions failed, please check the backregions logs in the following host:<br>
     <h5>    Backup server: %s <h5>
    </p>
  </body>
</html>
"""
#part1 = MIMEText(text, 'plain')
part2 = MIMEText(html % hostName, 'html')
message.attach(part2)

try:
    smtpObj = smtplib.SMTP() 
    #smtpObj.set_debuglevel(1)
    smtpObj.connect(mail_host, 25)
    smtpObj.ehlo()
    smtpObj.starttls()
    smtpObj.ehlo
    smtpObj.sendmail(sender, receivers, message.as_string())
    smtpObj.quit()
    print "Email send successful."
except smtplib.SMTPException, ex:
    print "Error: Email send failed."
    print ex