# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::User::EditUserName;
use strict;
$Bivio::UI::HTML::User::EditUserName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::User::EditUserName - allows the user to update name

=head1 SYNOPSIS

    use Bivio::UI::HTML::User::EditUserName;
    Bivio::UI::HTML::User::EditUserName->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::User::EditUserName::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::User::EditUserName> allows user to update name.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=head2 create_content() : Bivio::UI::HTML::Widget

Create values

=cut

sub create_content {
    my($self) = @_;
    $self->put_edit_heading('USER_NAME', 'USER_DISPLAY_NAME');
    return $self->form('UserNameForm', [
	$self->get_name_field,
	$self->get_full_name_fields,
    ]);
}

=for html <a name="get_full_name_fields"></a>

=head2 get_full_name_fields() : array

Returns full name fields

=cut

sub get_full_name_fields {
    return (
	['User.first_name', undef, <<'EOF', undef,
Your first and last names will be combined into a name used to
label club reports and messages.  Your middle name will be used
for, e.g. tax forms.  You may leave any or all of the following
fields blank.  If all fields are blank, your name will be
the same as your User ID.
EOF
	    {label_in_text => 'USER_DISPLAY_NAME'}],
	['User.middle_name'],
	['User.last_name'],
    );
;
}

=for html <a name="get_name_field"></a>

=head2 get_name_field() : array_ref

Returns input suitable for C<DescriptiveFormField>.

=cut

sub get_name_field {
    return ['RealmOwner.name', 'USER_NAME', <<'EOF', 'betsy_ross, johnq'];
Your User ID must be at least three characters long and begin with a letter,
and can contain letters, numbers and/or underscores, but no spaces.
EOF
}
#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
