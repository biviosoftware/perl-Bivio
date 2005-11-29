# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
$Bivio::Test::FormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::FormModel::VERSION;

=head1 NAME

Bivio::Test::FormModel - 

=head1 RELEASE SCOPE

Bivio

=head1 SYNOPSIS

    use Bivio::Test::FormModel;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test::Request;
@Bivio::Test::FormModel::ISA = ('Bivio::Test::Request');

=head1 DESCRIPTION

C<Bivio::Test::FormModel>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="builtin_form_values"></a>

=head2 builtin_form_values() : 

=cut

sub form_values {
    my($self, $hash) = @_;
    my($m) = $self->get(__PACKAGE__)->get_instance;
    $self->put(
	task => Bivio::Collection::Attributes->new({
	    form_model => ref($m),
	    next => 'MY_SITE',
	}),
	form => {
	    $m->VERSION_FIELD => $m->get_info('version'),
	    map(
		($m->get_field_name_for_html($_) => $m->get_field_type($_)
		     ->to_literal($hash->{$_})),
		keys(%$hash),
	    )},
    );
    return;
}

=for html <a name="new_unit"></a>

=head2 new_unit(string class_name) : self

=cut

sub new_unit {
    my($self, $class_name) = @_;
    return $self->SUPER::new_unit($class_name, 'initialize_fully')
	->put(__PACKAGE__ , $class_name);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
