# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::XlatorSet;
use strict;
$Bivio::UI::PDF::Form::XlatorSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::XlatorSet - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::XlatorSet;
    Bivio::UI::PDF::Form::XlatorSet->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Form::XlatorSet::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::XlatorSet>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::XlatorSet



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create_value_objs"></a>

=head2 create_value_objs() : 



=cut

sub create_value_objs {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    # Get a reference to the array of xlators for this set.  Call add_value for
    # each one so it can add whatever values to the value_objs array it can.
    my(%value_objs);

    my($xlators_array_ref) = $self->get_xlators_ref();
    map {
	$_->add_value($req, \%value_objs);
    } @{$xlators_array_ref};

    return(\%value_objs);
}

=for html <a name="get_xlator_ref"></a>

=head2 abstract get_xlator_ref() : 



=cut

sub get_xlator_ref {
    my($self, $field_name) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, " Abstract method\n");
    return;
}

=for html <a name="set_up"></a>

=head2 set_up() : 



=cut

sub set_up {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Do nothing; override in sub-class if anything needs to be setup.
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
