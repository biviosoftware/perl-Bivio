# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::TableBase;
use strict;
$Bivio::UI::HTML::Widget::TableBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::TableBase::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::TableBase - common attrs between Grid and Table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TableBase;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::TableBase::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TableBase>

=head1 ATTRIBUTES

=over 4

=item align : any [Table => Facade.HTML.table_default_align]

How to align the table.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<TD> tag.
No default if I<class> is set.

=item background : any

Widget which returns image to render for background.

=item bgcolor : any [] (dynamic)

The value to be passed to the C<BGCOLOR> attribute of the C<TABLE> tag.
See L<Bivio::UI::Color|Bivio::UI::Color>.

=item border : any [0]

Width of border surrounding the table and its cells.
No default if I<class> is set.

=item cellpadding : any [Table => 5, Grid => 0]

Padding inside each cell in pixels.
No default if I<class> is set.

=item cellspacing : any [0]

Spacing around each cell in pixels.
No default if I<class> is set.

=item class : any

The html CLASS for the table.  If exists, then pad, space, cellspacing,
cellpadding, border, and align default to "undef".

=item end_tag : any [true]

If false, this widget won't render the start tag.

=item expand : boolean [false]

If true, the table C<WIDTH> will be C<95%> or C<100%> depending
on Bivio::UI::HTML.page_left_margin.

=item height : any []

Dynamic height (only IE and Netscape support this attribute).

=item id : any

The html ID for the table.

=item pad : any [0]

B<DEPRECATED>

=item space : any [0]

B<DEPRECATED>

=item style : string

Style attribute for the table.  No elements of the string are interpolated.

=item start_tag : any [true]

If false, this widget won't render the end tag.

=item width : any []

Set the width of the table explicitly.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_HTML_ATTRS) = [qw(border cellpadding cellspacing width height style class id)];
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="initialize_html_attrs"></a>

=head2 initialize_html_attrs()

Initializes above attributes.

=cut

sub initialize_html_attrs {
    my($self, $source) = @_;
    # Grid used to use pad and space; Can't warn, because too many uses.
    foreach my $x ([pad => 'cellpadding'], [space => 'cellspacing']) {
	next unless $self->has_keys($x->[0]);
	$self->put($x->[1] => $self->get($x->[0]));
	$self->delete($x->[0]);
    }
    $self->put(
	width => $self->subclass_is_table
	    ? $_VS->vs_new(
		'If',
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
    $_VS->vs_html_attrs_initialize(
	$self, [@$_HTML_ATTRS, qw(align start_tag end_tag background bgcolor)],
        $source,
    );
    return;
}

=for html <a name="render_end_tag"></a>

=head2 render_end_tag(any source, string prefix) : string

Renders end table tag.

=cut

sub render_end_tag {
    my($self, $source) = @_;
    return ${$self->render_attr('end_tag', $source)}
	? ($self->subclass_is_table ? "\n" : '') . "</table>"
	: '';
}

=for html <a name="render_start_tag"></a>

=head2 render_start_tag(any source) : string

Returns <table tag with common attributes.

=cut

sub render_start_tag {
    my($self, $source) = @_;
    my($req) = $source->get_request;
    return ${$self->render_attr('start_tag', $source)}
	? join('',
	       ($self->subclass_is_table ? "\n" : ()),
	       '<table',
	       $_VS->vs_html_attrs_render($self, $source, $_HTML_ATTRS),
	       map({
		   my($class, $method, $attr) = @$_;
		   my($b);
		   # as_html works, b/c it ignores subsequent args
		   $self->unsafe_render_attr($attr, $source, \$b) && $b
		       ? $class->$method($b, $attr, $req) : '',
	       }
		   [qw(Bivio::UI::Color format_html bgcolor)],
		   [qw(Bivio::UI::Icon format_html_attribute background)],
		   [qw(Bivio::UI::Align as_html align)],
	       ),
	       '>',
	) : '';
}

=for html <a name="subclass_is_table"></a>

=head2 subclass_is_table() : boolean

Returns true if subclass is table.

=cut

sub subclass_is_table {
    return ref(shift) =~ /Table$/ ? 1 : 0;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
