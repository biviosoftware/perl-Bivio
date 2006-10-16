# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::t::Language::T1;
use strict;
$Bivio::Test::t::Language::T1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::t::Language::T1::VERSION;

=head1 NAME

Bivio::Test::t::Language::T1 - simple language for testing

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::t::Language::T1;

=cut

=head1 EXTENDS

L<Bivio::Test::Language> is a simple test language.

=cut

use Bivio::Test::Language;
@Bivio::Test::t::Language::T1::ISA = ('Bivio::Test::Language');

=head1 DESCRIPTION

C<Bivio::Test::t::Language::T1>

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SENTINEL_PREFIX) = __PACKAGE__ . '.tmp.';
Bivio::IO::Config->register(my $_CFG = {
    t1 => 'not foo',
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::t::Language::T1

Creates a new instance.

=cut

sub new {
    my($proto, $sentinel) = @_;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="assert_config"></a>

=head2 assert_config(string t1)

Asserts configuration is t1.

=cut

sub assert_config {
    my(undef, $t1) = @_;
    Bivio::Die->die($t1, ': not same as config value t1: ', $_CFG->{t1})
        unless $t1 eq $_CFG->{t1};
    return;
}

=for html <a name="die_now"></a>

=head2 die_now()

Always dies.

=cut

sub die_now {
    die('you gravy sucking pig');
    # DOES NOT RETURN
}

=for html <a name="double_it"></a>

=head2 double_it(string v) : string



=cut

sub double_it {
    my($self, $v) = @_;
    return $v.$v;
}

=for html <a name="handle_cleanup"></a>

=head2 static handle_cleanup()

Deletes all possible sentinel files.  Not just ones created by this test.

=cut

sub handle_cleanup {
    my($proto) = @_;
    unlink(<$_SENTINEL_PREFIX*>);
    $proto->SUPER::handle_cleanup;
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item t1 : int [1]

For testing passing command line args.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="handle_setup"></a>

=head2 handle_setup(string sentinel)

Stores sentinel as a file in __PACKAGE__.tmp.$sentinel

=cut

sub handle_setup {
    my($self, $sentinel) = @_;
    my($fields) = $self->[$_IDI];
    $sentinel .= "$_SENTINEL_PREFIX$sentinel";
    Bivio::IO::File->write($sentinel, "test file\n");
    $fields->{sentinel} = $sentinel;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
