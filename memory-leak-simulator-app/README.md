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
    3.1 <TO BE FILLED>
4. Deploy Steps
    4.1 (execute this if build steps were skipped. Importing pre-built image from quay.io) oc import-image memory-leak-simulator:latest \
        --from=quay.io/sankara_sundar/memory-leak-simulator:1.0.0 \
        --confirm
    4.2 oc process -f memory-leak-simulator-app/kube/openshift/deploy.yaml | oc apply -f -
5. Testing
    5.1 MEM_API_URL=$(oc get route memory-leak-simulator -o=jsonpath='{.spec.host}') | curl $MEM_API_URL/getMemoryDetails