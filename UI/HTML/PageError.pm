# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::PageError;
use strict;
$Bivio::UI::HTML::PageError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::PageError - the content of an error page

=head1 SYNOPSIS

    use Bivio::UI::HTML::PageError;
    Bivio::UI::HTML::PageError->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Join>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::PageError::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::PageError> renders a "we're sorry"
message with special text.

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_TOPIC"></a>

=head2 PAGE_TOPIC : string

Returns 'Error'

=cut

sub PAGE_TOPIC {
    return 'Error';
}

#=IMPORTS
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : array_ref

Wrap L<create_error_content|"create_error_content"> with
general support text.

=cut

sub create_content {
    my($self) = @_;
    return [
#TODO: Make this non-static
	$self->create_error_content,
	<<'EOF',
<p>
If you do not understand this error message, please feel free to call
customer support at
EOF
	['support_phone'],
	"\nor mail us at\n",
	Bivio::UI::HTML::Widget::Link->new({
	    href => ['->format_mailto', ['support_email']],
	    value => Bivio::UI::HTML::Widget::String->new({
		value => ['support_email'],
	    }),
	}),
	'.',
    ];
}

=for html <a name="create_error_content"></a>

=head2 abstract create_error_content() : array

Returns a list of values which can be used in a C<Join>.

=cut

sub create_error_content {
    die('abstract method');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
