# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSellForm;
use strict;
$Bivio::Biz::Model::InstrumentSellForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InstrumentSellForm - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSellForm;
    Bivio::Biz::Model::InstrumentSellForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentSellForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSellForm>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::TypeError;
use Bivio::UI::HTML::Format::Date;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::InstrumentBuyForm

Creates an instrument buy form.

=cut

sub new {
    my($self) = &Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {};

#TODO: rework when defaults available
    my($properties) = $self->internal_get;
    # default date_time to now
    $properties->{'RealmTransaction.date_time'} =
	    Bivio::UI::HTML::Format::Date->get_widget_value(
		    Bivio::Type::Date->now());

    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()


=cut

sub execute_input {
    my($self) = @_;
    _trace($self->internal_get) if $_TRACE;
    return;
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
		name => 'RealmTransaction.date_time',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    'RealmAccountEntry.realm_account_id',
	    'RealmInstrumentEntry.count',
	    'Entry.amount',
	    {
		name => 'commission',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
		name => 'admin_fee',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    'RealmTransaction.remark',
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
	primary_key => [
	    'RealmTransaction.realm_transaction_id',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;

    my($amount) = $self->get_model_properties('Entry')->{amount};

    # make sure the payment amount is > 0
    $self->internal_put_error('Entry.amount',
	    Bivio::TypeError::GREATER_THAN_ZERO())
	    unless $amount > 0;

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
