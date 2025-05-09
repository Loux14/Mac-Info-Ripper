# Mac-Info-Ripper

This script gathers detailed information about a macOS system and generates a comprehensive report. It collects information about system specs, hardware, user data, recent app usage, and security status, then sends the report via email using Mailgun.

![2](https://github.com/user-attachments/assets/c537959a-11c2-4234-b3c3-c79c622c7d12)
![3](https://github.com/user-attachments/assets/fe391fa9-9b31-4e70-8659-a6219df46204)


## Features

- **System Information**: macOS version, kernel version, IP address, external IP address, and more.
- **Hardware Information**: Processor details, memory, disk space, battery status, etc.
- **User Information**: Full name, username, shell type, account creation date, last login, etc.
- **App Information**: Installed applications, running applications, and recent app usage.
- **Security Information**: Firewall status, FileVault status, System Integrity Protection, and Gatekeeper.
- **Email Report**: The gathered data is sent via email using Mailgun.

## Requirements

- macOS target.
- **Mailgun** API key (you need to replace the placeholder API key in the script with your own), and email address

## Usage

   ```bash
   ./macInfoRipper.sh
