# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Secret;
use strict;
$Bivio::Type::Secret::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Secret::VERSION;

=head1 NAME

Bivio::Type::Secret - encrypted value in database, never displayed to user

=head1 SYNOPSIS

    use Bivio::Type::Secret;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Secret::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::Secret> encrypts its values before storing in the DB.  The key
is prompted if the configuration param I<prompt> is set to true.  Prompting at
program startup if $ENV{MOD_PERL} is set or at first use if not.

Database fields must be VARCHAR(4000) to allow for encryption expansion.

Subclasses should define L<get_width|"get_width"> to be the value
that the user enters.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::TTY;
use Crypt::CBC;

#=VARIABLES
# Should be short and non-numeric.  Placed on both ends of string to "ensure"
# decryption worked.
my($_MAGIC) = 'BWN';
# Character we use to blank out a word
my($_FILL) = '*';
# Before initialization (_init_cipher()) is set to key
my($_CIPHER) = undef;
my($_PROMPT) = 0;
Bivio::IO::Config->register({
    key => Bivio::IO::Config->REQUIRED,
    prompt => $_PROMPT,
});

=head1 METHODS

=cut

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string value) : string

Returns the string for this value.  Dies if there is an error parsing
the column from the database.

=cut

sub from_sql_column {
    my(undef, $value) = @_;
    return undef unless $value;
    _assert_cipher();

    # Decrypt and make sure surrounded by magic and a time not before now
    my($s) = $_CIPHER->decrypt_hex($value);
    # There is a configuration error if we can't decrypt values from DB
    Bivio::Die->throw('CONFIG_ERROR',
	    {entity => 'key', class => __PACKAGE__,
	    message => 'unable to decrypt value'})
		unless $s =~ s/^$_MAGIC//o
			&& $s =~ s/$_MAGIC(\d+)$//o && time >= $1;
    return $s;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item key : string (required)

The way we encrypt the data.

=item prompt : boolean [0]

Do we need to prompt for a passphrase to decrypt I<key>?

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CIPHER = $cfg->{key};
#TODO: Need a way to compute which programs need to decrypt the key.
    $_PROMPT = $cfg->{prompt};
    _init_cipher() if $ENV{MOD_PERL};
    return;
}

=for html <a name="is_secure_data"></a>

=head2 is_secure_data() : boolean

All secrets must be displayed/managed in a secure context.

=cut

sub is_secure_data {
    return 1;
}

#TODO: This doesn't work
#
#=for html <a name="to_html"></a>
#
#=head2 static to_html(string value) : value
#
#Converts to a invalid string which shows the last bit of the
#Secret, but nothing more.  Shows the last N chars of I<value> unless it
#is_password iwc it shows no chars.  N is selected dynamically
#based on the length of I<value>
#
#=cut
#
#sub to_html {
#    my($proto, $value) = @_;
#    return '' unless defined($value) && length($value);
#
#    # It's important that this transform be repeatable.  The value will
#    # pass through to_html several times in the event of form errors.
#    return length($value) x $_FILL if $proto->is_password;
#
#    # Show at most 4 chars of the real value.  If < 8 chars total,
#    # shows half the chars (rounding down).
#    my($len) = length($value) - 4;
#    $len = int((length($value) + 1) / 2) if $len < 4;
#    return Bivio::HTML->escape($_FILL x $len.substr($value, $len));
#}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(string value) : string

Return the string of I<value>.

=cut

sub to_sql_param {
    my(undef, $value) = @_;
    return undef unless defined($value);

    _assert_cipher();
    # Surround with magic and trailing time and encrypt
    return $_CIPHER->encrypt_hex($_MAGIC.$value.$_MAGIC.time);
}

#TODO: This code was related to using to_literal as a secret rendering
#      section of code.  It's not right.
#=for html <a name="value_was_changed"></a>
#
#=head2 static value_has_changed(string old, string new) : boolean
#
#I<old> is a value from the database.  I<new> is a value which has passed
#through L<to_literal|"to_literal">.  I<old> is converted to a literal and the
#results compared.  If there is no difference, it is assumed that I<new> is not
#different and the field doesn't need to be updated.
#
#=cut
#
#sub value_has_changed {
#    my($proto, $old, $new) = @_;
#    $old = $proto->to_literal($old);
#    return 1 unless defined($old) == defined($new);
#    return 0 unless defined($old);
#    return $old eq $new ? 1 : 0;
#}
#
#=for html <a name="value_is_blanked"></a>
#
#=head2 value_is_blanked(string value) : boolean
#
#Returns true if I<value> is blanked out with the fill character
#and I<probably> hasn't been modified.  Should be used by subclasses
#which need to do validation in I<from_literal>.
#
#=cut
#
#sub value_is_blanked {
#    my($proto, $value) = @_;
#    return 0 unless length($value);
#
#    # If there is no transformation, is likely to be blanked.
#    return $proto->to_literal($value) eq $value ? 1 : 0;
#}

#=PRIVATE METHODS

# _assert_cipher()
#
# If cypher doesn't exist, blows up.
#
sub _assert_cipher {
    return if ref($_CIPHER) || _init_cipher();
    Bivio::Die->throw('CONFIG_ERROR',
	    {entity => 'key', class => __PACKAGE__,
	    message => 'no cipher configured'});
    # DOES NOT RETURN
}

# _decrypt_key(string key_in) : string
#
# Returns the key or undef.
#
sub _decrypt_key {
    my($key_in) = @_;
    $_CIPHER = undef;

    my($p) = Bivio::IO::TTY->read_password(__PACKAGE__.' passphrase: ');
    unless (defined($p)) {
	Bivio::IO::Alert->warn('unable to open /dev/tty for key');
	return undef;
    }

    # Use this module to decrypt the key.  Protect against die, so
    # $_CIPHER can be reset.
    my($key_out) = Bivio::Die->eval(
	    sub {
		$_CIPHER = Crypt::CBC->new($p, 'IDEA');
		return __PACKAGE__->from_sql_column($key_in);
	    });
    $_CIPHER = undef;
    Bivio::IO::Alert->warn('unable to decrypt key in config: ', $@)
		if $@;
    return $key_out;
}

# _init_cipher() : boolean
#
# Initializes the cipher.
#
sub _init_cipher {
    # If no key, then blow up.
    return 0 unless defined($_CIPHER);
    my($key) = $_CIPHER;
    $_CIPHER = undef;
    $key = _decrypt_key($key) if $_PROMPT;
    return 0 unless $key;
    $_CIPHER = Crypt::CBC->new($key, 'IDEA');
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
