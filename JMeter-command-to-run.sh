$(Agent.HomeDirectory)/../../opt/apache-jmeter-5.3/bin/jmeter -n -f -t ./loadtest/petclinic_loadtest.jmx -Jhost=$(cat ~/testvm_public_IP ) -e -l ./loadtest/test_log -o ./loadtest/dashboard
