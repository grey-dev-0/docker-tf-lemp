FROM rockylinux:9
ARG UID=1000
ARG GID=1000
RUN echo 'fastestmirror=1' >> /etc/dnf/dnf.conf; echo 'max_parallel_downloads=8' >> /etc/dnf/dnf.conf; \
    yum install -y dnf-plugins-core git vim wget glibc-locale-source glibc-langpack-ar tzdata iproute; \
    groupadd --gid 101 nginx; useradd -M --uid 101 --gid 101 nginx; groupadd --gid $GID user; \
    useradd --uid $UID --gid $GID user