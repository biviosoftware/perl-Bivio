# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmMail;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::Mail::Incoming;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-realm-mail [options] command [args..]
commands
  delete_message_id message_id ... -- Message-ID: based removal of threads/msgs
  import_rfc822 [<dir>] -- imports RFC822 files in <dir>
  import_mbox -- imports mbox input file containing
EOF
}

sub delete_message_id {
    my($self, @message_id) = @_;
    my($req) = $self->get_request;
    foreach my $id (@message_id) {
	Bivio::Biz::Model->new($req, 'RealmMail')->cascade_delete({
	    message_id => $id,
	});
    }
    return;
}

sub import_mbox {
    my($self) = @_;
    my($rm) = Bivio::Biz::Model->new($self->get_request, 'RealmMail');
    my($t) = 0;
    my($n) = 0;
    foreach my $m (split(/(?<=\n)From [^\n]+\n/, ${$self->read_input})) {
        my($die) = Bivio::Die->catch(
            sub {
                $t++;
                $rm->create_from_rfc822(\$m);
                Bivio::IO::Alert->info("imported $t");
                $n++;
            });
        Bivio::IO::Alert->info("skipped $t\n", $die, \$m)
            if $die;
        $self->commit_or_rollback
            if $t % 100 == 0;
    }
    return "Imported $n of $t Messages\n";
}

sub import_rfc822 {
    my($self, $dir) = @_;
    my($req) = $self->get_request;
    $dir ||= '.';
    my($i) = 0;
    foreach my $f (
	map($_->[0],
	    sort {$a->[1] <=> $b->[1]}
	        map(_import_rfc822_validate($self, $_), glob("$dir/*")))
    ) {
	Bivio::Biz::Model->new($req, 'RealmMail')->create_from_rfc822($f);
	$self->commit_or_rollback
	    if ++$i % 100 == 0;
    }
    return;
}

sub _import_rfc822_validate {
    my($self, $name) = @_;
    return
	unless -f $name;
    my($in) = Bivio::Mail::Incoming->new(my $d = Bivio::IO::File->read($name));
    return
	unless my $dt = $in->get_date_time;
    return
	if Bivio::Biz::Model->new($self->get_request, 'RealmMail')
	    ->unsafe_load({message_id => my $id = $in->get_message_id});
    return [$d, $dt];
}

1;
