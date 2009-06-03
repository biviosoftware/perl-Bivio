# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPStats;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IOC) = b_use('IO.Config');
my($_C) = b_use('SQL.Connection');
my($_D) = b_use('Type.Date');
my($_F) = b_use('IO.File');
my($_FN) = b_use('Type.ForumName');
my($_SF) = b_use('ShellUtil.SiteForum');
my($_UIF) = b_use('UI.Facade');
my($_AWSTATS) = '/usr/local/awstats/wwwroot/cgi-bin/awstats.pl';
my($_BUILD_PAGES) = '/usr/local/awstats/tools/awstats_buildstaticpages.pl';
my($_LOG_MERGER) = '/usr/local/awstats/tools/logresolvemerge.pl';
my($_ICON_DIR) = '/usr/local/awstats/wwwroot/icon/';
b_use('IO.Config')->register(my $_CFG = {
    log_base => '/var/log',
});

sub USAGE {
    my($proto) = @_;
    return <<"EOF";
usage: bivio @{[$proto->simple_package_name]} [options] command [args..]
commands
    daily_report [date] -- create a report using the most recent access_log
    format_access_log_stream -- read stream from STDIN reformat to STDOUT
    import_history [date] -- import multiple access_logs
    init_forum name -- create report forum and import icons
EOF
}

sub daily_report {
    my($self, $date) = _parse_args(@_);
    _create_report($self, $date,
	"gunzip -c @{[$_CFG->{log_base}]}/<uri>/"
	. _previous_days_log($self));
    return;
}

sub format_access_log_stream {
    my($self) = @_;

    while (defined(my $line = <STDIN>)) {
	# remove li-, lo- user_id prefix
	$line =~ s/( \- )l.\-(\d+)/$1$2/;
	# remove su- prefix and target user
	$line =~ s/ su-(\d+)-..-\d+/ $1/;
	# add 0 process id if not present (older log files)
	$line =~ s/(\d+\.\d+\.\d+\.\d+) \-/$1 0 -/;
	print($line);
    }
    return;
}


sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub import_history {
    my($self, $date) = _parse_args(@_);
    # only works if the cached awstats after date have been deleted
    _create_report($self, $date,
	"$_LOG_MERGER @{[$_CFG->{log_base}]}/<uri>/*-access_log.gz");
    return;
}

sub init_forum {
    my($self, $name) = shift->name_args([qw(ForumName)], \@_);
    $self->assert_have_user;
    $self->usage_error($name, ': may not be top-level forum')
	if $_FN->is_top($name);
    my(@parts) = $_FN->split($name);
    pop(@parts);
    $self->initialize_fully->with_realm($_FN->join(@parts), sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Web Site Reports',
	   'RealmOwner.name' => $name,
	});
        $_F->do_in_dir($_ICON_DIR, sub {
            $self->new_other('RealmFile')->import_tree('icon');
	}) if -d $_ICON_DIR;
	return;
    });
    return;
}

sub _create_report {
    my($self, $date, $file_command) = @_;
    my($root) = $_UIF->get_default->get('local_file_prefix');
    $file_command =~ s/<uri>/$root/
	|| b_die('invalid file command: ', $file_command);
    my($static_config) = $self->internal_data_section;
    my($data_dir) = $_F->mkdir_p($self->use('IO.Log')
	->file_name('HTTPStats/data', $self->req));
    $_F->do_in_dir($data_dir, sub {
	$_F->write('userinfo.txt', _user_email($self));
    });

    foreach my $domain_info (@{_get_domains_from_most_recent_log($self, $root)}) {
	my($domain, $forum_name) = @$domain_info;
	$self->print("creating report for $domain in $forum_name\n");
	$self->req->set_realm_and_user($forum_name);
	my($tmp_dir) = $_F->mkdir_p($_F->temp_file);
	$_F->do_in_dir($tmp_dir, sub {
	    my($conf_file) = join('.', 'awstats', $domain, 'conf');
	    my($month, $year) = $_D->get_parts($date, qw(month year));
	    my($str) = $static_config . <<"EOF";
HostAliases="$domain"
SiteDomain="$domain"
LogFile="$file_command | bivio HTTPStats format_access_log_stream |"
DirData="$data_dir"
EOF
	    _trace($str) if $_TRACE;
	    $_F->write($conf_file, $str);
	    `$_AWSTATS -config=$domain --configdir=.`;
	    `$_BUILD_PAGES -config=$domain --configdir=. -lang=en -dir . -diricons="icon" -month=$month -year=$year`;
	    unlink($conf_file);
	    _organize_files($self, $domain, $date);
	    $self->new_other('RealmFile')->import_tree('/');
	});
	$_F->rm_rf($tmp_dir);
    }
    return;
}

