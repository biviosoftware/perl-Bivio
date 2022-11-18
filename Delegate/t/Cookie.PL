# $Id$
# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
config({
    'Bivio::IO::ClassLoader' => {
        delegates => {
            'Bivio::Agent::HTTP::Cookie' => class(),
        },
    },
});
b_use('AgentHTTP.Cookie');
Request();
req()->initialize_fully;
