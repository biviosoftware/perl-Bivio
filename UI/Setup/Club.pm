# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Club;
use strict;
$Bivio::UI::Setup::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Setup::Club - club creation view

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Club::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Club> is a club creation view.

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
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns an instance of the Club model.

=cut

sub get_default_model {
    return Bivio::Biz::Club->new();
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Creates a form for editing the specified Club model.

=cut

sub render {
    my($self, $club, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($reply) = $req->get_reply();

    $reply->print('<table border=0><tr><td>');
    $reply->print('<table border=0 cellpadding=0 cellspacing=0>');

    $reply->print('Now enter a short name for the club identifier, and a '
	    .'descriptive name for the full name.<p>');

    if (! $club->get_status()->is_ok() ) {
	$reply->print('<font color="#FF0000">');
	my($errors) = $club->get_status()->get_errors();
	foreach (@$errors) {
	    $reply->print($_->get_message().'<br>');
	}
	$reply->print('</font>');
    }

    $reply->print('<form action='.$req->make_path().' method="post">');

    $reply->print('<input type="hidden" name="ma" value=add>');
    $reply->print('<input type="hidden" name="admin" value='
	    .$req->get_arg('admin').' >');
    $reply->print('<tr><td rowspan=100 width=15></td></tr>');

    Bivio::UI::HTML::FieldUtil->entry_field($club, 'name', $req, 1);
    Bivio::UI::HTML::FieldUtil->entry_field($club, 'full_name', $req, 1);

    # could add club preferences here...

    $reply->print('<tr><td>&nbsp;</td></tr>');
    $reply->print('<tr><td>'
	    .'<input type="submit" value="Next">'
	    .'</td></tr>');

    $reply->print('</table></form>');
    $reply->print('</td></tr></table>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
