# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Language;
use strict;
$Bivio::Test::Language::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Language::VERSION;

=head1 NAME

Bivio::Test::Language - superclass of all acceptance test languages

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Language;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::Language::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::Language> provides support

put durable.  The attributes of one test which are durable are copied to the
next test.  Not sure if it makes totally sense, because the tests may not be
related.  However, if they are run in the same set, it may make sense.  Better
to have the feature with a caveat than to suffer performance loss as a result
of not having it.

put_durable is slightly different than in Request case.  Add the feature
explicitly as opposed to adding it to adding it to Attributes.

=head1 ATTRIBUTES

=over 4

=item script : string

name of the script


=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::Language

Instantiates the test language class.

=cut

sub new {
    my($proto) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto);
    $self->{$_PACKAGE} = {};
    return $self;
}

=for html <a name="setup"></a>

=head2 setup(string map_class, array setup_args) : Bivio::Test::Language

Loads TestLanguage I<map_class>.  Calls L<new|"new"> on the loaded class with
I<new_args>.

=cut

sub setup {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return;
}

=head1 METHODS

=cut

=for html <a name="cleanup"></a>

=head2 cleanup()

Clean up state, such as open files, external files, database values, etc.
You should call this like.

=cut

sub cleanup {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
