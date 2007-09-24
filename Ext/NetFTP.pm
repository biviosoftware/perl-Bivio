# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTP;
use strict;
use base 'Net::FTP';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    active_ports => [8100 .. 8199],
    timeout => 60,
});

sub bivio_get {
    my($proto, $args) = @_;
    my($required) = [qw(host cwd file req)];
    Bivio::Die->die($args, ': must supply args: ', $required)
        unless grep(defined($args->{$_}), @$required) == @$required;
    my($self) = $proto->new(
	$args->{host},
	map(($_ => $args->{$_}), sort(grep($_ =~ /^[A-Z]/, keys(%$args)))),
    );
    $self->login(
	defined($args->{user}) ? $args->{user} : 'anonymous',
	defined($args->{password}) ? $args->{password}
	    : $args->{req}->format_email(
		Bivio::UI::Text->get_value('support_email', $args->{req})),
    ) || _bivio_die($self, 'login');
    $self->cwd($args->{cwd}) || _bivio_die('cwd');
    my($type) = $args->{type} || 'binary';
    $self->$type() || _bivio_die($self, 'cwd');
    my($buf) = '';
    $self->get($args->{file}, Bivio::UNIVERSAL->use('IO::String')->new(\$buf))
	|| _bivio_die($self, 'cwd');
    $self->quit;
    return \$buf;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub new {
    my($self) = shift->SUPER::new(@_) || _bivio_die(undef, 'new');
    $self->debug(1) if $_TRACE;
    $self->timeout($_CFG->{timeout});
    ${*$self}{'net_ftp_listen'} = _bivio_socket($self)
	if ${*$self}{'net_ftp_passive'};
    return $self;
}

sub _bivio_die {
    my($self, $op) = @_;
    my($e) = "$!";
    $self->quit
	if $self;
    Bivio::Die->die($op, ': failed: ', $e);
    # DOES NOT RETURN
}

sub _bivio_socket {
    my($self) = @_;
    my($ports) = [@{$_CFG->{active_ports}}];
    my($shift) = [splice(@$ports, 0, $$ % @$ports)];
    foreach my $p (@$ports, @$shift) {
	my($s) = IO::Socket::INET->new(
	    Listen => 5,
	    Proto => 'tcp',
	    Timeout => $self->timeout,
	    LocalAddr => $self->sockhost,
	    LocalPort => $p,
	);
	return $s
	    if $s;
    }
    _bivio_die($self, 'port');
    # DOES NOT RETURN
}

1;
