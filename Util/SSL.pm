# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SSL;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('IO.File');

sub USAGE {
    return <<'EOF';
usage: b-ssl [options] command [args..]
commands
   read_crt file.crt -- dump a (PEM) X509 certificate
   self_signed_crt domain -- create a self-signed crt for domain
   self_signed_mdc file domain... -- create a self-signed multi-domain certificate
EOF
}

sub read_crt {
    my($self, $crt) = @_;
    return $self->do_sh("openssl x509 -text -in $crt");
}

sub self_signed_crt {
    my($self, $domain) = shift->name_args([['DomainName']], \@_);
    return _do($self, $domain, "-subj '/C=US/ST=Colorado/L=Boulder/CN=$domain'");
}

sub self_signed_mdc {
    my($self, $base, @domain) = shift->name_args(['Name', 'DomainName'], \@_);
    my($cfg) = $_F->write("$base.cfg", <<"EOF");
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = Colorado
L = Boulder
CN = $base
[v3_req]
subjectAltName = @{[join(', ', map("DNS:$_", @domain))]}
EOF
    return _do($self, $base, "-config $base.cfg");
}

sub _do {
    my($self, $base, $rest) = @_;
    return $self->do_sh("openssl req -x509 -nodes -days 9999 -newkey rsa:1024 -keyout $base.key -out $base.crt $rest");
}

1;
