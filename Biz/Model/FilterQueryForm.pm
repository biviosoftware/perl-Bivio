# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FilterQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_DATE_OP) = {qw(
    < LTE
    > GTE
    = EQ
)};
my($_DATE_OP_RE) = join('|', sort(keys(%$_DATE_OP)));
my($_T) = b_use('FacadeComponent.Text');

sub clear_on_focus_hint {
    my($self) = @_;
    return $_T->get_value(join('.',
	'clear_on_focus_hint', $self->req('task_id')->get_name));
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    $self->internal_put_field(b_filter => $self->clear_on_focus_hint)
	unless defined($self->unsafe_get('b_filter'));
    return;
}

sub filter_statement {
    my($self, $stmt, $args) = @_;
    return unless defined(my $filter = $self->get_filter_value);
    $stmt->where(map(_filter($_, $stmt, $args), split(' ', $filter)));
    return;
}

sub get_filter_value {
    my($self) = @_;
    return undef
	unless defined(my $f = $self->unsafe_get('b_filter'));
    return $f =~ /\S/ && $f ne $self->clear_on_focus_hint ? $f : undef;
}

sub internal_query_fields {
    return [
	[qw(b_filter Text)],
    ];
}

sub set_filter {
    my($self, $filter) = @_;
    $self->internal_put_field(b_filter => $filter);
    return;
}

sub _filter {
    my($word, $stmt, $args) = @_;
    return _filter_date($stmt, $args->{date_time}, $1, $word)
	if $args->{date_time} && $word =~ s/^($_DATE_OP_RE)//o;
    my($method) = $word =~ s/^-// ? 'NOT_ILIKE' : 'ILIKE';
    $word =~ s/\%/_/g;
    my($res);
    __PACKAGE__->do_by_two(sub {
        my($regexp, $field) = @_;
	return 1 unless $word =~ $regexp;
	$res = $stmt->$method($field, '%' . lc($word) . '%');
	return 0;
    }, $args->{match_fields});
    return $res ? $res : b_warn($word, ': invalid word');
}

sub _filter_date {
    my($stmt, $date_field) = (shift, shift);
    my($ops, $dates) = _filter_date_parse(@_);
    return
	unless $ops;
    my($method) = 'set_local_beginning_of_day';
    return @{__PACKAGE__->map_together(
	sub {
	    my($op, $date) = @_;
	    my($m) = $method;
	    $method = 'set_local_end_of_day';
	    return $op ? $stmt->$op($date_field, [$_DT->$m($date)])
		: ();
	},
	$ops,
	$dates,
    )};
}

sub _filter_date_parse {
    my($prefix, $word) = @_;
    my($op) = $_DATE_OP->{$prefix};
    my($parts) = [split(/\W+/, $word)];
    return b_warn($word, ': too many date parts')
	if @$parts > 3;
    return b_warn($word, ': too few date parts')
	if @$parts < 2;
    if (@$parts == 2) {
	my($begin) = $_DT->date_from_parts(
	    1,
	    length($parts->[0]) > 2 ? reverse(@$parts) : @$parts,
	);
	return ([qw(GTE LTE)], [$begin, $_DT->set_end_of_month($begin)]);
    }
    my($date, $e) = $_D->from_literal($word);
    return b_warn($word, ': ', $e)
	unless $date;
    return $op eq 'EQ' ? ([qw(GTE LTE)], [$date, $date])
	: $op eq 'LTE' ? ([undef, $op], [undef, $date])
	: ([$op, undef], [$date, undef]);
}

1;
