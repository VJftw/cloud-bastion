# Design

## Overview

Bastions are a method of securely entering a private network. This project aims
to provide a robust and secure implementation of bastions for various cloud
providers.

## Goals

* Audited
* Robust
* Secure (use of Cloud Provider entrypoints - AWS SSM, GCP IAP)
* Portable
* Immutable

## Design

* Use SSH tunnel through Cloud provider entrypoints
    * They are most likely to patch TLS zero-days on those endpoints faster.
    * Alternatively, give bastions public IPs and auto-update (hard-sell, controlled 
    environments most likely won't allow this style).

* Use Fedora CoreOS (for immutability):
    * AWS SSM in container image
    * GCP OS Login in container image
    * This is great as it means that we can add auditing outside the container 
    image instead of worrying that the user could turn it all off. 
