# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSpinoffInfoForm;
use strict;
$Bivio::Biz::Model::InstrumentSpinoffInfoForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentSpinoffInfoForm::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentSpinoffInfoForm - create global spinoff info

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSpinoffInfoForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentSpinoffInfoForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSpinoffInfoForm> create global spinoff info

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;
use Bivio::Biz::Model::InstrumentSpinoff;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Creates a new InstrumentSpinoff model.

=cut

sub execute_ok {
    my($self) = @_;
    my($source) = _get_instrument_id($self, 'source_ticker_symbol');
    my($new) = _get_instrument_id($self, 'new_ticker_symbol');
    return if $self->in_error;

    Bivio::Biz::Model::InstrumentSpinoff->new($self->get_request)->create({
	%{$self->get_model_properties('InstrumentSpinoff')},
	source_instrument_id => $source,
	new_instrument_id => $new,
    });
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [qw(
	    InstrumentSpinoff.spinoff_date
            InstrumentSpinoff.remaining_basis
            InstrumentSpinoff.new_shares_ratio
            ),
	    {
		name => 'source_ticker_symbol',
		type => 'Name',
    		constraint => 'NOT_NULL',
	    },
	    {
		name => 'new_ticker_symbol',
		type => 'Name',
    		constraint => 'NOT_NULL',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

# _get_instrument_id(string ticker_field) : string
#
# Returns the instrument of the specified ticker. Puts an error
# on the form if not found.
#
sub _get_instrument_id {
    my($self, $ticker_field) = @_;
    my($inst) = Bivio::Biz::Model::Instrument->new($self->get_request);
    if ($inst->unsafe_load(ticker_symbol => uc($self->get($ticker_field)))) {
	return $inst->get('instrument_id');
    }
    $self->internal_put_error($ticker_field, Bivio::TypeError::NOT_FOUND());
    return undef;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
