# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Label;
use strict;
$Bivio::UI::Label::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Label - a mapping of IDs to labels

=head1 SYNOPSIS

    use Bivio::UI::Label;
    Bivio::UI::Label->get_simple($value);

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Label::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Label> a list of labels to be used in the text.
The label is looked up with I<from_any> and I<get_short_desc>
is used as the name.

=cut

#=IMPORTS

#=VARIABLES
_compile(
#TODO: Should these be dynamically looked up?
    # Common labels
    PHONE => ['Phone', undef, 'Phone.phone'],
    TAX_ID => ['Tax ID', undef, 'TaxId.tax_id'],
    EMAIL => ['Email', undef, 'Email.email'],
    PASSWORD => ['Password'],
    OLD_PASSWORD => ['Old Password'],
    NEW_PASSWORD => ['New Password'],
    CONFIRM_NEW_PASSWORD => ['Confirm New'],

    # Address labels
    ADDRESS => ['Address'],
    STREET1 => ['Street1', undef, 'Address.street1'],
    STREET2 => ['Street2', undef, 'Address.street2'],
    CITY => ['City', undef, 'Address.city'],
    STATE => ['State', undef, 'Address.state'],
    ZIP => ['Zip', undef, 'Address.zip'],
    COUNTRY => ['Country', undef, 'Address.country'],

    # Club labels
    CLUB_DISPLAY_NAME => ['Name'],
    CLUB_NAME => ['Club ID'],
    CLUB_USER_TITLE => ['Privileges', undef, 'RealmUser.title'],
    CLUB_USER_CREATION_DATE_TIME => ['Joined', undef,
	'RealmUser.creation_date_time'],

    # User labels
    USER_DISPLAY_NAME => ['Name'],
    USER_NAME => ['User ID'],
    USER_FIRST_NAME => ['First Name', undef, 'User.first_name'],
    USER_MIDDLE_NAME => ['Middle Name', undef, 'User.middle_name'],
    USER_LAST_NAME => ['Last Name', undef, 'User.last_name'],

);

=head1 METHODS

=cut

=for html <a name="get_simple"></a>

=head2 static get_simple(any value) : string

Returns the "simple" name we use for this label.
You can use any part of the label to do the lookup.

=cut

sub get_simple {
    my($proto, $value) = @_;
    return $proto->from_any($value)->get_short_desc;
}

#=PRIVATE METHODS

# _compile(array cfg)
#
# Inserts numeric ID into the list.
#
sub _compile {
    my(@cfg) = @_;
    my($i) = 1;
    my($skip) = 1;
    foreach my $c (@cfg) {
	next if $skip;
	unshift(@$c, $i++);
    }
    continue {
	$skip = !$skip;
    }
    __PACKAGE__->compile(@cfg);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
