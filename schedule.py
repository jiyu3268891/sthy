#! /usr/bin/env python
#coding=utf-8
  
import time, os, sched
schedule = sched.scheduler(time.time, time.sleep)      
def perform_command(cmd, inc):  
    schedule.enter(inc, 0, perform_command, (cmd, inc))  
    os.system(cmd)  
    print(time.time())    
def timming_exe(cmd, inc = 60):  
    schedule.enter(inc, 0, perform_command, (cmd, inc))   
    schedule.run()            
print("show time after 10 seconds:")  
timming_exe("date +%Y-%m-%d-%H-%M-%S >> 1.txt && sleep 7", 20)