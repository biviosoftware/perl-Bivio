# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');

sub ROOT_FOLDER {
    return '/Wiki';
}

sub execute_empty {
    my($self) = @_;
    return unless _is_edit($self);
    $self->internal_put_field(
	'RealmFile.path_lc' => _name($self),
    );
    my($rf) = $self->new_other('RealmFile');
    return unless $rf->unsafe_load({path => _curr_path($self)});
    $self->internal_put_field(content => ${$rf->get_content});
    return;
}

sub execute_ok {
    my($self) = @_;
    my($new) = $_WN->absolute_path($self->get('RealmFile.path_lc'));
    my($c) = $self->get('content');
    my($rf) = $self->new_other('RealmFile');
    my($m) = _is_edit($self) && $rf->unsafe_load({path => _curr_path($self)})
	? 'update_with_content' : 'create_with_content';
    $rf->$m({path => $new}, \$c);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'content',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	    {
		# This is where the constraint is
		name => 'RealmFile.path_lc',
		type => 'WikiName',
	    },
	],
    });
}

sub _curr_path {
    my($self) = @_;
    return $_WN->absolute_path(_name($self));
}

sub _is_edit {
    return shift->get_request->unsafe_get('path_info') ? 1 : 0;
}

sub _name {
    return $_WN->from_literal_or_die(shift->get_request->get('path_info') =~ m{^/*(.+)});
}

1;
