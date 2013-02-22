package SMS::Send::KR::CoolSMS;
# ABSTRACT: An SMS::Send driver for the coolsms.co.kr service

use Moo;
use namespace::autoclean;

1;
__END__

=head1 SYNOPSIS

    use SMS::Send::KR::CoolSMS

    # create the sender object
    my $sender = SMS::Send->new('KR::CoolSMS',
        _user     => 'keedi',
        _password => 'mypass',
    );
    # send a message
    my $sent = $sender->send_sms(
        text => 'You message may use up to 80 chars',
        to'  => '+49 555 4444',
    );
    
    if ( $sent ) {
        print "Sent message\n";
    } else {
        print "Failed to send test message\n";
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
