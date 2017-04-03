#!/usr/bin/perl
use Term::ANSIColor;
use Sys::Hostname;
use HTTP::Request::Common;
use LWP::UserAgent;
#
#################################################################################################
## Description: APM Gateway Setup
## 08/05/15 - Dane - Original Build
## 12/11/15 - Tim  - Added iptables to remove need for Reverse Proxy
##
##
#################################################################################################
#
open (STDERR, ">>/root/firstboot/app_setup.log");

my $test = 0;

if (!$test)
{
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
	
	### Grab IP Address ###
	`tput clear`;
	`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | cut -d ':' -f2 | cut -d ' ' -f1 > /tmp/ip`;
	$ipaddr = `cat /tmp/ip`;
	$ipaddr =~ s/\n//g;
	###
}

### Main Logic ###

$installFirewall=$ARGV[0];
my $host = hostname;
installAPM($installFirewall);

### Install APM ###
sub installAPM {
	my $installFirewall = shift;
        print "\n\n";
        print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"                     Setting Up APM POC Gateway                       ") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n\n";

		print colored(['','black','on_white'], "Running APM Gateway Setup ...") . "\n\n";
		if (!$test)
		{
			`mkdir /opt/CA/APM`;
			`/sbin/service iptables save`;
			`touch /root/firstboot/apm_setup_done`;
		}
		my $ua = LWP::UserAgent->new;
		$ua->request(POST 'http://5.6.0.7:8081/Agents/rest/server', [host => $host, port => "8081"]);
		
		if (!$test)
		{
			`sleep 5`;
		}
}
###

	print ("APM Gateway Setup is Complete.  To continue, please visit:\n" . colored(['','black','on_white'], "http://" . $host . ":8081/Agents") . "\n\nPress Return ...\n\n");

	$done = <STDIN>;
###

close (STDERR);
#close (STDOUT);
