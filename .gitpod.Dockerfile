# docker build --no-cache --progress=plain -f .gitpod.Dockerfile .
FROM gitpod/workspace-postgres

USER root
RUN bash -c "install-packages postgresql-client build-essential libz-dev zlib1g-dev mysql-client"
RUN bash -c "apt-get update"

USER gitpod
# RUN bash -c "brew install hurl"
ARG JAVA_SDK="23-graalce"
RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh \
    && sdk install java $JAVA_SDK \
    && sdk default java $JAVA_SDK \
    && sdk install maven \
    && sdk install quarkus"
