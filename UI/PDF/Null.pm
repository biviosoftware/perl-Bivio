# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Null;
use strict;
$Bivio::UI::PDF::Null::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Null - encapsulates the PDF Null direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Null;
    Bivio::UI::PDF::Null->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Null::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Null>

=cut

#=IMPORTS
use Bivio::IO::Trace;

use Bivio::UI::PDF::Strings;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_NULL_OBJ_REGEX) = Bivio::UI::PDF::Regex::NULL_OBJ_REGEX();
my($_NULL_OBJ_VALUE) = Bivio::UI::PDF::Strings::NULL_OBJ_VALUE();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Null



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
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
    my($clone) = Bivio::UI::PDF::Null->new();
    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    # A null object just consists of the key word 'null'.
    $emit_ref->append_no_new_lines($_NULL_OBJ_VALUE);
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($_NULL_OBJ_VALUE));
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (${$line_iter_ref->current_ref()} =~ /$_NULL_OBJ_REGEX/) {
	if (defined($1)) {
	    # We found a null object.  Null objects keep no data, so just
	    # consume the 'null' string.
	    $line_iter_ref->replace_first($'); #'

	    _trace("Extracting null object \"$1\"") if $_TRACE;
	} else {
	    die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	}
    } else {
	die(__FILE__,", ", __LINE__, ": No match\n");
    }
    return;
}

=for html <a name="get_value"></a>

=head2 get_value() : 



=cut

sub get_value {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $_NULL_OBJ_VALUE;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
