# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::AccountOpeningBalance;
use strict;
$Bivio::UI::HTML::Club::AccountOpeningBalance::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::AccountOpeningBalance - opening account balance ui

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::AccountOpeningBalance;
    Bivio::UI::HTML::Club::AccountOpeningBalance->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::AccountOpeningBalance::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::AccountOpeningBalance> opening account balance ui

=cut

#=IMPORTS

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
	form_class => 'Bivio::Biz::Model::AccountOpeningBalanceForm',
	header => $_PACKAGE->join(<<'EOF')
Use this form to record the initial account balances prior to using bivio
club accounting.
EOF
    });
    $form->put(value => $form->create_fields([
	['RealmTransaction.date_time', 'Date', <<'EOF'],
The accounting switch-over date.
EOF
	['bank', 'Bank Balance', <<'EOF'],
The opening balance of the club's bank account.
EOF
	['broker', 'Broker Balance', <<'EOF'],
The opening balance of the club's broker account.
EOF
	['petty_cash', 'Petty Cash Balance', <<'EOF'],
The opening balance of the club's non-deductible account.
EOF
	['suspense', 'Suspense Balance', <<'EOF'],
The opening balance of the club's suspense account.
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
