# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_DATE_OP) = {qw(
    < LTE
    > GTE
    = EQ
)};
my($_DATE_OP_RE) = join('|', sort(keys(%$_DATE_OP)));

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => ['TaskLog.task_log_id'],
	date => 'TaskLog.date_time',
	order_by => [
	    'TaskLog.date_time',
	],
	other => [
	    'Email.email',
	    'RealmOwner.display_name',
	    'super_user.RealmOwner.name',
	    'TaskLog.uri',
	    'TaskLog.user_id',
	    [qw(TaskLog.super_user_id super_user.RealmOwner.realm_id(+))],
	],
	other_query_keys => [qw(b_filter)],
	auth_id => ['TaskLog.realm_id'],
    });
}

sub internal_left_join_model_list {
    return qw(Email RealmOwner);
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;

    foreach my $model ($self->internal_left_join_model_list) {
	$stmt->from($stmt->LEFT_JOIN_ON('TaskLog', $model, [
	    ['TaskLog.user_id', "$model.realm_id"],
	    b_use("Model.$model")->isa('Bivio::Biz::Model::LocationBase')
	        ? ["$model.location",
		    [$self->get_instance($model)->DEFAULT_LOCATION]]
	        : (),
	]));
    }

    if (my $qf = $self->ureq('Model.TaskLogQueryForm')) {
	if (defined(my $filter = $qf->get_filter_value)) {
	    $stmt->where(map(_filter($_, $stmt), split(' ', $filter)));
	}
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _filter {
    my($word, $stmt) = @_;
    return _filter_date($stmt, $1, $word)
	if $word =~ s/^($_DATE_OP_RE)//o;
    my($method) = $word =~ s/^-// ? 'NOT_ILIKE' : 'ILIKE';
    if ($word =~ m{[/\@]|^\w}) {
	$word =~ s/\%/_/g;
	return $stmt->$method(
	    $word =~ m{/} ? 'TaskLog.uri'
		: $word =~ m{\@} ? 'Email.email'
		    : 'RealmOwner.display_name',
	    '%' . lc($word) . '%',
	);
    }
    return b_warn($word, ': invalid word');
}

sub _filter_date {
    my($stmt) = shift;
    my($ops, $dates) = _filter_date_parse(@_);
    return
	unless $ops;
    my($method) = 'set_local_beginning_of_day';
    return @{__PACKAGE__->map_together(
	sub {
	    my($op, $date) = @_;
	    my($m) = $method;
	    $method = 'set_local_end_of_day';
	    return $op ? $stmt->$op('TaskLog.date_time', [$_DT->$m($date)])
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
