# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::IIF;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::Type::Date;
use Bivio::Type::Amount;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_D) = 'Bivio::Type::Date';
my($_DT) = 'Bivio::Type::DateTime';
my($_EOL) = "\r\n";
my($_M) = 'Bivio::Type::Amount';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my($proto, $def) = @_;
    my($self) = shift->SUPER::new;
    $self->[$_IDI] = {
        def => $def,
        rows => [],
    };
    return $self;
}

sub add_record {
    my($self, $type, $record) = @_;
    # destroys record contents
    my($fields) = $self->[$_IDI];
    my($def) = grep($_->[0] eq $type, @{$fields->{def}});
    Bivio::Die->die('invalid type: ', $type)
        unless $def;
    $record->{$type} = $type;

    push(@{$fields->{rows}}, [
        map(exists($record->{$_})
            ? _parse($self, $_, delete($record->{$_}))
            : '',
            @$def),
    ]);
    Bivio::Die->die('left-over fields: ', $record)
        if %$record;
    return;
}

sub to_string {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($str) = @{$fields->{rows}}
        ? _out($self, $fields->{def}, '!') . _out($self, $fields->{rows}, '')
        : '';
    return \$str;
}

sub _out {
    my($self, $rows, $prefix) = @_;
    return join($_EOL, map($prefix. join("\t", @$_), @$rows)) . $_EOL;
}

sub _parse {
    my($self, $type, $value) = @_;
    return '' unless defined($value);
    Bivio::Die->die('value contains a invalid character: ', $value)
        if $value =~ /\t|\r|\n/;

    # not YEARTODATE
    if ($type =~ /^(DATE|SERVICEDATE|DUEDATE|SHIPDATE)$/) {
        return $_D->to_string($value)
            if $_DT->is_date($value);
        return sprintf('%02d/%02d/%04d',
            ($_DT->local_to_parts($value))[4, 3, 5]);
    }
    elsif ($type =~ /^(AMOUNT|QNTY|PRICE)$/) {
        return $_M->to_literal($_M->from_literal_or_die($value)),
    }
    $value =~ s/"//g;
    return $value;
}

1;
