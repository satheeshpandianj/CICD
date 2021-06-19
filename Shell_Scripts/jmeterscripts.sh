if [ -d reports/jmeter ];then
  mkdir -p reports/jmeter
fi

#docker run -d --name jmeter-test 454579647685.dkr.ecr.eu-west-2.amazonaws.com/banking/nbs-banking-jmeter sleep infinity

docker run -d --name jmeter-test Jmeter:latest sleep infinity

echo "copying jmx fies"
docker cp /Volumes/Adhira/GitHub/CICD/Jmeter_Scripts/ReqRes.jmx jmeter-test:/home/jmeter/
#docker cp tests/performance/Tests/REMO Aggregator API.jmx jmeter-test:/home/jmeter/
#docker cp tests/performance/Tests/REMO Intermediary API.jmx jmeter-test:/home/jmeter/
#docker cp tests/performance/Tests/OverPayment.jmx jmeter-test:/home/jmeter/
#docker cp tests/performance/Tests/overpayment_new.jmx jmeter-test:/home/jmeter/

echo "Started load test"

echo "Generating .jtl file from .jmx file"
docker exec -i -e JVM_ARGS="-Xms2048m -Xmx6144m" jmeter-test /bin/bash -c 'jmeter -n -t /home/jmeter/ReqRes.jmx -l /home/jmeter/jmeter.jtl > /dev/null && cat /home/jmeter/jmeter.jtl' > reports/jmeter/jmeter.jtl

echo "Generating html report from .jtl file"
docker exec -i jmeter-test /bin/bash -c 'jmeter -g /home/jmeter/jmeter.jtl -e -o /home/jmeter/htmlreport/'

docker cp jmeter-test:/home/jmeter/htmlreport/ reports/jmeter/
docker rm -f jmeter-test