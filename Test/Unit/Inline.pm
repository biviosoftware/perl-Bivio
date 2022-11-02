# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::Inline;
use strict;
use Bivio::Base 'TestUnit.Unit';


sub run_unit {
    return shift->SUPER::run_unit(@_)
        if @_ == 3;
    my($self, $sub_or_cases) = @_;
    my($req) = b_use('Test.Request')->initialize_fully;
    return $self->SUPER::run_unit([
        map({
            my($op) = $_;
            b_die($op, ': imperative cases are subs only')
                unless ref($op) eq 'CODE';
            ($self->builtin_class() => sub {
                $op->();
                return 1;
            });
        } ref($sub_or_cases) eq 'CODE' ? $sub_or_cases : @$sub_or_cases),
    ]);
}

1;