sub _get_domains_from_most_recent_log {
    my($self, $root) = @_;
    my($facade_info) = {
	map({
	    my($facade) = $_;
	    ($facade->get('http_host') => {
		map(($_ => $facade->get($_)), qw(uri is_default)),
		facade => $facade,
	    });
	} (map($_UIF->get_instance($_), @{$_UIF->get_all_classes}))),
    };

    my($domains) = [];
    my($prev_log) = _previous_days_log($self);
    foreach my $domain (`gunzip -c @{[$_CFG->{log_base}]}/@{[$root]}/$prev_log | grep -o -P '^(\\S+)' | sort -u`) {
	chomp($domain);
	next
	    unless $domain =~ /\./;
	my($facade) = $facade_info->{$domain};
	foreach my $name (
	    $facade ? $facade->{facade}->REPORTS_REALM : (),
	) {
	    next
		unless _is_forum($self, $name);
	    push(@$domains, [$domain, $name]);
	    last;
	}
    }
    b_warn('no forums found for domains')
	unless @$domains;
    return $domains;
}

sub _is_forum {
    my($self, $name) = @_;
    my($err);
    ($name, $err) = $_FN->from_literal($name);
    return $name && $self->model('RealmOwner')->unauth_load({
	name => $name,
	realm_type => $self->use('Auth.RealmType')->FORUM,
    }) ? 1 : 0;
}

sub _organize_files {
    my($self, $domain, $date) = @_;
    # main report: <yyyymmdd.html>
    # sub reports: detail/yyyymmdd/<name>.html
    my($d) = $_D->to_file_name($date);
    $_F->mkdir_p('detail/' . $d);

    foreach my $file (<*.html>) {
	$file =~ /^awstats\.\Q$domain\E(\.)?(.*)\.html$/
	    || b_die('unexpected file name: ', $file);
	my($name) = $2;
	my($buf) = $_F->read($file);

	if ($name) {
	    $$buf =~ s,(icon/),../../$1,g;
	    $_F->write('detail/' . $d . '/' . $name . '.html', $buf);
	}
	else {
	    $$buf =~ s,awstats\.\Q$domain\E\.(\w+)\.html,detail/$d/$1.html,g;
	    $_F->write($d . '.html', $buf);
	}
	unlink($file);
    }
    return;
}

sub _parse_args {
    my($self, $date) = @_;
    $_IOC->assert_version(3);
    $self->initialize_fully;
    return ($self, $date
	? $_D->from_literal_or_die($date)
	: $_D->set_end_of_month($_D->add_days($_D->local_today, -1)));
}

sub _previous_days_log {
    my($self) = @_;
    return $_D->to_file_name($_D->add_days($_D->local_today, -1))
	. '*-access_log.gz';
}

sub _user_email {
    my($self) = @_;
    my($res) = '';
    $_C->do_execute(sub {
        my($row) = @_;
	$res .= join("\t", @$row) . "\n";
    }, <<'EOF', [$self->use('Type.Location')->get_default->as_sql_param]);
        SELECT realm_id, email
	FROM email_t
	WHERE location = ?
	ORDER BY realm_id
EOF
    return \$res;
}

1;

__DATA__
LogFormat="%virtualname %host %other - %logname %time1 %methodurl %code %bytesd %refererquot %uaquot"
LoadPlugin="userinfo"
DNSLookup=1
LoadPlugin="hashfiles"
ShowDomainsStats=PHB
ShowHostsStats=PHBL
ShowAuthenticatedUsers=PHBL
ShowRobotsStats=0
ShowPagesStats=PBEX
ShowOSStats=1
ShowBrowsersStats=1
ShowOriginStats=PH
ShowKeyphrasesStats=1
ShowKeywordsStats=1
ShowMiscStats=0
ShowHTTPErrorsStats=1
SkipUserAgents="REGEX[.*libwww-perl.*]"
SkipFiles="REGEX[^/_]"
