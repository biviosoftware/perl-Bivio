# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MemberTakeOffline;
use strict;
$Bivio::UI::HTML::Club::MemberTakeOffline::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::MemberTakeOffline::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::MemberTakeOffline - takes a club member offline

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MemberTakeOffline;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::MemberTakeOffline::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MemberTakeOffline>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Returns the page contents.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_MEMBER_TAKE_OFFLINE');
    return $self->director([sub {
				my($req) = shift;
				$req->get('auth_user_id')
					eq $req->get('selected_user') ? 1 : 0;
				}], {
		0 => _page_member($self),
		1 => _page_self($self),
				}
	   );
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets dynamic page data on the request.  In this case it is the selected user
info.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);
    $req->put(selected_user => $list->get('RealmUser.user_id'));

    $req->put(member_info => $list->format_identifying_info);

    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

# _page_member(self) : Bivio::UI::HTML::Widget::Form
#
# Displays member info and are you sure comment for taking member offline
#
sub _page_member {
    my($self) = @_;
    return $self->form('MemberOfflineForm', [],
	    {
		header => $self->join(
			'Would you like to take the following Member offline?',
			$self->indent($self->string(['member_info'])),
			'<p>',
			'If you wish to bring them online again, select '
			.'bring online in the member roster.'
		       ),
	    }
	   );
}

# _page_self(self) : Bivio::UI::HTML::Widget::Form
#
# Displays are you sure for taking self offline
#
sub _page_self {
    my($self) = @_;
    return $self->form('MemberOfflineForm', [],
	    {
		header => $self->join(
			'Are you sure you want to take yourself offline?',
			'<p>',
			'You will remain a bivio member but will not be able'
			.' to access this club.  If you wish to regain access,'
			.' contact a club administrator to have them send you'
			.' a new invitation.',
		       ),
	    }
	   );
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
