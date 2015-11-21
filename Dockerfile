# TODO: check installation routinehttps://hub.docker.com/r/nodebb/docker/~/dockerfile/
# NOTE: how to mount a shared volume http://docs.docker.com/engine/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes
#             needed for redis db and nodebb public
# TODO: write down commands needed to start nodebb and expose share volumes

FROM centos:centos7
MAINTAINER Linux statt Windows, Neotrace <Daniel.Jankowski@rub.de>, Niklas Heer <niklas.heer@gmail.com>

################### Installation #####################

# nodejs 4.x
RUN curl -sL https://rpm.nodesource.com/setup_4.x | bash -

# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install net-tools, small package with basic networking tools (e.g. netstat)
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)
# - Install yum-utils so we have yum-config-manager tool available
# - Install tar wget git ImageMagick openssl openssl-devel vim, as main tools needed
# - Install "Development Tools" because we need them to build stuff
# - Install nodejs
# - Install redis
# - Install nginx
# - Install SSH
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools hostname inotify-tools yum-utils tar wget git ImageMagick openssl openssl-devel vim&& \
  yum -y groupinstall "Development Tools"&& \
  yum -y install nodejs&& \
  yum -y install redis&& \
  yum -y install nginx&& \
  yum -y install openssh-server&& \
  yum clean all && \

  easy_install supervisor

# INSTALL - global nodejs modules
RUN npm -g install node-gyp
RUN npm -g install npm

################### Install NodeBB #####################
# Create a nodebb volume
#VOLUME /var/www/nodebb

# Define a working directory
WORKDIR /var/www/nodebb

RUN mkdir -p /var/www; git clone -b fix-lwip https://github.com/Linux-statt-Windows/nodebb.git  /var/www/nodebb
RUN cd /var/www/nodebb; git submodule init; git submodule update

# install nodejs sub-modules
RUN npm install --production

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
