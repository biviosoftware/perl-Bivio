# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Page;
use strict;
$Bivio::UI::HTML::Widget::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Page::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Page - renders an HTML page

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Page;
    Bivio::UI::HTML::Widget::Page->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Page::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Page> is an HTML C<PAGE> tag surrounding
a widget, which is usually a
L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
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

=item background : string

Name of the icon to use for the page background.

=back

=item body : Bivio::UI::Widget (required)

How to render the C<BODY> tag contents.  Usually a
L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>
or
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=item head : Bivio::UI::Widget (required)

How to render the C<HEAD> tag contents.
Usually a
L<Bivio::UI::HTML::Widget::Title|Bivio::UI::HTML::Widget::Title>.

=item page_alink_color : string

Facade color for active links.

=item page_bgcolor : string

Facade color for the page background.

=item page_link_color : string

Facade color for links.

=item page_text_color : string

Facade color for text.

=item page_vlink_color : string

Facade color for visited links.

=item style : Bivio::UI::Widget

Renders an inline style in the header.  The widget
must render the C<STYLE> or C<META> tags as appropriate.

=head1 COMPONENT ATTRIBUTES

=over 4

=item html_tag_attrs : string []

Attributes to be applied to the html_tag used to generate the component.
Only currently works for I<body> components.

Must have a leading space.

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
my($_IDI) = __PACKAGE__->instance_data_index;
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
    my($self) = Bivio::UI::Widget::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Calls L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as text/html.

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/html');
}

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

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
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
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    $$buffer .=
	    '<!doctype html public "-//w3c//dtd html 4.0 transitional//en">'
	    ."\n<html><head>\n";
    $fields->{head}->render($source, $buffer);
    $fields->{style}->render($source, $buffer) if $fields->{style};
    # This is a check for Internet Explorer.  Netscape is BROWSER_HTML4.
    # IE caches too much.
    $$buffer .= "<meta name=MSSmartTagsPreventParsing content=TRUE>\n"
	.'<meta http-equiv=pragma content="no-cache">'."\n"
	if $req->get('Type.UserAgent')->equals_by_name('BROWSER');
    $$buffer .= '</head><body';
    # Always have a background color
    $$buffer .= Bivio::UI::Color->format_html(
	$self->get_or_default('page_bgcolor', 'page_bg'), 'bgcolor', $req);
    foreach my $c ('text', 'link', 'alink', 'vlink') {
	my($n) = 'page_'.$c;
	$$buffer .= Bivio::UI::Color->format_html(
	    $self->get_or_default($n.'_color', $n), $c, $req);
    }

    # background image
    $$buffer .= ' background="'
	    .Bivio::UI::Icon->get_value($fields->{background}, $req)->{uri}
		    .'"' if $fields->{background};
    my($hta) = $fields->{body}->unsafe_get('html_tag_attrs');
    $$buffer .= $hta if $hta;
    $$buffer .= ">\n";

    $fields->{body}->render($source, $buffer);

    my($t) = $self->show_time_as_html($req);
    $$buffer .= "\n".$t."\n";

    $$buffer .= "</body></html>\n";
    return;
}

=for html <a name="show_time_as_html"></a>

=head2 static show_time_as_html(Bivio::Agent::Request req) : string

Returns page times as an html comment, no spaces or newlines.
Resets counters.  Returns empty string if I<show_time> not configured.

=cut

sub show_time_as_html {
    my($proto, $req) = @_;
    return '' unless $_SHOW_TIME || $_TRACE;
    # Output timing info
    my($times) = sprintf('total=%.3fs; db=%.3fs',
	    $req->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time);
    _trace($times) if $_TRACE;
    return $_SHOW_TIME ? "<!-- " . $times . " -->" : '';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
