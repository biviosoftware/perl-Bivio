#
# schelle@bivio.com
#
# PrintUtils.pm
#
# Description: Package containing methods used in printing to the screen
#

package PrintUtils;
use strict;

#
# Intelligently print the datastructure stemming from this $ref
#
# (can be complex, with hashes, arrays, and scalars) 
#
sub print_datastructure {

	my($self) = shift;
	my($ref) = shift;
	my($spaces) = shift;

	my($ref_type) = ref($ref);

	if (! $ref_type) {
		print "$ref\n";
	}
	elsif ($ref_type eq 'ARRAY') {
		my($element);
		foreach $element (@{$ref}) {
			PrintUtils->print_datastructure($element, $spaces + 1);
		}
	}
	elsif ($ref_type eq 'SCALAR' || $ref_type eq 'REF') {
		PrintUtils->print_datastructure($$ref, $spaces + 1);
	}
	else { # ($ref_type eq 'HASH')
		print "\n";
		my($key);
		foreach $key (keys %{$ref}) {
			print " "x$spaces;
			print "$key = ";
			PrintUtils->print_datastructure($ref->{$key}, $spaces + 1);
		}
	}
}

1;

