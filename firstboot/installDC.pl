#!/usr/bin/perl
#
#
#################################################################################################
## Description: Data Collector Installer
## 10/23/13 - Dane - Original Build
## 12/06/13 - Dane - v2.0 Added Spectrum - Removed VPN logic
## 01/05/16 - Dane - Reintroduced in v3.2
##
#################################################################################################
#
#open (STDERR, ">>/tmp/app_setup.log");

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
if ($#ARGV != 2) { die "Usage: installDC <Install Firewall> <DC Memory> <DA IP Address>\n eg. installDC 1 2G 192.168.0.1\n"; }

$installFirewall=$ARGV[0];
$dcmem=$ARGV[1];
$daipaddr=$ARGV[2];
installDC($installFirewall,$dcmem,$daipaddr);

### Download Data Collector ###
sub downloadDC {
	$daip = shift;
	system("wget -S http://$daip:8581/dcm/InstData/Linux/VM/install.bin -O /root/im_firmware/installDC.bin");
	if ( -e '/root/im_firmware/installDC.bin' ) {
		return 1
	} else {
		print "Download failed... ensure your DA is started and SSL tunnel is active. Setup will now try again\n";
		return 0
	}
}
###

### Install DC ###
sub installDC {

	my $installFirewall = shift;
	my $dcmem = shift;
	my $daipaddr = shift;
	if ($installFirewall == 1) { 
                'tput clear'; 
                print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
        }
        print "\n\n";
        print "------------------------------------------------------\n";
        print "          Installing the Data Collector               \n";
        print "------------------------------------------------------\n\n";
	$ret = 0;
	while ($ret < 1) {
		if ($daipaddr == 0) {
			print "What is the IP Address of your DA? ";
        		$daip = <STDIN>;
        		chomp $daip;
				print "\n\n";
		} else {$daip = $daipaddr;}
		print "Downloading DC Installation from the DA - Please be patient ...\n";
		$ret = downloadDC($daip);
	}
#	if ($dcmem == 0) {
#		print "How much memory allocated to your DC? [2G]: ";
#        	$mem = <STDIN>;
#        	chomp $mem;
#			print "\n\n";
#        	if ($mem eq '') { $mem='2G'}
#	} else {$mem = $dcmem;}
        print "Running installDC silent installation..\n";
		`cp -f /root/firstboot/response_files/installerDC.properties /root/im_firmware`;
#        `sed -i \'s/#IPADDR#/$datunip/g\' /root/im_firmware/installerDC.properties`;
#        `sed -i \'s/#MEM#/$mem/g\' /root/im_firmware/installerDC.properties`;
        system("cd /root/im_firmware;chmod 755 /root/im_firmware/installDC.bin;./installDC.bin -i console");	

### Check installation to make sure settings have been set correctly - correct if necessary ###
#        my $needToRestart = 0;
#        my $pid = `/bin/ps -efw|grep Dkaraf.home=/opt/IMDataCollector/apache-karaf-2.4.3|egrep -v grep |awk '{print $2}'`;
#        $pid=~s/\n//g;

#        $IM_MAX_MEM=`cat /opt/IMDataCollector/apache-karaf-2.4.3/bin/setenv | grep 'IM_MAX_MEM=\$'`;
#        if ($IM_MAX_MEM ne '') {
#                `sed -i \'s/export IM_MAX_MEM=/export IM_MAX_MEM=$mem/g\' /opt/IMDataCollector/apache-karaf-2.4.3/bin/setenv`;
###             `sed -i \'s/da.memory=/da.memory=$mem/g\' /etc/DA.cfg`;
#                $needToRestart=1;
#        }
#       if (! -e "/opt/IMDataCollector/apache-karaf-2.4.3/jms/local-jms-broker.xml") {
#               `cp -f /root/firstboot/response_files/DA_local-jms-broker.xml /opt/IMDataCollector/apache-karaf-2.4.3/jms/local-jms-broker.xml`;
#                `sed -i \'s/#IPADDR#/$datunip/g\' /opt/IMDataCollector/apache-karaf-2.4.3/jms/local-jms-broker.xml`;
#                $needToRestart=1;
#        }
#       if ($needToRestart == 1) {
#                print "Adjusting Configuration after installation\n";
#		if ($pid > 1) {
#               	`kill -9 $pid;rm -rf /opt/IMDataCollecter/apache-karaf-2.4.3/data;rm -f /opt/IMDataCollector/apache-karaf-2.4.3/deploy/*jms*xmil`
#	}
#           `/etc/init.d/dcmd start`;
#              sleep 3;
#     }
###
		
### Create Cron Job ###
	`echo "EXECUTED_BY_CRON=1" > /tmp/cron`;
        `echo "* * * * * /etc/init.d/dcmd start > /dev/null " >> /tmp/cron`;
	if (-e "/var/spool/cron/root") {
        	`crontab -l | grep -v dcmd | grep -v EXECUTED_BY_CRON >> /tmp/cron`;
	}
        `crontab /tmp/cron`;
###
#	print ("Data Collector Installation is Complete.  To continue, please visit :\n" . colored(['','black','on_white'], "http://" . $host . ":8885/pc/desktop/page") . "\n\nPress Return ...\n\n");
	print "Data Collector Installation is Complete\n";
}
###

#close (STDERR);