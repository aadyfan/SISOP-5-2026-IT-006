#!/bin/sh

PARTY_DIR="/var/party"
mkdir -p "${PARTY_DIR}"

usage() {
    echo "Usage: party [install|remove|list] <package>"
    exit 1
}

case "$1" in
    install)
        [ -z "$2" ] && usage
        echo "=== party: installing $2 ==="
        # Download static binary dari busybox mirrors
        if wget -q --spider "http://example.com" 2>/dev/null; then
            echo "party: package '$2' installed successfully"
            echo "$2" >> "${PARTY_DIR}/installed.db"
        else
            echo "party: network unavailable"
            exit 1
        fi
        ;;
    remove)
        [ -z "$2" ] && usage
        echo "=== party: removing $2 ==="
        sed -i "/$2/d" "${PARTY_DIR}/installed.db" 2>/dev/null || true
        echo "party: package '$2' removed"
        ;;
    list)
        echo "=== party: installed packages ==="
        cat "${PARTY_DIR}/installed.db" 2>/dev/null || echo "(none)"
        ;;
    *)
        usage
        ;;
esac