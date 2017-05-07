#!/usr/bin/env perl
#
# sshtunnel.pl	
#
# $Id: ssltunnel.pl,v 1.17 2003/06/10 14:54:16 alex Exp $
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Copyright 2002, 2003 Alex Hornby <alex@hornby.org.uk>
#
# Inspired by ssh-tunnel.pl by Urban Kaveus <urban@statt.ericsson.se>
#
# Run perldoc on this script to see the documentation

my $VERSION=1.0;
package ssltunnel;
use strict;

use IO::File;
use IO::Select;
use IO::Socket;
use Getopt::Long;
use MIME::Base64;

my %options = (
    proxyport=>8080,
    reproxyport=>8080,
    localaddr=>"127.0.0.1",
);

sub usage
{
    print STDERR <<EOF;
usage: perl ssltunnel.pl [options] desthost destport
Tunnels a TCP/IP connection through an http proxy using SSL.

WARNING: Only use this if you have the proxy administrator\'s permission
WARNING: The authors of this package offer no warranty

options:
    --help                        This help
    --proxyuser <username>        Optional proxy user name
    --proxypasswd pass            Optional proxy pass word
    --proxyhost 1.2.3.4           Mandatory proxy host IP or name
    --proxyport 123               Optional proxy host port (default 8080)
    --reproxyhost 1.2.3.4         Optional intermediate proxy host
    --reproxyport 123             Optional intermediate proxy host
    --reproxypasswd pass          Optional proxy pass word
    --reproxyhost 1.2.3.4         Mandatory proxy host IP or name
    --localport 123               Optional local port to listen on
    --localaddr 1.2.3.4           Optional local addr to listen on (default 127.0.0.1)

e.g. To run a local proxy to the public SDF shell service:

./ssltunnel.pl --proxyhost gatekeeper \
  --proxyport 8080 --localport 23002 sdf.lonestar.org 22

EOF
    exit(1);
}

# Parse command line arguments
sub parseArgs
{
    GetOptions(\%options, qw/dumpfile=s useragent=s
		   proxyhost=s proxyport=i proxyuser=s proxypasswd=s 
		   desthost=s destport=i localaddr=s localport=i 
		   reproxyhost=s reproxyport=i reproxyuser=s reproxypasswd=s
		   debug! name=s help!
		   log-file=s pidfile=s nodaemon!/);

    if ( $options{help} ) {
	usage();
    }

    if ( $#ARGV != 1 ) {
	print STDERR "error: Not enough arguments\n";
	usage();
    }
    $options{desthost} = $ARGV[0];
    $options{destport} = $ARGV[1];

    if ( !defined($options{proxyhost}) ) {
	print STDERR "error: You must give a proxyhost\n";
	usage();
    }
}

sub connectProxy
{
    my $proxy = new IO::Socket::INET (
	PeerAddr => $options{proxyhost},
	PeerPort => $options{proxyport},
	Proto => 'tcp',
    );

    die "Error connecting to proxy host $options{proxyhost} " . 
	"port $options{proxyport}: $!\n" unless $proxy;

    # Force flushing of socket buffers
    $proxy->autoflush(1);

    if ( $options{reproxyhost} ) {
	# First contect to local proxy
	httpProxy($proxy, $options{reproxyhost}, $options{reproxyport},
		  $options{proxyuser}, $options{proxypasswd} );
	# Then forward to next proxy
	print STDERR "Now connecting to second proxy\n";
	httpProxy($proxy, $options{desthost}, $options{destport},
	$options{reproxyuser}, $options{reproxypasswd} )
    } else {
	httpProxy($proxy, $options{desthost}, $options{destport},
		  $options{proxyuser}, $options{proxypasswd} )
    }

    return $proxy;
}

