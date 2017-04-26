#!/usr/bin/perl
use Term::ANSIColor;
use Sys::Hostname;
use HTTP::Request::Common;
use LWP::UserAgent;
#
#
#################################################################################################
## Description: Collector Set Up Script
## 10/23/13 - Dane - Original Build
## 12/06/13 - Dane - v2.0 Added Spectrum
## 01/10/14 - Dane - Added UIM
## 12/17/14 - Dane - Commented out all but UIM for this release
## 06/02/15 - Dane - Added logic for NFA and logic for looping to install multiple products
## 09/03/15 - Dane - Added logic for Spectrum
## 12/11/15 - Dane - Added logic for APM and iptables to remove need for Reverse Proxy
## 09/02/16 - Dane - 3.2 major release - removed system setup logic and added all Enterprise Management Products
#################################################################################################
#
### Logging ###
#open (STDERR, ">>/root/firstboot/app_setup.log");
#open (STDOUT, ">>/root/firstboot/app_setup.log");
###

### Check for previous run ###
 if ( -e "/root/firstboot/app_setup_done" ) { print colored(['','black','on_white'], "Product(s) were already installed, or you quit out of the menu.") . "\nPress Return to Continue ...\n"; $done = <STDIN>; exit; }
###

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

### Now making root access by default ###
`sed -i \'s/PermitRootLogin no/PermitRootLogin yes/g\' /etc/ssh/sshd_config`;
$sshdpid = `/bin/ps -efw|grep '/usr/sbin/sshd' | grep -v grep | awk '{print $2}'`;
if ($sshdpid > 1) {
	`kill -HUP $sshdpid`;
}
###

### Grab IP Address ###
`tput clear`;
`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | cut -d ':' -f2 | cut -d ' ' -f1 > /tmp/ip`;
$ipaddr = `cat /tmp/ip`;
$ipaddr =~ s/\n//g;
###

### Main Menu ###
sub menuSelect {
	print "\n";
	print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
	print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
	print colored(['','white','on_blue'],"CA Hybrid POC Product Setup                                           ") . "\n";
	print colored(['','white','on_blue'],"Choose your Product option:                                           ") . "\n";
	print colored(['','white','on_blue'],"        a - UIM Remote Hub                                            ") . "\n";
	print colored(['','white','on_blue'],"        b - NFA Harvester                                             ") . "\n";
	print colored(['','white','on_blue'],"        c - APM Gateway                                               ") . "\n";
	print colored(['','white','on_blue'],"        d - Spectrum SDC                                              ") . "\n";
	print colored(['','white','on_blue'],"        e - PM Data Collector                                         ") . "\n";
	print colored(['','white','on_blue'],"        f - ADA Gateway                                               ") . "\n";
	print colored(['','white','on_blue'],"        g - SOI Gateway                                               ") . "\n";
	print colored(['','white','on_blue'],"        x - ALL of the Above                                          ") . "\n";		
	print colored(['','white','on_blue'],"        q - Quit to shell and disable this menu                       ") . "\n";
	print colored(['','white','on_blue'],"----------------------------------------------------------------------") . "\n";
	print colored(['','white','on_blue'],"Enter your selection: ");
	$selection = <STDIN>;
	chomp $selection;
	return $selection;
}
my $selecthist = '';
my $select = '_';
while (! grep (/$select/, ('a','b','c','d','e','f','g','x','q')) and (! -f "/root/firstboot/app_setup_done" )) {
	$select = menuSelect;

###  UIM Remote Hub
	if (($select eq 'a') && (! grep (/a/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installUIM.pl",0);
		$selecthist = $selecthist . ' a';
		$select = '_';
	}elsif (($select eq 'a') && (grep (a, $selecthist ))) { print colored(['','white','on_blue'],"UIM has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

###  NFA Harvester
	if (($select eq 'b')  && (! grep (/b/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installNFA.pl",0);
		$selecthist = $selecthist . ' b';
		$select = '_';
	}elsif (($select eq 'b') && (grep (/b/, $selecthist ))) { print colored(['','white','on_blue'],"NFA has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

### APM Gateway
	if (($select eq 'c')  && (! grep (/c/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installAPM.pl",0);
		$selecthist = $selecthist . ' c';
		$select = '_';
	}elsif (($select eq 'c') && (grep (/c/, $selecthist ))) { print colored(['','white','on_blue'],"APM Gateway has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

###	Spectrum SDC
	if (($select eq 'd') && (! grep (/d/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installSDC.pl",0);
		$selecthist = $selecthist . ' d';
		$select = '_';
	}elsif (($select eq 'd') && (grep (d, $selecthist ))) { print colored(['','white','on_blue'],"Spectrum has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

###  PM Data Collector
		if (($select eq 'e') && (! grep (/e/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installDC.pl",0,0,$datunip);
		$selecthist = $selecthist . ' e';
		$select = '_';
	}elsif (($select eq 'e') && (grep (e, $selecthist ))) { print colored(['','white','on_blue'],"Spectrum has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

###  ADA Gateway
	if (($select eq 'f') && (! grep (/f/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installADA.pl",0);
		$selecthist = $selecthist . ' f';
		$select = '_';
	}elsif (($select eq 'f') && (grep (f, $selecthist ))) { print colored(['','white','on_blue'],"Spectrum has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }	

### SOI Gateway
	if (($select eq 'g') && (! grep (/g/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installSOI.pl",0);
		$selecthist = $selecthist . ' g';
		$select = '_';
	}elsif (($select eq 'g') && (grep (g, $selecthist ))) { print colored(['','white','on_blue'],"Spectrum has been installed already, Press Return ...\n"); $done = <STDIN>; $select = '_'; }

### ALL
	if (($select eq 'x') && (! grep (/x/, $selecthist ))) {
		system("/root/firstboot/installVPN.pl");
		system("/root/firstboot/installAPM.pl",0);
		system("/root/firstboot/installADA.pl",0);
		system("/root/firstboot/installSOI.pl",0);
		system("/root/firstboot/installUIM.pl",0);
		system("/root/firstboot/installNFA.pl",0);
		system("/root/firstboot/installSDC.pl",0);
		system("/root/firstboot/installDC.pl",0,0,$datunip);
		
		$selecthist = $selecthist . ' a b c d e f g x';
		$select = '_';
	}elsif (($select eq 'x') && (grep (x, $selecthist ))) { print colored(['','white','on_blue'],"ALL PRODUCTS havw been installed already, ASK CA for Assistance - Press Return ...\n"); $done = <STDIN>; $select = '_'; }	

	if ($select eq 'q') {
		print "\n";
		`touch /root/firstboot/app_setup_done`;
	}
}

### Post Product Setup ###
`mount.cifs //5.6.0.20/launch /mnt/launch -o user=Administrator,password=CAdemo123`;
`sed -i \'s/#GATEWAY#/$ipaddr/g\' /mnt/launch/wwwroot/index.html`;

### Cron for PMstatus
        if (-e "/var/spool/cron/root") {
                `crontab -l | grep -v PMstatus > /tmp/cron`;
        }
        `echo "* * * * * /root/firstboot/PMstatus.pl > /dev/null" >> /tmp/cron`;
        `crontab /tmp/cron`;
###
print colored(['','black','on_white'],"Appliance Installation Complete - Press Return ...") . "\n";
$done = <STDIN>;
#close (STDERR);
#close (STDOUT);