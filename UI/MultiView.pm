# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MultiView;
use strict;
use Bivio::UI::View;
$Bivio::UI::MultiView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::MultiView - A view which contains other views.

=head1 SYNOPSIS

    use Bivio::UI::MultiView;
    Bivio::UI::MultiView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

@Bivio::UI::MultiView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::MultiView> is an abstract html rendering view which
houses many other views. Only one view may be active at any time. Allows
drawing a menu bar which shows all the available views.

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, array views) : Bivio::UI::MultiView

Creates a new MultiView with the specified name and sub views.

=head2 static new(string name, array views, Menu menu) : Bivio::UI::MultiView

Creates a MultiView with the specified name, sub views, and menu.

=cut

sub new {
    my($proto, $name, $views, $menu) = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);
    $self->{$_PACKAGE} = {
	views => $views,
	menu => $menu,
	active_view => undef
    };
    my($view);
    foreach $view (@$views) {
	$view->set_parent($self);
    }

    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_active_view"></a>

=head2 get_active_view() : View

Returns the active view.

=cut

sub get_active_view {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{active_view};
}

=for html <a name="get_menu"></a>

=head2 get_menu() : Menu

Returns the menu of sub views. If no menu exists, then undef is returned.

=cut

sub get_menu {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{menu};
}

=for html <a name="get_views"></a>

=head2 get_views() : array

Returns an array of sub views.

=cut

sub get_views {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    #copies into a new array
    my(@result) = @{$fields->{views}};
    return \@result;
}

=for html <a name="set_active_view"></a>

=head2 set_active_view(View v) : MultiView

Sets the specified child view as active. Returns the root of the view
tree.

=cut

sub set_active_view {
    my($self, $view) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{active_view} = $view;
    return $self->activate();
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut


=head1 old methods

sub get_title {
    my($self, $target) = @_;
    my($fields) = $self->{$_PACKAGE};
    return &_get_view($self, $fields->{active_view})->get_title($target);
}

sub get_active_view {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return &_get_view($self, $fields->{active_view});
}

sub render_menu {
    my($self, $top, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # don't show menu if bottom and only one item
    if (!$top && scalar(@{$fields->{views}}) <= 2) {
        return;
    }

    $req->print('<table border=0 cellpadding=2 cellspacing=0>
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
        $req->print($menu."\n");
        $req->print('</tr><tr>
');
        $req->print($pad."\n");
    }
    else {
        $req->print($pad."\n");
        $req->print('</tr><tr>
');
        $req->print($menu."\n");
    }

    $req->print('</tr></table>
');
}

sub set_path {
    my($self, $path, $index) = @_;
    my($fields) = $self->{$_PACKAGE};

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
    if ($subview->isa($_PACKAGE)) {
        $subview->set_path($path, ++$index);
    }
}


=cut


1;
