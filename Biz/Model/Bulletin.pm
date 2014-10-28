# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Bulletin;
use strict;
use Bivio::Base 'Biz.PropertyModel';

my($_DT) = b_use('Type.DateTime');

sub create {
    my($self, $values) = @_;
    $values->{date_time} ||= $_DT->now;
    return shift->SUPER::create(@_);
}

sub delete_all {
    my($self) = @_;
    $self->do_iterate(sub {
        my($bulletin) = @_;
	$bulletin->delete;
	return 1;
    });
    return;
}

sub get_attachment_file_names {
    # Returns an array of attachment file names.
    my($self) = @_;
    my($dir) = b_use('UI.Facade')->get_local_file_name(
        b_use('UI.LocalFileType')->REALM_DATA,
	'bulletin/' . $self->get('bulletin_id'),
	$self->req,
    );
    return [<$dir/*>];
}

sub get_body_as_html {
    # Returns the message body formatted for html.
    my($self, $body, $content_type) = @_;
    $body ||= $self->get('body');
    $body = $$body if ref($body);
    $content_type ||= $self->get('body_content_type');

    if ($content_type eq 'text/html') {
        $body =~ s/<(\/)?(html|body).*?>//gis;
        return $body;
    }
    $body = b_use('Bivio.HTML')->escape($body);
    $body =~ s/$/<br \/>/mg;
    return $body;
}

sub has_attachments {
    my($self) = @_;
    return int(@{$self->get_attachment_file_names}) > 0 ? 1 : 0;
}

sub internal_initialize {
    return {
	version => 1,
	table_name => 'bulletin_t',
	columns => {
            bulletin_id => ['PrimaryId', 'PRIMARY_KEY'],
            date_time => ['DateTime', 'NOT_NULL'],
            subject => ['Line', 'NOT_NULL'],
            body => ['Text64K', 'NOT_NULL'],
            body_content_type => ['Line', 'NOT_NULL'],
	},
    };
}

1;
