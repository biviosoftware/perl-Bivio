# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSDailyQuote;
use strict;
$Bivio::Biz::Model::MGFSDailyQuote::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSDailyQuote - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSDailyQuote;
    Bivio::Biz::Model::MGFSDailyQuote->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSDailyQuote::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSDailyQuote>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::Date;
use Bivio::Data::MGFS::Id;
use Bivio::Type::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATES) = 'a8' x 265;
my($_AMOUNTS) = 'a6' x 265;



=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::MGFSDailyQuote

Creates a new MGFS Daily Quote model.

=cut

sub new {
    my($self) = &Bivio::Biz::Model::MGFSBase::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, hash_ref values, boolean update)

Overrides MGFSBase.from_mgfs to deal with the one-to-many format for
MGFS quotes.

=cut

sub from_mgfs {
    my($self, $record, $values, $update) = @_;
    my($fields) = $self->{$_PACKAGE};

    # date records store the array in a local var
    my($record_id) = substr($record, 4, 8);
    if ($record_id =~/^DATE/) {
	my(@dates) = unpack($_DATES, substr($record, 48, 2120));
	foreach my $date (@dates) {
	    if ($date =~ /^00000000$/) {
		$date = undef;
	    }
	    else {
		$date = Bivio::Data::MGFS::Date->from_mgfs($date);
	    }
	}
	$fields->{dates} = \@dates;
    }
    # quote records iterate all the dates and create models
    else {
	$fields->{mg_id} = Bivio::Data::MGFS::Id->from_mgfs($record_id);
	my($format_switch) = substr($record, 106, 1);
	my(@highs) = unpack($_AMOUNTS, substr($record, 107, 1590));
	my(@lows) = unpack($_AMOUNTS, substr($record, 1697, 1590));
	my(@closes) = unpack($_AMOUNTS, substr($record, 3287, 1590));
	# add decimal point, except for format 'x'
	if ($format_switch ne 'x') {
	    _add_decimal(\@highs);
	    _add_decimal(\@lows);
	    _add_decimal(\@closes);
	}
	my(@volumes) = unpack($_AMOUNTS, substr($record, 4877, 1590));
	# volume in hundreds
	foreach my $volume (@volumes) {
	    $volume .= '00';
	}
	my($dates) = $fields->{dates};
	my($id) = $fields->{mg_id};

	my($values) = {mg_id => $id};
	for (my($i) = 0; $i <= 265; $i++) {
	    last unless defined($dates->[$i]);
	    $values->{dttm} = $dates->[$i];
	    $values->{high} = $highs[$i];
	    $values->{low} = $lows[$i];
	    $values->{close} = $closes[$i];
	    $values->{volume} = $volumes[$i];

	    my($die) = $self->try_to_update_or_create($values, $update);
	    if ($die) {
		$self->write_reject_record($die, $record);
		last;
	    }
	}
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_daily_quote_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
            dttm => ['Bivio::Type::Date',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    high => ['Bivio::Data::MGFS::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            low => ['Bivio::Data::MGFS::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            close => ['Bivio::Data::MGFS::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            volume => ['Bivio::Data::MGFS::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

#=PRIVATE METHODS

# _add_decimal(array_ref values)
#
# Iterates each value and inserts a '.' before the second-to-last digit.
#
sub _add_decimal {
    my($values) = @_;
    foreach my $value (@$values) {
	$value =~ s/^(.*)(..)$/$1\.$2/;
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
