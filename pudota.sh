#!/bin/sh

TARGET_HOST="vps1"

_fail_ending() {
    if [ -n "$NO_COLORS" ]; then
        printf "fail\n"
    else
        printf "\033[31mfail\033[0m\n"
    fi
    exit
}

_success_ending() {
    if [ -n "$NO_COLORS" ]; then
        printf "ok\n"
    else
        printf "\033[32mok\033[0m\n"
    fi
}

_pretty_ending() {
    if [ "$?" -ne 0 ]; then
        _fail_ending
    else
        _success_ending
    fi
}

_colorized() {
    if [ -n "$NO_COLORS" ]; then
        printf "%s\n" "$2"
    else
        printf "\033[%dm%s\033[0m\n" "$1" "$2"
    fi
}

backup() {
    chmod +x encrypt.sh backup.sh

    printf "Uploading scripts... \t"
    printf "put backup.sh\nput encrypt.sh" | sftp -q "$TARGET_HOST" >/dev/null
    _pretty_ending

    printf "Creating backups... \t"
    ssh -tq "$TARGET_HOST" "sudo ./backup.sh"
    _pretty_ending

    echo ""
    echo "Encrypting backups..."
    ssh -tq "$TARGET_HOST" "sudo ./encrypt.sh"
    echo ""

    printf "Querying the size of the backup... "
    result="$(ssh "$TARGET_HOST" "du -sh backup.tar.gz.enc | awk '{print \$1}'")"
    _pretty_ending
    printf "Size of the backup is %s\n" "$(_colorized 33 "$result")"
    echo ""

    printf "Downloading backup... \t"
    #! echo "get backup.tar.gz.enc" | sftp -q "$TARGET_HOST" 2>&1 | grep -qv "sftp"
    _pretty_ending

    printf "Cleaning up... \t\t"
    ssh -q "$TARGET_HOST" "rm -f backup.sh encrypt.sh backup.tar.gz.enc 2>/dev/null"
    _pretty_ending
}

backup
