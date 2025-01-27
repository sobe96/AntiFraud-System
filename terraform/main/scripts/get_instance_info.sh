#!/bin/zsh
IP=$(yc compute instance list --format json | jq -r '.[] | select(.labels.subcluster_role == "masternode") | .network_interfaces[].primary_v4_address.one_to_one_nat.address')
echo "{\"ip\":\"$IP\"}"