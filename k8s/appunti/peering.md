# Approaches

Liqo supports two non-mutually exclusive peering approaches (i.e., the same cluster can leverage a different approach for different remote clusters), respectively referred to as out-of-band control plane and in-band control plane. The following sections briefly overview the differences among them, outlining the respective trade-offs. Additional in-depth details about the networking requirements are presented in the installation requirements section, while the usage section describes the operational commands to establish both types of peering.

## Out-of-band control plane

The standard peering approach is referred to as out-of-band control plane, since the Liqo control plane traffic (i.e., including both the initial authentication process and the communication with the remote Kubernetes API server) flows outside the VPN tunnel interconnecting the two clusters (still, TLS is used to ensure secure communications). Indeed, this tunnel is dynamically started in a later stage of the peering process, and it is leveraged only for cross-cluster pods traffic.

![Alt text](https://docs.liqo.io/en/v0.5.4/_images/out-of-band.drawio.svg)

Overall, the out-of-band control plane approach:

* Supports clusters under the control of different administrative domains, as each party interacts only with its own cluster: the provider retrieves an authentication token that is subsequently shared with and leveraged by the consumer to start the peering process.

* Is characterized by high dynamism, as upon parameters modifications (e.g., concerning VPN setup) the negotiation process ensures synchronization between clusters and the peering automatically re-converges to a stable status.

* Requires each cluster to expose three different endpoints (i.e., the Liqo authentication service, the Liqo VPN endpoint and the Kubernetes API server), making them accessible from the pods running in the remote cluster.

## In-band control plane

The alternative peering approach is referred to as in-band control plane, since the Liqo control plane traffic flows inside the VPN tunnel interconnecting the two clusters. In this case, the tunnel is statically established at the beginning of the peering process (i.e., part of the negotiation process is carried out directly by the Liqo CLI tool), and it is leveraged from that moment on for all inter-cluster traffic.

![Alt text](https://docs.liqo.io/en/v0.5.4/_images/in-band.drawio.svg)

Overall, the in-band control plane approach:

* Requires the administrator starting the peering process to have access to both clusters (although with limited permissions), as the network parameters negotiation is performed through the Liqo CLI tool (which interacts at the same time with both clusters). The remainder of the peering process, instead, is completed as usual, although the entire communication flows inside the VPN tunnel.

* Statically configures the cross-cluster VPN tunnel at peering establishment time, hence requiring manual intervention in case of configuration changes causing connectivity loss.

* Relaxes the connectivity requirements, as only the Liqo VPN endpoint needs to be reachable from the pods running in the remote cluster. Specifically, the Kubernetes API service is not required to be exposed outside the cluster.



