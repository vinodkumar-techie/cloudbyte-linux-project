# CloudByte Linux Project

A multi-user Linux server for CloudByte Solutions: user and group management,
automated backups, log analysis, and system health monitoring. Built section by
section as part of a cloud computing bootcamp.

## Section 1: Server Foundations

Created the CloudByte server environment on Amazon Linux 2023 using Lima.
Added twelve user accounts, four groups, shared team directories, and
company documentation directories with the required permissions.
A verification script checks the users, groups, and directory permissions.

## Section 2: File Management and Permissions

Configured team directories with setgid permissions to ensure new files
inherit the correct team group. Created a shared dropbox with the sticky
bit to prevent users from deleting files owned by others.
Tested hard links, symbolic links, and file ownership.
A permissions test report and verification script document the results.

## Section 3: User Onboarding Automation

Created an automated Bash script at `scripts/onboard-user.sh` to create
user accounts, assign team groups, set temporary passwords, and require
password changes at first login.

The script supports interactive onboarding, CSV-based bulk onboarding,
dry-run mode, duplicate-user protection, and input validation.

Tested the script with three sample users. The onboarding verification
script reported 17 checks passed and 0 failures.
