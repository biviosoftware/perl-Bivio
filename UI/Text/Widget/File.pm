# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Text::Widget::File;
use strict;
$Bivio::UI::Text::Widget::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::Widget::File::VERSION;

=head1 NAME

Bivio::UI::Text::Widget::File - text content from a file

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Text::Widget::File;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Text::Widget::File::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Text::Widget::File> is a UI adapter for getting text content
from a file.

=head1 ATTRIBUTES

=over 4

=item file : any (required)

The file object that that is the source of the data.  I<file> will be sent
the message read() to get the contents to be rendered.

If I<file> is an array_ref, it will be dereferenced and passed to
C<$source-E<gt>get_widget_value> to get the uri to use.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any file, hash_ref attributes) : Bivio::UI::Text::Widget::File

Creates a C<File> widget with attributes I<file>.
And optionally, set extra I<attributes>.

=cut

sub new {
    my($proto, $file, $attributes) = @_;
    $attributes ||= {};
    $attributes->{file} = $file;
    $attributes->{filename} = [$file, '->filename']
	unless exists($attributes->{filename});
    $attributes->{content_type} = [$file, '->content_type']
	unless exists($attributes->{content_type});
    my($self) = $proto->SUPER::new($attributes);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;

    my($req) = $source->get_request();
    my $file = $self->get('file');
    do {
	$file = $req->get_widget_value($file);
    }
    while ($file && ref($file) eq 'ARRAY');

    $self->die('file evaluated to false')
	unless $file;

    $$buffer .= ${$file->read()};

    return;
}

=for html <a name="want_render"></a>

=head2 want_render(Bivio::Agent::Request req) : boolean

Return true if the widget wants to receive render message.

=cut

sub want_render {
    my($self, $req) = @_;

    my $file = $self->get('file');
    while ($file && ref($file) eq 'ARRAY') {
	$file = $req->get_widget_value($file);
    }

    return $file ? 1 : 0;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
