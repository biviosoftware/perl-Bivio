# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::UserDemographics;
use strict;
$Bivio::Biz::UserDemographics::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::UserDemographics - demographics

=head1 SYNOPSIS

    use Bivio::Biz::UserDemographics;
    Bivio::Biz::UserDemographics->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::UserDemographics::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::UserDemographics> are fields describing the current user.
All of the fields are optional.
    first_name
    middle_name
    last_name
    gender
    age

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Biz::SqlSupport;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    user => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    first_name => ['First Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    middle_name => ['Middle Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    last_name => ['Last Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    gender => ['Gender',
	    Bivio::Biz::FieldDescriptor->lookup('GENDER', 1)],
    age => ['Age',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 3)],
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('user_', {
    user => 'id',
    first_name => 'first_name',
    middle_name => 'middle_name',
    last_name => 'last_name',
    gender => 'gender',
    age => 'age'
    });

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::UserDemographics

Creates an uninitialized UserDemographics model. Use find() to load
the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'demographics',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {
    };

    $_SQL_SUPPORT->initialize();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(hash find_params) : boolean

Finds demographics given the specified search parameters. Valid parameters
are 'user'.

=cut

sub find {
    my($self, $fp) = @_;

    $self->get_status()->clear();

    if ($fp->{'user'}) {
	$_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where id=?', $fp->{'user'});
    }
    else {
	$self->get_status()->add_error(
		Bivio::Biz::Error->new("User not found"));
    }
    return $self->get_status()->is_OK();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
