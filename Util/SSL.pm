# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SSL;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-ssl [options] command [args..]
commands
   self_signed_crt domain -- create a self-signed crt for domain
EOF
}

sub self_signed_crt {
    my($self, $domain) = shift->arg_list(\@_, [['DomainName']]);
    return $self->do_sh(
	"openssl req -x509 -nodes -days 9999 -subj '/C=US/ST=Colorado/L=Boulder/CN=$domain' -newkey rsa:1024 -keyout $domain.key -out $domain.crt",
    );
}

1;
