# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Adm::InstrumentSpinoffList;
use strict;
$Bivio::UI::HTML::Adm::InstrumentSpinoffList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Adm::InstrumentSpinoffList::VERSION;

=head1 NAME

Bivio::UI::HTML::Adm::InstrumentSpinoffList - lists global spin-offs

=head1 SYNOPSIS

    use Bivio::UI::HTML::Adm::InstrumentSpinoffList;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Adm::InstrumentSpinoffList::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Adm::InstrumentSpinoffList> lists global spin-offs

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Returns the page content.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('ADM_SPINOFFS');
    $self->put(page_action_bar => []);

    return $self->join(
	    '<p>&nbsp;',
	    $self->link('ADM_SPINOFF_CREATE'),
	    '<p>&nbsp;',
	    $self->table('AdmInstrumentSpinoffList', [
		'InstrumentSpinoff.spinoff_date',
		'source_name',
		'new_name',
		['InstrumentSpinoff.remaining_basis', {decimals => 6}],
		['InstrumentSpinoff.new_shares_ratio', {decimals => 6}],
		$self->list_actions([['delete', 'ADM_SPINOFF_DELETE']]),
	    ]),
	   );
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request)

Draws the page contents.

=cut

sub execute {
    my($self, $req) = @_;
    $req->put(
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    page_type => Bivio::UI::PageType::LIST(),
	   );
    return $self->SUPER::execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
