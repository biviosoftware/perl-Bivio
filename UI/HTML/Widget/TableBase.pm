# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::TableBase;
use strict;
use Bivio::Base 'Widget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::TableBase>
#
#
#
# align : any [Table => Facade.HTML.table_default_align]
#
# How to align the table.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.
# No default if I<class> is set.
#
# background : any
#
# Widget which returns image to render for background.
#
# bgcolor : any [] (dynamic)
#
# The value to be passed to the C<BGCOLOR> attribute of the C<TABLE> tag.
# See L<b_use('FacadeComponent.Color')|Bivio::UI::Color>.
#
# border : any [0]
#
# Width of border surrounding the table and its cells.
# No default if I<class> is set.
#
# cellpadding : any [Table => 5, Grid => 0]
#
# Padding inside each cell in pixels.
# No default if I<class> is set.
#
# cellspacing : any [0]
#
# Spacing around each cell in pixels.
# No default if I<class> is set.
#
# class : any
#
# The html CLASS for the table.  If exists, then pad, space, cellspacing,
# cellpadding, border, and align default to "undef".
#
# end_tag : any [true]
#
# If false, this widget won't render the start tag.
#
# expand : boolean [false]
#
# If true, the table C<WIDTH> will be C<95%> or C<100%> depending
# on b_use('FacadeComponent.HTML').page_left_margin.
#
# height : any []
#
# Dynamic height (only IE and Netscape support this attribute).
#
# id : any
#
# The html ID for the table.
#
# pad : any [0]
#
# B<DEPRECATED>
#
# space : any [0]
#
# B<DEPRECATED>
#
# style : string
#
# Style attribute for the table.  No elements of the string are interpolated.
#
# start_tag : any [true]
#
# If false, this widget won't render the end tag.
#
# width : any []
#
# Set the width of the table explicitly.

my($_HTML_ATTRS) = b_use('UI.Facade')->if_2014style(
    [qw(style class id)],
    [qw(border cellpadding cellspacing width height style class id)],
);

sub initialize_html_attrs {
    # (self) : undef
    # Initializes above attributes.
    my($self, $source) = @_;
    # Grid used to use pad and space; Can't warn, because too many uses.
    foreach my $x ([pad => 'cellpadding'], [space => 'cellspacing']) {
	next unless $self->has_keys($x->[0]);
	$self->put($x->[1] => $self->get($x->[0]));
	$self->delete($x->[0]);
    }
    $self->put(
	width => $self->subclass_is_table
	    ? If(
		[['->get_request'], 'Bivio::UI::Facade', 'HTML',
		 '->get_value', 'page_left_margin'],
		'95%',
		'100%',
	    ) : '100%',
    ) if $self->unsafe_get('expand');
    unless ($self->has_keys('class')) {
	$self->get_if_exists_else_put(
	    align => [['->get_request'],
		      'Bivio::UI::Facade', 'HTML', '->get_value',
		      'table_default_align'],
	) if $self->subclass_is_table;
	foreach my $k (qw(border cellpadding cellspacing)) {
	    $self->put($k => $k eq 'cellpadding' && $self->subclass_is_table
			   ? 5 : 0)
		unless $self->has_keys($k);
	}
    }
    # Make sure these two exist
    $self->get_if_exists_else_put(end_tag => 1);
    $self->get_if_exists_else_put(start_tag => 1);
    vs_html_attrs_initialize(
	$self, [@$_HTML_ATTRS, qw(align start_tag end_tag background bgcolor)],
        $source,
    );
    return;
}

sub render_end_tag {
    # (self, any, string) : string
    # Renders end table tag.
    my($self, $source) = @_;
    return ${$self->render_attr('end_tag', $source)}
	? ($self->subclass_is_table ? "\n" : '') . "</table>"
	: '';
}

sub render_start_tag {
    # (self, any) : string
    # Returns <table tag with common attributes.
    my($self, $source) = @_;
    my($req) = $source->get_request;
    return ${$self->render_attr('start_tag', $source)}
	? join('',
	       ($self->subclass_is_table ? "\n" : ()),
	       '<table',
	       vs_html_attrs_render($self, $source, $_HTML_ATTRS),
	       map({
		   my($class, $method, $attr) = @$_;
		   my($b);
		   # as_html works, b/c it ignores subsequent args
		   $self->unsafe_render_attr($attr, $source, \$b) && $b
		       ? b_use($class)->$method($b, $attr, $req) : '',
	       }
		   [qw(FacadeComponent.Color format_html bgcolor)],
		   [qw(FacadeComponent.Icon format_html_attribute background)],
		   [qw(UI.Align as_html align)],
	       ),
	       '>',
	) : '';
}

sub subclass_is_table {
    # (self) : boolean
    # Returns true if subclass is table.
    return ref(shift) =~ /Table$/ ? 1 : 0;
}

1;
