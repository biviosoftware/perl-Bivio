# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ListView;
use strict;
$Bivio::UI::HTML::ListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::ListView - A view which renders a ListModel.

=head1 SYNOPSIS

    use Bivio::UI::HTML::ListView;
    Bivio::UI::HTML::ListView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::HTML::ListView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::ListView>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

#=IMPORTS
use Data::Dumper;
use Bivio::UI::DateRenderer;
use Bivio::UI::StringRenderer;
use Bivio::UI::HTML::EmailRenderer;
use Bivio::UI::HTML::ListCellRenderer;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UI::HTML::ListView

Creates a ListView.

=cut

sub new {
    my($proto, $name) = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);
    $self->{$_PACKAGE} = {
	col_renderer => [],
	head_renderer => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_renderer"></a>

=head2 get_default_renderer(FieldDescriptor type) : ListCellRenderer

Returns a default renderer for the specified field type.

=cut

sub get_default_renderer {
    my($self, $type) = @_;

    my($inner);
    my($attributes);

    if ($type->get_type() == Bivio::Biz::FieldDescriptor::DATE()) {
	$inner = Bivio::UI::DateRenderer->new();
	$attributes = "nowrap";
    }
    elsif ($type->get_type() == Bivio::Biz::FieldDescriptor::EMAIL_REF()) {
	$inner = Bivio::UI::HTML::EmailRenderer->new();
	$attributes = "nowrap";
    }
    else {
	$inner = Bivio::UI::StringRenderer->new();
    }

    return Bivio::UI::HTML::ListCellRenderer->new($inner);
}

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Draws the target, must be a ListModel.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    #TODO: hard-coded for now, need to configure it.
    $req->print('<table width="100%" border=0 cellpadding=5 cellspacing=0>');
    $self->render_heading($model, $req);
    $self->render_body($model, $req);
    $req->print('</table>');

=for comment

<table width="100%" border=0 cellpadding=5 cellspacing=0>
<tr bgcolor="#E0E0FF">
  <th align=left>
    <font face="arial,helvetica,sans-serif">
    <small>Subject</small></font>
  </th>
  <th width="1%" nowrap align=left>
    <font face="arial,helvetica,sans-serif">
    <small>From</small></font>
  </th>
  <th width="1%" nowrap align=left>
    <font face="arial,helvetica,sans-serif">
    <small>Date</small></font>
  </th>
</tr>
<tr>
  <td align=left>
    <small><a href="/naic/messages/04697">Re: YahooClubs</a></small>
  </td>
  <td nowrap align=left>
    <small><a href="mailto:CbereJacki@aol.com?subject=Re:%20YahooClubs">
    CbereJacki</a></small>
  </td>
  <td nowrap align=right>
    <small>06/29</small>
  </td>
</tr>
<tr bgcolor="#eeeeee">
  <td align=left>
    <small><a href="/naic/messages/04696">
    SSG-Sect. 5 (5 yr. potential</a></small>
  </td>
  <td nowrap align=left>
    <small><a href=
    "mailto:MNatto@aol.com?subject=Re:%20SSG-Sect.%205%20(5%20yr.%20potential">
    MNatto</a></small>
  </td>
  <td nowrap align=right>
    <small>06/29</small>
  </td>
</tr>
</table>

=cut

}

=for html <a name="render_body"></a>

=head2 render_body(ListModel model, Request req)

Draws the table body - all the rows.

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

Draws the table heading.

=cut

sub render_heading {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    #TODO: use $fields->{head_renderer}

    $req->print('<tr bgcolor="#E0E0FF">');
    for (my($i) = 0; $i < $model->get_column_count(); $i++ ) {
	$req->print('<th align=left><font face="arial,helvetica,sans-serif">
<small>'.$model->get_column_heading($i).'</small></font></th>');
    }

    $req->print('</tr>');
}

=for html <a name="set_column_heading_renderer"></a>

=head2 set_column_heading_renderer(int column, Renderer rdr)

Sets the renderer to use for the heading of the specified column index.

=cut

sub set_column_heading_renderer {
    my($self, $column, $renderer) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{head_renderer}->[$column] = $renderer;
}

=for html <a name="set_column_renderer"></a>

=head2 set_column_renderer(int column, ListCellRenderer rdr)

Sets the renderer to use for the column with the specified index.

=cut

sub set_column_renderer {
    my($self, $column, $renderer) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{col_renderer}->[$column] = $renderer;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
