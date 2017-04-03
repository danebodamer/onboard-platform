#!/usr/bin/perl
use Term::ANSIColor;
use Sys::Hostname;
use HTTP::Request::Common;
use LWP::UserAgent;
#
#
#################################################################################################
## Description: MFA Harvester Installer
## 06/02/15 - Dane - Original Build
## 12/11/15 - Dane - Added iptables to remove need for Reverse Proxy
##
##
#################################################################################################
#
open (STDERR, ">>/root/firstboot/app_setup.log");
#open (STDOUT, ">>/root/firstboot/app_setup.log");

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

### Main Logic ###
# if ($#ARGV != 1) { die "Usage: installNFA <Install Firewall>\n eg. installNFA 1 \n"; }

$installFirewall=$ARGV[0];
installNFA($installFirewall);

### Install NFA ###
sub installNFA {
	my $installFirewall = shift;
#	if ($installFirewall == 1) { 
#                'tput clear'; 
#                print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
#        }
		print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"                     Setting Up NFA POC Harvester                     ") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n\n";
		
		print colored(['','black','on_white'], "Running NFA Harvester silent installation...") . "\n";
		
		`cp -f /root/firstboot/response_files/nfa-installer.properties /root/im_firmware/nfa/installer.properties`;
        $output = `cd /root/im_firmware/nfa/;chmod 755 /root/im_firmware/nfa/NFHarvesterSetup9.3.3.bin;/root/im_firmware/nfa/NFHarvesterSetup9.3.3.bin -i silent > /dev/null 2>&1`;
}
###
	print "NFA Harvester Setup is Complete.  To continue, please visit:\n" . colored(['','black','on_white'], "http://" . $host) . "\n\nPress Return ...\n\n";
	$done = <STDIN>;
###

close (STDERR);
#close (STDOUT);