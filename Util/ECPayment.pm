# Copyright (c) 2018 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::ECPayment;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();
b_use('IO.ClassLoaderAUTOLOAD');

sub USAGE {
    return <<'EOF';
usage: bivio Project [options] command [args..]
commands
  process_all - run Action.ECPaymentProcessAll
EOF
}

sub process_all {
    # No global lock is needed
    b_use('Action.ECPaymentProcessAll')->execute(shift->req);
    return;
}
