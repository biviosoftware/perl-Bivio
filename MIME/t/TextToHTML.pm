# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::MIME::TextToHTML;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Cases are defined at the end of this file.
my($test) = 2;
local($/);

foreach my $case (split(/^%%\d*\n/m, <DATA>)) {
    # Skip first %% line
    next unless length($case);

    # Process
    my($input, $expected) = split(/^##\n/m, $case);
    my($th) = Bivio::MIME::TextToHTML->new;
    my($entity) = MIME::Entity->new(Type => 'text/plain',
           Data => \$input);
    $th->convert($entity, 'myurl');
    my($output) = $entity->as_string;
    # Check results
    print $output eq $expected ? "ok $test\n" : "not ok $test\n";
    $test++;
}

# Cases are preceded by "%%" and their case number.  This is for
# documentation purposes only.  Input and expected output are separated
# by "##".
#
# If you add cases, don't forget to update the "1..N\n" line at
# the top of this file.  Make sure cases are number continuously.
# End the last expected output with "%%", so it ends with newline.
__DATA__
%%2
<p>
This is some text.
</p>
<p>
This is more text.
</p>
##
This
is
more
some
text
##
%%3
<p>
This is text with a url: <a href="http://bivio.com">http://bivio.com</a>
</p>
##
This
a
http://bivio.com
is
text
url
with
%%
