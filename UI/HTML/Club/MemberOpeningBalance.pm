# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MemberOpeningBalance;
use strict;
$Bivio::UI::HTML::Club::MemberOpeningBalance::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MemberOpeningBalance - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MemberOpeningBalance;
    Bivio::UI::HTML::Club::MemberOpeningBalance->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::MemberOpeningBalance::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MemberOpeningBalance>

=cut

#=IMPORTS
use Bivio::UI::HTML::DescriptivePageForm;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content()

Returns the form.

=cut

sub create_content {
    my($form) = Bivio::UI::HTML::DescriptivePageForm->new({
	form_class => 'Bivio::Biz::Model::MemberOpeningBalanceForm',
	header => $_PACKAGE->join(<<'EOF')
Use this form to record a member's investment in the club at the time the
accounting is transferred to bivio.
EOF
    });
    $form->put(value => $form->create_fields([
	['RealmTransaction.date_time', 'Date', <<'EOF'],
The accounting switch-over date.
EOF
	['paid', 'Total Paid', <<'EOF'],
The total cash contributions for the member to date.
EOF
	['earnings', 'Earnings Distributed', <<'EOF'],
The taxable earnings distributed to the member to date. This value plus "total paid" determines the member's tax basis.
EOF
	['MemberEntry.units', 'Units', <<'EOF'],
The number of valuation units purchased by the member to date.
EOF
    ]));
    return $form;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
