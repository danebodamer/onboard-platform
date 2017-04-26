#!/usr/bin/perl
#
use Net::Ping;
#use Switch;
#
#################################################################################################
## Description: OpenVPN Tunnel Initiation Script
## 12/06/13 - Dane - Original Build
## 07/01/15 - Dane - Added logic for multiple product runs
##
##
#################################################################################################
#
open (STDERR, ">>/tmp/app_setup.log");

### Gather environment variables ###
my ($variable,$value);
open (MYFILE, '/root/firstboot/variables');
	while (<MYFILE>) {
        chomp;
		($variable,$value) = split("=", $_);
		$$variable = "$value";
	}
 close (MYFILE);
###

### Check if OpenVPN is Up ###
my $host    = $rctunip;
my $timeout = 5;
my $pinger  = Net::Ping->new('icmp', $timeout);

if ($pinger->ping($host)) {
	$done = 1;
	print "\n\n";
	print "OpenVPN Tunnel is Active\n\n";
}else{
	$done = 0;
}
### Added OpenVPN client configuration ###
`rm -f /root/firstboot/response_files/client.conf`;
while (! $done) {
	print "Enter the configuration URL (q to skip VPN Setup):\n";
	$custid = <STDIN>;
	chomp $custid;
	
	if ($custid ne 'q') {
		if ($custid ne '') {
			print "Waiting for OpenVPN Certificate Installation\n";
			if (! grep (/http/, $custid ))    {
			`curl -u tsoguest:3TU1i8ec ftp://ftpca.ca.com/RP/$custid/client.conf -o /root/firstboot/response_files/client.conf`;
			}else{
			`wget -O /root/firstboot/response_files/client.conf $custid`;
			}
			if ( -e '/root/firstboot/response_files/client.conf' ) {
				$conf = `head -1 /root/firstboot/response_files/client.conf`;
				chomp $conf;
				
				if ($conf eq 'client')
				{
					`cp -f /root/firstboot/response_files/client.conf /etc/openvpn/client.conf`;
					`/etc/init.d/openvpn restart`;
					$indone=0;
					print "Waiting for OpenVPN Tunnel to Initiate\n";
					while (! $indone) {
						sleep 3;
						`ifconfig tap0 | grep 'inet addr' | awk {'print $2'} | cut -d ':' -f2 | cut -d ' ' -f1 > /tmp/ip`;
						$localtunip = `cat /tmp/ip`;
						$localtunip =~ s/\n//g;
						if ($localtunip ne '') {
							$indone = 1;
							$done = 1;
							`echo "$custid" > /root/custid-file`;
							print "OpenVPN Tunnel is Initiated ...\n";
						}
					}
				}
				else
				{
					print "\nInvalid Certificate\n\n";
				}
			}       
		}
	} else { $done = 1; }
}
###

close (STDERR);
