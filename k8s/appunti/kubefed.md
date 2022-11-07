# Kubefed

The central concept of Kubernetes Federation is a host cluster containing all the configurations to be propagated to the designated clusters. You can also assign real workloads to the host cluster, but it is generally easier to make it a standalone cluster.

All configurations throughout a cluster are managed through one API. A configuration determines which clusters it applies to and what they should do. A set of policies, templates and overrides specific to individual clusters determines the content of a federated configuration.

Federated configurations manage the DNS entries for all the multi-cluster services. A configuration must have access to any cluster it is intended to govern, in order to create configuration items and apply or remove them (this includes deployments). Deployments usually have their own namespaces, which remain consistent across clusters. 

![Immagine kubefed](https://lh6.googleusercontent.com/gc0U4b4ZGxC4sCuKLUr-pGIuAN45FyZ2mENjoOpjJsojtdSNaRbYEqvXqseJBxEOFHpoZ1gtW09BdGdSyULXRWX_zN1Vxn6z2gtvLwbibDqISzGA55qwX6E17vactsd-j2j_8BqK=s0)

KubeFed uses two kinds of configuration information:

* Type configuration—defines the types of APIs to be handled by KubeFed 
* Cluster configuration—defines the clusters to be targeted by KubeFed 

The mechanism for distributing a resource to member clusters of a federation configuration is called *propagation*.

There are three main concepts that inform type configuration:

* Templates—define how a common resource is represented across federated clusters
* Placement—designates the clusters intende to use the resource 
* Overrides—define cluster-specific variations to the template at the field level

These three concepts represent resources intended for multiple clusters in a concise manner. They provide a minimum amount of information needed for propagation and can act as the link between propagation mechanisms and higher-order actions, such as dynamic scheduling and policy-based placement.

These concepts are the building blocks for higher-level APIs:

* Status—describes the status of a resource distributed across a federation of clusters
* Policy—defines the clusters to which a resources can be distributed
* Scheduling—determines how workloads are spread across various clusters (works similarly to a human operator)
