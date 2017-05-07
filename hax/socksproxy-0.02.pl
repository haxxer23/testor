#!/usr/bin/perl
#Socks Proxy Server

##############################################################################
#
#  This script is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the
#  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#  Boston, MA  02111-1307, USA.
#
#  Copyright (C) 2005 Emmanuel Elango.
#
##############################################################################

=head1 NAME

SocksProxy - A SOCKS v5 Proxy Server, single threaded yet capable of handling multiple sockets.

=head1 DESCRIPTION

This is full fledged Socks v5 proxy server.

By design it is single threaded and handles multiple sockets using select.

It does not use threads or fork therefore it consumes very little memory. 
It is also very fast because it does very little processing other than reading or writing to sockets 
and is quiescent (as defined in Advanced Perl Programming - 
does not unnecessarily loop around but waits till there is something to do) otherwise.


=head2 Why another socks proxy server?

There are dozens of Socks proxy server floating around. Most of them have features far more than this and better written. 
A good one is Dante available at http://www.inet.no/dante/
However all the unix/linux based ones require fork and consume much more memory than required. 
Of course on a modern system it wouldnt be noticeable but systems with less than 32 MB of RAM and 200 Mhz of CPU 
stuff like Dante are too heavy.

Portability across platforms is another problem. With perl (and as long as you dont use fork) you can more or less be 
certain that it will work anywhere. The windows hack is an ugly one though. Beware! 
Major modifications of the IO::Socket::Socks perl module was required to get it running on perl 5.005_03 on a DEC OSF4 machine. 
If you want that module please email me.

Thirdly this is proof of concept that network apps need not fork.

=head2 How to use?

Just configure the parameters in the user configurable section below. 
You will need to set the hostname/ip and the port on which you want to run the server.

Set the userid and the password also. 
Please note that the passwords are transferred over the network in clear text. There is no encryption or SSL.

=head1 PREREQUISITES

Requires the following modules: C<Socket>, C<IO::Socket>, C<IO::Select>, C<IO::Socket::Socks>, C<Filehandle> and C<Fcntl>.

=head1 AUTHOR

Emmanuel Elango

=head1 COPYRIGHT

This script is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 README

B<SocksProxy> - A full fledged platform independent SOCKS v5 Proxy Server, 
single threaded yet capable of handling multiple connections.
Supports the full SOCKS v5 specifications (except the encrypted auth mechanisms).


=head1 CAVEATS

The script will hang indefinitely if a client does not complete the initial SOCKS handshake properly
but still keeps the connection open. The script does *not* multitask when an initial handshake is in progress.

When the clients are on a local network as this proxy script the effect is not visible. However if the script
is to run as a remote proxy where there is significant lag between the client and the proxy the effect may be noticeable.

This is because the IO::Socket::Socks module does not support any form of timeout or release the script to 
do something else during the initial handshake if the handshake is taking too long. 

On *nix systems one possible workaround is to enclose the Socks accept in an alarm and eval construct.

=head1 TODO

-Convert the code to OO form. Its pretty unmanageable now.
-Create a separate configuration file and have a better way to set options.
-Modify the IO::Socket::Socks module so that it supports timeouts and reentry during initial handshake.
-Add a GUI?
-Add support for other authentication methods and encryption.

=head1 CHANGES

See the Changes file in the same directory.


=pod OSNAMES

any

=pod SCRIPT CATEGORIES

Networking

=cut


BEGIN {
	require Errno;
     	 import  Errno qw(EWOULDBLOCK EINPROGRESS);
     	}

use Socket;
use IO::Socket;
use IO::Select;
use IO::Socket::Socks;
use FileHandle;
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);


#############################################
#############################################
# User configurable parameters
#
#Set the proxy hostname or ip below.
$hostname = 'localhost';
#
#Set the proxy port below.
$hostport = '1080';
#
#Set the socks user id below. It is recommended to change the defaults below to prevent misuse of your proxy server.
#Please note that the username and password are sent in clear text and can be easily sniffed on a network. For greater 
#security you could allow only certain hosts to connect by modifiying the IO::Socket::Socks module. A modified module 
#is available in the same directory as this script. Instructions are in the modifed module.
$socksuser = 'foo';
#
#Set the password below.
$socksuserpass = 'bar';
#
###############################################
###############################################



