#
# schelle@bivio.com
#
# HTTPTools.pm
#
# Description: Package containing methods used to request a BivioResponse
#

package HTTPTools;
use strict;

use LWP;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;

use BivioResponse;
use PrintUtils;

#
# Global variables
#
my($_DEFS);      # definitions (read from defs.PL)
my($_BASE_URL);  # base url of the web page
my($_DEBUG);     # verbose output
my($_USERAGENT); # LWP::UserAgent
my($_COOKIEJAR); # HTTP::Cookies

#
# Read config, definition, etc files
#
local($/);  # This lets you read a file in one go
open(IN, "defs.PL") || die("Failed to open defs.PL\n");
$_DEFS = eval(<IN>) || die("defs.PL: $@");
die("defs.PL: did not return hash") unless ref($_DEFS) eq 'HASH';
close(IN);

#
# Initialize global variables
#
$_BASE_URL = $_DEFS->{BASE_URL};
$_DEBUG = $_DEFS->{DEBUG};

################################################################################
##                                                                            ##
##                          Subroutines                                       ##
##                                                                            ##
################################################################################

########################
##                    ##
## Public Subroutines ##
##                    ##
########################

#
# create LWP::UserAgent and HTTP::Cookies variables
#
sub create_user_agent {

	$_USERAGENT = new LWP::UserAgent;
	$_USERAGENT->agent("Mozilla/4.7 [en] (Win98; I)"); # this is arbitrary?

	$_COOKIEJAR = HTTP::Cookies->new;
}

#
# Subroutine to get a BivioResponse by a simple URL request
#
# Arguments:      section of the page (only used if it's 'URL')
#                 if section is URL, target is the URL to request
#                   else section is the image name or text for an href link
#                 current response (BivioResponse)
#
# Return values:  new response (BivioResponse)
#
sub http_href {
 
	my($section) = shift;
	my($target) = shift;
	my($bivio_res) = shift;

	# TODO: update (remove HTTP_RESPONSE)
	die("Must pass BivioResponse to http_href unless using URL for \$section")
		unless ($section eq 'URL' || $bivio_res->{HTTP_RESPONSE}->is_success);

	my($title) = $bivio_res->{TITLE};

	my($urltorequest);
	if ($section eq 'URL') {
		# the URL was passed
		$urltorequest = $target;
	}
	else {
		# the URL must be extracted from the current BivioResponse
		#$urltorequest = $bivio_res->{$section}->{$target};
		$urltorequest = $bivio_res->{LINKS}->{$target};
	}

	#die("$title does not contain $target in $section\n")
	die("$title does not contain $target\n")
		unless $urltorequest;

	if ($urltorequest !~ /$_BASE_URL/) {
		$urltorequest = $_BASE_URL.$urltorequest;
	}

	return BivioResponse::new(_request_page(_get_request_by_url($urltorequest)));
}

