# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::DeleteMember;
use strict;
$Bivio::UI::HTML::Club::DeleteMember::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::DeleteMember - delete a member

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::DeleteMember;
    Bivio::UI::HTML::Club::DeleteMember->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::DeleteMember::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::DeleteMember> delete a member

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

    return $self->form('DeleteMemberForm', [], {
	header => $self->join(
	    'Would you like to remove the following Member from your club?',
	    $self->indent($self->string(['member_info'])),
	    '<p>',
	    $self->string(['error_message'], 'error'),
	),
    });
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sets dynamic page data on the request. In this case, it is the 'email'
value.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);

    $req->put(member_info => $list->format_identifying_info);

    # need to display errors manually, there are no fields on the form
    my($form) = $req->get('Bivio::Biz::Model::DeleteMemberForm');
    $req->put(error_message =>
	    $form->in_error && exists($form->get_errors->{error})
	    ? $form->get_errors->{error}->get_long_desc
	    : '');

    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
