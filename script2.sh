#!/bin/bash

#Retrieve hostname from /etc/hostname
Hostname=$(cat /etc/hostname)
#OS information could be retrieve from  etc/os-release
Operatingsystem=$(source /etc/os-release && echo "$PRETTY_NAME")
# Uptime command could be used here
time=$(uptime -p)

cpu=$(lshw -class cpu|grep product) 
speed=$(lscpu | awk '/MHz/ {print $3}')
#free command  to get RAM
ram=$(free | grep Mem| awk '{print $2}')
#lsblk command to get disk information
disks=$(lsblk | grep disk |awk '{print $1, $4}')
#Get video card informating  using lshw
video=$(lshw -class display|grep product)

#Retrieve fully qualified domain name (FQDN) and IP address
Fqdn=$(hostname)
Ip=$(hostname -I)
#Get gateway IP address using ip route here
gateway=$(ip route | grep default| awk '{print $3}')
#cat command is used here to read the file and grep used to filter the result
dns=$(cat /etc/resolv.conf | grep nameserver| awk '{print $2}')

#Get active interface name  using ifconfig
interfacename=$(ifconfig | awk '/UP/ && /RUNNING/ {print $1}')
#This command is used to get ip address in cidr format
ipcidr=$(ip -4 addr show | grep inet | awk '{print $2}')
#who command  used to get the list of users
loggins=$(who | awk '{print $1}' | sort -u | tr '\n' ',')
#using df command to to get avaialable disk space
diskspace=$(df -h)
#counting  total number of processes using ps command
processcount=$(ps aux | wc -l)

#using uptime command to load averages
loadaverages=$(uptime | awk -F'load average: ' '{print $2}')
# Getting the allocation of the memory using free command here
memoryallocation=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

#  Retriving list of listening networks 
listeningports=$(ss -tuln | awk '/LISTEN/ {print $5}' | awk -F':' '{print $NF}' | sort -n | uniq)
#Get Uncomplicated Firewalls using ufw command
ufwrules=$(sudo ufw status numbered)



#output of the system report with all information here

cat <<EOF
System Report generated by $USER, $(date)

System Information
-------------------
Hostname=$Hostname
OS:$Operatingsystem
Uptime:$time

Hardware Information
--------------------
CPU:$cpu
Speed:$speed
RAM:$ram
DISK(s):$disks
VIDEO:$video

Network Information
-------------------
FQDN: $Fqdn
Host Address: $Ip
Gateway IP: $gateway
DNS Server: $dns
 
InterfaceName:$interfacename
IP Address:$ipcidr

System Status
-------------
Users Logged In: $loggins
Disk Space: $diskspace
Process Count: $processcount
Load Averages: $loadaverages
Memory Allocation:$memoryallocation
Listening Network Ports:$listeningports
UFW Rules:$ufwrules
