# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Message;
use strict;
$Bivio::UI::Mail::Widget::Message::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Mail::Widget::Message::VERSION;

=head1 NAME

Bivio::UI::Mail::Widget::Message - creates and enqueues a mail message

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Mail::Widget::Message;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Mail::Widget::Message::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Mail::Widget::Message> creates and enqueues a plain text
mail message.  Eventually, this widget will be expanded to support
attachments and other content types.

See L<Bivio::Mail::Outgoing|Bivio::Mail::Outgoing>.

=head1 ATTRIBUTES

All attributes are rendered identically.  They may be widget values,
constants, widgets, or widget values which return widgets.

=over 4

=item body : any []

The body of the message.

=item cc : any []

The Cc: address(es) in the header.  See I<recipients> for
the actual send-to addresses.

=item from : any (required)

The From: address in the header.

=item headers : any []

Any additional headers.  Returns a string in RFC 822 header format.  Each
header appears on its own line.

=item log_file : any []

Where to log the message, if defined.  Calls
L<Bivio::IO::Log::write|Bivio::IO::Log/"write"> with the formatted
message.

=item recipients : any (required)

The recipients is a string of addresses separated by a comma.
Use a L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join> with
a comma separator if you have more than one address.

=item subject : any []

The Subject: address in the header.

=item to : any []

The To: address(es) in the header.  See I<recipients> for
the actual send-to addresses.

=item want_aol_munge : boolean [true]

munge body by wrapping urls and email addresses in HTMl.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Mail::Address;
use Bivio::Mail::Outgoing;
use Bivio::IO::Log;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Mail::Widget::Message

Create a widget.

=cut

sub new {
    return shift->SUPER::new(@_);
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Creates and sends a mail message.

=cut

sub execute {
    my($self, $req) = @_;
    my($msg) = Bivio::Mail::Outgoing->new();
    my($from) = $self->render_attr('from', $req);
    $msg->set_header('From', $$from);
    my($email) = Bivio::Mail::Address->parse($$from);
    $self->die('from', $req, 'no email in From: ', $$from)
	unless $email;
    $msg->set_envelope_from($email);

    my($recipients) = '';
    $self->unsafe_render_attr('recipients', $req, \$recipients);
    my(@recips) = ();

    foreach my $header (qw(to cc subject)) {
	my($value) = '';

	if ($self->unsafe_render_attr($header, $req, \$value) && $value) {
	    $msg->set_header(ucfirst($header), $value);
	    push(@recips, $value) unless $header eq 'subject';
	}
    }
    $msg->set_recipients(
	$recipients
	? $recipients
        : join(',', @recips));
    $msg->set_header('X-Originating-IP', $req->get('client_addr'))
	    if $req->has_keys('client_addr');

    my($body) = $self->render_attr('body', $req);
#TODO: Headers must be rendered after body, b/c Widget::MIMEEntity
#      depends on this.
    _headers($self, $msg, $req);
    if ($self->get_or_default('want_aol_munge', 1)
	&&  $recipients =~ /\@(?:aol|compuserve|cs).com$/i) {
	# AOL and compuserv are totally brain dead.
	$body = _text_to_aol($body);
    }
    $msg->set_body($$body);
    $msg->enqueue_send;
    my($lf);
    Bivio::IO::Log->write($lf, $msg->as_string)
        if $self->unsafe_render_attr('log_file', $req, \$lf) && $lf;
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('from');
    foreach my $f (qw(recipients body cc to subject headers log_file)) {
	$self->unsafe_initialize_attr($f);
    }
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

This widget is not renderable.

=cut

sub render {
    Bivio::Die->die('This widget is only executable, it cannot be rendered');
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _headers(self, Bivio::Mail::Outgoing msg, Bivio::Agent::Request req)
#
# Sets headers if any
#
sub _headers {
    my($self, $msg, $req) = @_;
    my($b) = '';
    return
	unless $self->unsafe_render_attr('headers', $req, \$b) && $b;
    foreach my $h (split(/\n(?=\S)/, $b)) {
	chomp($h);
	next unless $h;
	Bivio::Die->die($h, ': invalid header')
	    unless $h =~ /^(\S+):\s*(.+)/s;
        $msg->set_header($1, $2);
    }
    return;
}

# _text_to_aol(string_ref text) : string_ref
#
# Generates something that AOL's mail reader can understand.  AOL
# does not highlight links unless they are in an <a href>.  It also
# doesn't understand all tags.  The tags it does understand, it strips.
#
sub _text_to_aol {
    my($text) = @_;
    my($html) = "<html>\n";
    foreach my $line (split(/\n/, $$text)) {
	# Put in minimal tags to generate links.  Don't replace anything
	# else.
	$line =~ s/(https?:\S+\w)/<a href="$1">$1<\/a>/g;
	$line =~ s/(\w\S+@\S+\w)/<a href="mailto:$1">$1<\/a>/g;
	$html .= $line ."\n";
    }
    $html .= "</html>\n";
    return \$html;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
