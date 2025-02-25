uci set zerotier.global.enabled='1'
uci delete zerotier.earth
uci set zerotier.mynet=network
uci set zerotier.mynet.id=<network_id>
uci commit zerotier
service zerotier restart

root@OpenWrt# zerotier-cli get {network_id} portDeviceName
ztXXXXXXXX

# Create interface
uci -q delete network.ZeroTier
uci set network.ZeroTier=interface
uci set network.ZeroTier.proto='none'
uci set network.ZeroTier.device='ztXXXXXXXX' # Replace ztXXXXXXXX with your own ZeroTier device name
 
# Configure firewall zone
uci add firewall zone
uci set firewall.@zone[-1].name='vpn'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci set firewall.@zone[-1].masq='1'
uci add_list firewall.@zone[-1].network='ZeroTier'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='lan'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='wan'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpn'
 
# Commit changes
uci commit
 
# Reboot
reboot
