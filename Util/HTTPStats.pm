# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPStats;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

b_use('IO.Trace');
our($AUTOLOAD);
our($_TRACE);
my($_C) = b_use('SQL.Connection');
my($_D) = b_use('Type.Date');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_FN) = b_use('Type.ForumName');
my($_UIF) = b_use('UI.Facade');
my($_ACCESS_LOG_GLOB) = '*-access_log.gz';
my($_AWSTATS) = '/usr/local/awstats';
my($_AWSTATS_PL) = "$_AWSTATS/wwwroot/cgi-bin/awstats.pl";
my($_BUILD_PAGES) = "$_AWSTATS/tools/awstats_buildstaticpages.pl";
my($_LOG_MERGER) = "$_AWSTATS/tools/logresolvemerge.pl";
my($_ICON_DIR) = "$_AWSTATS/wwwroot/icon";
#TODO: How about URLWithQuery directives? Defaults to ignoring query in URIs so
# you end up with more unique Pages-URL, but requires less memory to process
my($_STATIC_CONFIG) = <<'EOF';
LogFormat="%virtualname %host %other - %logname %time1 %methodurl %code %bytesd %refererquot %uaquot"
LoadPlugin="userinfo"
DNSLookup=1
LoadPlugin="hashfiles"
NotPageList="css js class gif jpg jpeg png bmp ico swf rss atom ics"
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
SkipFiles="REGEX[^\/_]"
SkipUserAgents="REGEX[.*libwww-perl.*]"
ValidHTTPCodes="200 201 207 302 304"
EOF

b_use('IO.Config')->register(my $_CFG = {
    log_base => '/var/log',
});

sub USAGE {
    my($proto) = @_;
    return <<"EOF";
usage: bivio @{[$proto->simple_package_name]} [options] command [args..]
commands
    daily_report [today] -- create a report using previous day's log
    format_access_log_stream -- read stream from STDIN reformat to STDOUT
    import_history month year -- import multiple access_logs
    init_forum name -- create report forum and import icons
EOF
}

sub daily_report {
    sub DAILY_REPORT {[[qw(today Date), sub {$_D->local_today}]]}
    my($self, $bp) = shift->parameters(\@_);
    _create_report(
	$self,
	_yesterday($bp->{today}),
	"gunzip -c @{[_log_dir($self)]}" . _previous_days_log($self, $bp->{today}),
    );
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
    sub IMPORT_HISTORY {[
	[qw(Month)],
	[qw(Year)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    # only works if the cached awstats after date have been deleted
    my($mon) = $bp->{Month}->as_int;
    _create_report(
	$self,
	$_D->date_from_parts(1, $mon, $bp->{Year}),
	sprintf(
	    '%s %s%04d%02d%s',
	    $_LOG_MERGER,
	    _log_dir($self),
	    $bp->{Year},
	    $mon,
	    $_ACCESS_LOG_GLOB,
	),
    );
    return;
}

sub init_forum {
    my($self, $name) = shift->name_args([qw(ForumName)], \@_);
    $self->assert_have_user;
    $self->usage_error($name, ': may not be top-level forum')
	if $_FN->is_top($name);
    $self->initialize_fully->with_realm(
	$_FN->extract_top($name),
	sub {
	    $self->model(
		'ForumForm',
		{
		   'RealmOwner.display_name' => 'Web Site Reports',
		   'RealmOwner.name' => $name,
		},
	    ) unless _forum_exists($self, $name);
	    $_F->do_in_dir(
		$_ICON_DIR,
		sub {$self->new_other('RealmFile')->import_tree('icon')},
	    );
	    return;
	},
    );
    return;
}

sub _create_report {
    my($self, $date, $file_command) = @_;
    my($end_of_month) = _end_of_month($date);
    my($static_config) = $_STATIC_CONFIG;
    my($data_dir) = $_F->mkdir_p(
	b_use('Biz.File')->absolute_path('HTTPStats'),
    );
    $_F->do_in_dir(
	$data_dir,
	sub {
	    $_F->write('userinfo.txt', _user_email($self));
	    return;
	},
    );
    foreach my $x (@{_domain_forum_map($self)}) {
	my($facade, $forum_name) = @$x;
	my($domain) = $facade->get('http_host');
	$self->print("creating report for $domain in $forum_name\n");
	$self->req->set_realm_and_user($forum_name);
	my($tmp_dir) = $_F->mkdir_p($_F->temp_file);
	$_F->do_in_dir($tmp_dir, sub {
	    my($conf_file) = join('.', 'awstats', $domain, 'conf');
	    my($month, $year) = $_D->get_parts($end_of_month, qw(month year));
	    my($str) = $static_config . <<"EOF";
HostAliases="$domain"
SiteDomain="$domain"
LogFile="$file_command | bivio HTTPStats format_access_log_stream |"
DirData="$data_dir"
EOF
	    _trace($str) if $_TRACE;
	    $_F->write($conf_file, $str);
	    $self->piped_exec(qq{$_AWSTATS_PL -config=$domain --configdir=. 2>&1});
	    $self->piped_exec(qq{$_BUILD_PAGES -config=$domain --configdir=. -lang=en -dir . -diricons="icon" -month=$month -year=$year 2>&1});
	    unlink($conf_file);
	    _organize_files($self, $domain, $end_of_month);
	    $self->new_other('RealmFile')->import_tree('/', 1);
	});
	$_F->rm_rf($tmp_dir);
    }
    return;
}

sub _domain_forum_map {
    my($self) = @_;
    my($seen) = {};
    return [
	grep(
	    !$seen->{$_->[1]}++,
	    sort(
		_sort_default_facade_first
		@{$_UIF->map_iterate_with_setup_request(
		    $self->req,
		    sub {_domain_forum_map_one($self, shift)},
		)},
	    ),
	),
    ];
}

sub _domain_forum_map_one {
    my($self, $facade) = @_;
    return
	unless my $realm = $facade->get('Constant')
	->unsafe_get_value('site_reports_realm_name');
    return
	unless _forum_exists($self, $realm);
    return [$facade, $realm];
}

sub _end_of_month {
    my($date) = @_;
    return $_D->set_end_of_month($date);
}

sub _forum_exists {
    my($self, $name) = @_;
    return $self->model('RealmOwner')->unauth_rows_exist({
	name => $name,
	realm_type => b_use('Auth.RealmType')->FORUM,
    });
}

sub _log_dir {
    my($self) = @_;
    $self->initialize_fully;
    return $_FP->add_trailing_slash(
	$_FP->join(
	    $_CFG->{log_base},
	    $_UIF->get_default->get('local_file_prefix'),
	),
    );
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

sub _previous_days_log {
    my($self, $today) = @_;
    return $_D->to_file_name($today) . $_ACCESS_LOG_GLOB;
}

sub _sort_default_facade_first {
    my($af) = $a->[0];
    my($bf) = $b->[0];
    return $af->get('is_default') ? -1
	: $bf->get('is_default') ? 1
        : $af->simple_package_name cmp $bf->simple_package_name;
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

sub _yesterday {
    return $_D->add_days(shift, -1);
}

1;
