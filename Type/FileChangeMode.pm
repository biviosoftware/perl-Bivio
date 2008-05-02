# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FileChangeMode;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    # folder:
    #  UPLOAD
    #  TEXT_FILE
    #  ADD_SUBFOLDER
    #  RENAME
    #  MOVE
    #  DELETE

    # file:
    #  TEXT_FILE
    #  UPLOAD
    #  RENAME
    #  MOVE
    #  DELETE

    UNKNOWN => [0],
    UPLOAD => [1],
    TEXT_FILE => [2],
    ADD_SUBFOLDER => [3],
    RENAME => [4],
    MOVE => [5],
    DELETE => [6],
]);

1;
