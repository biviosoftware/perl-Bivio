#!/bin/bash
test $UID = 0 && {
    echo 'Run as an ordinary user, not root' 1>&2
    exit 1
}
test "x$PERLLIB" = x -o "x$PERLLIB" = "x$HOME/src/perl" || {
    echo 'Unset $PERLLIB. This script will set $PERLLIB in ~/.bashrc.' 1>&2
    exit 1
}
perl -v | grep -s -q v5.16 || {
    echo 'You need perl v5.16' 1>&2
    exit 1
}
perl -MSearch::Xapian -e 1 > /dev/null 2>&1 || {
    cat <<'EOF' 1>&2
Search::Xapian is not installed.  You probably need quite a few
prerequisites.  We won't be installing those.  Instead, you
will need to install
EOF
    exit 1
}
perl -M
cat <<'EOF'
Setting up BOP involves creating numerous files and directories
If you are at all concerned, read this script first.
This script is idempotent so you can run multiple times.
[type enter to continue]
EOF
read a

set -e
for d in ~/src/biviosoftware ~/src/perl ~/bin; do
    test -d $d || {
        mkdir -p $d
    }
done
test -L ~/src/perl/Bivio || {
    ln -s ~/src/biviosoftware/perl-Bivio ~/src/perl/Bivio
}
test -d ~/src/biviosoftware/perl-Bivio/.git || (
    cd ~/src/biviosoftware
    git clone https://github.com/biviosoftware/perl-Bivio
)
grep -s -q BIVIO_HTTPD_PORT ~/.bashrc || {
    perl -pi -e 'm{if.*/etc/bashrc} && print("export BIVIO_HTTPD_PORT=8000\n")' ~/.bashrc
}
for f in bivio b-sendmail-http; do
    test -x ~/bin/$f || {
        perl -p -e 's{(?=^\#\!)perl}{$^X}m' ~/src/biviosoftware/perl-Bivio/Util/$f > ~/bin/$f
        chmod +x ~/bin/$f
    }
done
grep -s -q PERLLIB ~/.bashrc || {
    echo 'export PERLLIB="$HOME/src/perl"' >> ~/.bashrc
}
expr match ":$PATH:" ".*:$HOME/bin:" >/dev/null || {
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
}
. ~/.bashrc
bivio dev setup
b_pet
psql -f /dev/null pet$USER petuser >/dev/null 2>&1 || {
    bivio sql init_dbms
    bivio sql -f create_test_db
}
