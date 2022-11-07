# Controller runtime

## Informers

![alt text](https://aly.arriqaaq.com/content/images/size/w1000/2021/10/Screenshot-2021-10-03-at-12.07.12-PM.png)

A single informer creates a local cache for itself. But in reality, a single resource could be watched by multiple controllers. And if each controller creates a cache for itself, there are synchronisation issues as multiple controllers have a watch on their own cache. client-go provides a Shared Informer which is used so that the cache is shared amongst all controllers. Every built-in Kubernetes resource has an Informer.

The informer mechanism has three components:
* Watches specific resources like certain CRD, and puts events, such as Added, Updated, and Deleted, into the local cache DeltaFIFO.
* DeltaFIFO. A FIFO queue to store the related resource events.
* Indexer. It is the local storage implemented by client-go, keeping consistent with the etcd, reducing the pressure of the API Server and etcd.

## Webhooks

A WebHook is an HTTP callback: an HTTP POST that occurs when something happens; a simple event-notification via HTTP POST. A web application implementing WebHooks will POST a message to a URL when certain things happen.

When specified, mode Webhook causes Kubernetes to query an outside REST service when determining user privileges.

![alt text](https://slack.engineering/wp-content/uploads/sites/7/2021/12/sequence-diagram.jpg?resize=640,427)

Figure 1 is a simplified sequence diagram showing the flow of a user creating a pod, where an admission webhook has been configured to receive CREATE operations on pods resources. Note that users usually create deployments, jobs, or other higher-level objects which result in pods being created and follow the same flow as pictured. 

It is common to build admission webhooks controlling user defined custom resources (CRDs) but controlling resources isn’t required to build a functional admission webhook.

## Kubebuilder

Kubebuilder is a framework for building Kubernetes APIs using custom resource definitions (CRDs).

Similar to web development frameworks such as Ruby on Rails and SpringBoot, Kubebuilder increases velocity and reduces the complexity managed by developers for rapidly building and publishing Kubernetes APIs in Go. It builds on top of the canonical techniques used to build the core Kubernetes APIs to provide simple abstractions that reduce boilerplate and toil.

Kubebuilder does not exist as an example to copy-paste, but instead provides powerful libraries and tools to simplify building and publishing Kubernetes APIs from scratch. It provides a plugin architecture allowing users to take advantage of optional helpers and features. To learn more about this see the Plugin section.

Kubebuilder is developed on top of the controller-runtime and controller-tools libraries.

### Kubebuilder is also a framework

Kubebuilder is extensible and can be used as a library in other projects. Operator-SDK is a good example of a project that uses Kubebuilder as a library. Operator-SDK uses the plugin feature to include non-Go operators e.g. operator-sdk's Ansible and Helm-based language Operators.
