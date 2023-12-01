The purpose of this repository is to provide a java application which would simulate a memory leak and ansible scripts to remediate the application by increasing the memory limits.

### Assumptions
- Target platform
    - Openshift 4.x
- Have admin privileges to cluster.
- oc client installed


### CLI Commands

+ Login to Openshift Cluster using admin user - `oc login -u <user> <ocp_api_url>`
+ Create namespace to house application - `oc new-project rh-apps`
+ Build Steps 
    + `oc import-image ubi9-openjdk-17:1.17 --from=registry.access.redhat.com/ubi9/openjdk-17:1.17 --confirm`
    + `oc process -f memory-leak-simulator-app/kube/openshift/build.yaml | oc apply -f -`
    + Follow the build logs - `oc logs memory-leak-simulator-1-build -f`
+ Deploy Steps
    + (Optional) Import pre-built image from quay.io if you want to skip build steps <br> `oc import-image memory-leak-simulator:latest --from=quay.io/sankara_sundar/memory-leak-simulator:1.0.0 --confirm`
    + `oc process -f memory-leak-simulator-app/kube/openshift/deploy.yaml | oc apply -f -`
+ Testing
    + `curl $(oc get route memory-leak-simulator -o=jsonpath='{.spec.host}')/getMemoryDetails`