#sub  timeout();


#daemonize?

#	$pid = fork();   													#	
#	if ($pid != 0)   													#	
#	{                													#	
#		close ();													#	
#		exit();  													#	
#	}                													#	
#	else             													#	
#	{                													#	
	         														
	

$SIG{PIPE} = 'IGNORE';
#$SIG{ALRM} = \&timeout;

$server = IO::Socket::Socks->new(	ProxyAddr=> $hostname,
					ProxyPort=> $hostport, 
			               	Listen=>1,
                                	UserAuth=>\&auth,
					RequireAuth=>1,
                                	) or die "Unable to bind server socket $!\n";
if ($^O =~ m/Win32/)
{
	my $temp = 1;
	#ioctl($server, 0x8004667E, \$temp);                                  		
}
else
{

if ($flags = fcntl($server, F_GETFL, 0)<0)
{
	die "Unable to get server socket flags\n";
}
					 
 if (($flags = fcntl($server, F_SETFL, $flags | O_NONBLOCK)) < 0)
 {
 	
        	die "Unable to set server socket to at non-block\n";
 }                                  		
                                  		
}                                  		
                                  		
$readable =  IO::Select->new();
$writable =  IO::Select->new();
$readable ->add($server);
#print "Server ID $server \n";
while (1)
{ #print "Entering Select\n";
if (defined (($sockets_read, $sockets_write) = IO::Select->select($readable,$writable,undef)))
{	
	#print "Select returned\n";
	#$pause = <STDIN>;
	#print $sockets_read[0]->[0];
       	foreach  $sock (@$sockets_read)
       	{
       		#print "Got a socket to work on	$sock\n";
       		if ($sock == $server)
       		{
       			#print "Detected Server Socket Read\n";
       			#alarm 5;
			eval {$client = $server->accept();};
			if ($@) {print "$@\n";}
			if ($@) {next;}
			if(defined($client))
			{
				
				if ($^O =~ m/Win32/)
				{
					my $temp = 1;
					#ioctl($client, 0x8004667E, \$temp);                                  		
				}
				else
				{
				if ($flags = fcntl($client, F_GETFL, 0)<0)
				{
					print "Unable to get client socket flags\n";
				        	close($client);
				        	next;
				}
				 if (($flags = fcntl($client, F_SETFL, $flags | O_NONBLOCK))<0)
				 {
				 	
				        	print "Unable to set client socket to non-block\n";
				        	close($client);
				        	next;
				  }
				}
				#print "$client Accepted \n";	
				#alarm 0;
				$client->autoflush(1);
				$command = $client->command();
				#printf "Command = %x", $command->[0], "\n";
				
				if ($command->[0] == 1)
				{
					#print "Command: ",$command->[0]," Host: ",$command->[1], " Port: ", $command->[2],"\n";
					if (!($remote = IO::Socket::INET->new()))
					{
						$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at IO::Socket create Error: $@\n";
					        	close($client);
					        	next;
					 }
					 $proto = getprotobyname('tcp');
					 $remote->socket(AF_INET, SOCK_STREAM, $proto);
					 
					if ($^O =~ m/Win32/)
					{
						my $temp = 1;
						#ioctl($remote, 0x8004667E, \$temp);                                  		
					}
					else
					{
					 if ($flags = fcntl($remote, F_GETFL, 0)<0)
					{
						$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at get flags\n";
					        	close($client);
					        	next;
					 }
					 
					 if (($flags = fcntl($remote, F_SETFL, $flags | O_NONBLOCK))<0)
					 {
					 	$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at non-block\n";
					        	close($client);
					        	next;
					  }
					}
				               if (!($iaddr = inet_aton($command->[1])))
				               {	
				               	$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at inet_aton\n";
					        	close($client);
					        	next;
					 }
				               
				               if (!($sockaddr = sockaddr_in($command->[2], $iaddr)))
				               {	
				               	$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at sockaddr_in\n";
					        	close($client);
					        	next;
					  }
					  
					  if ($remote->connect($sockaddr))
					  {
					  	$hash{$client}= $remote;
					        	$hash{$remote}= $client;
					        	#$port = $remote->sockport();
					        	#print "Peerhost = ",$remote->peerhost(),"Port = " ,$remote->peerport(),"\n";
					        	$client->command_reply(0,$remote->sockhost(),$remote->sockport());#$remote->sockhost(), $remote->sockport());
					        	#print "Sent reply at CONNECT\n";
					        	$readable->add($client);
				       		$readable->add($remote);
				       		$remote->autoflush(1);
				       	}
				       	elsif ($! == EWOULDBLOCK or $! == EINPROGRESS)
				       	{	
				       		$writable->add($remote);
				       		$connectpending{$client} = $remote;
				       		$connectpending{$remote} = $client;
				       	}
				       	else
					{
					        	$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at CONNECT\n";
					        	close($client);
					        	next;
					}
			       	} 
			       	elsif ($command->[0]==2)
			       	{
			       		print "BIND detected\n";
			       		print "Command 1 = ", $command->[0],"        Command 2 = ", inet_ntoa(inet_aton($command->[1])),"        Command 3 = ", $command->[2],"\n";
			       		if ($command->[2] < 1024) { $port = 0;} else {$port = $command->[2];}
			       		print "$port\n";
			       		$remote = IO::Socket::INET->new(Listen    => 1,
			                                  LocalAddr => '202.41.106.14',
			                                  LocalPort => $port,
			                                 Proto     => 'tcp',
			                                 Blocking =>0,
			                                 Reuse => 1);
			                
				                if($remote)
				                {
				                  	$hash{$client}= $remote;
					        	$hash{$remote}= $client;
					        	$client->command_reply(0, $remote->sockhost(), $remote->sockport());
					        	print $remote->sockhost(), $remote->sockport(),"\n";
					        	#print "Sent reply at BIND\n";
					        	$readable->add($client);
				       		$readable->add($remote);              																																									
				       		$servers{$remote} = $client;          																																									
				       		#$servers{$client} = $remote;         																																									
				       		$commands{$client} = $command->[1];   																																									
					  }                                           																																									
					  else                                        																																									
					  {                                           																																									
					      	$client->command_reply(4,undef,undef);
					      	print "Sent error at BIND\n";																																									
					        	close($client);               																																									
					  }                                           																																									
					        
				}
			       	elsif ($command->[0]==3)
				{
					
					if ($command->[2] < 1024) { $port = 0;} else {$port = $command->[2];}
					(exists $udpinuse1{$port}) ? $port = 0:$port;
					$udp = 	IO::Socket::INET->new(
			                             	LocalPort => $port,
			                                  	LocalAddr => '202.41.106.14',
			                                 	Proto     => 'udp',
			                                 	Blocking =>0,
			                                 	Reuse => 1);
			                                 	
			                             
			                                 
			                             if (!$udp)
			                                 {
			                                 	$client->command_reply(1,undef,undef);
					        	print "Sent reply error at new UDP server socket $!\n";
					        	$client->command_reply(1,undef,undef);
					        	close($client);
					        	next;
					     }    
					     if ($^O =~ m/Win32/)
						{
							my $temp = 1;
							#ioctl($udp, 0x8004667E, \$temp);                                  		
						}
						else
						{
			                                 if ($flags = fcntl($udp, F_GETFL, 0)<0)
			                                 {
			                                 	$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at get flags\n";
					      	close($client);
					      	next;
					      }
					 
					 if (($flags = fcntl($udp, F_SETFL, $flags | O_NONBLOCK))<0)
					{
						$client->command_reply(1,undef,undef);
					        	#print "Sent reply error at non-block\n";
					      	close($client);
					      	next;
					        	
					  }
					}  
					  
					  
		                                 	$udpassociate{$client} = $udp;
		                                 	$udpservers{$udp} = $client;
		                                 	$command->[1] ? $udpadd{$udp} = $command->[1]:$udpadd{$udp} = $client->peerhost();
		                                 	$udpport{$udp} = $command->[2];
		                                 	$client->command_reply(0,$udp->sockhost(), $udp->sockport());
		                                 	$port = $udp->sockport();
		                                 	$readable->add($udp);
		                                 	$readable->add($client);
		                                 	$udpinuse1{$port} = $client;
		                                 	$udpinuse2{$client} = $port;
		                                 	print STDOUT "UDP Server setup Host: ", $udp->sockhost(),"  Port: ", $udp->sockport(),"\n";
		                                 	print STDOUT "UDP Server client Host: ", $udpadd{$udp}," Port: ", $udpport{$udp},"\n";
		                                
			                                 
			                                          
				}
			       	else
			       	{
			       		$client->command_reply(7,undef,undef); #Command not supported
			       		close($client);
			       	}
			       	
			}
			else
			{
				#alarm 0;
				print "Socks Accept failed Error: $! \n";
			}
				
					
       		}
       		
       		elsif (exists ($servers{$sock}))
       		{
       			print "Detected incoming to BIND\n";
       			if (defined ($remoteserver = $sock->accept()))
       			{	
       				
       				if ((inet_aton($commands{$servers{$sock}})) eq (inet_aton($remoteserver->peeraddr())))
       				{
       					$servers{$sock}->command_reply(0,$sock->peeraddr(),$sock->peerport());
       					
       					$hash{$remoteserver} = $servers{$sock};
       					$hash{$servers{$sock}} = $remoteserver;
       					delete $servers{$servers{$sock}};
       					delete $commands{$servers{$sock}};
       					delete $hash{$sock};
       					delete $servers{$sock};
       					#print "Sent reply at BIND CONNECT\n";
       					$readable->remove($sock);
       					close($sock);
       					$readable->add($remoteserver);
       					$readable->add($hash{$remoteserver});
       				}	
       				else
				{
					$servers{$sock}->command_reply(1,undef,undef);
					#print "Sent error at BIND CONNECT bad IP\n";
					$readable->remove($sock);
					close($sock);
					close($servers{$sock});
					delete $servers{$hash{$sock}};
					delete $servers{$sock};
					delete $commands{$hash{$sock}};
					delete $hash{$hash{$sock}};
					delete $hash{$sock};
					
					
				}
			}
			else
			{
				$servers{$sock}->command_reply(1,undef,undef);
				#print "Sent error at BIND CONNECT \n";
				$readable->remove($sock);
				close($sock);
				close($servers{$sock});
				delete $servers{$hash{$sock}};
				delete $servers{$sock};
				delete $commands{$servers{$sock}};
				delete $hash{$hash{$sock}};
				delete $hash{$sock};
			}	
		
		}
		elsif (exists ($udpassociate{$sock}))
       		{       					
       			
       			print "Control socket read detected\n";
       			$bytesread = sysread($sock,$databuf, 102400,0);
       			if((!defined($bytesread )) or ($bytesread == 0))
       	       		{	
       				print "Control socket close detected\n";
       				$readable->remove($sock);
       				$readable->remove($udpassociate{$sock});
       				close($sock);
       				close($udpassociate{$sock});
       				delete ($udpport{$udpassociate{$sock}});
       				delete ($udpadd{$udpassociate{$sock}});
       				delete $udpinuse1{$udpinuse2{$sock}};
       				delete $udpinuse2{$sock};
       				delete ($udpservers{$udpassociate{$sock}});
       				delete ($udpassociate{$sock});
       				
       			}
       				
       		}
       		elsif (exists ($udpservers{$sock}))
       		{
       			$paddr = recv($sock,$databuf, 102400,0);
       			#print STDOUT "Reached UDP1\n";
       			if((defined($paddr)))
       	       		{	
       				#print STDOUT "Reached UDP2\n";
       				($port, $ipaddr) = sockaddr_in($paddr);
       				
       				#$port = $sock->peerport();
       				#$ipaddr = $sock->peerhost();
       				#print STDOUT "From: ",inet_ntoa($ipaddr), " $port\n";
       				if (($udpadd{$sock} eq inet_ntoa($ipaddr)) and ($udpport{$sock} == $port))
       				{
       					#print STDOUT "Detected local auth access UDP\n";
       					if (ord((substr($databuf,2,1))) != 0)
       					{
       						next;
       					}
       					if(ord((substr($databuf,3,1))) == 1)
       					{
       						#print "UDP IP given\n";
       						$udpremoteip =  substr($databuf,4,4);
       						$udpremoteport = unpack("n",substr($databuf,8,2));
       						#($udpremoteport == 9) ? $udpremoteport = 11 : $udpremoteport;
       						$data = substr($databuf,10,length($databuf) - 10);
       						#print "To: ", inet_ntoa($udpremoteip), " $udpremoteport\n";
       					}
       					elsif (ord((substr($databuf,3,1))) == 3)
       					{
       						#print "UDP ADD given\n";
       						$chars = ord((substr($databuf,4,1)));
       						$udpremoteadd = substr($databuf,5,$chars);
       						$udpremoteip   = gethostbyname ($udpremoteadd);
       						$udpremoteport = unpack("n",substr($databuf,4+$chars,2));
       						$data = substr($databuf,6+$chars,(length($databuf) - (6+$chars)));
       						#print $udpremoteadd, " $udpremoteport\n";
       					}
       					else
       					{
       						next;
       					}
       					
       					$portaddr = sockaddr_in($udpremoteport, $udpremoteip);
       					
       					if (send($sock, $data, 0, $portaddr) != length($data))
       					{
       						print STDOUT "Remote UDP Send error $!\n";
       					}
       				}
       				else
       				{
       					#print STDOUT "Detected remote incoming access UDP\n";
       					$portaddr = sockaddr_in($udpport{$sock}, inet_aton($udpadd{$sock}));
       					if (!(send($sock,chr(0).chr(0).chr(0).chr(1). $ipaddr.pack("n",$port).$databuf, 0, $portaddr) ))
       					{
       						print STDOUT "Local UDP Send error\n $!";
       					}
       				}
       			}
        
       		
       		
       		}
       		
       		else
       		{	#print "Detected read on normal socket $sock\n";
       	       		if (length($data{$sock})>32768)
       	       		{
       	       			#print "Read paused. Buffers full on $sock\n";
       	       			$readpaused{$sock} = 1;
       	       			$readable->remove($sock);
       	       			next;
       	       		}
       	       		$bytesread = sysread($sock,$databuf, 102400,0);
       	       		#print "Bytes read = $bytesread from Socket $sock  \n";#Buffer = $databuf MOTE \n";
       	       		if(!defined($bytesread ))
       	       		{
       	       			
       	       			#print "Error occured  in READ.  Closing socket. $sock \n";
       	       			#$sock->flush();
       	       			#$hash{$sock}->flush();
       	       			if (exists ($hash{$sock}))
       	       			{
	       	       			$readable->remove($sock);
	       	       			#print "Removed first readable socket\n";
	       	       			$readable->remove($hash{$sock});
	       	       			#print "Removed second readable socket\n";
	       	       			$writable->remove($sock);
	       	       			#print "Removed first readable socket\n";
	       	       			close ($sock);
	       	       			delete($data{$hash{$sock}});
	       	       			if (!(length($data{$sock})))
	       	       			{
		       	       			$writable->remove($hash{$sock});
			       	       		#print "Removed second readable socket $hash{$sock}. Cleaning up in READ error\n";
		       	       			#close($sock);
		       	       			close($hash{$sock});
		       	       			delete($data{$hash{$sock}});
		       	       			delete($data{$sock});
		       	       			#delete($hash{$hash{$sock}});
		       	       			delete($hash{$sock});
		       	       			delete($readpaused{$sock});
		       			}       			
	       	       			if (exists($servers{$hash{$sock}}))
	       	       			{
	       	       				delete $servers{$hash{$sock}};
	       	       				delete $commands{$sock};
	       	       			}
	       	       			
	       	       		}
	       	       		
	       	       		
       	     		}
       	     		elsif (($bytesread == 0))
       	     		{	
       	     			#print "Socket closed  in READ.  Closing socket $sock.\n";
       	     			
       	     			if (exists ($hash{$sock}))
       	     			{
	       	     			$readable->remove($sock);
	       	       			$readable->remove($hash{$sock});
	       	       			$writable->remove($sock);
	       	       			close($sock);
	       	       			delete($data{$hash{$sock}});
	       	       			if (!(length($data{$sock})))
	       	       			{
						#print "Removed second writable socket $hash{$sock}. Cleaning up in READ close\n";
		       	       			$writable->remove($hash{$sock});
			       	       		#print "Removed second readable socket\n";
		       	       			#close($sock);
		       	       			close($hash{$sock});
		       	       			delete($data{$hash{$sock}});
		       	       			delete($data{$sock});
		       	       			#delete($hash{$hash{$sock}});
		       	       			delete($hash{$sock});
		       	       			delete($readpaused{$sock});
		       			}       			
	       	       			
	       	       			if (exists ($servers{$hash{$sock}}))
	       	       			{
	       	       				delete $servers{$hash{$sock}};
	       	       				delete $commands{$sock};
	       	       			}
	       	       			
	       	       		}
       	       		}
       	     		else
       	     		{
       	     			if (exists ($hash{$sock}))
       	     			{
       	     				$data{$sock}.=$databuf;
       	     		
	       	       			$bytessent= syswrite($hash{$sock},$data{$sock},length($data{$sock}),0);
	       	       			
	       	       			
	       	       			if(!defined($bytessent))
		       	       		{
		       	       			if ( !(($! == EWOULDBLOCK) or ($! == EAGAIN)))
		       	       			{
			       	       			#print "Error occured in READ-WRITE.  Closing socket $hash{$sock}\n";
			       	       			if (defined ($hash{$sock}))
			       	       			{
				       	       			$readable->remove($sock);
				       	       			$readable->remove($hash{$sock});
				       	       			$writable->remove($hash{$sock});
				       	       			close ($hash{$sock});
				       	       			delete($data{$sock});
				       	       			if (!(length($data{$hash{$sock}})))
				       	       			{	
				       	       				#print "Removed first writable socket $sock. Cleaning up in READ-WRITE close\n";
					       	       			$writable->remove($sock);
					       	       			#close($hash{$sock});
					       	       			close($sock);
					       	       			delete($data{$hash{$sock}});
					       	       			#delete($data{$sock});
					       	       			delete($hash{$hash{$sock}});
					       	       			delete($hash{$sock});
					       	       			delete($readpaused{$sock});
					       	       		}
				       	       		}
		       	     			}
		       	     			else
		       	     			{
		       	     				#print "EWOULDBLOCK on ", $hash{$sock},"\n";
		       	     				$hash{$sock}->flush();
		       	     				$writable->add($hash{$sock});
		       	     			}
		       	     		}
		       	     		
		       	     	
		       	     		elsif ($bytessent < length($data{$sock}))
		       	     		{	
		       	     			#print "Partial Bytes sent = $bytessent to Socket $hash{$sock} in READ\n";
		       	     			$hash{$sock}->flush();
		       	     			$writable->add($hash{$sock});
		       	     			substr($data{$sock}, 0, $bytessent) = '';
		       	     			
		       	     		}
		       	     		
		       	     		else
		       	     		{	
		       	     			#print "Complete Bytes sent = $bytessent to Socket $hash{$sock} in READ\n";
		       	     			$hash{$sock}->flush();
		       	     			$writable->remove($hash{$sock});
		       	     			substr($data{$sock}, 0, $bytessent) = '';
		       	     		}
		       	     		
		       	     		
		       	     		#print "Buffer Length  = ", length($data{$sock});
	       	     		}
       	       		}
       	       	}
       		
       	}
       	foreach  $sock (@$sockets_write)
       	{	#print "Entered write section on $sock \n";
       		if (exists $connectpending{$sock})
       		{
       			if ($sock->peername())
       			{
	       			#print "Delayed connect success in WRITE\n";
	       			$hash{$sock}= $connectpending{$sock};
			        	$hash{$connectpending{$sock}}= $sock;
			        	#$port = $remote->sockport();
			        	#print "Peerhost = ",$sock->peerhost()," Port = " ,$sock->peerport(),"\n";
			        	$hash{$sock}->command_reply(0, $sock->sockhost(),$sock->sockport());#$hash{$sock}->sockhost(), $hash{$sock}->sockport());
			        	#print "Sent CONNECT reply in WRITE\n";
			        	$readable->add($sock);
		       		$readable->add($hash{$sock});
		       		$writable->remove($sock);
		       		$sock->autoflush(1);
		       		delete $connectpending{$connectpending{$sock}};
		       		delete $connectpending{$sock};
		       	}
		       	else
		       	{
       			        	#print "Delayed connect failed in WRITE\n";
       			        	$connectpending{$sock}->command_reply(1,undef,undef);
			        	#print "Sent CONNECT reply error in WRITE\n";
			        	$writable->remove($sock);
			        	close($sock);
			        	close($connectpending{$sock});
			        	delete $connectpending{$connectpending{$sock}};
			        	delete $connectpending{$sock};
			 }
			        	

	       	}
       		
       		elsif ((length($data{$hash{$sock}}))>0)
       		{
			#print "Whew I have something to write to $sock;-)\n";
       	       		$bytessent= syswrite($sock,$data{$hash{$sock}},length($data{$hash{$sock}}),0);
       			if(!defined($bytessent))
       	       		{
       	       			if (!(($! != EWOULDBLOCK) or ($! != EAGAIN)))
	       	       		{	
	       	       			#print "Error occured on $sock in WRITE\n";
	       	       			if (defined ($hash{$sock}))
		       	       		{
		       	       			$writable->remove($sock) if $writable->exists($sock);
		       	       			$readable->remove($sock) if $readable->exists($sock);
		       	       			$readable->remove($hash{$sock}) if $readable->exists($hash{$sock});
		       	       			close($sock);
		       	       			delete($data{$hash{$sock}});
		       	       			if (!(length($data{$hash{$sock}})))
		       	       			{
			       	       			$writable->remove($hash{$sock}) if $writable->exists($hash{$sock});
			       	       			#print "Removing first writable socket $hash{$sock}. Cleaning up in WRITE error.\n";
			       	       			close($hash{$sock});
			       	       			#close($sock);
			       	       			#delete($data{$hash{$sock}});
			       	       			delete($data{$sock});	       	       			
			       	       			delete($hash{$hash{$sock}});
			       	       			delete($hash{$sock});
			       	       			delete($readpaused{$sock});
			       	       		}
	
	       	       			}
       	     			}
       	     			else
       	     			{
       	     						#print "In write section EWOULDBLOCK on ", $sock,"\n";
		       	     				#$sock->flush();
		       	     	}

       	     		}
       	     		elsif ($bytessent == length($data{$hash{$sock}}))
       	     		{
       	     			#print "Complete Bytes sent = $bytessent to $sock in WRITE\n";
       	     			$writable->remove($sock);				
       	     			substr($data{$hash{$sock}}, 0, $bytessent) = '';
       	     		}
       	     		else
       	     		{
       	     			#print "Partial Bytes send = $bytessent to $sock in WRITE\n";
       	     			substr($data{$hash{$sock}}, 0, $bytessent) = '';
       	     		}
       	     		
       	     		#print "Sent $bytessent bytes to $sock Buffer length now = ", length($data{$hash{$sock}}),"\n";
       	     		
       	       		if ((length($data{$hash{$sock}}) < 32768) and ($readpaused{$hash{$sock}}))
       	       		{
       	       			#print "Buffers cleared. Reading renabled on $hash{$sock}\n";
       	       			$readpaused{$hash{$sock}} = 0;
       	       			$readable->add($hash{$sock});
       	       		}


       	     		if ((length($data{$hash{$sock}}) == 0) and (!($readable->exists($hash{$sock}))))
       	     		{
       	     			#print "Removing first writable socket $hash{$sock}. Cleaning up in WRITE data all sent.\n";
       	     			$writable->remove($sock) if $readable->exists($sock);
       	       			close($hash{$sock});
       	       			close($sock);
       	       			delete($data{$hash{$sock}});
       	       			delete($data{$sock});	       	       			
       	       			delete($hash{$hash{$sock}});
       	       			delete($hash{$sock});
       	       			delete($readpaused{$sock});
       	       		}
       	       		

       	       			
       	     			
       	     	}
       	     	#else
       	     	#{
       	     	#	$writable->remove($sock);
       	     	#}
       	}
}


}

sub auth
{
    my $user = shift;
    my $pass = shift;

    #print "user($user) pass($pass)\n";

    return 1 if (($user eq $socksuser) && ($pass eq $socksuserpass));
    #return 1;
}




#sub timeout()
#{
#	print "Alarm went off\n";
#	($package, $filename, $line) = caller;
#	print $package,"\n", $filename,"\n", $line,"\n";
#	if ($package eq "IO::Socket::Socks")
#	{
#		print 'Closing $self', $package::self,"\n";
#		
#		close ($self);
		#exit;
#		return undef;
#	}
#	exit;
#}