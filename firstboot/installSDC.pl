#!/usr/bin/perl
use Term::ANSIColor;
use Sys::Hostname;
use HTTP::Request::Common;
use LWP::UserAgent;
#
#
#################################################################################################
## Description: Spectrum Secure Domain Connector Installer
## 09/03/15 - Dane - Original Build
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
# if ($#ARGV != 1) { die "Usage: installSDC <Install Firewall>\n eg. installSDC 1 \n"; }

$installFirewall=$ARGV[0];
installSDC($installFirewall);

### Install SDC ###
sub installSDC {
	my $installFirewall = shift;
#	if ($installFirewall == 1) { 
#                'tput clear'; 
#                print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
#        }
		print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"                     Setting Up Spectrum POC SDC                      ") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n\n";
		
		print colored(['','black','on_white'], "Running Spectrum SDC silent installation...") . "\n";
		
		`cp -f /root/firstboot/response_files/installerSDC.properties /root/im_firmware/sdc/installer.properties`;
		
        $output = `cd /root/im_firmware/sdc/;chmod 755 /root/im_firmware/sdc/install.bin;/root/im_firmware/sdc/install.bin -i silent > /dev/null 2>&1`;
		`cp -f /root/firstboot/response_files/sdc.config /opt/CA/SDMConnector/bin/`;
		`/opt/CA/SDMConnector/bin/SdmConnectorService.exe --restart`;
		}
###
	print "SPECTRUM SDC Setup is Complete.  To continue, please visit:\n" . colored(['','black','on_white'], "http://" . $host) . "\n\nPress Return ...\n\n";
	$done = <STDIN>;
###

close (STDERR);
#close (STDOUT);