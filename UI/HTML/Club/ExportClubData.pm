# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ExportClubData;
use strict;
$Bivio::UI::HTML::Club::ExportClubData::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ExportClubData - export club data links

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ExportClubData;
    Bivio::UI::HTML::Club::ExportClubData->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::ExportClubData::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ExportClubData> export club data links

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Creates an export club data page contents.

=cut

sub create_content {
    my($self) = @_;

    return $self->join([
	Bivio::UI::HTML::Widget::Grid->new({
	    values => [
		[
		    $self->string('Export Club Data', 'page_heading'),
		],
		[
		    ' ',
		],
		[
		    $self->string(<<'EOF',
Club accounting data is exported as an XML document.  XML is a rapidly emerging
standard for exchanging data between different software packages.  It
 expresses data as a set of human readable, labeled fields, and is not tied
to any particular software package or database format.
EOF
		    ),
		],
		[
		    ' ',
		],
		[
		    $self->string(<<'EOF',
The XML document containing your club data can be exported in any one of three
file formats.  In two of these formats the data is compressed, reducing
the amount of space it takes up on your disk and reducing download time.  The
other format is plain, uncompressed text.
EOF
		    ),
		],
	    ]
	}),
	$self->task_list(
	    'File Formats',
	    [
		['CLUB_ACCOUNTING_EXPORT_CLUB_DATA_ZIP', undef, $self->join(
		     "This format is most commonly used by Microsoft "
 		     . "Windows users.  It can be uncompressed by ",
		     Bivio::UI::HTML::Widget::Link->new(
			     {
				 value => $self->string('WinZip'),
				 href => 'http://www.winzip.com'
			     }),
		     "."
		    )],
		['CLUB_ACCOUNTING_EXPORT_CLUB_DATA_UNCOMPRESSED', undef,
		    "This format does not need any de-compression software, "
		    . "but it is much larger than either of the compressed "
		    . "formats."],
		['CLUB_ACCOUNTING_EXPORT_CLUB_DATA_GZ', undef,
		    "This format is most commonly used by Unix users.  "
		    . "It can be uncompressed by gzip."],
	    ],
	    # want_sort is true
	    1,
	),
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
