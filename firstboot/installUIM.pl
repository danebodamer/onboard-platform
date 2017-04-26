#!/usr/bin/perl
use Term::ANSIColor;
use Sys::Hostname;
use HTTP::Request::Common;
use LWP::UserAgent;
#
#
#################################################################################################
## Description: Nimsoft Monitor Hub Installer
## 01/10/14 - Dane - Original Build
## 04/21/15 - Dane - Changed Domain and Hub name to match new Gold Image
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
$host = `hostname`;
$host =~ s/\n//g;
my $nmhub = $host . "-hub";
### 

### Grab IP Address ###
`tput clear`;
`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | cut -d ':' -f2 | cut -d ' ' -f1 > /tmp/ip`;
$ipaddr = `cat /tmp/ip`;
$ipaddr =~ s/\n//g;
###

### Main Logic ###
# if ($#ARGV != 1) { die "Usage: installNIM <Install Firewall>\n eg. installNIM 1 \n"; }

$installFirewall=$ARGV[0];
installUIM($installFirewall);

### Install UIM ###
sub installUIM {
	my $installFirewall = shift;
#	if ($installFirewall == 1) { 
#                'tput clear'; 
#                print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
#        }
		print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"                     Setting Up UIM POC Hub                           ") . "\n";
        print colored(['','white','on_blue'],"                                                                      ") . "\n";
        print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n\n";
		
		print colored(['','black','on_white'], "Running UIM HUB silent installation...") . "\n\n";
		system("curl -u http://$nmtunip/uimhome/setupFiles/unix/nimldr.tar.Z -o /root/im_firmware/uim/nimldr.tar.Z;cd /root/im_firmware/uim/;tar -xvf nimldr.tar.Z");
		system("curl -u http://$nmtunip/uimhome/archiveFiles/install_LINUX_23_64.zip -o /root/im_firmware/uim/install_LINUX_23_64.zip;cd /root/im_firmware/uim/;tar -xvf install_LINUX_23_64.zip");
		$output = `/root/im_firmware/uim/nimldr/LINUX_23_64/nimldr -D UIM_domain -H UIM_remotehub -p /opt/CA/nimsoft -t /opt/CA/nimsoft/tmp -o 48003 -R$ipaddr -F /root/im_firmware/uim -E -i > /dev/null 2>&1`;
		$output = `/bin/cp -rf /root/im_firmware/uim/archive /opt/CA/nimsoft/ > /dev/null 2>&1`;
		$output = `service nimbus stop`;
		$output = `sed -i '/postroute_interval/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/postroute_reply_timeout/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/postroute_passive_timeout/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/hub_request_timeout/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/tunnel_hang_timeout/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/tunnel_hang_retries/d' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ postroute_interval = 120' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ postroute_reply_timeout = 180' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ postroute_passive_timeout = 300' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ hub_request_timeout = 300' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ tunnel_hang_timeout = 300' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `sed -i '/license/i \ tunnel_hang_retries = 3' /opt/CA/nimsoft/hub/hub.cfg`;
		$output = `service nimbus start`;
		}
		
###
	print "UIM Hub Setup is Complete.  To continue, please visit:\n" . colored(['','black','on_white'], "http://" . $host) . "\n\nPress Return ...\n\n";
	$done = <STDIN>;
###

close (STDERR);
#close (STDOUT);