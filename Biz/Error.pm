# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Error;
use strict;
$Bivio::Biz::Error::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Error - An error message

@Bivio::Biz::Error::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Error> describes a validation or processing error for a model
action.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string message) : Bivio::Biz::Error

Creates a new error with the specified message.

=cut

sub new {
    my($proto, $message) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	message => $message
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_message"></a>

=head2 get_message() : string

Returns the message associated with the error.

=cut

sub get_message {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{message};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
