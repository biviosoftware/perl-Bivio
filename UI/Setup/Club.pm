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
use Bivio::Agent::TaskId;
use Bivio::Biz::PropertyModel::Club;
use Bivio::UI::HTML::FieldUtil;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::AgentRequest req)

=cut

sub execute {
    my($self, $req) = @_;
#TODO: Need to allow for no model in rendering code
    $self->activate->render(
	    Bivio::Biz::PropertyModel::Club->new($req), $req);
    return;
}

=for html <a name="render"></a>

=head2 render(undef, Request req)

Creates a form for editing the specified Club model.

=cut

sub render {
    my($self, $club, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0><tr><td>');
    $reply->print('<table border=0 cellpadding=0 cellspacing=0>');

    $reply->print('Now enter a short name for the club identifier, and a '
	    .'descriptive name for the full name.<p>');

    $reply->print('<form action='
	    .$req->format_uri(Bivio::Agent::TaskId::SETUP_CLUB_CREATE)
	    .' method="post">');

#TODO: Need to get club_create from somewhere
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
