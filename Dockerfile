FROM centos:7

VOLUME /sys/fs/cgroup /run /tmp

MAINTAINER luonglit <pvluong0001@gmail.com>

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
RUN yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y

# salt-master
RUN yum -y install initscripts && \
    yum install -y epel-release && \
    yum install -y --nogpgcheck https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm && \
    yum update -y && \
    yum install -y salt-master && \
    yum install -y libselinux-utils && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN sed -i "s|#auto_accept: False|auto_accept: True|g" /etc/salt/master

CMD ["/usr/sbin/init"]