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
L<Bivio::UI::HTML::Widget::Submit|Bivio::UI::HTML::Widget::Submit>.

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

=back

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
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
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
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
    return if $fields->{prefix};
    $fields->{middle} = '</head><body';
    # Always have a background color
    $fields->{middle} .= Bivio::UI::Color->as_html_bg('page_bg');
    foreach my $c ('text', 'link', 'alink', 'vlink') {
	my($n) = 'page_'.$c;
	$fields->{middle} .= Bivio::UI::Color->as_html($c, $n)
		if Bivio::UI::Color->unsafe_from_any($n);
    }
    $fields->{middle} .= ">\n";
    my($v);
    foreach $v (($fields->{head}, $fields->{body})
	    = $self->get('head', 'body')) {
	$v->put(parent => $self);
	$v->initialize;
    }
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= "<html><head>\n";
    $fields->{head}->render($source, $buffer);
    $$buffer .= $fields->{middle};
    $fields->{body}->render($source, $buffer);
    $$buffer .= "</body></html>\n";
    $$buffer .= sprintf("<!-- %.3fs total -->\n<!-- %.3fs db -->\n",
	    Bivio::Agent::Request->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time) if $_SHOW_TIME;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
