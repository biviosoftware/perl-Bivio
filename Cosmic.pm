# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::WWW::Cosmic;

use strict;

use Bivio::Club ();

@Bivio::WWW::ISA = qw(Bivio::Club);

$Bivio::WWW::VERSION = '0.01';

my $Bivio::WWW::Cosmic::_Cosmic = new Bivio::WWW::Cosmic();

sub new ($) {
    my $proto = shift;
    my $class = ref($proto) || $proto; 			  	   # hello this
    my $self = $class->SUPER::new('cosmic');
    return bless($self, $class);
}

sub handler ($)
{
    defined($r)
    Bivio::Request->execute(shift,
			    sub { $Bivio::WWW::Cosmic::_Cosmic->_request });
}

1;
__END__

=head1 NAME

Bivio::WWW::Cosmic - mod_perl handler for cosmic page

=head1 SYNOPSIS

  use Bivio::WWW::Cosmic;

=head1 DESCRIPTION

Handler for cosmic directory.  Cosmic is a Bivio::Club.  All of the
the work is in Club.

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

Bivio::Club, Bivio::Request

=cut
