# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::OPIE;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base 'Bivio::ShellUtil';

# C<Bivio::Util::OPIE>

sub USAGE {
    return <<'EOF';
usage: b-opie [options] command [args...]
commands:
    opiekey sequence_number seed -- generates a one time password
EOF
}

#=IMPORTS
use Bivio::OTP::RFC2289;

#=VARIABLES

=head1 METHODS

=cut

sub opiekey {
    my($self, $count, $seed) = @_;

    $self->usage_error('Please supply the sequence_number')
	unless $count;
    $self->usage_error('Please supply the seed')
	unless $seed;

    $self->print(<<'EOF');
Using the MD5 algorithm to compute response.
Reminder: Don't use opiekey from telnet or dial-in sessions.
EOF

    my($passwd) = $self->readline_stdin('Enter secret pass phrase: ');
    $self->usage_error(
        'Secret pass phrases must be between 1 and 127 characters long.'
    )
        unless $passwd =~ /^\w{1,127}/;

    return Bivio::OTP::RFC2289->to_six_word_format(
        Bivio::OTP::RFC2289->compute($passwd, $seed, $count)) . "\n";
}

#=PRIVATE SUBROUTINES

1;
