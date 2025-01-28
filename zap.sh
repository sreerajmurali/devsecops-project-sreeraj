#!/bin/bash

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

# Set permissions and print user ID
chmod 777 $(pwd)
echo $(id -u):$(id -g)

# Run ZAP API scan with custom rules
echo "Running ZAP API scan with custom rules..."
docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap_rules -r zap_report.html

exit_code=$?

# Move HTML report to the appropriate directory
sudo mkdir -p owasp-zap-report
sudo mv zap_report.html owasp-zap-report

echo "Exit Code : $exit_code"

if [[ ${exit_code} -ne 0 ]]; then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1
else
    echo "OWASP ZAP did not report any Risk"
fi