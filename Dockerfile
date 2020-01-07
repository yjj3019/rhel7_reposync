FROM registry.access.redhat.com/rhel7
MAINTAINER jjyoo@rockplace.co.kr
LABEL "RHEL7 reposync with Podman"
LABEL summary="RHEL7 base reposync image"

### Timezone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### Source IP
ENV sip=""

#ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /repo1 > /dev/null

### Package Update
RUN yum update -y > /dev/null

### Package Install
RUN yum install cronie createrepo -y > /dev/null
RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-eus-rpms --enable rhel-7-server-rh-common-rpms --enable rhel-ha-for-rhel-7-server-rpms --enable rhel-rs-for-rhel-7-server-rpms > /dev/null 
RUN yum clean all -y > /dev/null

### Cron Setting
# Seems like a container specific issue on Centos: https://github.com/CentOS/CentOS-Dockerfiles/issues/31 
RUN sed -i '/session    required   pam_loginuid.so/d' /etc/pam.d/crond
RUN echo "* 01 * * * /repo1/rhel7_reposync.sh" > /var/spool/cron/root > /dev/null 
RUN touch /var/log/cron.log > /dev/null

### Cron Add
ADD start-cron.txt /tmp/start-cron.txt
RUN crontab /tmp/start-cron.txt 
RUN rm -f /tmp/start-cron.txt

### reposync file Add
RUN mkdir -p /root/reposync
ADD rhel7_reposync.sh /root/reposync
ADD rhel7_channel.txt /root/reposync
RUN chmod +x /root/reposync/rhel7_reposync.sh

##custom entry point — needed by cron
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
