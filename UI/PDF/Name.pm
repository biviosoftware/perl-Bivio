# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Name;
use strict;
$Bivio::UI::PDF::Name::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Name - encapsulates a PDF name direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Name;
    Bivio::UI::PDF::Name->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Name::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Name>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_NAME_REGEX) = Bivio::UI::PDF::Regex::NAME_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Name



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    # $value will be undefined in some cases.
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
    my($clone) = Bivio::UI::PDF::Name->new();
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
    $emit_ref->append_no_new_lines('/' . $fields->{'value'});
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($fields->{'value'}) + 1);	# 1 for the '/'.
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (${$line_iter_ref->current_ref()} =~ /$_NAME_REGEX/) {
	if (defined($1)) {
	    $fields->{'value'} = $1;
	    $line_iter_ref->replace_first($');

	    _trace("Extracting name \"$1\"") if $_TRACE;
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
    return($fields->{'value'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
