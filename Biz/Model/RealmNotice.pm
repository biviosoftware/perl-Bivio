# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmNotice;
use strict;
$Bivio::Biz::Model::RealmNotice::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmNotice::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmNotice - manage realm_notice_t

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmNotice;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmNotice::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmNotice> manages realm_notice_t.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time>, I<realm_id> (auth_id), and
I<at_least_role> (ACCOUNTANT)
if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{creation_date_time};
    $values->{realm_id} = $self->get_request('auth_id')
	    unless $values->{realm_id};
    $values->{at_least_role} = Bivio::Auth::Role::ACCOUNTANT()
	    unless $values->{at_least_role};
    return $self->SUPER::create($values);
}

=for html <a name="create_template"></a>

=head2 create_template(string template, hash_ref values) : Bivio::Biz::PropertyModel

Creates a TEMPLATE type notice.  I<values> may be undef.

=cut

sub create_template {
    my($self, $template, $values) = @_;
    $values ||= {};
    $values->{notice_type} = Bivio::Type::Notice::TEMPLATE();
    # Make sure the template compiles
    Bivio::UI::HTML::Widget->template($template);
    $values->{template_or_args} = $template;
    return $self->create($values);
}

=for html <a name="create_standard"></a>

=head2 create_standard(string type, array_ref args, hash_ref values) : Bivio::Biz::PropertyModel

Creates a notice of I<type>.  I<args> may be undef.  I<values> may be
undef.

=cut

sub create_standard {
    my($self, $type, $args, $values) = @_;
    $values ||= {};
    $args ||= [];
    $values->{notice_type} = Bivio::Type::Notice->from_name($type);
    $values->{template_or_args} = join($;, @$args);
    return $self->create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns configuration.

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_notice_t',
	columns => {
            realm_notice_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            at_least_role => ['Bivio::Auth::Role', 'NOT_ZERO_ENUM'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
            notice_type => ['Notice', 'NOT_NULL'],
	    template_or_args => ['LongText', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
