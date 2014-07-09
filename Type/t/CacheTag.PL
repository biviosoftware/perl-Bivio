# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
use Digest::MD5 ();
req()->initialize_fully;
my($prefix) = Type_CacheTag()->get_prefix;
my($local_path) = UI_Facade()->get_local_plain_file_name(
    UI_Facade()->get_local_file_plain_app_uri('css/cache-tag-unit-test.css'), req());
my($content) = random_string();
IO_File()->write($local_path, $content);
my($md5) = Digest::MD5::md5_hex($content);
($local_path, $prefix, $md5);

