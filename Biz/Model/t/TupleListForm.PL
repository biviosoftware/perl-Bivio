FormModel({
    setup_request => sub {
	my($params) = shift->get('params');
	req()->put(
	    query => ref($params->[0]) || !defined($params->[0]) ? undef
		: {this => shift(@$params)},
	);
	return;
    },
});
req()->set_realm_and_user(qw(demo demo));
