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
use Bivio::UI::StringRenderer;

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
	renderer => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="install_renderers"></a>

=head2 install_renderers(ListModel)

Sets up the column renderers based on the ListModel field types.

=cut

sub install_renderers {
    my($self, $model) = @_;
    my($fields) = $self->{$_PACKAGE};

    #NOTE: may want to only do this if the model class has changed
    $fields->{renderer} = [];
    for(my($col) = 0; $col < $model->get_column_count(); $col++ ) {

	$fields->{renderer}->[$col] = $self->lookup_renderer(
		$model->get_column_descriptor($col));
    }
}

=for html <a name="lookup_renderer"></a>

=head2 lookup_renderer(FieldDescriptor type) : Renderer

Returns a field renderer for the specified type.

=cut

sub lookup_renderer {
    my($self, $type) = @_;

    #TODO: move this to another class

    # for now always return a StringRenderer
    return Bivio::UI::StringRenderer->new();
}

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Draws the target, must be a ListModel.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $self->install_renderers($model);

    #$req->log_error("\n\n".Dumper($fields)."\n\n");

    #TODO: hard-coded for now, need to configure it.
    $req->print('<table width="100%" border=0 cellpadding=5 cellspacing=0>');
    $self->render_heading($model, $req);
    $self->render_body($model, $req);
    $req->print('</table>');

=html

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

	    #TODO: need a way to render td per type

	    $req->print('<td align=left><small>');
	    $fields->{renderer}->[$col]->render(
		    $model->get_value_at($row, $col), $req);
	    $req->print('&nbsp;</small></td>');
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

    $req->print('<tr bgcolor="#E0E0FF">');
    for (my($i) = 0; $i < $model->get_column_count(); $i++ ) {
	$req->print('<th align=left><font face="arial,helvetica,sans-serif">
<small>'.$model->get_column_heading($i).'</small></font></th>');
    }

    $req->print('</tr>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
