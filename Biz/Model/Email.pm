# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Email;
use strict;
$Bivio::Biz::Model::Email::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Email::VERSION;

=head1 NAME

Bivio::Biz::Model::Email - interface to email_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::Email;
    Bivio::Biz::Model::Email->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::LocationBase>

=cut

use Bivio::Biz::Model::LocationBase;
@Bivio::Biz::Model::Email::ISA = qw(Bivio::Biz::Model::LocationBase);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Email> is the create, read, update,
and delete interface to the C<email_t> table.

=cut

#=IMPORTS
use Bivio::Type::Email;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<want_bulletin> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{want_bulletin} = 1
	    unless defined($values->{want_bulletin});
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 2,
	table_name => 'email_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            email => ['Email', 'NOT_NULL_UNIQUE'],
	    want_bulletin => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="is_ignore"></a>

=head2 is_ignore() : boolean

=head2 static is_ignore(Bivio::Biz::Model model, string model_prefix) : boolean

Calls L<Bivio::Type::Email::is_ignore|Bivio::Type::Email/"is_ignore">
on the email address.

=cut

sub is_ignore {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return Bivio::Type::Email->is_ignore($model->get($model_prefix.'email'));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
