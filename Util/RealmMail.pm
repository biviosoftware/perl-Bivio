# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmMail;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::Mail::Incoming;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FCT) = __PACKAGE__->use('FacadeComponent.Text');
my($_F) = __PACKAGE__->use('FacadeComponent.Facade');
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_IOF) = __PACKAGE__->use('IO.File');
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_E) = __PACKAGE__->use('Type.Email');

sub USAGE {
    return <<'EOF';
usage: b-realm-mail [options] command [args..]
commands
  delete_message_id message_id ... -- Message-ID: based removal of threads/msgs
  import_rfc822 [<dir>] -- imports RFC822 files in <dir>
  import_mbox -- imports mbox input file containing
  import_bulletins -- imports old Bulletins into forum mail files
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

sub import_bulletins {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    my($rm) = $self->use('Model.RealmMail')->new($req);
    my($t) = 0;
    my($n) = 0;
    $self->model('Bulletin')->do_iterate(
        sub {
            my($b) = @_;
            my($msg) = $_O->new;
            $msg->set_header(Subject => $b->get('subject'));
            $msg->set_header(Date => $_DT->rfc822($b->get('date_time')));
            my($email) = $_FCT->get_value('support_email', $req);
            $email = $_E->is_valid($email)
                ? $email
                : $_E->join_parts($email, $_F->get_value('mail_host', $req));
            $msg->add_missing_headers($req, $email);
            if ($b->has_attachments) {
                $msg->set_content_type('multipart/mixed');
                $msg->attach(\($b->get('body')), $b->get('body_content_type'));
                foreach my $fullname (@{$b->get_attachment_file_names}) {
                    $msg->attach($_IOF->read($fullname),
                                 $self->use('Model.RealmFile')
                                     ->get_content_type_for_path($fullname),
                                 $_FP->get_tail($fullname));
                }
            }
            else {
                $msg->set_body($b->get('body'));
                $msg->set_content_type($b->get('body_content_type'));
            }
            _create_from_rfc822($self, $rm, $msg->as_string, \$t, \$n);
            return 1;
        },
        'unauth_iterate_start',
        {},
    );
    return "Imported $n of $t Messages\n";
}

sub import_mbox {
    my($self) = @_;
    my($rm) = Bivio::Biz::Model->new($self->get_request, 'RealmMail');
    my($t) = 0;
    my($n) = 0;
    foreach my $m (split(/(?<=\n)From [^\n]+\n/, ${$self->read_input})) {
        _create_from_rfc822($self, $rm, $m, \$t, \$n);
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
	    sort {$_DT->compare($a->[1], $b->[1])}
	        map(_import_rfc822_validate($self, $_), glob("$dir/*")))
    ) {
	Bivio::Biz::Model->new($req, 'RealmMail')->create_from_rfc822($f);
	$self->commit_or_rollback
	    if ++$i % 100 == 0;
    }
    return;
}

sub _create_from_rfc822 {
    my($self, $rm, $m, $t, $n) = @_;
    my($die) = Bivio::Die->catch(
        sub {
            $$t++;
            $rm->create_from_rfc822(\$m);
            Bivio::IO::Alert->info("imported $$t");
            $$n++;
        });
    Bivio::IO::Alert->info("skipped $$t\n", $die, \$m)
            if $die;
    $self->commit_or_rollback;
    return;
}

sub _import_rfc822_validate {
    my($self, $name) = @_;
    return
	unless -f $name;
    my($in) = Bivio::Mail::Incoming->new(my $d = Bivio::IO::File->read($name));
    return
	if Bivio::Biz::Model->new($self->get_request, 'RealmMail')
	    ->unsafe_load({message_id => my $id = $in->get_message_id});
    return [$d, $in->get_date_time];
}

1;
