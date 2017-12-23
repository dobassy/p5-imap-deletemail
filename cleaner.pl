#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use Encode;
use IO::Socket::SSL;
use Mail::IMAPClient;
use DateTime;
use DDP;

my $user   = $ENV{X_IMAP_REDMINE_USER} or die 'not set X_IMAP_REDMINE_USER';
my $pass   = $ENV{X_IMAP_REDMINE_PASS} or die 'not set X_IMAP_REDMINE_PASS';
my $logdir = "$FindBin::Bin/log/remove_mail.log";
my $host   = $ENV{X_IMAP_REDMINE_MAILHOST} or die 'not set X_IMAP_REDMINE_MAILHOST';

my $socket = IO::Socket::SSL->new(
	PeerAddr => $host,
	PeerPort => 993,
) or die "socket(): $@";

my $client = Mail::IMAPClient->new(
	Socket   => $socket,
	User     => $user,
	Password => $pass,
) or die "new(): $@";

my $dt = DateTime->now(time_zone => 'Asia/Tokyo');

open my $fh, '>>', $logdir;
if ($client->IsAuthenticated())
{
	$client->select("INBOX");
  my @seenMsgs = $client->seen or die "No seen msgs: $@\n";

  for my $msg (@seenMsgs) {
    my $hashref = $client->parse_headers($msg, 'Date','Received','Subject','To','From');
    # p $hashref;

    my $subject = Encode::decode('MIME-Header', $hashref->{Subject}->[0]);
    my $logformat = sprintf("%s removed: %s by [%s]\n", $dt, $subject, $hashref->{From}->[0]);
    $logformat = Encode::encode_utf8($logformat);
    print $fh $logformat;

    $client->delete_message($msg);
  }
}
close $fh;

$client->logout();
