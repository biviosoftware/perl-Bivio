# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::FileTable;
use strict;
$Bivio::UI::HTML::Club::FileTable::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::FileTable - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::FileTable;
    Bivio::UI::HTML::Club::FileTable->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::FileTable::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::FileTable>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::FileTreeList;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Format::Bytes;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::ListActions;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table;
use Bivio::UI::PageType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::FileTable


=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{content} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::Model::FileTreeList'],
	headings => [
	    'Date',
	    'User',
	    'Name',
	    'Size',
	    'Directory',
	    'ID',
	    'Source',
	    'Type',
	],
	cells => [
	    Bivio::UI::HTML::Widget::DateTime->new({
		mode => 'DATE',
		value => ['File.modified_date_time'],
		column_nowrap => 1,
	    }),
	    ['RealmOwner.name'],
	    ['File.name'],
	    ['File.bytes', 'Bivio::UI::HTML::Format::Bytes'],
	    ['File.directory_id'],
	    ['File.file_id'],
	    ['File.source_name'],
	    ['File.content_type'],
	    Bivio::UI::HTML::Widget::ListActions->new({
		values => [
		    ['delete', 'CLUB_COMMUNICATIONS_FILE_DELETE',
		        'THIS_CHILD_LIST'],
		    ['upload', 'CLUB_COMMUNICATIONS_FILE_UPLOAD',
			'THIS_CHILD_LIST'],
		    ['download', 'CLUB_COMMUNICATIONS_FILE_DOWNLOAD',
			'THIS_CHILD_LIST'],
		    ['replace', 'CLUB_COMMUNICATIONS_FILE_REPLACE',
			'THIS_CHILD_LIST'],
		    ['mkdir', 'CLUB_COMMUNICATIONS_FILE_CREATE_DIRECTORY',
			'THIS_CHILD_LIST'],
		],
	    }),
	],
    });
    $fields->{content}->initialize;

    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)


=cut

subsub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $req->put(page_subtopic => undef,
	    page_content => $fields->{content},
	    page_type => Bivio::UI::PageType::NONE(),
	   );

    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
