export PROJECT_ID=`gcloud config get-value project` &&   export M_TYPE=n1-standard-2 &&   export ZONE=us-central1-b &&   export CLUSTER_NAME=${PROJECT_ID}-${RANDOM} &&   gcloud services enable container.googleapis.com &&   gcloud container clusters create $CLUSTER_NAME   --cluster-version 1.20.15   --machine-type=$M_TYPE   --num-nodes 4   --zone $ZONE   --project $PROJECT_ID



wget https://github.com/kubeflow/manifests/archive/refs/heads/v$1-branch.zip

unzip v$1-branch.zip

cd manifests-$1-branch/

while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt
openssl req -out httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout tls.key -subj "/CN=httpbin.example.com/O=httpbin organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in httpbin.example.com.csr -out tls.crt

kubectl create secret generic istio-ingressgateway-certs --from-file=tls.key=tls.key --from-file=tls.crt=tls.crt -n istio-system

kubectl patch svc istio-ingressgateway -n istio-system -p '{"metadata":{"annotations":{"beta.cloud.google.com/backend-config":"{\"ports\": {\"http2\":\"iap-backendconfig\"}}"}}}'


kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch MutatingWebhookConfiguration istio-sidecar-injector -p '{"metadata":{"annotations":{"admissions.enforcer/disabled": "true"}}}'

kubectl delete pod --all -n kubeflow

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kubeflow-gateway
  namespace: kubeflow
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - '*'
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      mode: SIMPLE
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
EOF

watch kubectl get svc -n istio-system
