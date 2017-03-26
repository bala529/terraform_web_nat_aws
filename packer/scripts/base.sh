sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
yum-config-manager --enable epel
cp /tmp/*.repo /etc/yum.repos.d/
yum -y update


echo "++++++++++++++++++++++++++++++"
echo "Debugging network config"
cat /etc/sysconfig/network-scripts/ifcfg-eth0
echo "Hostname:"
hostname -f
echo "++++++++++++++++++++++++++++++"



sudo yum -y update
sudo yum -y install nginx

sudo mv index.html /usr/share/nginx/html/balu/

sudo mv /tmp/nginx.conf /etc/nginx/


echo "cleaning up dhcp leases"
rm /var/lib/dhclient/*

echo "cleaning up udev rules"
#rm /etc/udev/rules.d/70-persistent-net.rules
#mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules
