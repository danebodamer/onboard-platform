#!/usr/bin/perl
#
#
#################################################################################################
## Description: System / OS Set Up Script.  Includes hosts file, IP address, etc.
## 10/23/13 - Dane - Original Build
## 12/06/13 - Dane - Adding logic for Spectrum Secure Domain Manager
## 01/10/14 - Dane - Adding logic for Nimsoft Monitor
## 12/17/14 - Dane - Removed some logic for sysedge and hosts file
## 09/02/16 - Dane - Streamlined iptables and host entry logic - 3.2 major release
##
#################################################################################################

### Main Logic ###
if ( -e "/root/firstboot/system_setup_done" ) { exit; }

### Down Interface for Reassignment ###
`ifdown eth0`;
###

print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
print "----------------------------------------------------------------------\n";
print "       CA Enterprise Management Hybrid POC System Setup     \n";
print "----------------------------------------------------------------------\n\n";

print "Please change your root password: \n";
`passwd root`;
open (STDERR, ">>/tmp/app_setup.log");
print "\n";
###

###
print "Please set your hostname [CAEMHybridPOCAppliance]: ";
$hostname = <STDIN>;
chomp $hostname;
if ($hostname eq '') { $hostname = 'CAEMHybridPOCAppliance'; }
`hostname $hostname`;
`echo "NETWORKING=yes" > /etc/sysconfig/network`;
`echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network`;
`echo "HOSTNAME=$hostname" >> /etc/sysconfig/network`;
`export HOSTNAME=$hostname`;
print "\n";
$host = "`hostname`";
###

###
print "Network Configuration Setup\n";
print "        Please set your the IP address of this VM [dhcp]: ";
$ipaddr = <STDIN>;
chomp $ipaddr;
if ($ipaddr eq '') {$ipaddr = 'dhcp'};
if ($ipaddr !~ /dhcp/i) {
	print "        Please set your Network Mask [255.255.255.0]: ";
	$netmask=<STDIN>;chomp $netmask;
	if ($netmask eq '') { $netmask='255.255.255.0'}
	print "        Please set your Gateway IP Address: ";
	$gateway=<STDIN>;chomp $gateway;
	print "        Please set your DNS IP Address [$gateway]: ";
	$dns=<STDIN>;chomp $dns;
	if ($dns eq '') { $dns=$gateway}
}
`echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0`;
`echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
`echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
if ($ipaddr =~ /dhcp/i) {
	`echo "BOOTPROTO=dhcp" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
} else {
	`echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
	`echo "IPADDR=$ipaddr" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
	`echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
	if ($gateway ne '') {
		`echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
	}
	if ($dns ne '') {
		`echo "DNS1=$dns" >> /etc/sysconfig/network-scripts/ifcfg-eth0`;
	}
} 
### Set Up Forwarding ###
`chkconfig --add iptables`;
`iptables -t nat-F`;
`iptables -t nat -A POSTROUTING -o tap0 -j MASQUERADE`;
`echo 1 > /proc/sys/net/ipv4/ip_forward`;
`sed -i \'s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g\' /etc/sysctl.conf`;

`iptables -t nat -A PREROUTING -p tcp --dport 5001 -j DNAT --to-destination 5.6.0.7:5001`;
`iptables -t nat -A PREROUTING -p tcp --dport 8081 -j DNAT --to-destination 5.6.0.7:8081`;
`iptables -t nat -A PREROUTING -p tcp --dport 8088 -j DNAT --to-destination 5.6.0.7:8088`;
`iptables -t nat -A PREROUTING -p tcp --dport 8443 -j DNAT --to-destination 5.6.0.7:8443`;
`iptables -t nat -A PREROUTING -p tcp --dport 8888 -j DNAT --to-destination 5.6.0.7:8888`;
`iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 5.6.0.7:8080`;
`iptables -t nat -A PREROUTING -p tcp --dport 8882 -j DNAT --to-destination 5.6.0.5:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8883 -j DNAT --to-destination 5.6.0.5:8080`;
`iptables -t nat -A PREROUTING -p tcp --dport 8883 -j DNAT --to-destination 5.6.0.5:8080`;
`iptables -t nat -A PREROUTING -p tcp --dport 8881 -j DNAT --to-destination 5.6.0.4:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8881 -j DNAT --to-destination 5.6.0.4:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8884 -j DNAT --to-destination 5.6.0.8:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8382 -j DNAT --to-destination 5.6.0.8:8381`;
`iptables -t nat -A PREROUTING -p tcp --dport 8181 -j DNAT --to-destination 5.6.0.10:8181`;
`iptables -t nat -A PREROUTING -p tcp --dport 8381 -j DNAT --to-destination 5.6.0.10:8381`;
`iptables -t nat -A PREROUTING -p tcp --dport 8581 -j DNAT --to-destination 5.6.0.11:8581`;
`iptables -t nat -A PREROUTING -p tcp --dport 8880 -j DNAT --to-destination 5.6.0.10:8880`;
`iptables -t nat -A PREROUTING -p tcp --dport 7070 -j DNAT --to-destination 5.6.0.12:7070`;
`iptables -t nat -A PREROUTING -p tcp --dport 8887 -j DNAT --to-destination 5.6.0.13:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8870 -j DNAT --to-destination 5.6.0.13:8081`;
`iptables -t nat -A PREROUTING -p tcp --dport 8870 -j DNAT --to-destination 5.6.0.13:8081`;
`iptables -t nat -A PREROUTING -p tcp --dport 8382 -j DNAT --to-destination 5.6.0.13:8382`;
`iptables -t nat -A PREROUTING -p tcp --dport 8885 -j DNAT --to-destination 5.6.0.15:80`;
`iptables -t nat -A PREROUTING -p tcp --dport 8383 -j DNAT --to-destination 5.6.0.15:8381`;
`iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 5.6.0.20:80`;
`iptables save`;
### Set Up Forwarding ###

### Hosts File Entries ###
`echo "$ipaddr	     $host"         >  /etc/hosts`;
`echo "$nmtunip      $nmtunname"   >> /etc/hosts`;
`echo "$nfatunip     $nfatunname"  >> /etc/hosts`;
`echo "$apmtunip     $apmtunname"  >> /etc/hosts`;
`echo "$sstunip      $sstunname"   >> /etc/hosts`;
`echo "$datunip      $datunname"   >> /etc/hosts`;
`echo "$pctunip      $pctunname"   >> /etc/hosts`;
`echo "$adatunip     $adatunname"  >> /etc/hosts`;
`echo "$soitunip     $soitunname"  >> /etc/hosts`;
`echo "$jumptunip    $jumptunname" >> /etc/hosts`;
`echo "127.0.0.1     localhost.localdomain localhost"     >>/etc/hosts`;
### Hosts File Entries ###

print "\nStarting Network\n\n";
system("/etc/init.d/network start");
###

`/etc/init.d/motd`;
`touch /root/firstboot/system_setup_done`;
print "System Configuration Complete - Press Enter to continue\n";
$done = <STDIN>;
close (STDERR);