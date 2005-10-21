# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmFile;
use strict;
use base ('Bivio::ShellUtil');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 DESCRIPTION

C<Bivio::Util::RealmFile> is an interface to administer realm files.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage string.

=cut

sub USAGE {
    return <<'EOF';
usage: b-realm-file [options] command [args...]
commands:
    import_tree root -- imports a directory/files
EOF
}

#=IMPORTS
use Bivio::Biz::Model::RealmFile;
use File::Find;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="import_tree"></a>

=head2 import_tree(string root)

Imports a directory and its files.

=cut

sub import_tree {
    my($self, $root) = @_;
    my($req) = $self->initialize_ui;
    my($foo) = [];
    find(
	sub{
	    print("$File::Find::name\n");
	    push(@$foo, $File::Find::name =~ m{^\./(.+)})
		unless -d $_;
	}, '.',
    );
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    foreach my $p (sort(@$foo)) {
	my($x, $e) = Bivio::Type::FilePath->from_literal("$root/$p");
	if ($e) {
	    $self->print($p, ": bad file path: ", $e->get_name);
	    next;
	}
	$f->create_with_content({
	    path => $self->convert_literal('FilePath', "$root/$p"),
	    creation_date_time => Bivio::Type::DateTime->from_unix(
		(stat($p))[9],
	    ),
	    volume => Bivio::Type::FileVolume->PLAIN,
	},
	Bivio::IO::File->read($p),
	);
    }
    return;
}

1;
