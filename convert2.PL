foreach my $file (@ARGV) {
    system("cvs edit $file");
    open(IN, $file) || die;
    my(@lines) = <IN>;
    close(IN) || die;
    my($version) = 0;
    foreach my $line (@lines) {
	$line =~ /^(\$Bivio[:a-z0-9_]+::VERSION)/i && ($version = $1, next);
	$version && $line =~ s/^\s*$/\$_ = $version;\n\n/;
	$line =~ s/1999(, ?2000)?(, ?2001)? bivio,? (LLC|Inc)\.?/1999-2001 bivio Inc./;
	$line =~ s/2000 bivio,? (LLC|Inc)\.?/2000,2001 bivio Inc./;
	$line =~ s/bivio, Inc./bivio Inc./;
	$version = undef;
    }
    open(OUT, ">$file") || die("create($file): $!");
    print OUT @lines;
    close(OUT) || die("close($file): $!");
}
