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

The body of the message.  B<Attachments not supported.>

=item cc : any []

The Cc: address(es) in the header.  See I<recipients> for
the actual send-to addresses.

=item from : any (required)

The From: address in the header.

=item recipients : any (required)

The recipients is a string of addresses separated by a comma.
Use a L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join> with
a comma separator if you have more than one address.

=item subject : any []

The Subject: address in the header.

=item to : any []

The To: address(es) in the header.  See I<recipients> for
the actual send-to addresses.

=back

=cut

#=IMPORTS
use Bivio::Mail::Address;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Mail::Widget::Message

Creates a Message.  There is no positional notation for this widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Creates and sends a mail message.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Headers
    my($msg) = Bivio::Mail::Outgoing->new();
    my($recipients) = $self->render_value('recipients',
	    $fields->{recipients}, $req);
    $msg->set_recipients($$recipients);
    my($from) = $self->render_value('from', $fields->{from}, $req);
    $msg->set_header('From', $$from);
    my($email) = Bivio::Mail::Address->parse($$from);
    $self->die('from', $req, 'no email in From: ', $$from) unless $email;
    $msg->set_envelope_from($email);

    foreach my $f (qw(to cc subject)) {
	my($b) = '';
	$msg->set_header(ucfirst($f), $b)
		if $self->unsafe_render_value($f, $fields->{$f}, $req, \$b);
    }
    $msg->set_header('X-Originating-IP', $req->get('client_addr'))
	    if $req->has_keys('client_addr');

    my($body) = '';
    $self->unsafe_render_value('body', $fields->{body}, $req, \$body);
    if ($recipients =~ /\@(?:aol|compuserve|cs).com$/i) {
	# AOL and compuserv are totally brain dead.
	$msg->set_body(_text_to_aol($body));
    }
    else {
	# The rest of the word understands plain text with links.
	$msg->set_body($body);
    }
    $msg->enqueue_send;
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{recipients} = $self->initialize_attr('recipients');
    $fields->{from} = $self->initialize_attr('from');
    foreach my $f (qw(body cc to subject)) {
	$fields->{$f} = $self->unsafe_initialize_attr($f);
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

# _text_to_aol(string text) : string
#
# Generates something that AOL's mail reader can understand.  AOL
# does not highlight links unless they are in an <a href>.  It also
# doesn't understand all tags.  The tags it does understand, it strips.
#
sub _text_to_aol {
    my($text) = @_;
    my($html) = "<html>\n";
    foreach my $line (split(/\n/, $text)) {
	# Put in minimal tags to generate links.  Don't replace anything
	# else.
	$line =~ s/(https?:\S+\w)/<a href="$1">$1<\/a>/g;
	$line =~ s/(\w\S+@\S+\w)/<a href="mailto:$1">$1<\/a>/g;
	$html .= $line ."\n";
    }
    $html .= "</html>\n";
    return $html;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
