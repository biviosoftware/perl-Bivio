# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::IndirectObjRef;
use strict;
$Bivio::UI::PDF::IndirectObjRef::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::IndirectObjRef - encapsulates a PDF indirect object reference
direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::IndirectObjRef;
    Bivio::UI::PDF::IndirectObjRef->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::IndirectObjRef::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::IndirectObjRef>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::Regex;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_OBJ_REF_REGEX) = Bivio::UI::PDF::Regex::OBJ_REF_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::IndirectObjRef



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    # The object number and object generation may be undefined if they are to
    # be extracted from an ArrayIterator.
    my(undef, $obj_number, $obj_generation) = @_;
    $self->{$_PACKAGE} = {
	'obj_number' => $obj_number,
	'obj_generation' => $obj_generation
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
    my($clone) = Bivio::UI::PDF::IndirectObjRef->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'obj_number'} = $fields->{'obj_number'};
    $clone_fields->{'obj_generation'} = $fields->{'obj_generation'};
   return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $emit_ref->append_no_new_lines($self->get_value());
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($self->get_value()));
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (${$line_iter_ref->current_ref()} =~ /$_OBJ_REF_REGEX/) {
	if (defined($1)) {
	    unless (defined($2)) {
		die(__FILE__,", ", __LINE__, ": no object generation\n");
	    }
	    # We found the object reference.
	    $fields->{'obj_number'} = $1;
	    $fields->{'obj_generation'} = $2;
	    $line_iter_ref->replace_first($'); #'

	    _trace("Indirect object ref \"$1 $2\"") if $_TRACE;
	} else {
	    die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	}
    } else {
	die(__FILE__,", ", __LINE__, ": No match\n");
    }
    return;
}

=for html <a name="get_obj_number"></a>

=head2 get_obj_number() : 



=cut

sub get_obj_number {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'obj_number'});
}

=for html <a name="get_value"></a>

=head2 get_value() : 



=cut

sub get_value {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'obj_number'} . ' '
	    . $fields->{'obj_generation'} . ' R');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
