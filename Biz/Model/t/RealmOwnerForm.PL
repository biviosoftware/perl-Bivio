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
        'b_owner#UserMeta' => [
            map(+{
                label => $_,
                type => (/integer/ ? 'Integer' : 'String'),
                /required/ ? (is_required => 1) : (),
            },
                qw(b_optional b_required b_integer b_string)),
        ],
    });
    return model('TupleUse')->create_from_label('UserMeta');
}

sub setup_request {
    my(undef, $params) = @_;
    req()->set_realm_and_user('fourem', shift(@$params));
    return $params;
}
1;
