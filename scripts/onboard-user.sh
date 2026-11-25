#!/bin/bash
#
# CloudByte User Onboarding Script
# Creates Linux user accounts and assigns them to team groups.
#
# Usage:
#   sudo ./scripts/onboard-user.sh
#   sudo ./scripts/onboard-user.sh --csv data/new-hires.csv
#   sudo ./scripts/onboard-user.sh --dry-run
#

set -eo pipefail

# Must be run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run this script with sudo or as root."
    exit 1
fi
# Temporary password for newly created users
TEMP_PASSWORD="ChangeMe123!"
# Function to create a new user
create_user() {
    local username="$1"
    local group="$2"
    local fullname="$3"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would create user: $username (Group: $group, Name: $fullname)"
        return 0
    fi    

    # Check whether the group exists
    if ! getent group "$group" > /dev/null; then
        echo "Error: Group '$group' does not exist."
        return 1
    fi

    # Check whether the user already exists
    if id "$username" &> /dev/null; then
        echo "User '$username' already exists. Skipping."
        return 0
    fi

    # Create the user account
    useradd -m -c "$fullname" "$username"

    # Set temporary password
    echo "$username:$TEMP_PASSWORD" | chpasswd

    # Add user to the team group
    usermod -aG "$group" "$username"

    # Force password change at first login
    chage -d 0 "$username"

    echo "Successfully created user: $username (Group: $group)"
}
# Interactive user creation
interactive_onboarding() {
    echo "=== CloudByte User Onboarding ==="

    read -rp "Enter username: " username
    read -rp "Enter team group: " group
    read -rp "Enter employee full name: " fullname

    create_user "$username" "$group" "$fullname"
}
# Create users from a CSV file
csv_onboarding() {
    local csv_file="$1"

    if [[ ! -f "$csv_file" ]]; then
        echo "Error: CSV file '$csv_file' not found."
        return 1
    fi

    echo "=== CloudByte CSV Onboarding ==="

    while IFS=, read -r username group fullname; do
        # Skip the header row
        [[ "$username" == "username" ]] && continue

        # Skip empty lines
        [[ -z "$username" ]] && continue

        create_user "$username" "$group" "$fullname"
    done < "$csv_file"
}
# Command-line argument handling
CSV_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --csv)
            CSV_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: sudo $0 [--csv FILE] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --csv FILE   Create users from a CSV file"
            echo "  --dry-run    Preview actions without creating users"
            echo "  -h, --help   Display this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            exit 1
            ;;
    esac
done

# Start onboarding
if [[ -n "$CSV_FILE" ]]; then
    csv_onboarding "$CSV_FILE"
else
    interactive_onboarding
fi
