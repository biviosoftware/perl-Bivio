# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmMail;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FCT) = b_use('FacadeComponent.Text');
my($_F) = b_use('FacadeComponent.Facade');
my($_O) = b_use('Mail.Outgoing');
my($_IOF) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Email');
my($_I) = b_use('Mail.Incoming');
my($_C) = b_use('SQL.Connection');

sub USAGE {
    return <<'EOF';
usage: b-realm-mail [options] command [args..]
commands
  anonymize_emails -- anonymize emails in the database
  audit_threads -- reconnect thread_root_id and thread_parent_id
  audit_threads_all_realms -- audit_threads for all realms with mail
  delete_message_id message_id ... -- Message-ID: based removal of threads/msgs
  import_rfc822 [<dir>] -- imports RFC822 files in <dir>
  import_mbox -- imports mbox input file
  import_bulletins -- imports old Bulletins into forum mail files
  toggle_is_public_for_all -- toggles is_public for all emails
EOF
}

sub anonymize_emails {
    my($self) = @_;
    $self->req->assert_test;
    $self->initialize_ui;
    my($prefix) = b_use('Type.Email')->INVALID_PREFIX;
    my($length) = b_use('Type.Email')->get_width - 1;
    foreach my $x (
	[qw(email_alias_t outgoing)],
	[qw(nonunique_email_t email)],
	[qw(realm_mail_bounce_t email)],
	[qw(realm_mail_t from_email)],
        [qw(email_t email)],
    ) {
	my($table, $field) = @$x;
        $_C->execute(<<"EOF", [$prefix . '%']);
            UPDATE $table
            SET $field = SUBSTR('$prefix' || $field, 1, $length)
            WHERE $field NOT LIKE ?
EOF
    }
    return;
}

sub audit_threads {
    my($self) = @_;
    $self->model('RealmMail')->audit_threads;
    return;
}

sub audit_threads_all_realms {
    my($self) = @_;
    $self->print("auditing mail threads\n");
    my($realms) = {
	@{$_C->map_execute(
	    sub {shift->[0] => 1},
	    <<'EOF',
		SELECT DISTINCT(name)
		FROM realm_mail_t, realm_owner_t
		WHERE realm_mail_t.realm_id = realm_owner_t.realm_id
		ORDER BY name ASC
EOF
	)},
    };
    foreach my $realm (sort(keys(%$realms))) {
	my($die) = b_catch(
	    sub {
		$self->req
		    ->with_realm(
			$realm,
			sub {
			    $self->print("$realm\n");
			    $self->audit_threads;
			    return;
			},
		    );
	    },
	);
	$self->commit_or_rollback($die);
    }
    return;
}

sub delete_message_id {
    my($self, @message_id) = @_;
    my($req) = $self->get_request;
    foreach my $id (@message_id) {
	$self->model('RealmMail')->cascade_delete({
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
    my($rm) = $self->model('RealmMail');
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
	$self->model('RealmMail')->create_from_rfc822($f);
	$self->commit_or_rollback
	    if ++$i % 100 == 0;
    }
    return;
}

sub toggle_is_public_for_all {
    my($self) = @_;
    $self->model('RealmMailList')
	->do_iterate(
	    sub {
		my($rf) = shift->get_model('RealmFile');
		$rf->toggle_is_public;
		return 1;
	    },
	);
}

sub _create_from_rfc822 {
    my($self, $rm, $m, $t, $n) = @_;
    my($die) = Bivio::Die->catch(
        sub {
            $$t++;
            $rm->create_from_rfc822(\$m);
            b_info("imported $$t");
            $$n++;
        });
    b_info("skipped $$t\n", $die, \$m)
            if $die;
    $self->commit_or_rollback;
    return;
}

sub _import_rfc822_validate {
    my($self, $name) = @_;
    return
	unless -f $name;
    my($in) = $_I->new(my $d = $_IOF->read($name));
    return
	if $self->model('RealmMail')
	    ->unsafe_load({message_id => my $id = $in->get_message_id});
    return [$d, $in->get_date_time];
}

1;
