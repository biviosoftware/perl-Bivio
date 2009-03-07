# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RemoteCopyList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_COLS) = [
    [qw(realm Name)],
    [qw(user RealmName)],
    [qw(pass Line)],
    [qw(uri HTTPURI)],
    [qw(folder FilePathArray)],
];

sub internal_initialize {
    my($self) = @_;
    my($c) = [@$_COLS];
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
	    primary_key => [shift(@$c)],
	    other => $c,
	),
    });
}

sub internal_load_rows {
    my($self) = @_;
    return [sort(
	{$a->{realm} cmp $b->{realm}}
	map({
	    $_->{uri} =~ s{/+$}{};
	    $_->{uri} ||= '/';
	    $_->{folder} = $_->{folder}->sort_unique;
	    $_;
        } values(%{
	    $self->new_other('RealmSettingList')
		->get_all_settings(RemoteCopy => [@$_COLS])
	    }),
	),
    )];
}

sub unauth_if_setting_available {
    my($self, $realm_id) = @_;
    return $self->new_other('RealmSettingList')
	->unauth_if_file_exists(RemoteCopy => $realm_id);
}

1;
