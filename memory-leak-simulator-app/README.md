The purpose of this repository is to provide a java application which would simulate a memory leak and ansible scripts to remediate the application by increasing the memory limits.

### Assumptions
- Target platform
    - Openshift 4.x
- Have admin privileges to cluster.
- oc client installed


### High level steps
- Create namespace 'rh-apps' for housing application
- Import base image to the cluster
- (Optional) Build the component image using openshift s2i build
- Deploy the component
- Testing component

### CLI Commands

1. oc login -u <user> <ocp_api_url>
2. oc new-project rh-apps
3. Build Steps 
    3.1 oc import-image ubi9-openjdk-17:1.17 \
        --from=registry.access.redhat.com/ubi9/openjdk-17:1.17 \
        --confirm
    3.2 oc process -f memory-leak-simulator-app/kube/openshift/build.yaml | oc apply -f -
    3.3. Follow the build logs - oc logs memory-leak-simulator-1-build -f 
4. Deploy Steps
    4.1 (execute this if build steps were skipped. Importing pre-built image from quay.io) oc import-image memory-leak-simulator:latest \
        --from=quay.io/sankara_sundar/memory-leak-simulator:1.0.0 \
        --confirm
    4.2 oc process -f memory-leak-simulator-app/kube/openshift/deploy.yaml | oc apply -f -
5. Testing
    5.1 curl $(oc get route memory-leak-simulator -o=jsonpath='{.spec.host}')/getMemoryDetails