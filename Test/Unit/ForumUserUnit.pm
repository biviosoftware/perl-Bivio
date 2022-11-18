# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::ForumUserUnit;
use strict;
use Bivio::Base 'Test.Request';

my($_R) = b_use('Auth.Role');
my($_M) = b_use('Biz.Model');

sub run_unit {
    my($self, $cases) = @_;
    $self->initialize_fully;
    $self->set_realm_and_user(undef, 'demo');
    Bivio::Type->get_instance('FormMode')->CREATE->execute($self, 1);
    my($realm_id) = _create_realms(
        $self,
        undef, [
            ['fuaf1', [
                 ['fuaf1-sub1', [
                      ['fuaf1-sub1-sub1'],
                 ]],
                 ['fuaf1-sub2', [
                      ['fuaf1-sub2-sub1'],
                 ]],
                 ['fuaf1-sub3'],
            ]],
            ['fuaf2', [
                ['fuaf2-sub1'],
            ]],
        ],
    );
    my($test_main_roles);
    return b_use('Bivio.Test')->new({
            class_name => shift->get('class_name'),
            compute_params => sub {
                my(undef, $params) = @_;
                $test_main_roles = $params->[3];
                return [$self, {
                    'Email.email' => $params->[2] || $params->[0]
                        . '@a.a' . ($params->[1] ? 'admin' : ''),
                    realm => $params->[0],
                    administrator => $params->[1],
                }];
            },
            compute_return => sub {
                my($case) = @_;
                my($f) = $case->get('object');
                return [sort(
                    @{$_M->new($self, 'RealmUser')
                        ->map_iterate(sub {
                            my($ru) = @_;
                            my($role) = $ru->get('role');
                            return
                                unless !$test_main_roles
                                    || grep($_R->is_equal($role, $_),
                                            $_R->get_main_list);
                            return grep(
                                $realm_id->{$_} eq $ru->get('realm_id'),
                                keys(%$realm_id));
                        },
                        'unauth_iterate_start',
                        'realm_id',
                        {
                            user_id => $f->unsafe_get('User.user_id'),
                            $test_main_roles ? () :
                                (role => $f->unsafe_get('administrator')
                                    ? $_R->ADMINISTRATOR
                                    : $_R->MEMBER),
                        },
                 )})];
            },
        })->unit(shift);
}

sub _create_realms {
    my($self, $parent, $children, $realm_id) = @_;
    $realm_id ||= {};
    my($ff) = $_M->get_instance('ForumForm');
    foreach my $child (@$children) {
        my($n) = $child->[0];
        $self->set_realm($parent);
        $ff->execute($self, {'RealmOwner.name' => $n});
        $realm_id->{$n} = $self->get('auth_id');
        _create_realms($self, @$child, $realm_id)
            if @$child == 2;
    }
    return $realm_id;
}

1;
