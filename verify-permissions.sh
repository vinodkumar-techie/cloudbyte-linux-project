
#!/bin/bash

# CloudByte Section 02 - File Management and Permissions Verification

PASS=0
FAIL=0

check() {
    if eval "$2"; then
        echo "[PASS] $1"
        ((PASS++))
    else
        echo "[FAIL] $1"
        ((FAIL++))
    fi
}

echo "=========================================="
echo " CloudByte Permissions Verification"
echo "=========================================="

# Check team directory ownership and permissions
check "Engineering directory" \
"test \"$(stat -c '%U:%G:%a' /shared/engineering)\" = 'root:engineering:2770'"

check "Marketing directory" \
"test \"$(stat -c '%U:%G:%a' /shared/marketing)\" = 'root:marketing:2770'"

check "Operations directory" \
"test \"$(stat -c '%U:%G:%a' /shared/operations)\" = 'root:operations:2770'"

# Check Dropbox
check "Dropbox directory" \
"test \"$(stat -c '%U:%G:%a' /shared/dropbox)\" = 'root:admins:1773'"

# Check sample files
check "Engineering README" "test -f /shared/engineering/README.md"
check "Engineering app.conf" "test -f /shared/engineering/app.conf"
check "Engineering deploy.sh" "test -f /shared/engineering/deploy.sh"

check "Marketing README" "test -f /shared/marketing/README.md"
check "Marketing campaign.conf" "test -f /shared/marketing/campaign.conf"
check "Marketing social-posts.txt" "test -f /shared/marketing/social-posts.txt"

check "Operations README" "test -f /shared/operations/README.md"
check "Operations backup.sh" "test -f /shared/operations/backup.sh"
check "Operations monitoring.conf" "test -f /shared/operations/monitoring.conf"

# Check setgid inheritance test files
check "Engineering setgid group" \
"test \"$(stat -c '%G' /shared/engineering/setgid-test.txt)\" = 'engineering'"

check "Marketing setgid group" \
"test \"$(stat -c '%G' /shared/marketing/setgid-test.txt)\" = 'marketing'"

check "Operations setgid group" \
"test \"$(stat -c '%G' /shared/operations/setgid-test.txt)\" = 'operations'"

echo
echo "=========================================="
echo " Results: $PASS passed, $FAIL failed"
echo "=========================================="

if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
