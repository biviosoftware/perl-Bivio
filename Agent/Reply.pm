# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
$Bivio::Agent::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::Reply - a user agent reply

=head1 SYNOPSIS

    my($req) = ...;
    my($reply) = $req->get_reply();

    $reply->set_output_type('image/gif');  # default is 'text/plain'
    $reply->print($image);
    $reply->set_die_code($die->get('code'));
    $reply->set_die_code(undef);
    $reply->send($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Reply::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Reply> is the complement to
L<Bivio::Agent::Request>, it is the output channel
for responses. Initially, a reply is in the NOT_HANDLED state indicating
that no action has been taken for the corresponding Request.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Reply

Creates a reply in an error state with the 'text/plain' output type.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
        'output_type' => 'text/plain',
        'die_code' => Bivio::DieCode::DIE(),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="send"></a>

=head2 send(Bivio::Agent::Request req)

Sends the buffered reply data.

=cut

sub send {
}

=for html <a name="get_output_type"></a>

=head2 get_ouput_type() : string

Returns the reply format type.

=cut

sub get_output_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{output_type};
}

#TODO: Don't think we need this
#=for html <a name="get_die_code"></a>
#
#=head2 get_die_code() : Bivio::DieCode or undef
#
#Returns the die code associated with the reply. 
#
#=cut
#
#sub get_die_code {
#    my($self) = @_;
#    my($fields) = $self->{$_PACKAGE};
#    return $fields->{die_code};
#}

=for html <a name="print"></a>

=head2 abstract print(string str)

Writes the specified string to the request's output stream. Binary output
types can pass binary data to this method as well.

=cut

sub print {
    die("abstract method");
}

=for html <a name="set_output_type"></a>

=head2 set_output_type(string type)

Sets the reply format type. For example this could be 'text/html'.

=cut

sub set_output_type {
    my($self, $type) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{output_type} = $type;
    return;
}

#TODO: Don't think we need this
#=for html <a name="set_die_code"></a>
#
#=head2 set_die_code(Bivio::DieCode die_code)
#
#Sets I<die_code> to the appropriate state.
#
#=cut
#
#sub set_die_code {
#    my($self, $die_code) = @_;
#    my($fields) = $self->{$_PACKAGE};
#    if (defined($die_code) && !UNIVERSAL::isa($die_code, 'Bivio::DieCode')) {
#	my($dc) = Bivio::DieCode->from_any($die_code);
#	# By calling die here, Bivio::Die takes over error handlingo
#	Bivio::Die->die($die_code, {reply => $self}, caller) unless $dc;
#	$die_code = $dc;
#    }
#    $fields->{die_code} = $die_code;
#    return;
#}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
