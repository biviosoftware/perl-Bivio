# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::F1065Parameters;
use strict;
$Bivio::UI::HTML::Club::F1065Parameters::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::F1065Parameters - IRS 1065 parameters

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::F1065Parameters;
    Bivio::UI::HTML::Club::F1065Parameters->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::F1065Parameters::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::F1065Parameters> IRS 1065 parameters

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
    my($self) = @_;
    return $self->form('F1065ParametersForm', [
	    ['TaxId.tax_id', undef, <<'EOF', '12-3456789'],
Partnership's identifying number
EOF
	    ['Club.start_date', undef, <<'EOF', undef, {allow_undef => 1}],
The date the club began as a partnership
EOF
	    ['Address.street1', undef, <<'EOF', undef,
Partnership's address and ZIP code
EOF
		    {label_in_text => 'Address'}],
	    ['Address.street2'],
	    ['Address.city'],
	    ['Address.state', undef, undef, 'NY, CA, CO', {size => 2}],
	    ['Address.zip', undef, undef, '12345, 12345-6789'],
	    ['Tax1065.irs_center', 'IRS Center', <<'EOF'],
Select the state where the partnership files its return
EOF
	    ['Tax1065.partnership_type', 'Partnership Type',
		    <<'EOF',
Schedule B 1. Most investment clubs are formed as general partnerships. Members in a general partnership do not have liability protection.
EOF
		    undef, {show_unknown => 0}],
	    ['Tax1065.partner_is_partnership', 'Member is Partnership',
		    <<'EOF'],
Schedule B 2.
EOF
	    ['Tax1065.partnership_is_partner', 'Club is Partner',
		   <<'EOF'],
Schedule B 3.
EOF
	    ['Tax1065.consolidated_audit', 'Consolidated Audit', <<'EOF'],
Schedule B 4. We recommend that you choose Consolidated Audit, so that the tax treatment of partnership items is determined at the partnership level, rather than in a separate proceeding.
EOF
    ],
    {
	header => $_PACKAGE->join(<<'EOF')
IRS 1065 tax fields. The default values should be suitable for most clubs.
EOF
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
