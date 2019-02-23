FROM asia.gcr.io/hip-microservices-experiment-2/java-base

# create an app user so our program doesn't run as root
RUN groupadd -g 1000 -r appuser \
&&  useradd -rm -u 1000 -g appuser -d /home/appuser -c "Crud Application User" appuser

ENV APP_HOME=/opt/app

RUN mkdir -p ${APP_HOME}

COPY src/main/resources/application.properties ${APP_HOME}/
COPY build/libs/*.jar ${APP_HOME}/app.jar
COPY bin/signalfx-tracing.jar ${APP_HOME}/
COPY bin/app-start.sh ${APP_HOME}/

WORKDIR ${APP_HOME}
RUN chown -R appuser:appuser ${APP_HOME}
USER appuser

RUN find / -perm +6000 -type f -exec chmod a-s {} \; || true

EXPOSE 8080
ENTRYPOINT ["/opt/app/app-start.sh"]

