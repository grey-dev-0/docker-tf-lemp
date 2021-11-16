FROM kernel:latest
RUN yum install -y gcc-c++ make; \
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -; \
    yum install -y nodejs jq; npm install -g @vue/cli @vue/cli-service-global @vue/compiler-sfc