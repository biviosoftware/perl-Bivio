# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentMergerSpinoff;
use strict;
$Bivio::Biz::Model::InstrumentMergerSpinoff::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentMergerSpinoff::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentMergerSpinoff - merger/spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentMergerSpinoff;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::InstrumentMergerSpinoff::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentMergerSpinoff> merger/spin-off info

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::SQL::Connection;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::InstrumentAction;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'instrument_merger_spinoff_t',
	columns => {
	    action_date => ['Date', 'PRIMARY_KEY'],
	    action => ['InstrumentAction', 'PRIMARY_KEY'],
	    source_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    new_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    remaining_basis => ['Amount', 'NOT_NULL'],
	    new_shares_ratio => ['Amount', 'NOT_NULL'],
        },
	other => [
	    [qw(source_instrument_id Instrument_1.instrument_id)],
	    [qw(new_instrument_id Instrument_2.instrument_id)],
	],
    };
}

=for html <a name="unsafe_load_recent"></a>

=head2 unsafe_load_recent(Bivio::Type::InstrumentAction action, string new_ticker, string date) : boolean

Attempts to load the specified action for the instrument within one week
of the specified date.

=cut

sub unsafe_load_recent {
    my($self, $action, $new_ticker, $date) = @_;

    _trace('looking for ', $new_ticker, ' ',
	    Bivio::Type::Date->to_literal($date), ' ', $action) if $_TRACE;

    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'instrument_merger_spinoff_t.action_date');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT $date_param,
                instrument_merger_spinoff_t.source_instrument_id,
                instrument_merger_spinoff_t.new_instrument_id
            FROM instrument_merger_spinoff_t, instrument_t
            WHERE instrument_merger_spinoff_t.new_instrument_id
                =instrument_t.instrument_id
            AND instrument_t.ticker_symbol=?
            AND instrument_merger_spinoff_t.action=?
            AND instrument_merger_spinoff_t.action_date BETWEEN
                $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE",
	    [uc($new_ticker), $action->as_int,
		Bivio::Type::Date->add_days($date, -7), $date]);

    my($found_it) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	my($action_date, $source, $target) = @$row;
	$self->load({
	    action_date => $action_date,
	    action => $action,
	    source_instrument_id => $source,
	    new_instrument_id => $target,
	});

	Bivio::Die->die("> 1 merger/spinoff found ", $self) if $found_it;
	$found_it = 1;
    }
    return $found_it;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
