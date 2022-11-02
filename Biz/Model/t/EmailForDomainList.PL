# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
my($users) = [qw(demo root)];
my($domain) = sub {
    return ($_[0] ? $_[0] . '@' : '') . 'emailfordomain.com';
};
foreach my $u (@$users) {
    unauth_model(Email => {realm_id => realm_id($u)})
        ->update({email => $domain->($u)});
}
($domain, $users);