#
# Subroutine to get a BivioResponse by a form action
#
# Arguments:      input to the form (HASH ref)
#                 current response (BivioResponse)
#
# Return values:  new response (BivioResponse)
#
sub http_form {

	my($form_input) = shift;
	my($bivio_res) = shift;

	my($cur_uri) = $bivio_res->{URI};

	#
	# Decide which form we want based on which form's inputs we are using
	#
	my($form_name);
	my($fn);
	foreach $fn (keys %{$bivio_res->{FORMS}}) {
		my($key);
		foreach $key (keys %{$form_input}) {
			if (defined $bivio_res->{FORMS}->{$fn}->{$key}) {
				if (defined $form_name && $form_name ne $fn) {
					die("Don't know which form to use: $form_name or $fn");
				}
				else {
					$form_name = $fn;
				}
			}
		}
	}

	if (! defined $form_name) {
		die ("Did not find form to use");
	}

	my($action) = $bivio_res->{FORMS}->{$form_name}->{action};
	my($method) = $bivio_res->{FORMS}->{$form_name}->{method};

	my(@content_array);

	# get hidden fields
	my($n);
	foreach $n (keys %{$bivio_res->{FORMS}->{$form_name}->{HIDDEN_FIELDS}}) {
		push @content_array, $n.'='.$bivio_res->{FORMS}->{$form_name}->{HIDDEN_FIELDS}->{$n};
	}

	# not sure if we need to get these name=value pairs from the current URI
	my($p);
	foreach $p ($cur_uri =~ /\?(\S+=\S*)/) {
		push @content_array, $p;
	}

	#
	# Get the input pairs from $form_input and add the results to @content_array
	#
	my($key);
	foreach $key (keys %{$form_input}) {
	
		# see below for what $key and $value may be
		my($value) = $form_input->{$key};

		my($parsed_bit);
		$parsed_bit = $bivio_res->{FORMS}->{$form_name}->{$key};

		if (! defined $parsed_bit) {
			die("Could not find $key in \$bivio_res->{FORMS}->{$form_name}\n");
		}

		my($ref_type) = ref($parsed_bit);

		#
		# $key                    => $value
		#
		# checkbox input:
		# 'Save Password'         => '1',
		# '(adjacent text)'       => '(value, where 1=notchecked and 0=checked)',
		#
		# radio input:
		# 'Member Report'         => '',
		# '(adjacent text)'       => '', (by including it, the radio is chosen)
		#
		if (! $ref_type) { # checkbox or radio input

			my($n);
			my($v);
			($n, $v) = split(/=/, $parsed_bit); # $parsed_bit = name=value

			if (! defined $n) {
				die("\nTest Failed!!\n\nDidn't find $n in $cur_uri");
			}

			if (! defined $v) {
				die("\nTest Failed!!\n\nDidn't find $v in $cur_uri");
			}

			if ($value eq '') { # get value from page (radio inputs)
				push @content_array, $n.'='.$v;
			}
			else { # get value from config (checkbox inputs)
				push @content_array, $n.'='.$value;
			}
		}
		#
		# $key                    => $value
		#
		# text or password input:
		# 'Date'                  => '5/5/1955',
		# 'TEXTLESS' (if no text) => 'dog:cat', (for mult inputs, separate w/ ':')
		# '(adjacent text)'       => '(text to input)',
		#
		# textarea input:
		# 'Remark'                => 'Test',
		# '(adjacent text)'       => '(text to input)',
		#
		# submit input:
		# 'Generate'              => '1',
		# '(text on button)'      => '(button # w/ same text, 0=1st, 1=2nd, etc)',
		#
		elsif ($ref_type eq 'ARRAY') { # text, textarea, password or submit input

			my(@values);
			my($num_values) = 0;
			if ($value eq '') { # want to input ''
				$values[0] = '';
				$num_values = 1;
			}
			else {
				@values = split(/:/, $value);
				$num_values = (scalar(@values) > scalar(@{$parsed_bit})) ? scalar(@values) : scalar(@{$parsed_bit});
			}

			for (my($i) = 0; $i < $num_values; $i++) {

				if ($parsed_bit->[$i] =~ /=/) { # text or password input
					my($n) = split(/=/, $parsed_bit->[$i]);
					my($v) = $values[$i];

					if (! defined $n) {
						die("\nTest Failed!!\n\nDidn't find correct number of $key inputs ($num_values) in $cur_uri\n");
					}

					if (! defined $v) {
						$v = '';
					}

					push @content_array, $n.'='.$v;
				}
				elsif ($i == $value) { # submit input, and this # is the one we want

					my($n) = $parsed_bit->[$i];

					if (! defined $n) {
						die("\nTest Failed!!\n\nDidn't find $key in $cur_uri\n");
					}

					push @content_array, $n.'='.$key;
				}
			}
		}
		#
		# $key                    => $value
		#
		# RealmChooser:
		# 'RealmChooser'          => 'Trez Talk'
		# 'RealmChooser'          => '(text within RealmChooser)'
		#
		# select input:
		# 'Source Account'        => 'Bank',
		# '(adjacent text)'       => '(text within SELECT)',
		#
		elsif ($ref_type eq 'HASH') { # select or RealmChooser input

			my($n) = $bivio_res->{FORMS}->{$form_name}->{$key}->{name};
			my($v) = $bivio_res->{FORMS}->{$form_name}->{$key}->{$value};

			if (! defined $n) {
				die("\nTest Failed!!\n\nDidn't find $key in $cur_uri\n");
			}

			if (! defined $v) {
				die("\nTest Failed!!\n\nDidn't find $value in $key in $cur_uri\n");
			}

			push @content_array, $n.'='.$v;

			# TODO: Fix this.  The way action/method is done is not clean!
			$action = $bivio_res->{FORMS}->{$form_name}->{$key}->{action};
			$method = $bivio_res->{FORMS}->{$form_name}->{$key}->{method};
		}
		else {
			die("Unknown \$ref_type: $ref_type\n");
		}
	}

	my($content) = '';
	my($component) = '';
	foreach $component (@content_array) {

		if (! $content) {
			$content = $component;
		}
		else {
			$content .= '&'.$component;
		}
	}

	my($urltorequest) = $_BASE_URL.$action;

	if ($method eq 'POST') {
		if ($_DEBUG) { print "  URL to request (POST):       $urltorequest\n"; }
		my($req) = HTTP::Request->new(POST => $urltorequest);
		$req->content_type('application/x-www-form-urlencoded');
		$_COOKIEJAR->add_cookie_header($req);
	
		if ($_DEBUG) { print "  POST content:                $content\n"; }
	
		$req->content($content);

		return BivioResponse::new(_request_page($req));
	}
	elsif ($method eq 'GET') {
		$urltorequest = $urltorequest.'?'.$content;

		if ($_DEBUG) { print "  URL to request (GET):        $urltorequest\n"; }

		return BivioResponse::new(_request_page(_get_request_by_url($urltorequest)));
	}
}

