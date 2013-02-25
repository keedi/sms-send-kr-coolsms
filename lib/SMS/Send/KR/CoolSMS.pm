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
