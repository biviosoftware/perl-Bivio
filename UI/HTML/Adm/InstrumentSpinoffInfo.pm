# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Adm::InstrumentSpinoffInfo;
use strict;
$Bivio::UI::HTML::Adm::InstrumentSpinoffInfo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Adm::InstrumentSpinoffInfo::VERSION;

=head1 NAME

Bivio::UI::HTML::Adm::InstrumentSpinoffInfo - create global spinoff info

=head1 SYNOPSIS

    use Bivio::UI::HTML::Adm::InstrumentSpinoffInfo;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Adm::InstrumentSpinoffInfo::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Adm::InstrumentSpinoffInfo> create global spinoff info

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Returns the form content.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('ADM_SPINOFF_CREATE');
    return $self->form('InstrumentSpinoffInfoForm', [
	['InstrumentSpinoff.spinoff_date'],
	['source_ticker_symbol'],
	['new_ticker_symbol'],
	['InstrumentSpinoff.remaining_basis', undef, undef, '96.07'],
	['InstrumentSpinoff.new_shares_ratio'],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
