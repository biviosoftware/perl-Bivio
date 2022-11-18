# Copyright (c) 2009-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::CallingContext;
use strict;
# Bivio::IO::Alert imports so do not change import structure
use base 'Bivio::UNIVERSAL';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_A) = 'Bivio::IO::Alert';

sub as_string {
    my($self) = @_;
    return shift->SUPER::as_string(@_)
        unless ref($self);
    my($file, $line, $sub) = $self->get(qw(file line sub));
    return join(
        ':',
        $file =~ /\(eval/ && $sub ne '(eval)' ? $sub : (),
        $file,
        $line,
    );
}

sub calling_context_get {
    $_A->warn_deprecated('use get');
    return shift->get(@_);
}

sub equals {
    my($self, $that) = @_;
    return 0
        unless $self->is_blesser_of($that);
    foreach my $f (qw(file line)) {
        return 0
            unless $self->get($f) eq $that->get($f);
    }
    return 1;
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

sub inc_line {
    my($self, $inc) = @_;
    return $self->new_from_file_line(
        $self->get('file'),
        $self->get('line') + $inc,
    );
}

sub new_from_caller {
    my($proto, $skip_packages) = @_;
    my($frame) = 0;
    if ($skip_packages) {
        while (1) {
            my($p, $f) = caller($frame);
            last
                unless grep(ref($_) ? $p =~ $_ || $f =~ $_ : $p eq $_, @$skip_packages);
            $frame++;
        }
    }
    else {
        $frame++;
    }
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
        sub => '',
        package => '',
    }];
    return $self;
}

1;
