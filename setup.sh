#!/bin/bash
test $UID = 0 && {
    echo 'Run as an ordinary user, not root' 1>&2
    exit 1
}
rpm -q Bivio-bOP > /dev/null 2>&1 || {
    echo 'You need the Bivio-bOP rpm installed' 1>&2
    exit 1
}
cat <<'EOF'
Setting up BOP involves creating numerous files and directories
If you are at all concerned, read this script first.
This script is idempotent so you can run multiple times.
[type enter to continue]
EOF
read a

export BIVIO_HTTPD_PORT="$(perl -e 'printf(q{%02d}, $< % 100)')"
grep -s -q BIVIO_HTTPD_PORT ~/.bashrc || {
    perl -pi -e 'm{if.*/etc/bashrc} && print("export BIVIO_HTTPD_PORT=80$ENV{BIVIO_HTTPD_PORT}\n")' ~/.bashrc
}
bivio dev setup
. ~/.bashrc
b_pet
psql -f /dev/null pet$USER petuser >/dev/null 2>&1 || {
    bivio sql init_dbms
    bivio sql -force create_test_db
}
cd ~/src/perl/Bivio/IO/t
bivio test unit Config*t
