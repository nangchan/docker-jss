# docker-jss
*To Build:*

docker build --rm --no-cache -t noreplyback/jss .
docker run --privileged --name jss -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2200:22 -p 3000:3000 -d noreplyback/jss

Dockerfile that stands up a Sitecore JSS 11 website on CentOS7

*Has the following services enabled:*

1. SystemD
2. SSHD

*Has the following packages installed:*

1. SSH 7
2. Vim 7.4
3. Tmux 1.8
4. Node.js 11
5. NPM 6.5
6. Git 1.8
7. Python 2.7
