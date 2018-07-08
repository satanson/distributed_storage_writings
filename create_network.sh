#!/bin/bash

set -e -o pipefail

basedir=$(dirname ${BASH_SOURCE:-$0})
script=${0##${basedir}/}
basedir=$(cd ${basedir};pwd)

usage="USAGE: $script <num> <bridge> <subnet>"
num=${1:?"undefined <num>: $usage"};shift
bridge=${1:?"undefined <bridge>: $usage"};shift
subnet=${1:?"undefined  <network segment>: $usage"};shift

add_bridge(){
	local usage="add_bridge <bridge-name> <subnet>"
	local bridge=${1:?"undefined <bridge-name>: $usage"};shift
	local subnet=${1:?"undefined <subnet>: $usage"};shift

	del_bridge $bridge
	ip link add $bridge type bridge
	ip link set dev $bridge up
	return 0
}

del_bridge(){
	local usage="del_bridge <bridge-name>"
	local bridge=${1:?"undefined <bridge-name>:$usage"};shift

	if ip link list | grep "\<$bridge\>" >/dev/null 2>&1;then
		ip link set dev $bridge down
		ip link delete dev $bridge
	fi
	return 0
}

allocate_netns(){
	local usage="allocate_netns <netns-name> <ip> <bridge-name>"
	local netns=${1:?"undefined <netns>: $usage"};shift
	local ip=${1:?"undefined <ip>: $usage"};shift
	local bridge=${1:?"undefined <bridge-name>: $usage"};shift

	local eth=${netns}_ethA
	local br_eth=${netns}_ethB
	
	if ip netns ls |grep "\<$netns\>";then
		ip netns del $netns
	fi

	if ip link |grep "\<$eth\>"; then
		ip link set $eth down
		ip link del $eth
	fi

	if ip link |grep "\<$br_eth\>"; then
		ip link set $br_eth down
		ip link del $br_eth
	fi

	ip netns add $netns
	ip link add $eth type veth peer name $br_eth
	ip link set $eth netns $netns
	ip netns exec $netns ip link set dev $eth name "eth0"
	ip netns exec $netns ifconfig "eth0" $ip netmask 255.255.255.0 up
	# enable ping self
	ip netns exec $netns ifconfig "lo" up

	ip link set dev $br_eth master $bridge
	ip link set dev $br_eth up
	return 0
}

create_network(){
	local usage="create_network <num> <bridge-name> <subnet>"
	local num=${1:?"undefined <num>: $usage"};shift
	local bridge=${1:?"undefined <bridge-name>: $usage"};shift
	local subnet=${1:?"undefined <subnet>: $usage"};shift
	
	valid=$(perl -e "print qq/valid/ if qq/${subnet}/ =~ /^\d+\.\d+\.\d+$/")
	if [ "xx${valid}xx" != "xxvalidxx" ];then
		echo "<subnet> must be 3-component 'xxx.xxx.xxx' form" 2>&1
		exit 1
	fi
	# bridge
	add_bridge $bridge $subnet
	ifconfig $bridge ${subnet}.1 netmask 255.255.255.0 up

	# enable bridge to exchanging packages from different netns
	iptables -t nat -A POSTROUTING -s ${subnet}.0/24 ! -o ${bridge} -j MASQUERADE
	systemctl restart iptables

	for i in $(eval "echo {1..$(($num))}");do
		local ip="${subnet}.$((1+$i))"
		allocate_netns ${bridge}${i} $ip $bridge
	done
}

create_network $num $bridge $subnet