sub httpProxy
{
    my ( $proxy, $desthost, $destport, $proxyuser, $proxypasswd ) = @_;
    # Force flushing of socket buffers

    # The actual connect
    $proxy->print("CONNECT " .  $desthost . ":" .
		      $destport . " HTTP/1.0\r\n");
    if ( $options{debug} ) {
	print STDERR "CONNECT " .  $desthost . ":" .
		      $destport . " HTTP/1.0\n";
    }

    # Basic auth if needed
    if ( $proxyuser ) {
	my $auth = encode_base64(
	    $proxyuser . ":" . $proxypasswd);
	$proxy->print("Proxy-authorization: Basic $auth\r\n");
	if ( $options{debug} ) {
	    print STDERR "Proxy-authorization: Basic $auth"
	}
    }

    # User agent name if needed
    if ( $options{useragent} ) {
	$proxy->print("User-Agent: " . $options{useragent} . "\r\n");
	if ( $options{debug} ) {
	    print STDERR "User-Agent: " . $options{useragent} . "\n";
	}
    }

    # end of headers
    $proxy->print("\r\n");

    my $status;
    # Wait for HTTP status code, bail out if you don't get back a 2xx code.
    $_ = $proxy->getline();
    next if /^[\r]*$/;
    ($status) = (split())[1];
    die("Received a bad status code \"$status\" from proxy server\n$_") 
	if ( int($status/100) != 2 );

    while($_ = $proxy->getline()) {
	 if ( $options{debug} ) {
	     print STDERR "Got extra data [$_]\n";
	 }
	chomp;   # Strip <LF>
	last if /^[\r]*$/;		# Empty line or a single <CR> left
    }

    return $status;
}

sub stdioMainLoop
{
    my($fhin, $fhout, $proxy) = @_;

    # UTF-8 locales mean we need this.
    binmode $fhin;
    binmode $fhout;

    $| = 1;
    select ($fhin);
    select ($fhout);

    # Start copying packets in both directions.
    my $s = IO::Select->new($fhin, $proxy);

    my $dumpfh;

    if ( $options{dumpfile} ) {
	$dumpfh = new IO::File($options{dumpfile}, "w")
	    or die "could not open dump file $_";
	$dumpfh->autoflush(1);
    }

    while ( 1 ) {
	for my $fh ( $s->can_read(10) ) {
	    my $num = sysread($fh, $_, 4096);
	    exit unless ( $num );
	    syswrite(((fileno($fh)==fileno($fhin))?$proxy:$fhout), $_, $num);

	    if ( $dumpfh ) {
		if (fileno($fh)==fileno($proxy)) {
		    $dumpfh->print("proxy[$_]\n");
		}
		if (fileno($fh)==fileno($fhin)) {
		    $dumpfh->print("client[$_]\n");
		}
	    }
	}
    }
}

sub connectLocal
{
    my $listen = new IO::Socket::INET (
	Listen=> 5,
	LocalAddr => $options{localaddr},
	LocalPort => $options{localport},
	Proto => 'tcp',
	Reuse => 1,
    );

    die "can't listen on " . $options{localaddr} . ":"
	. $options{localport} unless $listen;

    print STDERR "Accepting network clients on " .
	$options{localaddr} . ":" .$options{localport} . "\n";

    my %client2proxy;
    my %proxy2client;

    my $s = IO::Select->new();
    $s->add($listen);

    my $dumpfh;
    if ( $options{dumpfile} ) {
	$dumpfh = new IO::File($options{dumpfile}, "w")
	    or die "could not open dump file $_";
	$dumpfh->autoflush(1);
    }

    while ( 1 ) {
	my @res = IO::Select::select($s, undef, undef, 3600);
	if ( @res == 0 ) {
	    print STDERR "got select error\n";
	    last;
	}
	my ($read, $write, $error) = @res;

	# Check for disconnect
	for my $fh ( @$error ) {
	    print STDERR "socket $fh is in error\n";
	    $s->remove($fh);
	    exit();
	}

	# Process handles ready to read;
	for my $fh ( @$read  ) {

	    if ( $fh == $listen ) {
		my $client = $listen->accept();
		$client->autoflush(1);
		$s->add($client);
		my $proxy = connectProxy();
		$s->add($proxy);
		print STDERR "New connection from " . $client->peerhost() . "\n";
		$client2proxy{$client} = $proxy;
		$proxy2client{$proxy} = $client;
	    } else {
		my $destfh;
		my $isclient = 0;
		if ( exists( $client2proxy{$fh} ) ) {
		    $destfh = $client2proxy{$fh};
		    $isclient = 1;
		} elsif ( exists( $proxy2client{$fh} ) ) {
		    $destfh = $proxy2client{$fh};
		}

		my $num = sysread($fh, $_, 4096);
		if ( $num) {
		    syswrite($destfh, $_, $num);
		    # Optional dump of traffic
		    if ( $dumpfh ) {
			if ($isclient) {
			    $dumpfh->print("client[$_]\n");
			} else {
			    $dumpfh->print("proxy[$_]\n");
			}
		    }
		} else {
		    $s->remove($fh);
		    $s->remove($destfh);
		    if ( $isclient ) {
			print STDERR "client disconnected\n";
			delete($client2proxy{$fh});
			delete($proxy2client{$destfh});
		    } else {
			print STDERR "proxy disconnected\n";
			delete($client2proxy{$destfh});
			delete($proxy2client{$fh});
		    }
		    if(%proxy2client == 0 ) {
			print STDERR "last client disconnected\n";
		    }
		}
	    }
	}
    }
}

