# Copyright (c) 2001 bivio Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Tax::Subscription;
use strict;
$Bivio::UI::HTML::Tax::Subscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Tax::Subscription::VERSION;

=head1 NAME

Bivio::UI::HTML::Tax::Subscription - shows subscriptions including tax-only

=head1 RELEASE SCOPE

Societas

=head1 SYNOPSIS

    use Bivio::UI::HTML::Tax::Subscription;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Tax::Subscription::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Tax::Subscription>

=cut

#=IMPORTS
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::Widget::Director

Returns widget which renders this page.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_ACCOUNTING_TAXES_SUBSCRIPTION');
    return $_VS->vs_template_as_string(<<'EOF', 'page_text');
<p>
You are currently registered for a
vs_link('trial subscription', 'CLUB_ADMIN_EC_SUBSCRIPTION_INFO').
<p>
To gain complete access, please subscribe to one of our
vs_link('economically priced services', 'SERVICES').
<p>
Special Offer: vs_link_static_site('Subscribe for tax season only.', 'hm/tax-season.html')
EOF
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
