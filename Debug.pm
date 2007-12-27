# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Debug;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Exporter qw(import);
our @EXPORT = qw(pprint class model unauth_model);

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($self) = __PACKAGE__->new();
init();
sub init {
    # TODO: refactor this with Bivio::ShellUtil::_setup_for_main
    my($fields) = $self->[$_IDI];
    my($db, $user, $realm) = $self->unsafe_get(qw(db user realm));
    $self->use('Bivio::Test::Request');
    my($p) = $self->use('Bivio::SQL::Connection')->set_dbi_name($db);
    $fields->{prior_db} = $p unless $fields->{prior_db};
    $self->put_request($self->use('Bivio::Test::Request')->get_instance)
        unless $self->unsafe_get('req');
}

sub pprint {
    my($ref, $depth) = @_;
    print ${$self->use('Bivio::IO::Ref')->to_string($ref, $depth || 3)};
}

sub class {return $self->use(@_);}
sub model {return $self->SUPER::model(@_);}
sub unauth_model {return $self->SUPER::unauth_model(@_);}

1;
