#!/bin/bash
echo "+----------------------------------------------------------------------+"
echo "| ESXi Auto VM Reset WatchDog                                          |"
echo "| https://github.com/Upinel/ESXi-Auto-VM-Reset                         |"
echo "+----------------------------------------------------------------------+"
echo "| This source file is subject to version 2.0 of the Apache license,    |"
echo "| that is bundled with this package in the file LICENSE, and is        |"
echo "| available through the world-wide-web at the following url:           |"
echo "| http://www.apache.org/licenses/LICENSE-2.0.html                      |"
echo "| If you did not receive a copy of the Apache2.0 license and are unable|"
echo "| to obtain it through the world-wide-web, please send a note to       |"
echo "| license@swoole.com so we can mail you a copy immediately.            |"
echo "+----------------------------------------------------------------------+"
echo "| Author: Nova Upinel Chow  <dev@upinel.com>                           |"
echo "| Date:   04/Sep/2024                                                  |"
echo "+----------------------------------------------------------------------+"

# Configuration
VM_IP="10.0.1.100" #Your VM IP to Ping
PING_COUNT=3
PING_WAIT=1
CHECK_INTERVAL=60 #Ping Interval
ESXI_HOST="10.0.1.3" #Your ESXi Host IP
ESXI_USER="root" #Your ESXi Host root
ESXI_PASS="PASSWORD" #Your ESXi Host Password
VM_ID="12" #Your VM ESXi IP (You can find it on the VM URL, it is a number)
LOG_FILE="PATH/watchdog_vm_monitor.log" #Your monitor log PATH

# Function to reset VM via SSH
reset_vm() {
    local ssh_command="vim-cmd vmsvc/power.reset ${VM_ID}"  # Hard reset: power off -> power on
    sshpass -p "$ESXI_PASS" ssh -o StrictHostKeyChecking=no "$ESXI_USER@$ESXI_HOST" "$ssh_command"
    if [ $? -eq 0 ]; then
        echo "$(date): VM ${VM_ID} reset successfully." | tee -a "$LOG_FILE"
    else
        echo "$(date): Failed to reset VM ${VM_ID}." | tee -a "$LOG_FILE"
    fi
}

# Monitor loop
while true; do
    if ! ping -c $PING_COUNT -W $PING_WAIT "$VM_IP" > /dev/null; then
        echo "$(date): Ping to $VM_IP failed. Triggering reset for VM ${VM_NAME} on $ESXI_HOST." | tee -a "$LOG_FILE"
        reset_vm
    else
        echo "$(date): VM $VM_IP is reachable." | tee -a "$LOG_FILE"
    fi

    sleep $CHECK_INTERVAL
done
