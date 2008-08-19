# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPStats;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_F) = __PACKAGE__->use('IO.File');
my($_AWSTATS) = '/usr/local/awstats/wwwroot/cgi-bin/awstats.pl';
my($_BUILD_PAGES) = '/usr/local/awstats/tools/awstats_buildstaticpages.pl';
my($_LOG_MERGER) = '/usr/local/awstats/tools/logresolvemerge.pl';
my($_ICON_DIR) = '/usr/local/awstats/wwwroot/icon/';
Bivio::IO::Config->register(my $_CFG = {
    log_base => '/var/log',
});

sub USAGE {
    return <<'EOF';
usage: b HTTPStats [options] command [args..]
commands
    daily_report [date] -- create a report using access_log.1.gz
    format_access_log_stream -- read stream from STDIN reformat to STDOUT
    import_icons -- imports awstats icons into RealmFile
    import_history [date] -- import multiple access_logs
EOF
}

sub daily_report {
    my($self, $date) = _parse_args(@_);
    _create_report($self, $date,
	"gunzip -c @{[$_CFG->{log_base}]}/<uri>/access_log.1.gz");
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
#TODO: skip lines such as internal calls /_mail_receive
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
	"$_LOG_MERGER @{[$_CFG->{log_base}]}/<uri>/access_log.*.gz");
    return;
}

sub import_icons {
    my($self) = @_;
    $self->req->set_realm_and_user('site');
    $_F->do_in_dir($_ICON_DIR, sub {
        $self->new_other('Bivio::Util::RealmFile')
	    ->import_tree('HTTPStats/icon');
    });
    return;
}

sub _create_report {
    my($self, $date, $file_command) = @_;
#TODO: create report for each facade
    #foreach my $facade (map($self->use('Bivio::UI::Facade')
    #    ->get_instance($_), @{$_F->get_all_classes})) {
    #}
    my($facade) = $self->use('Bivio::UI::Facade')->get_default;
    my($uri, $http_host) = $facade->get(qw(uri http_host));
    $file_command =~ s/<uri>/$uri/ || die('invalid file command');
    my($data_dir) = $_F->mkdir_p($self->use('IO.Log')
	->file_name('HTTPStats/data', $self->req));
    $_F->do_in_dir($data_dir, sub {
	$_F->write(join('.', 'userinfo', $uri, 'txt'), _user_email($self));
    });
    $self->req->set_realm_and_user('site');
    my($tmp_dir) = $_F->mkdir_p($_F->temp_file);
    $_F->do_in_dir($tmp_dir, sub {
	my($conf_file) = join('.', 'awstats', $uri, 'conf');
	my($month, $year) = $_D->get_parts($date, qw(month year));
	$_F->write($conf_file, $self->internal_data_section . <<"EOF");
HostAliases="REGEX[.*$uri.*]"
SiteDomain="$http_host"
LogFile="$file_command | bivio HTTPStats format_access_log_stream |"
DirData="$data_dir"
EOF
	`$_AWSTATS -config=$uri --configdir=.`;
	`$_BUILD_PAGES -config=$uri --configdir=. -lang=en -dir . -diricons="../icon" -month=$month -year=$year`;
	unlink($conf_file);
        $self->new_other('Bivio::Util::RealmFile')->import_tree(
	    'HTTPStats/' . $_D->to_file_name($date));
    });
    $_F->rm_rf($tmp_dir);
    return;
}

sub _parse_args {
    my($self, $date) = @_;
    $self->initialize_fully;
    return ($self, $date
	? $_D->from_literal_or_die($date)
	: $_D->add_days($_D->local_today, -1));
}

sub _user_email {
    my($self) = @_;
    my($res) = '';
    $self->use('Bivio::SQL::Connection')->do_execute(sub {
        my($row) = @_;
	$res .= join("\t", @$row) . "\n";
    }, <<'EOF', [$self->use('Type.Location')->HOME->as_sql_param]);
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
