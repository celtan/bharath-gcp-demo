#!/bin/bash

#Author: Bharath Raj
#This script is used to start the simple Java CRUD app

#Set environment variables
JAVA_OPTS="${JAVA_OPTS} -Xmx1024m"
JAVA_OPTS="${JAVA_OPTS} -Xmn650m"
JAVA_OPTS="${JAVA_OPTS} -javaagent:/opt/app/signalfx-tracing.jar"

export JAEGER_ENDPOINT=http://${SFX_AGENT_HOST}:9081/v1/trace

java ${JAVA_OPTS} -jar app.jar

