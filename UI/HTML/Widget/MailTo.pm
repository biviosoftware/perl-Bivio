# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::MailTo;
use strict;
$Bivio::UI::HTML::Widget::MailTo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::MailTo - render an email address as a link

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::MailTo;
    Bivio::UI::HTML::Widget::MailTo->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::MailTo::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::MailTo> displays an email as a
C<mailto> link.


=head1 ATTRIBUTES

=over 4

=item email : array_ref (required)

Text to render for the mailto.

=item email : string (required)

Literal to render for the mailto.  The email address need not
have the host suffix.  It will be appended.

=item value : array_ref [I<email>]

Text to render.  If same as I<email>, nothing will be rendered
if email is invalid.

=item value_invalid : string []

What to display if the value is invalid.

=item subject : array_ref []

Text to use for subject of mailto.

=item string_font : any [mailto]

Used to render value.

=item want_link : boolean [1]

By default, render as a link.  Otherwis, just render the email address.

=back

=cut

#=IMPORTS
use Bivio::Type::Email;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::MailTo

Create an Email.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{email};

    foreach my $f (qw(value subject value_invalid)) {
	my($v) = $self->unsafe_get($f);
	$fields->{$f} = $v ? $v : '';
    }
    $fields->{email} = $self->get('email');

    # Must be undef, because passed to mailto
    $fields->{subject} = undef unless $fields->{subject};

    # If no value, need to set to email
    unless ($fields->{value}) {
	if (ref($fields->{email})) {
	    # Should already be an email if a widget value
	    $fields->{value} = $fields->{email};
	}
	else {
	    # Literal string need to format as an email
	    $fields->{value} = [['->get_request'],
		'->format_email', $fields->{email}];
	}
    }

    # Make the value into a widget
    my($string_font) = $self->get_or_default('string_font', 'mailto');
    $fields->{value_widget} = Bivio::UI::HTML::Widget::String->new({
	value => $fields->{value},
	parent => $self,
	string_font => $string_font,
    });
    $fields->{value_widget}->initialize;

    if ($fields->{value_invalid}) {
	$fields->{value_invalid} = Bivio::UI::HTML::Widget::String->new({
	    value => $fields->{value_invalid},
	    parent => $self,
	    string_font => $string_font,
	});
	$fields->{value_invalid}->initialize;
    }
    $fields->{want_link} = $self->get_or_default('want_link', 1);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the file field on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;

    # Format as an email first before seeing if ignore.  This
    # allows the case where the email doesn't have a "host" which
    # would be considered invalid (and ignored).
    my($email) = ref($fields->{email})
	    ? $source->get_widget_value(@{$fields->{email}})
	    : $req->format_email($fields->{email});

    # Don't render anything which is ignored.
    if (Bivio::Type::Email->is_ignore($email)) {
	# Don't make visible ignored addresses
	if ($fields->{email} eq $fields->{value}
		|| $email eq $source->get_widget_value(@{$fields->{value}})) {
	    $fields->{value_invalid}->render($source, $buffer)
		    if $fields->{value_invalid};
	} else {
	    # MessageDetail uses this case
	    $fields->{value_widget}->render($source, $buffer);
	}
    }
    elsif ($fields->{want_link}) {
	# Not ignored email
	$$buffer .= '<a href="'
		.$req->format_mailto($email, $fields->{subject}).'">';
	$fields->{value_widget}->render($source, $buffer);
	$$buffer .= '</a>';
    }
    else {
	# Don't render the link
	$fields->{value_widget}->render($source, $buffer);
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
