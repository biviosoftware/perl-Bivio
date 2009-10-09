# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::CallingContext;
use strict;
# Bivio::IO::Alert imports so do not change import structure
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_A) = 'Bivio::IO::Alert';

sub calling_context_get {
    $_A->warn_deprecated('use get');
    return shift->get(@_);
}

sub get {
    my($self) = shift;
    my($fields) = $self->[$_IDI]->[0];
    return $self->return_scalar_or_array(
	map(exists($fields->{$_}) ? $fields->{$_}
	    : $_A->bootstrap_die($_, ': not a calling_context field'),
	    @_),
    );
}

sub get_top_package_file_line_sub {
    return @{shift->[$_IDI]->[0]}{qw(package file line sub)};
}

sub internal_as_string {
    my($self) = @_;
    return [$self->get(qw(file line))];
}

sub new_from_caller {
    my($proto, $skip_packages) = @_;
    my($frame) = 0;
    if ($skip_packages) {
	while (my $p = caller($frame)) {
	    last
		unless grep($p eq $_, @$skip_packages);
	    $frame++;
	}
    }
    $frame++;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = [
	map(+{
	    package => (caller($_))[0] || undef,
	    file => (caller($_))[1] || undef,
	    line => (caller($_))[2] || undef,
	    sub => (caller($_ + 1))[3] || undef,
	}, $frame, $frame + 1),
    ];
    return $self;

}

sub new_from_file_line {
    my($proto, $file, $line) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = [{
	file => $file,
	line => $line,
    }];
    return $self;
}

1;
