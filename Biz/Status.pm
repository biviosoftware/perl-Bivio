# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Status;
use strict;
$Bivio::Biz::Status::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Status - A collection of errors.

=head1 SYNOPSIS

    use Bivio::Biz::Status;
    Bivio::Biz::Status->new();

=cut

@Bivio::Biz::Status::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Status>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Status

Creates a new Status with no initial errors.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	errors => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_error"></a>

=head2 add_error(Error error)

Adds the specified error to the error list.

=cut

sub add_error {
    my($self, $error) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{errors}}, $error);
}

=for html <a name="clear"></a>

=head2 clear()

Removes all errors.

=cut

sub clear {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{errors} = [];
}

=for html <a name="get_errors"></a>

=head2 get_errors() : array

Returns an array of Errors associated with the status.

=cut

sub get_errors {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{errors};
}

=for html <a name="is_OK"></a>

=head2 is_OK() : 

Returns > 0 if there are no errors.

=cut

sub is_OK {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return ! scalar(@{$fields->{errors}});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
