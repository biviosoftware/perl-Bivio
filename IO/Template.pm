# Copyright (c) 2008-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::Template;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

my($_F) = b_use('IO.File');

sub replace_in_file {
    my($proto, $file_name, $vars) = @_;
    return $proto->replace_in_string($_F->read($file_name), $vars);
}

sub replace_in_string {
    my(undef, $template, $vars) = @_;
    my($d) = ref($template) ? $template : \$template;
    $$d =~ s{(\$\$)|\$\{([a-z]\w*)\}|\$([a-z]\w*)}{_do($vars, $1, $2, $3)}egs;
    return ref($template) ? $d : $$d;
}

sub _do {
    my($vars) = shift(@_);
    my($in) = grep(defined($_), @_);
    return '$'
        if $in eq '$$';
    foreach my $v ($in, '') {
        next unless exists($vars->{$v});
        my($out) = $vars->{$v};
        $out = $out->($in)
            if ref($out) eq 'CODE';
        Bivio::Die->die($in, ': var value is undefined')
            unless defined($out);
        Bivio::Die->die($in, ': var value is a reference: ', $out)
            if ref($out);
        return $out;
    }
    Bivio::Die->die($in, ': not found in vars map');
    # DOES NOT RETURN
}

1;
