package SMS::Send::KR::CoolSMS;
# ABSTRACT: An SMS::Send driver for the coolsms.co.kr service

use strict;
use warnings;
use parent qw( SMS::Send::Driver );

our $AGENT   = 'SMS-Send-KR-CoolSMS/' . $SMS::Send::KR::CoolSMS::VERSION;
our $SSL     = 0;
our $TIMEOUT = 3;
our $TYPE    = 'sms';
our $COUNTRY = 'KR';

sub new {
    my $class  = shift;
    my %params = (
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
