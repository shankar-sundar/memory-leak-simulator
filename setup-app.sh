#!/bin/bash
#OCP_API_URL=https://api.crc.testing:6443
OCP_API_URL=$1
OCP_TOKEN=$2
OCP_APP_NS=rh-apps
APP_NAME=memory-leak-simulator
APP_IMAGE_LOCATION=quay.io/sankara_sundar/memory-leak-simulator:1.0.0


# Function to run a command and check its exit status
check_command_status() {
    # Run the provided command
    "$@"

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "Command executed successfully."
    else
        echo "Command failed with an error."
        exit -1
    fi
}

# Login to OCP Cluster
echo -e "\n\n >>>> STEP 1 - Logging into $OCP_API_URL with user $OCP_USER"
#check_command_status oc login -u $OCP_USER -p $OCP_PASSWORD $OCP_API_URL
check_command_status oc login --token=$OCP_TOKEN --server=$OCP_API_URL --insecure-skip-tls-verify=true

# Create application namespace
echo -e "\n\n >>>> STEP 2 - Creating $OCP_APP_NS namespace"
check_command_status oc new-project $OCP_APP_NS

# Importing pre-built application image 
echo -e "\n\n >>>> STEP 3 - Importing $APP_NAME from $APP_IMAGE_LOCATION"
check_command_status oc import-image $APP_NAME:latest \
        --from=$APP_IMAGE_LOCATION \
        --confirm

# Deploying memory leak simulator app
echo -e "\n\n>>>> STEP 4 - Deploying $APP_NAME to $OCP_APP_NS"
oc process -f memory-leak-simulator-app/kube/openshift/deploy.yaml | oc apply -f -

max_attempts=5
current_attempt=1

while [ $current_attempt -le $max_attempts ]; do
    echo "Attempting command (Attempt $current_attempt)..."
    
    # Replace the following command with the command you want to execute
    oc get pod $(oc get pod -l app.kubernetes.io/component=$APP_NAME -o custom-columns=NAME:.metadata.name --no-headers) --output=jsonpath='{.status.phase}' | grep -p 'Running'

    # Check the exit status of the command
    if [ $? -eq 0 ]; then
        echo "Memory leak simulator is setup and running!"
        break
    else
        echo "Application is not running. Retrying in 5 seconds..."
        sleep 5
        current_attempt=$((current_attempt + 1))
    fi
done

if [ $max_attempts -eq $current_attempt ]; then
    echo "Maximum attempts reached. Application is not running."
    exit -1
fi

warmup_time=60
echo "Waiting 60 seconds for component to warm up to serve requests"
for ((i=60; i>0; i--)); do
    printf "\r%02d seconds remaining" "$i"
    sleep 1
done

# Testing application 
MEM_API_URL=$(oc get route memory-leak-simulator -o=jsonpath='{.spec.host}')
echo -e "\n\n>>>> STEP 5 - Testing $APP_NAME getMemoryDetails endpoint - $MEM_API_URL/getMemoryDetails"
curl $MEM_API_URL/getMemoryDetails