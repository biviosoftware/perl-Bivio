# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::TextArea;
use strict;
$Bivio::Type::TextArea::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::TextArea::VERSION;

=head1 NAME

Bivio::Type::TextArea - very long version of Text used for HTML areas

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::TextArea;

=cut

=head1 EXTENDS

L<Bivio::Type::Text>

=cut

use Bivio::Type::Text;
@Bivio::Type::TextArea::ISA = ('Bivio::Type::Text');

=head1 DESCRIPTION

C<Bivio::Type::TextArea> same as L<Bivio::Type::Text|Bivio::Type::Text>
except 64K characters. This is a typical limit for HTML TEXTAREAs.

=cut


=head1 CONSTANTS

=cut

=for html <a name="LINE_WIDTH"></a>

=head2 LINE_WIDTH : string

Return default line width

=cut

sub LINE_WIDTH {
    return 60;
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 from_literal(string value, int line_width) : any

Wrap text lines at I<line_width> if desired by looking
up the user's preference.

=cut

sub from_literal {
    my($self, $value, $line_width) = @_;

    # careful to see if Preferences model is present before accessing
    if (defined($value) && Bivio::IO::ClassLoader->is_loaded(
	    'Bivio::Societas::Biz::Model::Preferences')
	    && Bivio::Societas::Biz::Model::Preferences->get_user_pref(
		    Bivio::Agent::Request->get_current,
		    'TEXTAREA_WRAP_LINES')) {
	return $self->wrap_lines($value, $line_width || $self->LINE_WIDTH);
    }
    return $self->SUPER::from_literal($value);
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 64K.

=cut

sub get_width {
    return 64*1024;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
