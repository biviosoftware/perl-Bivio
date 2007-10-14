# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
require 'Blog.PL';
[map({
    my($x) = {
	title => "Title $_ *?:/",
	body => "body\n" x $_,
    };
    Bivio::Biz::Model->new(req(), 'BlogCreateForm')->process($x);
    $x->{path_info} = Bivio::Type->get_instance('BlogFileName')->from_absolute(
	req()->get('Model.RealmFile')->get('path'));
    commit();
    $x;
} 1..3)];
