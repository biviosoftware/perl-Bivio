# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::StringParen;
use strict;
$Bivio::UI::PDF::StringParen::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::StringParen - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::StringParen;
    Bivio::UI::PDF::StringParen->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::String>

=cut

use Bivio::UI::PDF::String;
@Bivio::UI::PDF::StringParen::ISA = ('Bivio::UI::PDF::String');

=head1 DESCRIPTION

C<Bivio::UI::PDF::StringParen>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_STRING_END_PAREN_REGEX) = Bivio::UI::PDF::Regex::STRING_END_PAREN_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::StringParen



=cut

sub new {
    my($self) = Bivio::UI::PDF::String::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($clone) = Bivio::UI::PDF::StringParen->new();
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
    return(')');
}

# _get_closing_regex() : 
#
#
#
sub _get_closing_regex {
    my($self) = @_;
    return($_STRING_END_PAREN_REGEX);
}

# _get_opening_char() : 
#
#
#
sub _get_opening_char {
    my($self) = @_;
    return('(');
}

=for html <a name="_get_string_type"></a>

=head2 _get_string_type() : 



=cut

sub _get_string_type {
    my($self) = @_;
    return('paren');
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
