# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use strict;
$Bivio::Mail::Incoming::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Mail::Incoming - parses an incoming mail message

=head1 SYNOPSIS

    use Bivio::Mail::Incoming;
    Bivio::Mail::Incoming->new($rfc822_ref);
    Bivio::Mail::Incoming->uninitialize();
    Bivio::Mail::Incoming->initialize($rfc822_ref);

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Incoming::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Mail::Incoming> parses and maintains the state of an incoming mail
message.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string_ref rfc822) : Bivio::Mail::Incoming

Create an instance and L<initialize|"initialize"> with I<rfc822>.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    my(undef, $rfc822) = @_;
    $self->initialize($rfc822);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="uninitialize"></a>

=head2 uninitialize()

Clear any state associated with this object.

=cut

sub uninitialize {
    my($self) = @_;
    delete($self->{$_PACKAGE});
    return;
}

=for html <a name="get_body_ref"></a>

=head2 get_body_ref() : string

=head2 get_body_ref(string_ref body)

Returns the body of the message or puts a copy in I<body>.

=cut

sub get_body {
    my($self, $body) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($body)) {
	$$body = substr(${$fields->{rfc822}}, $fields->{body_offset});
	return;
    }
    return substr(${$fields->{rfc822}}, $fields->{body_offset});
}

=for html <a name="get_from_email"></a>

=head2 get_from_email() : string

Return the email address of the message.

=cut

sub get_from_email {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    defined($fields->{from_email}) && return $fields->{from_email};
    my($from) = &_get_field($fields, 'from:');
comment
ctext ( () \( )

dtext [bla \ spaces]
domain-literal

quoted string
qtext "\""
ignore all but first address;
    return $email;
}

=for html <a name="initialize"></a>

=head2 initialize(string_ref $rfc822)

Initializes the object with the reference supplied.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub initialize {
    my($self, $rfc822) = @_;
# RJN: Turns out this is about the fastest way, since any way you
# clear a hash is expensive.  This is likely to generate more
# memory churn, but the objects are small..
    my($i) = index($$rfc822, "\n\n");
    my($h);
    if ($i >= 0) {
	$h = substr($$rfc822, 0, $i);
	# Account for \n\n
	$i += 2;
    }
    else {
	$h = $$rfc822;
	$i = length($$rfc822);
    }
    # unfold all headers, since we are likely to have to parse one header.
    #
    # [rfc882] Unfolding is accomplished by regarding CRLF immediately
    # followed by a LWSP-char as equivalent to the LWSP-char.
    # Can't use \s, because isn't locale specific.
    $h =~ s/\r?\n[ \t]/ /gs;
    $self->{$_PACKAGE} = {
	'rfc822' => $rfc822,
	# If there is no body, get_body will return empty string.
	'body_offset' => $i,
	# Must include the \n\n
	'header' => $h,
    };
    return;
}

#=PRIVATE METHODS

# $name must be lc and ending with a ':'
sub _get_field {
    my($fields, $name) = @_;
    # May be that the field is undefined.
    unless (exists($fields->{$name})) {
	($fields->{$name}) = $fields->{header} =~ /^$name\s*(.*)/im;
    }
    return $fields->{$name};
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
