# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::HtmlRef;
use strict;
$Bivio::Biz::HtmlRef::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::HtmlRef - A (link, name) type.

=head1 SYNOPSIS

    use Bivio::Biz::HtmlRef;
    Bivio::Biz::HtmlRef->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::CompoundField>

=cut

@Bivio::Biz::HtmlRef::ISA = qw(Bivio::Biz::CompoundField);

=head1 DESCRIPTION

C<Bivio::Biz::HtmlRef>

=cut

=head1 CONSTANTS

=cut

=for html <a name="LINK"></a>

=head2 LINK : int

The link index.

=cut

sub LINK {
    return 0;
}

=for html <a name="NAME"></a>

=head2 NAME : int

The name index.

=cut

sub NAME {
    return 1;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string link, string name) : Bivio::Biz::HtmlRef

Create a HtmlRef for the specified link and name.

=cut

sub new {
    my($proto, $link, $name) = @_;
    my($self) = &Bivio::Biz::CompoundField::new($proto,
	   [$link, $name], 2);
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
