#!/bin/bash
ip netns list|awk "/^$1/{print \$1}"|xargs -i{} ip netns del '{}'
for nic in $(ip link list|perl -lne "print \$1 if/^\d+:\s*\b(\w*$1\w*)\b/");do
	ip link set dev $nic down  >/dev/null
	ip link del $nic  >/dev/null
done
(brctl show | grep $1) &&  brctl delbr $1
$ipEntry=$(iptables-save |grep $1)
[ -n "${ipEntry}" ] && iptables -t nat -D ${ipEntry##*-A)
