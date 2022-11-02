# Copyright (c) 2012 bivio Software, Inc.  All rights reserved.
# $Id: 
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
        'Bivio::IO::ClassLoader' => {
            delegates => {
                'Bivio::Agent::TaskId' => 'Bivio::Agent::t::TaskId::TestTaskId',
            },
        },
    });
}
use Bivio::Test;
Bivio::Test->new({
    method_is_autoloaded => 1,
})->unit([
    'Bivio::Agent::TaskId' => [
        bunit_validate_all => undef,
        included_components => [
            [] => [['blog']],
        ],
        canonicalize_task_info => [
            [[
                {
                    name => 'F1',
                    int => 1,
                    permission_set => [qw(ANYBODY)],
                },
                [qw(
                    F2
                    2
                    GENERAL
                    ANYBODY
                    Action.EmptyReply
                )],
            ]] => [[
                {
                    name => 'F1',
                    int => 1,
                    permission_set => [qw(ANYBODY)],
                },
                {
                    name => 'F2',
                    int => 2,
                    realm_type => 'GENERAL',
                    permission_set => 'ANYBODY',
                    items => [qw(Action.EmptyReply)],
                },
            ]],
            [[
                {
                    name => 'G1',
                    int => 1,
                },
                [qw(
                    G1
                    2
                )],
            ]] => qr{duplicate}i,
        ],
        merge_task_info => [
            xapian => [[
                {
                    name => '_TASK_COMPONENT_xapian',
                    int => 0,
                },
                {
                    name => 'JOB_XAPIAN_COMMIT',
                    int => 60,
                    realm_type => 'ANY_OWNER',
                    permission_set => 'ANYBODY',
                    items => [qw(
                        Search.Xapian
                    )],
                },
                {
                    name => 'SEARCH_LIST',
                    int => 61,
                    realm_type => 'GENERAL',
                    permission_set => 'ANYBODY',
                    items => [qw(
                        Model.SearchForm
                        Model.SearchList->execute_load_page
                        View.Search->list
                    )],
                    next => 'SEARCH_LIST',
                },
                {
                    name => 'GROUP_SEARCH_LIST',
                    int => 62,
                    realm_type => 'ANY_OWNER',
                    permission_set => 'ANYBODY',
                    items => [qw(
                        Model.SearchForm
                        Model.SearchList->execute_load_page
                        View.Search->list
                    )],
                    next => 'GROUP_SEARCH_LIST',
                },
                {
                    name => 'SEARCH_SUGGEST_LIST_JSON',
                    int => 63,
                    realm_type => 'GENERAL',
                    permission_set => 'ANYBODY',
                    items => [qw(
                        Model.SearchSuggestList->execute_load_page
                        View.Search->suggest_list_json
                        Action.JSONReply->http_ok
                    )],
                },
                {
                    name => 'GROUP_SEARCH_SUGGEST_LIST_JSON',
                    int => 64,
                    realm_type => 'ANY_OWNER',
                    permission_set => 'ANYBODY',
                    items => [qw(
                        Model.SearchSuggestList->execute_load_page
                        View.Search->suggest_list_json
                        Action.JSONReply->http_ok
                    )],
                },
            ]],
            [[[a => 1]], [[b => 2]]] => [[{
                name => 'a',
                int => 1,
                realm_type => undef,
                permission_set => undef,
                items => [],
            }, {
                name => 'b',
                int => 2,
                realm_type => undef,
                permission_set => undef,
                items => [],
            }]],
            [[[a => 1]], [[a => 3], [b => 2]]] => [[{
                name => 'b',
                int => 2,
                realm_type => undef,
                permission_set => undef,
                items => [],
            }, {
                name => 'a',
                int => 3,
                realm_type => undef,
                permission_set => undef,
                items => [],
            }]],
        ],
        included_components => [
            [] => [[qw(blog)]],
        ],
        from_name => [
            TEST_TASK_ID_1 => undef,
            _TASK_COMPONENT_blog => qr{no such},
            SEARCH_LIST => qr{no such},
        ],
    ],
]);
