# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ConfirmUpload;
use strict;
$Bivio::UI::HTML::Club::ConfirmUpload::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ConfirmUpload - confirms club transaction deletion

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ConfirmUpload;
    Bivio::UI::HTML::Club::ConfirmUpload->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::ConfirmUpload::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ConfirmUpload> confirms club transaction deletion

=cut

#=IMPORTS
use Bivio::Biz::Model::ConfirmUploadForm;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Returns content widget.

=cut

sub create_content {
    my($self) = @_;

#TODO: want this in the header, not heading, but can't figure it out
    $self->put(page_heading => '
Warning: This will delete all existing investments and accounting
transactions. Continue?
');

    return $self->form('ConfirmUploadForm', []);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
