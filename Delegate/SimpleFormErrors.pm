# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleFormErrors;
use strict;
$Bivio::Delegate::SimpleFormErrors::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleFormErrors::VERSION;

=head1 NAME

Bivio::Delegate::SimpleFormErrors - default form error formats

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleFormErrors;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimpleFormErrors::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleFormErrors>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : string_ref

Returns the form error definitions.

=cut

sub get_delegate_info {
    my($info) = <<'EOF';


NULL
You must supply a value for $label.
%%
EOF
    return \$info;
};

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
