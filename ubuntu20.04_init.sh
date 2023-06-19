echo "
* soft nproc 1024000
* hard nproc 1048000
* soft nofile 1024000
* hard nofile 1048000
root soft nproc 1024000
root hard nproc 1048000
root soft nofile 1024000
root hard nofile 1048000
">>/etc/security/limits.conf

net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ip_local_reserved_ports = 22,80,2379,2380,3260,3300,4369,5000,5672,5900,5901,5902,5903,5904,5905,5906,5907,5908,5909,5910,5911,5912,5913,5914,6010,6011,6013,6080,6633,6640,6789,6800,6801,6802,6803,6804,6805,6806,6807,6808,6809,6810,6811,6812,6813,6814,6815,6816,6817,6818,6819,6820,6821,6822,6823,6824,6825,6826,6827,6828,6829,6830,6831,6832,6833,8774,8775,8776,8778,9100,9283,9292,9696,10050,11211,15672,16509,25672
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 300 
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_keepalive_intvl = 2


# 优化核套接字TCP的缓存区
net.core.netdev_max_backlog = 8192
net.core.somaxconn = 8192
net.core.rmem_max = 12582912
net.core.rmem_default = 6291456
net.core.wmem_max = 12582912
net.core.wmem_default = 6291456
