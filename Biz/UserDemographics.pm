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

C<Bivio::Biz::UserDemographics>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register;
my($_CLASS_CFG);
my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::UserDemographics

Creates an uninitialized UserDemographics model. Use find() to load
the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, $_CLASS_CFG);

    $self->{$_PACKAGE} = {
    };
    return $self;

}

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

See PropertyModel->new() and SqlSupport->set_model_config() for format.

=cut

sub configure {
    my(undef, $cfg) = @_;

    $_CLASS_CFG = $cfg;
    $_SQL_SUPPORT->set_model_config($cfg);
}

=for html <a name="find"></a>

=head2 find(FindParams p) : boolean

Finds demographics given the specified search parameters. Valid parameters
are 'user'.

=cut

sub find {
    my($self, $fp) = @_;

    $self->get_status()->clear();

    if ($fp->get_value('user')) {
	$_SQL_SUPPORT->query($self, $self->internal_get_fields(),
		'where id=?', $fp->get_value('user'));
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
