# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ModelRef;
use strict;
$Bivio::Biz::ModelRef::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::ModelRef - A (model name, query) type.

=head1 SYNOPSIS

    use Bivio::Biz::ModelRef;
    Bivio::Biz::ModelRef->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::CompoundField>

=cut

@Bivio::Biz::ModelRef::ISA = qw(Bivio::Biz::CompoundField);

=head1 DESCRIPTION

C<Bivio::Biz::ModelRef>

=cut

=head1 CONSTANTS

=cut

=for html <a name="MODEL_NAME"></a>

=head2 MODEL_NAME : int

Returns the model name index.

=cut

sub MODEL_NAME {
    return 0;
}

=for html <a name="QUERY"></a>

=head2 QUERY : int

Return the model query string index.

=cut

sub QUERY {
    return 1;
}

=for html <a name="TEXT"></a>

=head2 TEXT : int

Returns the display text index.

=cut

sub TEXT {
    return 2;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string model_name, string query, string text) : Bivio::Biz::ModelRef

Creates a new ModelRef from the specified model name, query string and
display text.

=cut

sub new {
    my($proto, $model_name, $query, $text) = @_;
    my($self) = &Bivio::Biz::CompoundField::new($proto,
	    [$model_name, $query, $text], 3);
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