#########################
##                     ##
## Private Subroutines ##
##                     ##
#########################

#
# Subroutine to make a request
#
# Arguments:      request we want (HTTP::Request)
#
# Return values:  response from that request (HTTP::Response)
#
sub _request_page {

	my($req) = shift;

	my($http_res) = $_USERAGENT->request($req);
	$_COOKIEJAR->extract_cookies($http_res);

	my($cur_uri) = $http_res->request->uri;
	if ($_DEBUG) { print "  Performed request for:       $cur_uri\n"; }

	while ($http_res->is_redirect) {
		$http_res = _perform_redirect($http_res);
	}

	if (! $http_res->is_success) {
		my($error) = $http_res->error_as_HTML;
		print "$error\n";
	}

	return $http_res;
}

#
# Formulate HTTP::Request GET request using a URL
#
sub _get_request_by_url {

	my($urltorequest) = shift;

	if ($_DEBUG) { print "  URL to request (GET):        $urltorequest\n"; }
	my($req) = HTTP::Request->new(GET => $urltorequest);
	$_COOKIEJAR->add_cookie_header($req);

	return $req;
}

#
# Perform redirect
#
# Arguments:      response notifying of redirect (HTTP::Response)
#
# Return values:  new response (HTTP::Response)
#
sub _perform_redirect {

	my($http_res) = shift;

	my($cur_uri) = $http_res->request->uri;

	if ($_DEBUG) { print "  URI of response:             $cur_uri\n"; }
	if ($_DEBUG) { print "  Performing redirect...\n"; }

	my($redirect_ext) = ($http_res->as_string =~ /Location: (\S*)/s);

	my($base) = $_BASE_URL;

	# cut off last '/' if there is one
	if ($base =~ /\/$/) {
		($base) = ($base =~ /^(.*)\/$/);
	}

	my($urltorequest) = $base.$redirect_ext;

	return _request_page(_get_request_by_url($urltorequest));
}

1;

