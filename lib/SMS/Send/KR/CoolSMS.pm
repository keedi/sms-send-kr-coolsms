package SMS::Send::KR::CoolSMS;
# ABSTRACT: An SMS::Send driver for the coolsms.co.kr service

use strict;
use warnings;
use parent qw( SMS::Send::Driver );

use Digest::MD5 qw( md5_hex );
use HTTP::Tiny;

our $URL     = "api.coolsms.co.kr/sendmsg";
our $AGENT   = 'SMS-Send-KR-CoolSMS/' . $SMS::Send::KR::CoolSMS::VERSION;
our $SSL     = 0;
our $TIMEOUT = 3;
our $TYPE    = 'sms';
our $COUNTRY = 'KR';

#
# supported country code from coolsms HTTP API PDF document
# http://open.coolsms.co.kr/download/222303
#
my %country_code = (
    AR => { code => "AR", no => 54,  name => "Argentina" },
    AM => { code => "AM", no => 374, name => "Armenia" },
    AU => { code => "AU", no => 61,  name => "Australia" },
    AT => { code => "AT", no => 43,  name => "Austria" },
    BH => { code => "BH", no => 973, name => "Bahrain" },
    BD => { code => "BD", no => 880, name => "Bangladesh" },
    BE => { code => "BE", no => 32,  name => "Belgium" },
    BT => { code => "BT", no => 975, name => "Bhutan" },
    BO => { code => "BO", no => 591, name => "Bolivia" },
    BR => { code => "BR", no => 55,  name => "Brazil" },
    BN => { code => "BN", no => 673, name => "Brunei Darussalam" },
    BG => { code => "BG", no => 359, name => "Bulgaria" },
    KH => { code => "KH", no => 855, name => "Cambodia" },
    CM => { code => "CM", no => 237, name => "Cameroon" },
    CA => { code => "CA", no => 1,   name => "Canada" },
    CL => { code => "CL", no => 56,  name => "Chile" },
    CN => { code => "CN", no => 86,  name => "China" },
    CO => { code => "CO", no => 57,  name => "Colombia" },
    CU => { code => "CU", no => 53,  name => "Cuba" },
    DK => { code => "DK", no => 45,  name => "Denmark" },
    EG => { code => "EG", no => 20,  name => "Egypt" },
    ET => { code => "ET", no => 251, name => "Ethiopia" },
    FI => { code => "FI", no => 358, name => "Finland" },
    FR => { code => "FR", no => 33,  name => "France" },
    GA => { code => "GA", no => 241, name => "Gabon" },
    DE => { code => "DE", no => 49,  name => "Germany" },
    GH => { code => "GH", no => 233, name => "Ghana" },
    GR => { code => "GR", no => 30,  name => "Greece" },
    GL => { code => "GL", no => 299, name => "Greenland" },
    GY => { code => "GY", no => 592, name => "Guyana" },
    HK => { code => "HK", no => 852, name => "Hong Kong" },
    HU => { code => "HU", no => 36,  name => "Hungary" },
    IS => { code => "IS", no => 354, name => "Iceland" },
    IN => { code => "IN", no => 91,  name => "India" },
    IR => { code => "IR", no => 98,  name => "Iran" },
    IQ => { code => "IQ", no => 964, name => "Iraq" },
    IE => { code => "IE", no => 353, name => "Ireland" },
    IL => { code => "IL", no => 972, name => "Israel" },
    IT => { code => "IT", no => 39,  name => "Italy" },
    JP => { code => "JP", no => 89,  name => "Japan" },
    KZ => { code => "KZ", no => 7,   name => "Kazakhstan" },
    KE => { code => "KE", no => 254, name => "Kenya" },
    KR => { code => "KR", no => 82,  name => "Korea" },
    KW => { code => "KW", no => 965, name => "Kuwait" },
    LA => { code => "LA", no => 856, name => "Lao People's Democratic Republic" },
    LB => { code => "LB", no => 961, name => "Lebanon" },
    LY => { code => "LY", no => 218, name => "Libya" },
    LU => { code => "LU", no => 352, name => "Luxembourg" },
    MO => { code => "MO", no => 853, name => "Macao" },
    MG => { code => "MG", no => 261, name => "Madagascar" },
    MY => { code => "MY", no => 60,  name => "Malaysia" },
    MX => { code => "MX", no => 52,  name => "Mexico" },
    MC => { code => "MC", no => 377, name => "Monaco" },
    MN => { code => "MN", no => 976, name => "Mongolia" },
    MM => { code => "MM", no => 95,  name => "Myanmar" },
    NP => { code => "NP", no => 977, name => "Nepal" },
    NL => { code => "NL", no => 31,  name => "Netherlands" },
    NZ => { code => "NZ", no => 64,  name => "New Zealand" },
    NG => { code => "NG", no => 234, name => "Nigeria" },
    NO => { code => "NO", no => 47,  name => "Norway" },
    PK => { code => "PK", no => 92,  name => "Pakistan" },
    PY => { code => "PY", no => 595, name => "Paraguay" },
    PH => { code => "PH", no => 63,  name => "Philippines" },
    PL => { code => "PL", no => 48,  name => "Poland" },
    PT => { code => "PT", no => 351, name => "Portugal" },
    RO => { code => "RO", no => 40,  name => "Romania" },
    RU => { code => "RU", no => 7,   name => "Russian Federation" },
    SN => { code => "SN", no => 221, name => "Senegal" },
    SG => { code => "SG", no => 65,  name => "Singapore" },
    SK => { code => "SK", no => 42,  name => "Slovakia" },
    SI => { code => "SI", no => 386, name => "Slovenia" },
    ZA => { code => "ZA", no => 27,  name => "South Africa" },
    ES => { code => "ES", no => 34,  name => "Spain" },
    LK => { code => "LK", no => 94,  name => "Sri Lanka" },
    SZ => { code => "SZ", no => 268, name => "Swaziland" },
    SE => { code => "SE", no => 46,  name => "Sweden" },
    CH => { code => "CH", no => 41,  name => "Switzerland" },
    SY => { code => "SY", no => 963, name => "Syrian Arab Republic" },
    TW => { code => "TW", no => 886, name => "Taiwan" },
    TH => { code => "TH", no => 66,  name => "Thailand" },
    TR => { code => "TR", no => 90,  name => "Turkey" },
    AE => { code => "AE", no => 971, name => "United Arab Emirates" },
    GB => { code => "GB", no => 44,  name => "United Kingdom" },
    US => { code => "US", no => 1,   name => "United States" },
    UZ => { code => "UZ", no => 7,   name => "Uzbekistan" },
    VE => { code => "VE", no => 58,  name => "Venezuela" },
    VN => { code => "VN", no => 84,  name => "Viet Nam" },
);

