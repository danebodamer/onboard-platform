#!/usr/bin/perl
#
use Net::Ping;
#use Switch;
#
#################################################################################################
## Description: Status Checking Script for Appliance
## 10/23/13 - Dane - Original Build
## 12/06/13 - Dane - Added logic for SDC
## 01/10/14 - Dane - Added logic for Nimsoft Monitor
## 07/01/15 - Dane - Added logic for NFA and changed status display for UIM
##
##
#################################################################################################
#
### Logging ###
open (STDERR, ">/tmp/PMStatus.log");
open (STDOUT, ">>/tmp/PMStatus.log");
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

### Gather IP Address ###
`/sbin/ifconfig eth0 | grep 'inet addr' | awk '{print $2}' | cut -d ':' -f2 | cut -d ' ' -f1 > /tmp/ip`;
$ipaddr = `cat /tmp/ip`;
$ipaddr =~ s/\n//g;
###

$tundown = 0;

### Data Collector Status Check ###
if (-d "/opt/IMDataCollector") {
	my $dcpid = `/bin/ps -efw|grep Dkaraf.home=/opt/IMDataCollector/apache-karaf-2.4.3|egrep -v grep |awk '{print \$2}'`;
        $dcpid=~s/\n//g;
        if ($dcpid > 1) {
		$output.="DC:OK ";
	} else {
		$output.="DC:DOWN ";
	}
	my $host    = $datunip;
	my $timeout = 5;
	my $pinger  = Net::Ping->new('icmp', $timeout);

	if ($pinger->ping($host)) {
                $output.="DCTUN:OK ";
				print "$output/n";
	}else{
                $output.="DCTUN:DOWN ";
				$tundown = 1;
	}
}
###

### Spectrum SDC Status Check ###
if (-d "/opt/CA/SDMConnector") {
	my $sdcpid = `/bin/ps -efw|grep SdmConnectorService|egrep -v grep |awk '{print \$2}'`;
        $sdcpid=~s/\n//g;
        if ($sdcpid > 1) {
		$output.="SDC:OK ";
	} else {
		$output.="SDC:DOWN ";
		`/opt/CA/SDMConnector/bin/SdmConnectorService.exe --restart`;
	}
	my $host    = $sstunip;
	my $timeout = 5;
	my $pinger  = Net::Ping->new('icmp', $timeout);

	if ($pinger->ping($host)) {
                $output.="SSTUN:OK ";
				print "$output/n";
	}else{
                $output.="SSTUN:DOWN ";
				$tundown = 1;
	}
}
###

### UIM Status Check ###
if (-d "/opt/CA/nimsoft") {
	my $sdcpid = `/bin/ps -efw|grep -i nimbus | egrep -v grep |awk '{print \$2}'`;
        $sdcpid=~s/\n//g;
        if ($sdcpid > 1) {
		$output.="UIM:OK ";
	} else {
		$output.="UIM:DOWN ";
	}
	my $host    = $nmtunip;
	my $timeout = 5;
	my $pinger  = Net::Ping->new('icmp', $timeout);

	if ($pinger->ping($host)) {
                $output.="UIMTUN:OK ";
				print "$output/n";
	}else{
                $output.="UIMTUN:DOWN ";
				$tundown = 1;
	}
}
###

### NFA Status Check ###
if (-d "/opt/CA/NFA") {
	my $sdcpid = `/bin/ps -efw|grep -i harvester | egrep -v grep |awk '{print \$2}'`;
        $sdcpid=~s/\n//g;
        if ($sdcpid > 1) {
		$output.="NFA:OK ";
	} else {
		$output.="NFA:DOWN ";
	}
	my $host    = $nfatunip;
	my $timeout = 5;
	my $pinger  = Net::Ping->new('icmp', $timeout);

	if ($pinger->ping($host)) {
                $output.="NFATUN:OK ";
				print "$output/n";
	}else{
                $output.="NFATUN:DOWN ";
				$tundown = 1;
	}
}

### APM Status Check ###

if (-d "/opt/CA/APM") {
	my $sdcpid = `iptables -t nat -v -L|grep -i DNAT.*5001 | egrep -v grep |awk -F : '{print \$4}'`;
        $sdcpid=~s/\n//g;
        if ($sdcpid = 5001) {
		$output.="APM:OK ";
	} else {
		$output.="APM:DOWN ";
	}
	my $host    = $apmtunip;
	my $timeout = 5;
	my $pinger  = Net::Ping->new('icmp', $timeout);

	if ($pinger->ping($host)) {
                $output.="APMTUN:OK ";
				print "$output/n";
	}else{
                $output.="APMTUN:DOWN ";
				$tundown = 1;
	}
}
### If one tunnel IP was down ###
if ($tundown) {`/etc/init.d/openvpn restart`;}
###

### If No Install Display Default Information ###
if ($output ne "") {
	my $issue = `cat /etc/issue | grep -v 'Hybrid Status' | grep -v '^\$'`;
	$issue .= "Hybrid Status: ". $output."\n";
	`echo \'$issue\' > /etc/issue`;
}
###

close(STDERR);
close(STDOUT);