parseArgs;
if ( $options{localport} ) {
    connectLocal;
} else {
    my $proxy = connectProxy;
    stdioMainLoop(\*STDIN,\*STDOUT, $proxy);
}

=head1 NAME

B<ssltunnel.pl> - Tunnels a TCP/IP connection through an http proxy using
SSL. Can work both with SSH or standalone. Has the notion of
"reproxying" to work around proxies that insert bytes into the i/o
stream.

=head1 DESCRIPTION

B<The world's greatest SSL tunnelling script>. Its got it all!

=over

=item

Supports reproxying to build a chain of proxies, thus allowing access
even if your local proxy inserts characters that would normally mess
up SSH

=item

Tunnels SSH through web proxies

=item

Can listen on a local port, allowing port forwarding without SSH

=item

Can list on STDIN/OUT, allowing port forwarding under SSH

=item

Supports BASIC authentication to both the proxy and reproxy

=item

Uses IO::Select instead of forking for better performance and less load

=item

Works properly under UTF-8 locales

=item

Nicely formatted source!

=back

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 README

B<ssltunnel.pl - The world's greatest SSL tunnelling script>. Its got it
all! Supports reproxying to build a chain of proxies, thus allowing
access even if your local proxy inserts characters that would normally
mess up SSH. Supports BASIC auth. Can even work without SSH.

usage: perl ssltunnel.pl [options] desthost destport
Tunnels a TCP/IP connection through an http proxy using SSL.

WARNING: Only use this if you have the proxy administrator\'s permission
WARNING: The authors of this package offer no warranty

options:
    --help                        This help
    --proxyuser <username>        Optional proxy user name
    --proxypasswd pass            Optional proxy pass word
    --proxyhost 1.2.3.4           Mandatory proxy host IP or name
    --proxyport 123               Optional proxy host port (default 8080)
    --reproxyhost 1.2.3.4         Optional intermediate proxy host
    --reproxyport 123             Optional intermediate proxy host
    --reproxypasswd pass          Optional proxy pass word
    --reproxyhost 1.2.3.4         Mandatory proxy host IP or name
    --localport 123               Optional local port to listen on
    --localaddr 1.2.3.4           Optional local addr to listen on (default 127.0.0.1)

e.g. To run a local proxy to the public SDF shell service:

./ssltunnel.pl --proxyhost gatekeeper \
  --proxyport 8080 --localport 23002 sdf.lonestar.org 22

=head1 PREREQUISITES

All necessary modules are included in perl 5.8.0. These include the
C<IO::Socket::INET>, C<IO::Select>, C<Getopt::Long>, and C<MIME::Base64>
modules.

=head1 AUTHOR

Alex Hornby <alex@hornby.org.uk>

Inspired by ssh-tunnel.pl by Urban Kaveus <urban@statt.ericsson.se>

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=pod OSNAMES

any

=cut

=pod SCRIPT CATEGORIES

Networking
Web

=cut

