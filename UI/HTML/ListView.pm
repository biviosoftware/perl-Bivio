# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ListView;
use strict;
$Bivio::UI::HTML::ListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::ListView - A view which renders a ListModel.

=head1 SYNOPSIS

    use Bivio::UI::HTML::ListView;
    my($users) = Bivio::Biz::UserList->new();
    if ($users->find({club => $club_id})) {
        my($list_view) = Bivio::UI::HTML::ListView->new('userlist');
        $list_view->render($users, $req);
    }

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::HTML::ListView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::ListView> draws a ListModel within an HTML <table>
element. Each column in the table may be rendered by a different
L<Bivio::UI::HTML::ListCellRenderer>. If no renderer for a column has
been specified using L<"set_column_renderer"> then a default one is
created by invoking L<"get_default_renderer"> which uses the column field
type to determine the renderer to employ. Subclasses may want to override
L<"get_default_renderer"> to provide a dynamic list cell renderer.

If the target L<Bivio::Biz::ListModel> supports
L<Bivio::Biz::ListModel/"get_sort_key"> then the table headings will be
rendered as links for sorting columns.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

#=IMPORTS
use Bivio::UI::HTML::FieldUtil;
use Bivio::UI::HTML::ListCellRenderer;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UI::HTML::ListView

Creates a ListView with the specified view name.

=head2 static new(string name, string attributes) : Bivio::UI::HTML::ListView

Creates a ListView with the specified view name and HTML table attributes.

=cut

sub new {
    my($proto, $name, $attributes) = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);
    $self->{$_PACKAGE} = {
	attributes => $attributes
	    || 'width="100%" border=0 cellpadding=5 cellspacing=0',
	col_renderers => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_renderer"></a>

=head2 get_default_renderer(FieldDescriptor type) : ListCellRenderer

Returns a default cell renderer for the specified field type. See
L<Bivio::UI::HTML::FieldUtil/"get_renderer"> of FieldUtil.

=cut

sub get_default_renderer {
    my($self, $type) = @_;

    my($inner) = Bivio::UI::HTML::FieldUtil->get_renderer($type);
    my($attributes);

    if ($type->get_type() == Bivio::Biz::FieldDescriptor::DATE()) {
	$attributes = 'nowrap width="1%" align=right';
    }
    elsif ($type->get_type() == Bivio::Biz::FieldDescriptor::EMAIL_REF()) {
	$attributes = 'nowrap width="1%"';
    }

    return Bivio::UI::HTML::ListCellRenderer->new($inner, $attributes);
}

=for html <a name="render"></a>

=head2 render(ListModel model, Request req)

Draws the ListModel in an HTML <table> element. First the <table> element
is printed including the attributes specified in the constructor. Then
the heading and body are rendered using L<"render_heading"> and
L<"render_body">.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print('<table '.$fields->{attributes}.'>');
    $self->render_heading($model, $req);
    $self->render_body($model, $req);
    $req->print('</table>');
}

=for html <a name="render_body"></a>

=head2 render_body(ListModel model, Request req)

Draws the table body - all the rows. If no column renderer has been
specified using L<"set_column_renderer"> then a default one for the
data type is created by invoking L<"get_default_renderer">.

=cut

sub render_body {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($max_row) = $model->get_row_count();
    my($max_col) = $model->get_column_count();

    for (my($row) = 0; $row < $max_row; $row++ ) {
	if ($row & 0x01) {
	    $req->print('<tr bgcolor="#EEEEEE">');
	}
	else {
	    $req->print('<tr>');
        }

	for (my($col) = 0; $col < $max_col; $col++ ) {

	    my($cell_renderer) = $fields->{col_renderers}->[$col];
	    if (! $cell_renderer) {
		# lookup default - can be overridden by base class
		$cell_renderer = $self->get_default_renderer(
			$model->get_column_descriptor($col));
		$fields->{col_renderers}->[$col] = $cell_renderer;
	    }
	    $cell_renderer->render($model->get_value_at($row, $col), $req);
	}
	$req->print('</tr>');
    }
}

=for html <a name="render_heading"></a>

=head2 render_heading(ListModel model, Request req)

Draws the table heading. If the ListModel column supports sorting by
implementing L<Bivio::Biz::ListModel/"get_sort_key"> then the heading
is rendered as an HTML link for sorting the data.

=cut

sub render_heading {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print('<tr bgcolor="#E0E0FF">');
    for (my($i) = 0; $i < $model->get_column_count(); $i++ ) {

	$req->print('<th align=left>');
	$req->print('<font face="arial,helvetica,sans-serif"><small>');
	my($dir) = '';

	# no sort key means the column doesn't support sorting
	if ($model->get_sort_key($i)) {

	    my($fp) = $req->get_model_args();
	    my($fp2) = Bivio::Biz::FindParams->new();

	    # show a sorting indicator in the heading
	    if ($fp->get('sort') and $fp->get('sort') =~ /(.)$i/) {
		if ($1 eq 'a') {
		    $fp2->put('sort', 'd'.$i);
		    $dir = ' &lt;';
		}
		elsif ($1 eq 'd') {
		    $fp2->put('sort', 'a'.$i);
		    $dir = ' &gt;';
		}
	    }
	    else {
		$fp2->put('sort', 'a'.$i);
	    }
	    $req->print('<a href="/'.$req->get_target_name().'/'
		    .$req->get_controller_name().'/'
		    .$self->get_name().'/?'.$fp2->to_string().'">');
	}

	$req->print($model->get_column_heading($i));

	$req->print('</a>') if ($model->get_sort_key($i));
	$req->print($dir) if ($dir);
	$req->print('</small></font>');

	$req->print('</th>');
    }

    $req->print('</tr>');
}

=for html <a name="set_column_renderer"></a>

=head2 set_column_renderer(int column, ListCellRenderer rdr)

Sets the renderer to use for the column with the specified index.

=cut

sub set_column_renderer {
    my($self, $column, $renderer) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{col_renderers}->[$column] = $renderer;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
