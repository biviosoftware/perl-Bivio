# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmDecor;
use strict;

$Bivio::Biz::Model::RealmDecor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmDecor::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmDecor - realm page decoration properties

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmDecor;
    Bivio::Biz::Model::RealmDecor->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmDecor::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmDecor> holds information about the realm page
decoration.

=cut


=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Model::File;
use Image::Size ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="get_portrait"></a>

=head2 get_portrait() : hash_ref

Returns the profile portrait suitable for an Image widget
HACK: Returns HTML IMG code directly

=cut

sub get_portrait {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
#TODO: Needs to recache size whenever image changes
    unless ($properties->{portrait_filename} && $properties->{portrait_width}) {
        _cache_portrait_size($self, $req)
                if $properties->{portrait_filename};
        return ''
                unless $properties->{portrait_width};
    }

    my($portrait_uri) = $req->format_uri(
            Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_FILE_READ(),
            undef, undef, '/'.$properties->{portrait_filename});
    return '<IMG src="'.$portrait_uri.'" width='.$properties->{portrait_width}
            .' height='.$properties->{portrait_height}.' border=0 alt="'.
                    $properties->{profile_title}.'">';
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_decor_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            show_all_columns => ['Boolean', 'NOT_NULL'],
            show_disclaimer => ['Boolean', 'NOT_NULL'],
            show_profile => ['Boolean', 'NOT_NULL'],
            disclaimer => ['LongText', 'NONE'],
            profile_title => ['Line', 'NONE'],
            profile_bio => ['LongText', 'NONE'],
            portrait_filename => ['FileName', 'NONE'],
            portrait_width => ['Integer', 'NONE'],
            portrait_height => ['Integer', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

# _cache_portrait_size(Bivio::Agent::Request req) : boolean
#
# Find realm's portrait and cache its size
#
sub _cache_portrait_size {
    my($self, $req) = @_;
    my($properties) = $self->internal_get;

    my($fv) = Bivio::Type::FileVolume::FILE();
    my($root_dir_id) = $fv->get_root_directory_id($req->get('auth_id'));
    my($portrait) = Bivio::Biz::Model::File->new;
    unless ($portrait->unsafe_load(
            name => $properties->{portrait_filename},
            directory_id => $root_dir_id,
           )) {
        Bivio::IO::Alert->warn($properties->{portrait_filename},
                ': not found');
        return 0;
    }
    my($width, $height, $e) = Image::Size::imgsize($portrait->get('content'));
    unless (defined($width)) {
        Bivio::IO::Alert->warn($properties->{portrait_filename},
                ':Image::Size error: ', $e);
        return 0;
    }
    $self->update({
        portrait_width => $width,
        portrait_height => $height,
    });
    return 1;
}


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
