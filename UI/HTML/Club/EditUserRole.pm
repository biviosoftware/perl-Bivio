# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::EditUserRole;
use strict;
$Bivio::UI::HTML::Club::EditUserRole::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::EditUserRole - edits a user's title/role

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::EditUserRole;
    Bivio::UI::HTML::Club::EditUserRole->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::EditUserRole::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::EditUserRole> edits a club user's title/role.

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmUser;
use Bivio::Type::ClubUserTitle;
use Bivio::TypeValue;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Page;
use Bivio::UI::HTML::PageForm;
use Bivio::UI::HTML::Widget::Select;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_fields"></a>

=head2 create_fields() : array_ref

Create Grid I<values> for this form.

=cut

sub create_fields {
    my($self) = @_;
    # Add in UNKNOWN so comes up on blank form and forces use to
    # make a select (not just default).
    return [
	[$self->add_field('title', 'Privileges',
		Bivio::UI::HTML::Widget::Select->new({
		    field => 'title',
		    choices => 'Bivio::Type::ClubUserTitle',
		}))],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets attributes on I<req> and calls
L<Bivio::UI::HTML::Club::Page::execute|Bivio::UI::HTML::Club::Page/"execute">.

=cut

sub execute {
    my($self, $req) = @_;
#TODO: When a form gets an error, there is no routine that is
#      called.  The code in ClubUserForm which loads the
#      list isn't executed (in execute_input).
    # Make sure is loaded
    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $self->die(Bivio::DieCode::NOT_FOUND())
	    unless $list->set_cursor(0);
    $req->put(page_heading => 'Change Privileges for '
	    .$list->get('RealmOwner.display_name'),
	    page_subtopic => 'Change Privileges',
	    page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::ClubUserRoleForm']);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
