# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MembersMerge;
use strict;
$Bivio::UI::HTML::Club::MembersMerge::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::MembersMerge::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::MembersMerge - Merge a shadow user and club member

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MembersMerge;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::MembersMerge::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MembersMerge> allows a member with no accounting to be
merged with a shadow user.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget 

Returns the page content

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_ADMIN_MEMBERS_MERGE');
    return $self->form('MembersMergeForm', [
	['RealmUser.user_id', undef, undef, undef,
		{
		    choices => ['Bivio::Biz::Model::MemberList'],
		    list_display_field => 'last_first_middle',
		    list_id_field => 'RealmUser.user_id',
		}
	],
    ],
    {
        header => $self->join(
		'Merge member:',
		$self->indent($self->string(['member_info'])),
		'with'),
    });
}

=for html <a name="execute"></a>

=head2 execute()

Sets dynamic page data on the request. In this case, it is the member info.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);

#    $req->put(target_user_id => $list->get('RealmUser.user_id'));
    $req->put(member_info => $list->format_identifying_info);

    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
