# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::File;
use strict;
$Bivio::Biz::Model::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::File::VERSION;

=head1 NAME

Bivio::Biz::Model::File - interface to file_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::File;
    Bivio::Biz::Model::File->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::File::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::File> is the create, read, update,
and delete interface to the C<file_t> table.

=head1 PROPERTIES

=over 4

=item aux_info

The contents vary by volume type:

=over 4

=item FILE

Contains the C<Content-Type>.  It may be null
iwc we detect the content-type (on download) from the name.
Use L<extract_mime_content_type|"extract_mime_content_type">,
don't assume this.

=item MAIL_CACHE

Contains the mime header for
the message part.  There may be a C<Content-Type:> value in
the mime header.  See
L<extract_mime_content_type|"extract_mime_content_type">.

=back

=item name_sort

This is the downcased version of I<name>. It is overwritten by
L<create|"create">.  L<delete|"delete"> ignores it as well.
Use I<name> wherever possible.  However, the uniqueness constraint
is on I<name_sort>.  We emulate Windows here: case-preserving
file names.

=back

=cut

#=IMPORTS
use Bivio::Biz::Model::FileQuota;
use Bivio::IO::Trace;
use Bivio::MIME::Type;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::FileVolume;
use Bivio::Mail::RFC822;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_MAX_SQL_PARAMS) = Bivio::SQL::Connection->MAX_PARAMETERS;
my($_NOT_TSPECIALS) = Bivio::Mail::RFC822->TSPECIALS();
$_NOT_TSPECIALS =~ s/\[/[^/;

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 static cascade_delete(Bivio::Biz::Model::RealmOwner realm)

Deletes all files and quota.

=cut

sub cascade_delete {
    my(undef, $realm) = @_;
    my($id) = $realm->get('realm_id');
    Bivio::SQL::Connection->execute('
            DELETE FROM file_t
            WHERE realm_id=?',
	    [$id]);
    my($fq) = Bivio::Biz::Model::FileQuota->new($realm->get_request);
    $fq->delete() if $fq->unauth_load(realm_id => $id);
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Initializes I<modified_date_time>, I<realm_id>, and
I<user_id>, if not set.  Always sets I<bytes>.  I<content>
may be C<undef>.

Sets I<directory_id> if not set to the value of
L<Bivio::Biz::Model::FilePathList::set_cursor_to_target|Bivio::Biz::Model::FilePathList/"set_cursor_to_target">.

Sets I<volume> if not set to the value of the
C<Bivio::Type::FileVolume> attribute on the request.

I<content> need not be supplied.

=cut

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;

    $self->throw_die("directory can't have content!")
	    if $values->{is_directory} && $values->{content};

    # create_initial sets file_id, so this check will be skipped.  Others
    # don't set file_id (we hope!).
    if (!$values->{directory_id} && !$values->{file_id}) {
	my($fpl) = $self->get_request->unsafe_get(
		'Bivio::Biz::Model::FilePathList');
	$self->throw_die('DIE', 'directory_id not set!') unless $fpl;
	$values->{directory_id} = $fpl->set_cursor_to_target;
	unless ($fpl->get('File.is_directory')) {
	    $self->throw_die('DIE', 'no directories in file path list!')
		    unless $values->{directory_id}
			    = $fpl->get('File.directory_id');
	}
    }

    $values->{modified_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{modified_date_time};
    $values->{realm_id} = $self->get_request->get('auth_id')
	    unless $values->{realm_id};
    $values->{user_id} = $self->get_request->get('auth_user')->get('realm_id')
	    unless $values->{user_id};
    $values->{bytes} = ref($values->{content})
	    ? length(${$values->{content}}) : 0;
    $values->{name_sort} = lc($values->{name});
    $values->{is_public} = 0
            unless $values->{is_public};

    _set_title_in_auxinfo($values, $values->{name_sort});

    # Set the volume from request if not set.
    $values->{volume} = $req->get('Bivio::Type::FileVolume')
	    unless $values->{volume};

    # Check quota first and ensures directory_id is really a directory
    _update_directory($self, $values, $self->to_kbytes($values->{bytes}));

    $self->SUPER::create($values);
    return;
}

=for html <a name="create_initial"></a>

=head2 static create_initial(Bivio::Biz::Model::RealmOwner realm, string user_id)

Creates the quota and initial file volumes.

Demo club gets smaller default quota. 

=cut

sub create_initial {
    my($proto, $realm, $user_id) = @_;
    my($req) = $realm->get_request;
    my($realm_id) = $realm->get('realm_id');

    # CReate the quota
    my($fq) = Bivio::Biz::Model::FileQuota->new($req);
    $fq->create({
	realm_id => $realm_id,
	max_kbytes => $realm->is_demo_club()
	? $fq->DEFAULT_MAX_KBYTES_FOR_DEMO_CLUB() : $fq->DEFAULT_MAX_KBYTES(),
    });

    # Create the volumes
    my($self) = $proto->new($req);
    foreach my $v (Bivio::Type::FileVolume->get_list()) {
	$self->create_volume($realm_id, $user_id, $v);
    }
    return;
}

=for html <a name="create_volume"></a>

=head2 create_volume(string realm_id, string user_id, Bivio::Type::FileVolume volume)

Creates a volume for this instance.  Should only be used for upgrades.  Use
L<create_initial|"create_initial"> to create all the volumes for a realm.

=cut

sub create_volume {
    my($self, $realm_id, $user_id, $volume) = @_;
    $self->create({
	file_id => $volume->get_root_directory_id($realm_id),
	realm_id => $realm_id,
	volume => $volume,
	directory_id => undef,
	name => $volume->get_name.$realm_id,
	user_id => $user_id,
	bytes => 0,
	is_directory => 1,
	aux_info => undef,
	content => undef,
    });
    return;
}

=for html <a name="delete"></a>

=head2 delete() : boolean

=head2 delete(hash load_args) : boolean

Deletes the file.  If it is a directory, deletes all files below.

This method assumes I<load_args> (if passed) contains the following
properties: I<bytes>, I<is_directory>, I<volume>,
except I<content>.

=cut

sub delete {
    my($self) = shift;
    my($args);
    if (@_) {
	my($req) = $self->get_request;
	$args = {@_};
	# Ensure data security by forcing realm_id to current auth_id
	$args->{realm_id} = $req->get('auth_id');
	$args->{volume} = $req->get('Bivio::Type::FileVolume')
	    unless $args->{volume};

	# Delete by name?
	if (defined($args->{name})
		&& !(defined($args->{file_id}) && defined($args->{bytes}))) {
	    # Get the name from FilePathList?
	    unless ($args->{directory_id}) {
		my($fpl) = $self->get_request->unsafe_get(
			'Bivio::Biz::Model::FilePathList');
		$self->throw_die('DIE', 'directory_id not set!') unless $fpl;
		$args->{directory_id} = $fpl->set_cursor_to_target;
	    }

	    # Try to find the bytes and file_id
	    my($statement) = Bivio::SQL::Connection->execute(<<'EOF',
	    	SELECT file_id, bytes
		FROM file_t
		WHERE realm_id = ?
                AND volume = ?
                AND directory_id = ?
                AND name_sort = ?
EOF
		    [$args->{realm_id}, $args->{volume}->as_sql_param,
			$args->{directory_id}, lc($args->{name})]);

	    # Process result
	    my($row) = $statement->fetchrow_arrayref();
	    unless ($row) {
		# NOT_FOUND means deleted
		_trace('ignoring, not found: ', $args) if $_TRACE;
                return 0;
	    }
	    $args->{file_id} = $row->[0];
	    $args->{bytes} = $row->[1];
	}
        elsif (!(defined($args->{bytes}) && defined($args->{is_directory}))) {
	    Carp::croak('file_id: missing from load_args')
			unless defined($args->{file_id});
	    # Lookup missing bytes and/or is_directory attributes
	    my($statement) = Bivio::SQL::Connection->execute(<<'EOF',
	    	SELECT bytes, is_directory
		FROM file_t
		WHERE realm_id = ?
                AND volume = ?
                AND file_id = ?
EOF
		    [$args->{realm_id}, $args->{volume}->as_sql_param,
			$args->{file_id}]);
	    # Process result
	    my($row) = $statement->fetchrow_arrayref();
	    unless ($row) {
		# NOT_FOUND means deleted
		_trace('ignoring, not found: ', $args) if $_TRACE;
                return 0;
	    }
	    $args->{bytes} = $row->[0];
	    $args->{is_directory} = $row->[1];
        }
	foreach my $p (qw(is_directory file_id bytes)) {
	    Carp::croak("$p: missing from load_args on File::delete")
			unless defined($args->{$p});
	}
    }
    else {
        # Make a copy, because we modify further down
	$args = {%{$self->internal_get}};
    }

    # Can't delete the root
    $self->throw_die('NOT_FOUND', {message => 'attempt to delete file root',
	volume => $args->{volume}->get_name,
	file_id => $args->{file_id}})
	    if $args->{file_id} eq $args->{volume}->get_root_directory_id(
		    $args->{realm_id});

    my(@files) = ();
    my($kbytes) = 0;
    if ($args->{is_directory}) {
	# Find all the files that are children of this node
	# in depth-first order.
	my($statement) = Bivio::SQL::Connection->execute(<<'EOF',
	    	SELECT file_id, bytes
		FROM file_t
		START WITH file_id = ?
                    AND realm_id = ?
                    AND volume = ?
		CONNECT BY realm_id = ?
                    AND volume = ?
                    AND directory_id = PRIOR file_id
		ORDER BY LEVEL DESC
EOF
		[$args->{file_id}, $args->{realm_id},
                    $args->{volume}->as_sql_param, $args->{realm_id},
                    $args->{volume}->as_sql_param]);

	# Add in the files which this directory contains
	my($row);
	while ($row = $statement->fetchrow_arrayref()) {
	    push(@files, $row->[0]);
	    $kbytes += $self->to_kbytes($row->[1]);
	}
    }
    else {
	# Not a directory
	push(@files, $args->{file_id});
	$kbytes = $self->to_kbytes($args->{bytes});
    }

    # Delete the rows we just found.  Apparently you can't call
    # DELETE with a CONNECT BY.  Don't ask me why, I suppose she'll die. ;-)
#TODO: Move this into SQL::Connection.  Should be able to iterate over a list
    my($rows) = 0;
    while (@files) {
	my($params) = '?,' x (int(@files) > $_MAX_SQL_PARAMS
		? $_MAX_SQL_PARAMS : int(@files));
	chop($params);
	# We set volume here in case there is something really weird going on,
	# i.e. parallel deletes.
	my($sth) = Bivio::SQL::Connection->execute(<<"EOF",
	    DELETE
	    FROM file_t
	    WHERE realm_id = ?
            AND volume = ?
            AND file_id in ($params)
EOF
		[$args->{realm_id},
		    $args->{volume}->as_sql_param(),
		    splice(@files, 0, $_MAX_SQL_PARAMS)]);
	$rows += $sth->rows;
    }

    # Update the directory with the correct uid and modified_date_time.
    $args->{user_id}
	    = $self->get_request->get('auth_user')->get('realm_id');
    $args->{modified_date_time} = Bivio::Type::DateTime->now();
    _update_directory($self, $args, -$kbytes);
    return $rows ? 1 : 0;
}

=for html <a name="delete_all_in_volume"></a>

=head2 delete_all_in_volume(Bivio::Biz::Model::RealmOwner realm, Bivio::Type::FileVolume volume)

Deletes all the files in the volume except the root directory.

=cut

sub delete_all_in_volume {
    my($self, $realm, $volume) = @_;
    my($id) = $realm->get('realm_id');
    Bivio::SQL::Connection->execute('
            DELETE FROM file_t
            WHERE realm_id=?
            AND volume = ?
            AND file_id != ?',
	    [$id, $volume->as_sql_param,
		$volume->get_root_directory_id($id)]);
    return;
}

=for html <a name="extract_mime_content_id"></a>

=head2 extract_mime_content_id() : 

Treats aux_info field as a MIME header to find the content id.
Returns undef if not available.

=cut

sub extract_mime_content_id {
    my($self, $list_model, $model_prefix) = @_;
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    my($aux_info) = $m->get($p.'aux_info');

    return $1 if defined($aux_info)
	    && $aux_info =~ /content-id:\s+<?([^;\s>]+)>?/i;
    return undef;
}

=for html <a name="extract_mime_content_type"></a>

=head2 extract_mime_content_type() : string

=head2 static extract_mime_content_type(Bivio::Biz::ListModel list_model, string model_prefix) : string

=head2 static extract_mime_content_type(string_ref aux_info) : string

Treats aux_info field as a MIME header to find the content type.
Returns first occurence or looks up type via filename extension.

=cut

sub extract_mime_content_type {
    my($self, $list_model, $model_prefix) = @_;
    my($aux_info) = _get_aux_info_from_param(@_);

    if ($aux_info) {
#TODO: Deprecated case where the aux_info is just the content type
	return $aux_info
		if $aux_info =~ /^$_NOT_TSPECIALS+\/$_NOT_TSPECIALS+/oi;

	# Normal content type
	return lc($1)
		if $aux_info =~ /content-type:\s+([^;\s]+)/i;

	# Extract content type from the mime filename.  MIME::Type always
	# returns a valid content type.
	my($fn) = _extract_mime_filename($aux_info);
	return Bivio::MIME::Type->from_extension($fn) if defined($fn);
    }

    # Map file name, if possible.  If aux_info scalar, just default.
    my($fn) = '';
    unless (ref($list_model) eq 'SCALAR') {
	my($p) = $model_prefix || '';
	my($m) = $list_model || $self;
	$fn= $m->get($p.'name');
    }
    # MIME::Type always returns a valid type.
    return Bivio::MIME::Type->from_extension($fn);
}

=for html <a name="extract_mime_filename"></a>

=head2 extract_mime_filename() : string

=head2 static extract_mime_filename(Bivio::Biz::ListModel list_model, string model_prefix) : string

Treats aux_info field as a MIME header to find the (file)name specified.
Strips a leading path. Returns first occurence if found. If not, it
will create a name "download.<ext>" where <ext> matches the content-type.

Sample "aux_info" entries:

Content-Disposition: inline; filename="/tmp/nsmail38B49DB928B0262.jpeg"
Content-Disposition: inline;
 filename="ms_y2k.jpg"
Content-Type: image/gif;
        name="bivio_large.gif"
Content-Disposition: inline; filename="C:\windows\TEMP\nsmailQT.gif"

In the second form, I<list_model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub extract_mime_filename {
	my($self) = shift;
	Bivio::Biz::Model::File->extract_mime_filename($self, 'File.', @_);
    }

=cut

sub extract_mime_filename {
    my($self, $list_model, $model_prefix) = @_;
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    my($aux_info) = $m->get($p.'aux_info');
    my($fn) = _extract_mime_filename($aux_info);
    return $fn if defined($fn);

    # Create a name based on the Content-Type based file suffix
    # Use 'download.bin' in case the file type is unknown
    my($ct) = $self->extract_mime_content_type($list_model, $model_prefix);
    return 'download.bin' unless defined($ct);
    my($ext) = Bivio::MIME::Type->to_extension($ct);
    return 'download.'.(defined($ext) ? $ext : 'bin');
}

=for html <a name="extract_mime_title"></a>

=head2 extract_mime_title() : string

=head2 static extract_mime_title(Bivio::Biz::ListModel list_model, string model_prefix) : string

=head2 static extract_mime_title(string_ref aux_info) : string

Finds "Title:" tag in aux_info treated as a MIME header.
Returns the empty string if no title.

=cut

sub extract_mime_title {
    my($aux_info) = _get_aux_info_from_param(@_);
    return '' unless defined($aux_info)
	    && $aux_info =~ /title:\s*([^\n]+)/i;
    my($title) = $1;
    # unescape (loosely)
    $title =~ s/\\(.)/$1/g if $title =~ s/^"|"$//g;
    return $title;
}

=for html <a name="fixup_root_directory_name"></a>

=head2 static fixup_root_directory_name(hash_ref properties, Bivio::Agent::Request req)

Changes I<File.name> in properties to appropriate name.

Needed because the root dir name must be globally unique.

=cut

sub fixup_root_directory_name {
    my(undef, $properties, $req) = @_;
#TODO: Hack....
    my($volume) = $req->get('Bivio::Type::FileVolume');
    $properties->{'File.name_sort'}
	    = lc($properties->{'File.name'} = $volume->get_short_desc);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'file_t',
	columns => {
            file_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            volume => ['FileVolume', 'NOT_ZERO_ENUM'],
            directory_id => ['PrimaryId', 'NONE'],
            name => ['FileName', 'NOT_NULL'],
            name_sort => ['FileName', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
            bytes => ['Integer', 'NOT_NULL'],
            is_directory => ['Boolean', 'NOT_NULL'],
            is_public => ['Boolean', 'NOT_NULL'],
            aux_info => ['LongText', 'NONE'],
            content => ['BLOB', 'NONE'],
        },
	auth_id => [qw(realm_id)],
    };
}

=for html <a name="to_kbytes"></a>

=head2 static to_kbytes(int bytes) : int

Returns kbytes for bytes.  We round up from the smallest kb.
Must be synchronized with the value in Format::Bytes.

=cut

sub to_kbytes {
    my(undef, $bytes) = @_;
    my($kb) = int(($bytes + 1023)/1024);
    # Mininum of 1kb per file in quota.
    return $kb ? $kb : 1;
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Can update everything except I<is_directory>, I<bytes>,
and I<volume>.

Automatically sets I<bytes> and I<name_sort>.

If you are setting I<content>, you should also set I<aux_info>.

=cut

sub update {
    my($self, $new_values, $in_update_directory) = @_;
    Bivio::IO::Alert->warn_deprecated("don't pass second arg")
		if $in_update_directory;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
    $new_values->{modified_date_time} = Bivio::Type::DateTime->now()
	    unless $new_values->{modified_date_time};
    $new_values->{user_id} = $req->get('auth_user')->get('realm_id')
	    unless $new_values->{user_id};
    foreach my $k (qw(bytes is_directory volume name_sort)) {
	$self->throw_die('DIE', "can't set $k in update")
		if exists($new_values->{$k});
    }

    $new_values->{name_sort} = lc($new_values->{name})
	    if exists($new_values->{name});

    my($bytes);
    if (exists($new_values->{content})) {
	my($c) = $new_values->{content};
	$new_values->{bytes} = ref($c) ? length($$c) : 0;
	$bytes = $new_values->{bytes} - $properties->{bytes};
	_set_title_in_auxinfo($new_values,
		defined($new_values->{name_sort}) ? $new_values->{name_sort}
		: $properties->{name_sort});
    }
    $self->SUPER::update($new_values);
    _update_quota($self, $self->internal_get, $self->to_kbytes($bytes))
	    if $bytes;
    return;
}

#=PRIVATE METHODS

# _extract_mime_filename(string aux_info) : string
#
# Returns the filename or name attribute from aux_info.
#
sub _extract_mime_filename {
    my($aux_info) = @_;
    return undef
	    unless defined($aux_info) && $aux_info =~ /(file|)name="([^"]+)"/;
    my($name) = $2;
    $name = Bivio::Type::FileName->get_tail($name);
    return $name;
}

# _get_aux_info_from_param(Bivio::Biz::Model::File self) : string
# _get_aux_info_from_param(undef, Bivio::Biz::ListModel list_model, string model_prefix) : string
# extract_mime_content_type(undef, string_ref aux_info) : string
#
# Extract aux_info from a file or string_ref.
#
sub _get_aux_info_from_param {
    my($self, $list_model, $model_prefix) = @_;
    # Make a copy just in case
    return $$list_model if ref($list_model) eq 'SCALAR';
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    return $m->get($p.'aux_info');
}

# _set_title_in_auxinfo(hash_ref new_values, string name)
#
# We extract the title from the document and append it to aux_info.
# Must be called after bytes is is set.
#
sub _set_title_in_auxinfo {
    my($values, $name) = @_;

    # Only handle text/html right now.
    my($i) = $values->{aux_info} || '';
    return unless $values->{bytes} && $i !~ /title:/i;

    # Optimistic checking
    return unless extract_mime_content_type(undef, \$i) eq 'text/html'
	    || Bivio::MIME::Type->from_extension($name) eq 'text/html';

    # Look in the first few bytes
    my($t) = substr(${$values->{content}}, 0, 10000)
	    =~ /<title>\s*(.+)\s*<\/title>/is;
    return unless defined($t) && length($t);
    $t = Bivio::HTML->unescape($t);
    # Get rid of any special space chars and escape quoted literal
    $t =~ s/\s+/ /g;
    $t =~ s/(["\\])/\\$1/g;

    # Append the title to aux_info
    $i =~ s/\s+$/\n/;
    $i .= "Title: \"".$t.'"';

    # just in case, truncate.  Doesn't matter if it is in the middle
    # of the word--well almost, but LongText is very long.
    $values->{aux_info} = substr($i, 0, Bivio::Type::LongText->get_width());
    return;
}

# _update_directory(Bivio::Biz::Model::File self, hash_ref properties, int kbytes)
#
# Adjusts FileQuota if necessary.  Updates the modified_date_time
# and user_id for directory from the properties.
#
sub _update_directory {
    my($self, $properties, $kbytes) = @_;
    my($req) = $self->get_request;

    if (defined($properties->{directory_id})) {
	my($dir) = $self->new($req);
	# Must be a directory, blows up with NOT_FOUND
	$dir->load(file_id => $properties->{directory_id},
		volume => $properties->{volume},
		is_directory => 1);
	$dir->update({modified_date_time => $properties->{modified_date_time},
	    user_id => $properties->{user_id}});
    }
    _update_quota($self, $properties, $kbytes)
	    if $kbytes && $properties->{volume}->in_quota;

    return;
}

# _update_directory(Bivio::Biz::Model::File self, hash_ref properties, int kbytes)
#
# Adjusts FileQuota if necessary.  Updates the modified_date_time
# and user_id for directory from the properties.
#
sub _update_quota {
    my($self, $properties, $kbytes) = @_;
    Bivio::Biz::Model::FileQuota->get_current_or_load(
	    $self->get_request, $properties->{realm_id})
		->adjust_kbytes($kbytes);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

