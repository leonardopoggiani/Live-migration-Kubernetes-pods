# Pod IP Routing

The pod IP routing is the foundation of the multi-cluster ability. It allows pods across clusters to reach each other via their pod IPs. Cilium can operate in several modes to perform pod IP routing. All of them are capable to perform multi-cluster pod IP routing.
Tunneling mode

## Tunnelling mode

![Tunneling mode](https://cilium.io/static/5d5297bb7f990afbb1e2129165eded79/63a39/tunneling_mode.webp)

Tunneling mode encapsulates all network packets emitted by pods in a so-called encapsulation header. The encapsulation header can consist of a VXLAN or Geneve frame. This encapsulation frame is then transmitted via a standard UDP packet header. The concept is similar to a VPN tunnel.

* Advantage: The pod IPs are never visible on the underlying network. The network only sees the IP addresses of the worker nodes. This can simplify installation and firewall rules

* Disadvantage: The additional network headers required will reduce the theoretical maximum throughput of the network. The exact cost will depend on the configured MTU and will be more noticeable when using a traditional MTU of 1500 compared to the use of jumbo frames at MTU 9000.

* Disadvantage: In order to not cause excessive CPU, the entire networking stack including the underlying hardware has to support checksum and segmentation offload to calculate the checksum and perform the segmentation in hardware just as it is done for "regular" network packets. Availbility of this offload functionality is very common these days.

## Direct-routing mode

![Direct routing mode](https://cilium.io/static/1e8b0511519bd0d06b12f5e8fe2c6e4c/63a39/direct_routing_mode.webp)

In the direct routing mode, all network packets are routed directly to the network. This requires the network to be capable of routing pod IPs. Propagation of pod IP routing information across nodes can be achieved using multiple options:

* Use of the --auto-direct-node-routes option which is super lightweight route propagation method via the kvstore that will work if all worker nodes share a single layer 2 network. This requirement is typically met for all forms of cloud provider based virtual networks.

* Using the kube-router integration to run a BGP routing daemon.

* Use of any other routing daemon that injects routes into the standard Linux routing tables (bird, quagga, ...)

When a point is reached where the network no longer understands pod IPs, network packet addresses need to be masqueraded.

* Advantage: The reduced network packet headers can optimize network throughput and latency.

* Disadvantage: The entire network must be capable of routing pod IPs which can increase the operational complexity.
