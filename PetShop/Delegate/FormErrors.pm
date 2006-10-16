# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Delegate::FormErrors;
use strict;
$Bivio::PetShop::Delegate::FormErrors::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::FormErrors::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::FormErrors - pet shop form error formats

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::FormErrors;

=cut

use Bivio::Delegate::SimpleFormErrors;
@Bivio::PetShop::Delegate::FormErrors::ISA = ('Bivio::Delegate::SimpleFormErrors');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::FormErrors>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : string_ref

Returns the form error definitions.

=cut

sub get_delegate_info {
    my($proto) = @_;
    my($info) = <<'EOF'.${$proto->SUPER::get_delegate_info};
UserLoginForm
RealmOwner.password
PASSWORD_MISMATCH
The password you entered does not match the value stored
in our database.
Please remember that passwords are case-sensitive, i.e.
"HELLO" is not the same as "hello".
%%
EOF
    return \$info;
};

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
