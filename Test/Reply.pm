# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reply;
use strict;
$Bivio::Test::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Reply::VERSION;

=head1 NAME

Bivio::Test::Reply - holds the output

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Reply;

=cut

=head1 EXTENDS

L<Bivio::Agent::Reply>

=cut

use Bivio::Agent::Reply;
@Bivio::Test::Reply::ISA = ('Bivio::Agent::Reply');

=head1 DESCRIPTION

C<Bivio::Test::Reply>

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::Reply

New instance.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_output"></a>

=head2 get_output() : string_ref

Returns the reply as a string ref.  Always reads the contents.

=cut

sub get_output {
    return shift->[$_IDI]->{output}
	or Bivio::Die->die('no output');
}

=for html <a name="set_header"></a>

=head2 set_header(string name, string value)

Sets an arbitrary header value.

=cut

sub set_header {
    my($self, $name, $value) = @_;
    my($fields) = $self->[$_IDI];
    ($fields->{headers} ||= {})->{$name} = $value;
    return;
}

=for html <a name="set_output"></a>

=head2 set_output(any value)

Accepts outputs same as Bivio::Agent::HTTP::Reply.

=cut

sub set_output {
    my($self, $value) = @_;
    my($fields) = $self->[$_IDI];
    # Ignore duplicate calls, that's not what were testing
    $fields->{output} = ref($value) eq 'GLOB' || ref($value) eq 'IO::File'
        ? Bivio::IO::File->read($value)
	: ref($value) eq 'SCALAR' ? $value
	: Bivio::Die->die('not a GLOB or SCALAR reference');
    return $self;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
