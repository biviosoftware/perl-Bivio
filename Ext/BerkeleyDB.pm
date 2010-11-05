# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::BerkeleyDB;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use BerkeleyDB ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_C) = b_use('IO.Config');
my($_SUFFIX) = '.bdb';

sub db_create_or_open {
    my($self) = shift->new;
    my($name) = @_;
    $self->[$_IDI] = {
	db => BerkeleyDB::Btree->new(
	    -Filename => _file($name),
	    -Flags => BerkeleyDB::DB_CREATE(),
	) || b_die(_file($name), ': unable to open: ', $BerkeleyDB::Error || $!),
	name => $name,
    };
    return $self;
}

sub db_destroy {
    my(undef, $name) = @_;
    $_C->assert_test;
    unlink(_file($name));
    return;
}

sub db_do_glob {
    my($self, $name_glob, $op) = @_;
    foreach my $name (glob($name_glob . $_SUFFIX)) {
	$name =~ s/$_SUFFIX$//;
	return
	    unless $op->($self->db_create_or_open($name), $name);
    }
    return;
}

sub db_exists {
    my($proto, $name) = @_;
    return $proto->boolean(-e _file($name));
}

sub delete_keys {
    my($self) = shift;
    foreach my $k (@_) {
	_op($self, db_del => $k);
    }
    return;
}

sub do_each {
    my($self, $op) = @_;
    my($cursor) = $self->[$_IDI]->{db}->db_cursor;
    my($k, $v);
    {
	# With this shows an uninitialized subroutine entry.  We isolate this
	# warning with this DB_FIRST section.  Otherwise, the loop would be simpler.
	local($SIG{__WARN__}) = sub {};
	return
	    unless $cursor->c_get($k, $v, BerkeleyDB::DB_FIRST()) == 0;
    };
    do {
	return
	    unless $op->($k, $v);
    } while $cursor->c_get($k, $v, BerkeleyDB::DB_NEXT()) == 0;
    return;
}

sub get_values {
    return _get(1, @_);
}

sub put_key_values {
    my($self) = shift;
    $self->map_by_two(
	sub {
	    _op($self, db_put => shift, shift);
	    return;
	},
	\@_,
    );
    return;

}

sub unsafe_get_values {
    return _get(0, @_);
}

sub _err {
    my($self) = shift;
    b_die(@_, '; name=', $self->[$_IDI]->{name});
    # DOES NOT RETURN
}

sub _file {
    return shift(@_) . $_SUFFIX;
}

sub _get {
    my($die_on_not_found, $self) = (shift, shift);
    return $self->return_scalar_or_array(
	map(
	    {
		my($k, $v) = $_;
		_op($self, db_get => $k, $v)
		    ? $v
		    : $die_on_not_found
		    ? _err($self, $k, ': key not found')
		    : undef;
	    }
	    @_,
	),
    );
    return;
}

sub _op {
    my($self, $method) = (shift, shift);
    my($fields) = $self->[$_IDI];
    return $method =~ /db_del|db_put/ ? _op($self, 'db_sync') : 1
	if 0 == (my $status = $fields->{db}->$method(@_));
    return 0
	if $status = BerkeleyDB::DB_NOTFOUND();
    _err(
	$self,
	shift(@_),
	': ',
	$BerkeleyDB::Error,
	'; status=',
	$status,
    );
    # DOES NOT RETURN
}

1;
