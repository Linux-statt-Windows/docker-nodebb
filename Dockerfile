# TODO: check installation routinehttps://hub.docker.com/r/nodebb/docker/~/dockerfile/
# NOTE: how to mount a shared volume http://docs.docker.com/engine/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes
#             needed for redis db and nodebb public
# TODO: write down commands needed to start nodebb and expose share volumes

FROM centos:centos7
MAINTAINER Linux statt Windows, Neotrace <Daniel.Jankowski@rub.de>, Niklas Heer <niklas.heer@gmail.com>

################### Installation #####################
# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install net-tools, small package with basic networking tools (e.g. netstat)
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)
# - Install yum-utils so we have yum-config-manager tool available
# - Install tar wget git ImageMagick openssl openssl-devel vim, as main tools needed
# - Install "Development Tools" because we need them to build stuff
# - Install redis
# - Install nginx
# - Install SSH
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools hostname inotify-tools yum-utils tar wget git ImageMagick openssl openssl-devel vim&& \
  yum -y groupinstall "Development Tools"&& \
  yum -y install redis&& \
  yum -y install nginx&& \
  yum -y install openssh-server&& \
  yum clean all && \

  easy_install supervisor

# INSTALL - nodejs 0.12.7
RUN wget https://rpm.nodesource.com/pub_0.12/el/7/x86_64/nodejs-0.12.7-1nodesource.el7.centos.x86_64.rpm -O /tmp/nodejs-0.12.7.rpm
RUN rpm -Uvh /tmp/nodejs-0.12.7.rpm

# INSTALL - global nodejs modules
RUN npm -g install node-gyp
RUN npm -g install npm

################### Install NodeBB #####################
# Create a nodebb volume
#VOLUME /var/www/nodebb

# Define a working directory
WORKDIR /var/www/nodebb

# Clone NodeBB
RUN mkdir -p /var/www; git clone https://github.com/Linux-statt-Windows/nodebb.git  /var/www/nodebb
# Install NodeBB packages
RUN cd /var/www/nodebb; npm install --production
# Remove nodebb-theme-persona
RUN rm -rf /var/www/nodebb/node_modules/nodebb-theme-persona
# Init and update submodules
RUN git submodule init; git submodule update
# Run npm install for ever submodule
RUN git submodule foreach npm install

################## Start options ####################

# expose Ports
# Note: redis and nodebb live inside the container, thus they don't need to be exposed
EXPOSE 80
EXPOSE 22

# Add supervisord conf, bootstrap.sh, nginx and nodebb files
ADD container-files /

VOLUME ["/data"]
ENTRYPOINT ["/config/bootstrap.sh"]

# start nodebb
CMD [ "node", "app.js" ]
