# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Email;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_E) = b_use('Type.Email');

sub USAGE {
    return <<'EOF';
usage: bivio Email [options] command [args..]
commands
  replace_email_domain from_domain to_domain
EOF
}

sub replace_email_domain {
    sub REPLACE_EMAIL_DOMAIN {[[qw(from_domain DomainName)], [qw(to_domain DomainName)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->are_you_sure("Update all emails ending in $bp->{from_domain} to $bp->{to_domain}?");
    $self->model('EmailForDomainList')->do_iterate(
	sub {
	    my($e) = shift->get_model('Email');
	    $e->update({
		email => $_E->replace_domain($e->get('email'), $bp->{to_domain}),
	    });
	    return 1;
	},
	{b_domain_name => $bp->{from_domain}},
    );
    return;
}

1;
