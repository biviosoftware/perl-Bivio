# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Test::Model;
use strict;
$Bivio::Test::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Model::VERSION;

=head1 NAME

Bivio::Test::Model - abstract model of HTML pages

=head1 SYNOPSIS

    use Bivio::Test::Model;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::Model::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::Model> is an abstract model of Bivio HTML pages.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::Test::HTMLParser;
#use Data::Dumper;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string content) : Bivio::Test::Model



=cut

sub new {
    my($proto,$content);
    my($self) = Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {};

    $self->{'Bivio::Test::HTMLAnalyzer'}
	    = Bivio::Test::HTMLAnalyzer->new($content);
    bless($self->{'Bivio::Test::HTMLAnalyzer'});

    return $self;
}

=head1 METHODS

=cut

=for html <a name="list_forms"></a>

=head2 list_forms(Bivio::Test::Model) : array_ref

List the nmemonic names of all forms present in the page.

=cut

sub list_forms {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return ($self->{'Bivio::Test::HTMLAnalyzer'}->list_forms());
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
