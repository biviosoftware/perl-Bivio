# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentValuationForm;
use strict;
$Bivio::Biz::Model::InstrumentValuationForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InstrumentValuationForm - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentValuationForm;
    Bivio::Biz::Model::InstrumentValuationForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentValuationForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentValuationForm>

=cut

#=IMPORTS
use Bivio::Type::Date;
use Bivio::UI::HTML::Format::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::InstrumentValuationForm

Creates an instrument valuation form.

=cut

sub new {
    my($self) = &Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {};

#TODO: rework when defaults available
    my($properties) = $self->internal_get;
    # default date_time to now
    $properties->{'RealmInstrumentValuation.date_time'} =
	    Bivio::UI::HTML::Format::Date->get_widget_value(
		    Bivio::Type::Date->now());

    $properties->{page} = 1;

    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()


=cut

sub execute_input {
    my($self) = @_;

    my($req) = $self->get_request();
    my($properties) = $self->internal_get();
    use Data::Dumper;
    print(STDERR Dumper($properties));

    return;
}

=for html <a name="has_next"></a>

=head2 has_next() : boolean

Returns true if the form has more pages to go.

=cut

sub has_next {
    my($self) = @_;
    return $self->get('page') < 2;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    {
		name => 'RealmInstrumentValuation.date_time',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	],
	hidden => [
	    {
		name => 'page',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;

    my($properties) = $self->internal_get;

    # advance the form page if no errors
    if ( ! $self->in_error && $properties->{page} == 1) {
	$properties->{page} = 2;
#TODO: This is broken
	$self->internal_put_error('page',
		Bivio::TypeError::NEXT_PAGE())
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
