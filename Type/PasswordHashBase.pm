# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::PasswordHashBase;
use strict;
use Bivio::Base 'Type.SyntacticString';

my($_IDI) = __PACKAGE__->instance_data_index;
my(@_SALT_CHARS) = (
    'a'..'z',
    'A'..'Z',
    '0'..'9',
);
my($_SALT_INDEX_MAX) = int(@_SALT_CHARS) - 1;

sub ID {
    b_die('abstract method');
}

sub REGEX {
    b_die('abstract method');
}

sub SALT_LENGTH {
    b_die('abstract method');
}

sub as_literal {
    my($self) = @_;
    return $self->internal_format_literal($self->get_salt, $self->get_hash);
}

sub compare {
    my($self, $clear_text) = @_;
    return $self->as_literal cmp $self->to_literal($clear_text, $self->get_salt);
}

sub get_id {
    return shift->[$_IDI][0];
}

sub get_salt {
    return shift->[$_IDI][1];
}

sub get_hash {
    return shift->[$_IDI][2];
}

sub internal_format_literal {
    my($proto, $salt, $hash) = @_;
    return '$' . join('$', $proto->ID, $salt, $hash);
}

sub internal_post_from_literal {
    my($proto, $value) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = $proto->internal_to_parts($value);
    return $self;
}

sub internal_random_salt {
    my($proto) = @_;
    my($salt) = '';
    for (my($i) = 0; $i < $proto->SALT_LENGTH; $i++) {
        $salt .= $_SALT_CHARS[int(rand($_SALT_INDEX_MAX) + 0.5)];
    };
    return $salt;
}

sub internal_to_literal {
    b_die('abstract method');
}

sub internal_to_parts {
    my($proto, $value) = @_;
    return [split('\$', substr($value, 1))];
}

sub to_literal {
    my($proto, $clear_text, $salt) = @_;
    $salt ||= $proto->internal_random_salt;
    return $proto->internal_to_literal($clear_text, $salt);
}

1;