sub new {
    my $class  = shift;
    my %params = (
        _url      => $SMS::Send::KR::CoolSMS::URL,
        _agent    => $SMS::Send::KR::CoolSMS::AGENT,
        _ssl      => $SMS::Send::KR::CoolSMS::SSL,
        _timeout  => $SMS::Send::KR::CoolSMS::TIMEOUT,
        _user     => q{},
        _password => q{},
        _enc      => q{},
        _from     => q{},
        _type     => $SMS::Send::KR::CoolSMS::TYPE,
        _country  => $SMS::Send::KR::CoolSMS::COUNTRY,
        @_,
    );

    warn("$class->new: _user is needed\n"),     return unless $params{_user};
    warn("$class->new: _password is needed\n"), return unless $params{_password};
    warn("$class->new: _from is needed\n"),     return unless $params{_from};

    my $self = bless \%params, $class;
    return $self;
}

sub send_sms {
    my $self   = shift;
    my %params = (
        _datetime => q{},
        _mid      => q{},
        _gid      => q{},
        @_,
    );

    my $text     = $params{text};
    my $to       = $params{to};
    my $datetime = $params{_datetime};
    my $mid      = $params{_mid};
    my $gid      = $params{_gid};

    my %ret = (
        success => 0,
        reason  => q{},
        detail  => +{},
    );

    $ret{reason} = 'text is needed', return \%ret unless $text;
    $ret{reason} = 'to is needed',   return \%ret unless $to;

    my $http = HTTP::Tiny->new(
        agent       => $self->{_agent},
        timeout     => $self->{_timeout},
        SSL_options => { SSL_hostname => q{} }, # coolsms does not support SNI
    ) or $ret{reason} = 'cannot generate HTTP::Tiny object', return \%ret;

    my $url  = $self->{_ssl} ? "https://$URL" : "http://$URL";

    my $password;
    if ( $self->{_enc} && $self->{_enc} =~ m/^md5$/i ) {
        $password = md5_hex( $self->{_password} );
    }

    my %form = (
        user     => $self->{_user},
        password => $password,
        enc      => $self->{_enc},
        from     => $self->{_from},
        type     => $self->{_type},
        country  => $self->{_country},
        to       => $to,
        text     => $text,
        datetime => $datetime,
        mid      => $mid,
        gid      => $gid,
    );
    $form{$_} or delete $form{$_} for keys %form;

    my $res = $http->post_form( $url, \%form );
    $ret{reason} = 'cannot get valid response for POST request';
    if ( $res && $res->{success} ) {
        my %params = ( $res->{content} =~ /^([^=]+)=(.*?)$/gms );

        $ret{detail}  = \%params;
        $ret{reason}  = $params{'RESULT-MESSAGE'};
        $ret{success} = 1 if $params{'RESULT-CODE'} eq '00';
    }
    else {
        $ret{detail} = $res;
        $ret{reason} = $res->{reason};
    }

    return \%ret;
}

1;
__END__

=head1 SYNOPSIS

    use SMS::Send;

    # create the sender object
    my $sender = SMS::Send->new('KR::CoolSMS',
        _ssl      => 1,
        _user     => 'keedi',
        _password => 'mypass',
        _type     => 'sms',
        _from     => '01025116893',
    );

    # send a message
    my $sent = $sender->send_sms(
        text => 'You message may use up to 80 chars and must be utf8',
        to   => '01025116893',
    );

    unless ( $sent->{success} ) {
        warn "failed to send sms: $sent->{reason}\n";

        # if you want to know detail more, check $sent->{detail}
        use Data::Dumper;
        warn Dumper $sent->{detail};
    }


=head1 DESCRIPTION

SMS::Send driver for sending SMS messages with the L<coolsms SMS service|http://api.coolsms.co.kr>.


=method new

This constructor should not be called directly. See L<SMS::Send> for details.


=head1 SEE ALSO

=for :list
* L<SMS::Send>
* L<SMS::Send::Driver>
* L<coolsms API Manual|http://api.coolsms.co.kr>
