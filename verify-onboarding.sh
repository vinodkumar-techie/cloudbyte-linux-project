#!/bin/bash
#
# CloudByte User Onboarding Verification
# Verifies Section 3 onboarding requirements.
#

set -eo pipefail

SCRIPT="/host/scripts/onboard-user.sh"
CSV="/host/data/new-hires.csv"

PASS=0
FAIL=0

check() {
    local description="$1"

    if eval "$2"; then
        echo "[PASS] $description"
        ((PASS+=1))
    else
        echo "[FAIL] $description"
        ((FAIL+=1))
    fi
}

echo "=== CloudByte Onboarding Verification ==="

# Check script and CSV files
check "Onboarding script exists" '[[ -f "$SCRIPT" ]]'
check "CSV file exists" '[[ -f "$CSV" ]]'
check "Script is executable" '[[ -x "$SCRIPT" ]]'
check "Bash syntax is valid" 'bash -n "$SCRIPT"'

# Check users and group memberships
for entry in \
    "testuser1:engineering" \
    "testuser2:marketing" \
    "testuser3:operations"
do
    username="${entry%%:*}"
    group="${entry##*:}"

    check "$username account exists" "id '$username' &>/dev/null"
    check "$username belongs to $group" "id -nG '$username' | tr ' ' '\\n' | grep -qx '$group'"
    check "$username home directory exists" "[[ -d /home/$username ]]"
    check "$username password change required" "chage -l '$username' | grep -q 'password must be changed'"
done

# Check invalid user was not created
check "Invalid user was not created" '! id testinvalid &>/dev/null'

echo ""
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [[ "$FAIL" -eq 0 ]]; then
    echo "All onboarding checks passed!"
    exit 0
else
    echo "Some onboarding checks failed."
    exit 1
fi
