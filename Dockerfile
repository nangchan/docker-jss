# Resource: https://github.com/CentOS/CentOS-Dockerfiles/tree/master/systemd/centos7

# To Build: docker build --rm --no-cache -t noreplyback/jss .
# To Run:   docker run --privileged --name jss -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2200:22 -p 3000:3000 -d noreplyback/jss
# To SSH:   ssh -p 2200 webteam@localhost
# To Login: docker exec -it jss /bin/bash
# To Swap:  su webteam

# To Push:  docker push noreplyback/jss
# To Pull:  docker pull noreplyback/jss
# To PS:    docker ps
# To Stop:  docker stop jss
# To Start: docker start jss
# To RM:    docker rm jss
# To Term:  docker image rm noreplyback/jss

FROM centos:7

ENV container docker
MAINTAINER The CentOS Project <cloud-ops@centos.org>

# Update packages
RUN yum -y update; yum clean all

# Remove services run by SystemD
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install sshd
RUN yum -y install openssh-server; yum clean all

# Enable sshd
RUN systemctl enable sshd.service

# Create SSH keys
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

# Enable systemd-user-sessions thereby removing /var/run/nologin
# https://github.com/CentOS/CentOS-Dockerfiles/issues/173
RUN systemctl enable systemd-user-sessions.service 
RUN ln -s /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/default.target.wants/systemd-user-sessions.service

# Create new user webteam
RUN yum -y install openssl passwd; yum clean all
# Add user to wheel for sudo and set password to hUh458hDh2j382D02jD5cMw2Di8J19f2
RUN adduser webteam -g wheel -p $(echo hUh458hDh2j382D02jD5cMw2Di8J19f2 | openssl passwd -1 -stdin)

# Install sudo and SSH client
RUN yum -y install sudo openssh-clients; yum clean all



# Install extra packages
RUN yum -y install vim tmux git man; yum clean all

# Install nodejs 11 and npm 6
RUN curl -sL https://rpm.nodesource.com/setup_11.x | sudo bash -
RUN yum -y install nodejs

# Install jss module
RUN npm install -g @sitecore-jss/sitecore-jss-cli

# Install latest yarn 1.13
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
RUN yum -y install yarn

# Install htop
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install htop



# Copy SSH public key to container for user webteam
ADD ./authorized_keys /home/webteam/.ssh/authorized_keys
# Copy sudoers to not need a password
ADD ./sudoers /etc/

# Run start.sh under webteam user
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
RUN su webteam -c "./start.sh"



# show password
RUN echo ssh credentials - webteam:hUh458hDh2j382D02jD5cMw2Di8J19f2@localhost

EXPOSE 22

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]
