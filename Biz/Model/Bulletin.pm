# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Bulletin;
use strict;
$Bivio::Biz::Model::Bulletin::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Bulletin::VERSION;

=head1 NAME

Bivio::Biz::Model::Bulletin - site bulletins

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::Bulletin;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Bulletin::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Bulletin>

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref values) : self

Defaults the date to now.

=cut

sub create {
    my($self, $values) = @_;
    $values->{date_time} ||= Bivio::Type::DateTime->now;
    return $self->SUPER::create($values);
}

=for html <a name="get_attachment_file_names"></a>

=head2 get_attachment_file_names() : array_ref

Returns an array of attachment file names.

=cut

sub get_attachment_file_names {
    my($self) = @_;
    my($dir) = Bivio::UI::Facade->get_local_file_name(
        Bivio::UI::LocalFileType->REALM_DATA, 'bulletin/'
        . $self->get('bulletin_id'));
    return [<$dir/*>];
}

=for html <a name="get_body_as_html"></a>

=head2 get_body_as_html() : string

=head2 static get_body_as_html(string body, string content_type) : string

Returns the message body formatted for html.

=cut

sub get_body_as_html {
    my($self, $body, $content_type) = @_;
    $body ||= $self->get('body');
    $body = $$body if ref($body);
    $content_type ||= $self->get('body_content_type');

    if ($content_type eq 'text/html') {
        $body =~ s/<(\/)?(html|body).*?>//gis;
        return $body;
    }
    $body = Bivio::HTML->escape($body);
    $body =~ s/$/<br>/mg;
    return $body;
}

=for html <a name="has_attachments"></a>

=head2 has_attachments() : boolean

Returns true if the bulletin has attachments.

=cut

sub has_attachments {
    my($self) = @_;
    return int(@{$self->get_attachment_file_names}) > 0 ? 1 : 0;
}

=for html <a name="internal_initialze"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

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

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
