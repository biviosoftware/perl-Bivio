# Copyright (c) 2006-2026 bivio Software, Inc.  All Rights Reserved.
require(IO_File()->absolute_path('Blog.PL'));
[map({
    my($x) = {
        title => "Title $_ *?:/",
        content => "body\n" x $_,
    };
    Bivio::Biz::Model->new(req(), 'BlogCreateForm')->process($x);
    $x->{path_info} = Bivio::Type->get_instance('BlogFileName')->from_absolute(
        req()->get('Model.RealmFile')->get('path'));
    commit();
    $x;
} 1..3)];
