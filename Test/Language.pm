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

C<Bivio::Test::Language> is a framework for acceptance testing.  A test script
is a Perl program which is evaluated within the context of this class.  The
first line consists of a call to L<setup|"setup">, which identifies a subclass
of this class.  The subclass defines methods which are called with an instance
created during L<setup|"setup">.  The instance contains state about the test,
e.g. cookies and connections to servers.

=head1 ATTRIBUTES

=over 4

=item script : string

file name of the script

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SELF_IN_EVAL);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::Test::Language

Instantiates this class.

=cut

sub new {
    my($proto) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto);
    $self->[$_IDI] = {};
    return $self;
}

=for html <a name="setup"></a>

=head2 static setup(string map_class, array setup_args) : Bivio::Test::Language

Loads TestLanguage I<map_class>.  Calls L<new|"new"> on the loaded class with
I<new_args>.

=cut

sub setup {
    my($proto, $map_class, $setup_args) = @_;
    my($self) = _assert_in_eval();
    my($subclass) = Bivio::IO::ClassLoader->map_require($map_class);
    return;
}

=head1 METHODS

=cut

=for html <a name="cleanup"></a>

=head2 static cleanup()

Clean up state, such as external files, database values, etc.
Must not rely on state of instance, but be able to clean up globally.

Usage:

    sub cleanup {
        my($proto) = @_;
        my clean up...;
        $proto->SUPER::cleanup;
        return;
    }

=cut

sub cleanup {
    # need to handle explicit call.
    return;
}

=for html <a name="run"></a>

=head2 static run(string script_name) : boolean

=head2 static run(string_ref script) : boolean

Runs 


=cut

sub run {
    my($proto, $script) = @_;
    my($script_name) = ref($script) ? '<inline>' : $script;
    $_SELF_IN_EVAL->die($script_name, ': called from within test script')
	if $_SELF_IN_EVAL;
    $_SELF_IN_EVAL = $proto->new({script => $script_name});
    my($die) = Bivio::Die->catch(sub {
        $script = Bivio::IO::File->read($script_name) unless ref($script);
	my($copy) = 'use strict; '.$$script;
        Bivio::Die->eval_or_die(\$copy);
	return;
    });
    $_SELF_IN_EVAL = undef;
    return $die;
}

#=PRIVATE METHODS

# _assert_in_eval() : Bivio::Test::Language
#
# Returns the current test or terminates.
#
sub _assert_in_eval {
    my($op) = @_;
    return $_SELF_IN_EVAL if $_SELF_IN_EVAL;
    $op ||= 'eval';
    $op =~ s/.*:://;
    Bivio::Die->die($op, ': attempted operation outside script');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
