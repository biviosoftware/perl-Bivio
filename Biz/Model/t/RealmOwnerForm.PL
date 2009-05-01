# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
sub create_tuple {
    my($name, $args) = @_;
    req()->set_realm_and_user('fourem', $name);
    b_use('Bivio::Biz::Model::t::RealmOwnerForm')->execute(req(), $args);
    return;
}

sub create_tuple_def {
    req()->set_realm_and_user('fourem', 'root');
    model('TupleDef')->create_from_hash({
        'owner#UserMeta' => [
            map(+{
                label => $_,
                type => ($_ eq 'Integer' ? 'Integer' : 'String'),
                $_ eq 'Required' ? (is_required => 1) : (),
            },
                qw(Optional Required Integer String)),
        ],
    });
    return model('TupleUse')->create_from_label('UserMeta');
}

1;
