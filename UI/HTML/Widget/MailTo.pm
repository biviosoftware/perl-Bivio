# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::MailTo;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::HTML::Widget::MailTo> displays an email as a
# C<mailto> link.
#
#
#
#
# email : array_ref (required)
#
# Text to render for the mailto.
#
# email : string (required)
#
# Literal to render for the mailto.  The email address need not
# have the host suffix.  It will be appended.
#
# value : array_ref [I<email>]
#
# Text to render.  If same as I<email>, nothing will be rendered
# if email is invalid.
#
# value_invalid : string []
#
# What to display if the value is invalid.
#
# subject : array_ref []
#
# Text to use for subject of mailto.
#
# string_font : any [mailto]
#
# Used to render value.
#
# want_link : boolean [1]
#
# By default, render as a link.  Otherwise, just render the email address.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_E) = __PACKAGE__->use('Type.Email');
my($_S) = __PACKAGE__->use('HTMLWidget.String');

sub initialize {
    # (self) : undef
    # Initializes from configuration attributes.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
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
    $fields->{value_widget} = $_S->new({
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

sub new {
    # (proto, any, any, any, hash_ref) : Widget.MailTo
    # (proto, hash_ref) : Widget.MailTo
    # Create an MailTo widget using I<email>, I<value>, and I<subject>.
    # I<email> is the only required attribute.
    #
    #
    # Create an MailTo widget using I<attributes>.
    my($proto, @args) = _new_args(@_);
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Draws the file field on the specified buffer.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;

    # Format as an email first before seeing if ignore.  This
    # allows the case where the email doesn't have a "host" which
    # would be considered invalid (and ignored).
    my($email) = ref($fields->{email})
	    ? $source->get_widget_value(@{$fields->{email}})
	    : $req->format_email($fields->{email});
    $email ||= '';

    # Don't render anything which is ignored.
    if ($_E->is_ignore($email)) {
	# Don't make visible ignored addresses
	if ($fields->{email} eq $fields->{value}
	    || ref($fields->{value}) eq 'ARRAY'
	    && $email eq $source->get_widget_value(@{$fields->{value}}))
	{
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

sub _new_args {
    # (proto, any, ...) : array
    # Returns arguments to be passed to Attributes::new.
    my($proto, $email, $value, $subject, $attrs) = @_;
    return ($proto, $email) if ref($email) eq 'HASH' || int(@_) == 1;
    return ($proto, {
	email => $email,
	value => $value,
	subject => $subject,
	$attrs ? %$attrs : (),
    }) if defined($email);
    $proto->die(undef, undef, 'invalid arguments to new');
    # DOES NOT RETURN
}

1;
