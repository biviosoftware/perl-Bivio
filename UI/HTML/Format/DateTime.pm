# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::DateTime;
use strict;
$Bivio::UI::HTML::Format::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format::DateTime - transforms a unix time to date/time string

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::DateTime;
    Bivio::UI::HTML::Format::DateTime->get_widget_value($time);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format>

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::DateTime::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::DateTime> formats a unix time into
a date/time string.  May consult user preferences.

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(int time) : string

Formats a date/time value as a string.  Handles both unix
and DateTime formats.

=cut

sub get_widget_value {
    my(undef, $time) = @_;
    return '' unless defined($time);
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($time);
    return sprintf('%02d/%02d/%04d %02d:%02d:%02d',
	    $mon, $mday, $year, $hour, $min, $sec);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
