# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Club;
use strict;
$Bivio::UI::Setup::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::Setup::Club - club creation view

=head1 SYNOPSIS

    use Bivio::UI::Setup::Club;
    Bivio::UI::Setup::Club->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Club::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Club>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Club;
use Bivio::IO::Trace;
use Bivio::UI::HTML::FieldUtil;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Setup::Club

Creates a club creation view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::View::new($proto, 'info');
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns an instance of the User model.

=cut

sub get_default_model {
    return Bivio::Biz::Club->new();
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Creates a form for editing the specified model.

=cut

sub render {
    my($self, $club, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print('<table border=0><tr><td>');
    $req->print('<table border=0 cellpadding=0 cellspacing=0>');

    if (! $club->get_status()->is_OK() ) {
	$req->print('<font color="#FF0000">');
	my($errors) = $club->get_status()->get_errors();
	foreach (@$errors) {
	    $req->print($_->get_message().'<br>');
	}
	$req->print('</font>');
    }

    $req->print('<form action='.'/'.$req->get_target_name().'/'
	    .$req->get_controller_name().'/'.$self->get_name().'>');

    $req->print('<input type="hidden" name="ma" value=add>');
    $req->print('<input type="hidden" name="admin" value='
	    .$req->get_arg('admin').' >');
    $req->print('<tr><td rowspan=100 width=15></td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($club, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($club, 'full_name', $req, 1);

    $req->print('<tr><td>&nbsp;</td></tr>');
    $req->print('<tr><td>'
	    .'<input type="submit" value="Next">'
	    .'</td></tr>');

    $req->print('</table></form>');
    $req->print('</td></tr></table>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
