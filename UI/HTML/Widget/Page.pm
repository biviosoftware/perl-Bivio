# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Page;
use strict;
$Bivio::UI::HTML::Widget::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Page - renders an HTML page

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Page;
    Bivio::UI::HTML::Widget::Page->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Page::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Page> is an HTML C<PAGE> tag surrounding
a widget, which is usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>,
but might be a
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
The widget or its children should be a
L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.

The link, bg, and text colors are specified by the
L<Bivio::UI::Color|Bivio::UI::Color> names:
page_bg, page_text, page_link, page_vlink, and page_alink.
page_bg must be defined, but the others may be undefined iwc
the color defaults to the browser default.

=head1 ATTRIBUTES

=over 4

=item body : Bivio::UI::Widget (required)

How to render the C<BODY> tag contents.  Usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>
or
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=item head : Bivio::UI::Widget (required)

How to render the C<HEAD> tag contents.
Usually a
L<Bivio::UI::HTML::Widget::Title|Bivio::UI::HTML::Widget::Title>.

=item style : Bivio::UI::Widget

Renders an inline style in the header.  The widget
must render the C<STYLE> or C<META> tags as appropriate.

=item background : string

Name of the icon to use for the page background.

=back

=head1 FACADE ATTRIBUTES

=over 4

=item Bivio::UI::Color.page_link : string

Color of links.

=item INCOMPLETE

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SHOW_TIME) = 0;
Bivio::IO::Config->register({
    'show_time' => $_SHOW_TIME,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Page

Creates a new Page widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item show_time : boolean [false] (inherited)

Show the elapsed time in page trailer.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_SHOW_TIME = $cfg->{show_time};
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static inpageation.

=cut

sub initialize {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{head};

    my($v);
    foreach $v (($fields->{head}, $fields->{body})
	    = $self->get('head', 'body')) {
	$v->put(parent => $self);
	$v->initialize;
    }
    $fields->{style}->put_and_initialize(parent => $self)
	    if $fields->{style} = $self->unsafe_get('style');
    $fields->{background} = $self->get_or_default('background');
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .=
	    '<!doctype html public "-//w3c//dtd html 4.0 transitional//en">'
	    ."\n<html><head>\n";
    $fields->{head}->render($source, $buffer);
    $fields->{style}->render($source, $buffer) if $fields->{style};
    $$buffer .= '</head><body';
    my($req) = $source->get_request;
    # Always have a background color
    $$buffer .= Bivio::UI::Color->format_html('page_bg', 'bgcolor', $req);
    foreach my $c ('text', 'link', 'alink', 'vlink') {
	my($n) = 'page_'.$c;
	$$buffer .= Bivio::UI::Color->format_html($n, $c, $req);
    }

    # background image
    $$buffer .= ' background="'
	    .Bivio::UI::Icon->get_value($fields->{background}, $req)->{uri}
		    .'"' if $fields->{background};
    $$buffer .= ">\n";

    $fields->{body}->render($source, $buffer);

    if ($_SHOW_TIME || $_TRACE) {
        # Output timing info
        my($times) = sprintf('total=%.3fs; db=%.3fs',
                Bivio::Agent::Request->get_current->elapsed_time,
                Bivio::SQL::Connection->get_db_time);
        $$buffer .= "\n<!-- " . $times . " -->\n" if $_SHOW_TIME;
        _trace($times) if $_TRACE;
    }

    $$buffer .= "</body></html>\n";
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
