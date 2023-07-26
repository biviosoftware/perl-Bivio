# Copyright (c) 2001-2023 bivio Software, Inc.  All rights reserved.
package Bivio::Delegate::SimpleTypeError;
use strict;
use Bivio::Base 'Type.EnumDelegate';

# C<Bivio::Delegate::SimpleTypeError> returns default TypeErrors for
# simplest bOP site.
#
# You can extend this delegate with:
#
#     sub get_delegate_info {
#         return [
#             @{Bivio::Delegate::SimpleTypeError->get_delegate_info()},
#             ...my TypeErrors...
#         ];
#     }
#
# Start your TypeErrors at 501.  Don't worry about dups, because
# L<Bivio::Type::Enum|Bivio::Type::Enum> will die if you overlap.


sub get_delegate_info {
    # Returns the task declarations.
    return [
    UNKNOWN => [
        0,
    ],
    INTEGER => [
        1,
        undef,
        'expecting a number without a decimal point',
    ],
    NUMBER_RANGE => [
        2,
        undef,
        'number outside of expected range',
    ],
    DATE_TIME => [
        3,
        undef,
        'invalid date-time. Some possible formats are: mm/dd/yyyy hh:mm:ss and yyyymmddhhmmss',
    ],
    DATE => [
        4,
        undef,
        'invalid date format, must be mm/dd/yyyy',
    ],
    TIME => [
        5,
        undef,
        'invalid time format, must be hh:mm, hh:mm a, hh:mm:ss p',
    ],
    NUMBER => [
        6,
        undef,
        'expecting a number',
    ],
    YEAR_RANGE => [
        7,
        undef,
        'year outside of valid range (1800 to 2199)',
    ],
    EXISTS => [
        8,
        undef,
        'already exists',
    ],
    MONTH => [
        9,
        undef,
        'invalid month',
    ],
    DAY_OF_MONTH => [
        10,
        undef,
        'invalid day for this month',
    ],
    HOUR => [
        11,
        undef,
        'invalid hour',
    ],
    MINUTE => [
        12,
        undef,
        'invalid minute',
    ],
    SECOND => [
        13,
        undef,
        'invalid second',
    ],
    NULL => [
        14,
        undef,
        'field may not be empty',
    ],
    COUNTRY => [
        15,
        undef,
        'country must be exactly two letters',
    ],
    PASSWORD => [
        16,
        undef,
        'invalid password; must be at least SIX characters',
    ],
    REALM_NAME => [
        17,
        undef,
        'The name you create must begin with a letter and only contain'
        .' letters, numbers, and underscores, and be at least'
        .' three characters long.',
    ],
    GREATER_THAN_ZERO => [
        18,
        undef,
        'must be greater than zero',
    ],
    NOT_FOUND => [
        19,
        undef,
        'not found',
    ],
    NOT_NEGATIVE => [
        20,
        undef,
        'can not be negative',
    ],
    TOO_LONG => [
        21,
        undef,
        'field is too long',
    ],
    YEAR_DIGITS => [
        22,
        undef,
        'four digit year required (mm/dd/yyyy)',
    ],
    EMAIL => [
        23,
        undef,
        'invalid email address; should be of the form mary@aol.com',
    ],
    EMAIL_DOMAIN_LITERAL => [
        24,
        undef,
        'email addresses with domain literals [w.x.y.z] are not acceptable',
    ],
    EMAIL_UNQUALIFIED => [
        25,
        undef,
        'email does not contain a @domain.com',
    ],
    PASSWORD_MISMATCH => [
        26,
        undef,
        'The password you entered does not match the value stored in our database. Please remember that passwords are case-sensitive, i.e. "HELLO" is not the same as "hello".',
    ],
    UNSPECIFIED => [
        27,
        undef,
        'field must be specified',
    ],
    TEXT_TOO_LONG => [
        28,
        undef,
        'input is too long.  Maximum size is 500 characters.',
    ],
    FORM_DATA_MULTIPART_MIXED => [
        29,
        undef,
        'only one file may be uploaded at a time',
    ],
    PRIMARY_ID => [
        30,
        undef,
        'invalid URL, query string is invalid',
    ],
    FILE_FIELD_RESET_FOR_SECURITY => [
        31,
        undef,
        'your browser reset this field for security reasons',
    ],
    FILE_NAME => [
        32,
        undef,
        'File names may not contain \\, /, :, *, ?, ", <, >, % or |.  They may not be equal to "." or "..". or contain control characters or tabs.',
    ],
    NOT_ZERO => [
        33,
        undef,
        'may not be zero',
    ],
    TIME_COMPONENT_OF_DATE => [
        34,
        undef,
        'time component not valid for date value',
    ],
    TIME_RANGE => [
        35,
        undef,
        'seconds outside of the maximum for a time',
    ],
    DATE_RANGE => [
        36,
        undef,
        'days outside of the maximum for a date',
    ],
    US_ZIP_CODE => [
        37,
        undef,
        'invalid US Zip; must be 5 or 9 digits.',
    ],
    CREDITCARD_INVALID_NUMBER => [
        38,
        undef,
        "not a valid credit card number",
    ],
    CREDITCARD_EXPIRED => [
        39,
        undef,
        "expiration date is in the past",
    ],
    CREDITCARD_UNSUPPORTED_TYPE => [
        40,
        undef,
        "credit card type not supported; Amex, Visa and MasterCard only",
    ],
    CREDITCARD_WRONG_TYPE => [
        41,
        undef,
        "card number does not match card type",
    ],
    FILE_FIELD => [
        42,
        undef,
        'your browser has not submitted the file correctly; please try again',
    ],
    EMPTY => [
        43,
        undef,
        'file cannot be empty',
    ],
    OFFLINE_USER => [
        44,
        undef,
        'operation not allowed for offline user',
    ],
    CONFIRM_PASSWORD => [
        45,
        undef,
        'password and confirm password fields do not match',
    ],
    DOMAIN_NAME => [
        46,
        undef,
        'invalid internet domain name',
    ],
    INVALID_MESSAGE_BODY => [
        47,
        undef,
        'message body must be plain text or HTML',
    ],
    FIRST_NAME_LENGTH => [
        48,
        undef,
        'first name is too long',
    ],
    MIDDLE_NAME_LENGTH => [
        49,
        undef,
        'middle name is too long',
    ],
    LAST_NAME_LENGTH => [
        50,
        undef,
        'last name is too long',
    ],
    HTTP_URI => [
        51,
        undef,
        'invalid HTTP URL (web location)',
    ],
    US_ZIP_CODE_9 => [
        52,
        undef,
        'Nine (9) digit US Zip code required',
    ],
    FILE_PATH => [
        53,
        undef,
        'File paths may not contain \\, :, *, ?, ", <, >, |, tabs, control characters, leading or trailing dots.',
    ],
    PERMISSION_DENIED => [
        54,
        undef,
        'Permission denied',
    ],
    FORUM_NAME => [
        55,
        undef,
        'The first part of a forum name must be three or more characters and consist of alphanumeric characters followed by any number of hyphens and alphanumeric characters.',
    ],
    TOP_FORUM_NAME => [
        56,
        undef,
        'Top forum name not formed correctly.  Must not contain hyphens (-).',
    ],
    TOP_FORUM_NAME_CHANGE => [
        57,
        undef,
        'Top forum name may not be changed',
    ],
    EMAIL_ALIAS_OUTGOING => [
        58,
        undef,
        'Outgoing email alias values must be an email address or simple name',
    ],
    TIME_ZONE => [
        59,
        undef,
        'Unknown or invalid time zone in date',
    ],
    WIKI_NAME => [
        60,
        undef,
        'Wiki page names must be mixed case words starting with an upper-case letter, containing at least one lower case letter between two upper case letters, and containing only numbers and letters (no spaces, underscores, etc.)',
    ],
    BLOG_NAME => [
        61,
        undef,
        'Blog page names may only containg letters, numbers and spaces.',
    ],
    BLOG_FILE_NAME => [
        62,
        undef,
        'Blog identifiers must be of the form: YYYYMMDDHHMMSS',
    ],
    BLOG_TITLE_NULL => [
        63,
        undef,
        'Blog must start with a title of the form: @h1 some title',
    ],
    BLOG_BODY_NULL => [
        64,
        undef,
        'Blog body must contain some text after the title (@h1 line)',
    ],
    BLOG_TITLE_PREFIX => [
        65,
        undef,
        'Blog must start with "@h1 " to indicate title',
    ],
    MUTUALLY_EXCLUSIVE => [
        66,
        undef,
        'Two or more mutually exclusive values cannot be specified',
    ],
    SYNTAX_ERROR => [
        68,
        undef,
        'Invalid value',
    ],
    SIMPLE_CLASS_NAME => [
        69,
        undef,
        'Class names must consist of letters, numbers, or underscores',
    ],
    TOO_MANY => [
        70,
        undef,
        'Field has too many values',
    ],
    UNSUPPORTED_TYPE => [
        71,
        undef,
        'Value not supported by application',
    ],
    OTP_PASSWORD_MISMATCH => [
        72,
        undef,
        'Your OTP key did not match',
    ],
    OTP_PASSWORD => [
        73,
        undef,
        'Invalid OTP',
    ],
    FORUM_FOR_OTP_USERS => [
        74,
        undef,
        'This forum is for OTP users only',
    ],
    TOO_FEW => [
        75,
        undef,
        'Field has too few values',
    ],
    TOO_SHORT => [
        76,
        undef,
        'field is too short',
    ],
    INVALID_FOLDER => [
        77,
        undef,
        'A folder may not be put in one of its subfolders',
    ],
    STALE_FILE_LOCK => [
        78,
        undef,
        'Your lock on this file is no longer valid, please revisit the file from the file tree',
    ],
    INVALID_SENDER => [
        79,
        undef,
        'Your email address is invalid, please update and resend.',
    ],
    EMAIL_VERIFY_KEY => [
        80,
        undef,
        'Your verification key is invalid.',
    ],
    INTERNAL_SYSTEM_ERROR => [
        81,
        undef,
        'Unable to perform operation due to an internal system error.  Please contact customer support.'
    ],
    FILE_NAME_LEADING_DOT => [
        82,
        undef,
        'File names may not contain a leading dot.',
    ],
    WEAK_PASSWORD => [
        83,
        undef,
        'Password does not sufficiently protect against potential attackers. Do not use a common, easy to guess password, your user id, login name, or email address.',
    ],
];
}

1;
