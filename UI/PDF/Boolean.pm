# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Boolean;
use strict;
$Bivio::UI::PDF::Boolean::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Boolean - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Boolean;
    Bivio::UI::PDF::Boolean->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Boolean::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Boolean>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_BOOLEAN_REGEX) = Bivio::UI::PDF::Regex::BOOLEAN_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Boolean



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    # The value is optional.
    my(undef, $value) = @_;
    $self->{$_PACKAGE} = {
	'value' => $value
    };
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
    my($clone) = Bivio::UI::PDF::Boolean->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'value'} = $fields->{'value'};
    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $emit_ref->append_no_new_lines($fields->{'value'});
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($fields->{'value'}));
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (${$line_iter_ref->current_ref()} =~ /$_BOOLEAN_REGEX/) {
	if (defined($1)) {
	    $fields->{'value'} = $1;
	    $line_iter_ref->replace_first($');

	    _trace("Extracting boolean \"$1\"") if $_TRACE;
	} else {
	    die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	}
    } else {
	die(__FILE__,", ", __LINE__, ": No match\n");
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
