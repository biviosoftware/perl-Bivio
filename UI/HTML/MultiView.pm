# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::MultiView;
use strict;
use Bivio::UI::View;
$Bivio::UI::HTML::MultiView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::MultiView - A view which contains other views.

=head1 SYNOPSIS

    use Bivio::UI::HTML::MultiView;
    Bivio::UI::HTML::MultiView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

@Bivio::UI::HTML::MultiView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::MultiView> is an abstract html rendering view which
houses many other views. Only one view may be active at any time. Allows
drawing a menu bar which shows all the available views.

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, string default_view) : Bivio::UI::HTML::MultiView

Creates a page with the specified sub views. The parameter 'views' should
be an array of name, view values. Sub views will be renderered
in a menu bar, with one view being active.

=cut

sub new {
    my($proto, $views, $default_view) = @_;
    my($self) = &Bivio::UI::View::new($proto);
    $self->{$PACKAGE} = {
	views => $views,
	default_view => $default_view,
	active_view => undef,
	path => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_active_view"></a>

=head2 get_active_view() : View

Returns the view which is currently active.

=cut

sub get_active_view {
    my($self) = @_;
    my($fields) = $self->{$PACKAGE};
    return &_get_view($self, $fields->{active_view});
}

=for html <a name="get_title"></a>

=head2 get_title(UNIVERSAL target) : string

Returns the title of the active view.

=cut

sub get_title {
    my($self, $target) = @_;
    my($fields) = $self->{$PACKAGE};
    return &_get_view($self, $fields->{active_view})->get_title($target);
}

=for html <a name="render_menu"></a>

=head2 render_menu(boolean top, Request req)

Renders the sub view menu onto the specified request's print stream. If
top is true, then the menu will open downward, otherwise it will open
upward.

=cut

sub render_menu {
    my($self, $top, $req) = @_;
    my($fields) = $self->{$PACKAGE};

    # don't show menu if bottom and only one item
    if (!$top && scalar(@{$fields->{views}}) <= 2) {
	return;
    }

    print('<table border=0 cellpadding=2 cellspacing=0>
<tr>');

    my($pad) = '<td></td>';
    my($menu) = '<td>&nbsp;</td>'."\n";
    my($active) = $fields->{active_view};

    my($name);
    my($views) = $fields->{views};
    my($href) = '/'.join('/', @{$fields->{path}}).'/';

    my($i);
    for ($i = 0; $i < scalar(@$views); $i += 2) {
	my($name) = $views->[$i];

        if ($name eq $active) {
	    $pad .= '<td bgcolor="#E0E0FF"><img src="/i/dot.gif"
height=1 width=1 border=0></td>
';
	    $menu .= '<td bgcolor="#E0E0FF"><strong>
<a href="'.$href.$name.'">'
		    .$name.'</a></strong></td>
';
        }
	else {
	    $pad .= '<td></td>';
	    $menu .= '<td><a href="'.$href.$name.'">'.$name.'</a></td>
';
	}

	$pad .= '<td></td>';
	$menu .= '<td>&nbsp;</td>';
    }

    if ($top) {
	print($menu."\n");
	print('</tr><tr>
');
	print($pad."\n");
    }
    else {
	print($pad."\n");
	print('</tr><tr>
');
	print($menu."\n");
    }

    print('</tr></table>
');
}

=for html <a name="set_path"></a>

=head2 set_path(array path, int index)

Sets the navigation path to a particular view. Path should be an array
of view names. The index indicates this view's position in the path.

=cut

sub set_path {
    my($self, $path, $index) = @_;
    my($fields) = $self->{$PACKAGE};

    #print(STDERR join('/', @$path)."\n");

    if (scalar(@$path) <= $index) {
	push(@$path, $fields->{default_view});
    }
    $fields->{active_view} = $path->[$index];

    my(@local_path);
    for (my($i) = 0; $i < $index; $i++ ){
	push(@local_path, $path->[$i]);
    }
    $fields->{path} = \@local_path;

    my($subview) = $self->get_active_view();
    if ($subview->isa($PACKAGE)) {
	$subview->set_path($path, ++$index);
    }
}

#=PRIVATE METHODS

# _get_view(string name) : View
#
# Returns the named view.
#
sub _get_view {
    my($self, $name) = @_;
    my($views) = $self->{$PACKAGE}->{views};

    my($i);
    for ($i = 0; $i < scalar(@$views); $i += 2) {

	if ($views->[$i] eq $name) {
	    return $views->[$i + 1];
	}
    }
    die("couldn't find view $name");
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
