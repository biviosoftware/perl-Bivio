# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::StringAngle;
use strict;
$Bivio::UI::PDF::StringAngle::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::StringAngle - encapsulates a PDF direct string object whose
data is enclosed in angle brackets.

=head1 SYNOPSIS

    use Bivio::UI::PDF::StringAngle;
    Bivio::UI::PDF::StringAngle->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::String>

=cut

use Bivio::UI::PDF::String;
@Bivio::UI::PDF::StringAngle::ISA = ('Bivio::UI::PDF::String');

=head1 DESCRIPTION

C<Bivio::UI::PDF::StringAngle>

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

my($_STRING_END_ANGLE_REGEX) = Bivio::UI::PDF::Regex::STRING_END_ANGLE_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::StringAngle



=cut

sub new {
    my($self) = Bivio::UI::PDF::String::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($clone) = Bivio::UI::PDF::StringAngle->new();
    $self->SUPER::clone($clone);
    return($clone);
}

#=PRIVATE METHODS

# _get_closing_char() : 
#
#
#
sub _get_closing_char {
    my($self) = @_;
    return('>');
}

# _get_closing_regex() : 
#
#
#
sub _get_closing_regex {
    my($self) = @_;
    return($_STRING_END_ANGLE_REGEX);
}

# _get_opening_char() : 
#
#
#
sub _get_opening_char {
    my($self) = @_;
    return('<');
}

# _get_string_type() : 
#
#
#
sub _get_string_type {
    my($self) = @_;
    return('angle');
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
