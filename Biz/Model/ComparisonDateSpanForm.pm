# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ComparisonDateSpanForm;
use strict;
$Bivio::Biz::Model::ComparisonDateSpanForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ComparisonDateSpanForm - realm, instrument comparison

=head1 SYNOPSIS

    use Bivio::Biz::Model::ComparisonDateSpanForm;
    Bivio::Biz::Model::ComparisonDateSpanForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::DateSpanForm>

=cut

use Bivio::Biz::Model::DateSpanForm;
@Bivio::Biz::Model::ComparisonDateSpanForm::ISA = ('Bivio::Biz::Model::DateSpanForm');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ComparisonDateSpanForm> realm, instrument comparison

=cut

#=IMPORTS
use Bivio::Biz::Model::MGFSInstrument;
use Bivio::SQL::Connection;
use Bivio::TypeError;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::UserPreference;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Defaults to the currently selected realm instrument.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    # load the dates
    $self->SUPER::execute_empty;

    # get comparison ticker from user preferences, default to CSCO?

    my($symbol) = $req->get_user_pref(
	    Bivio::Type::UserPreference::COMPARISON_TICKER())
	    || 'CSCO';
    $properties->{'MGFSInstrument.symbol'} = $symbol;
    Bivio::Biz::Model::MGFSInstrument->new($req)->load(symbol => $symbol);

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($proto) = @_;
    my($res) = $proto->SUPER::internal_initialize;
    push(@{$res->{visible}}, 'MGFSInstrument.symbol');
    return $res;
}

=for html <a name="validate"></a>

=head2 validate()

Loads the selected RealmInstrument.

=cut

sub validate {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->SUPER::validate;

    return if $self->in_error;

    my($symbol) = uc($self->get('MGFSInstrument.symbol'));
    if (defined($symbol)) {
	my($instrument) = Bivio::Biz::Model::MGFSInstrument->new($req);
	if ($instrument->unsafe_load(symbol => $symbol)) {

	    _validate_quotes($self, $instrument);

	    $req->set_user_pref(
		    Bivio::Type::UserPreference::COMPARISON_TICKER()
		    => $symbol);
	}
	else {
	    $self->internal_put_error('MGFSInstrument.symbol',
		    Bivio::TypeError::TICKER_NOT_FOUND());
	}
    }
    return;
}

#=PRIVATE METHODS

# _validate_quotes(Bivio::Biz::Model::MGFSInstrument instrument)
#
# Ensures that quotes are available for the specified instrument from
# the start date. Adds an error to the form if not.
#
sub _validate_quotes {
    my($self, $instrument) = @_;
    my($start_date) = $self->get('start_date');

    # get the min and max quote dates, compare with start_date and end_date
    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'MIN(mgfs_daily_quote_t.date_time)');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT $date_param
            FROM mgfs_daily_quote_t
            WHERE mg_id=?",
	    [$instrument->get('mg_id')]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($start) = $row->[0];
	next unless Bivio::Type::Date->compare($start, $start_date) > 0;

	$self->internal_put_error('MGFSInstrument.symbol',
		Bivio::TypeError::QUOTES_NOT_AVAILABLE_AT_START());
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
