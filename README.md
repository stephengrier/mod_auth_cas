# Build the mod_auth_cas apache module

# Description

This repo contains the build files needed for building the mod_auth_cas
apache module and packaging it as an RPM.

The build system builds mod_auth_cas inside a docker container, which means 
it is possible to build it on any docker-enabled host without having to 
install compilers and libraries on your host. However, this does mean that 
docker is a pre-requisite and you'll need to install it first. If you're 
using a Redhat based system, install docker with:

```bash
yum install docker-io
service docker start
```

If you're using a Debian based system install docker with:

```bash
apt-get install docker.io
service docker.io start
```

# Building the mod_auth_cas RPM

Once you've got docker installed you can build the mod_auth_cas RPM by doing:

```bash
docker run --rm -v $(pwd):/host --hostname="centos6.build.ucl.ac.uk" centos:centos6 /host/build-rpm.sh

docker run --rm -v $(pwd):/host --hostname="centos7.build.ucl.ac.uk" centos:centos7 /host/build-rpm.sh

```

All being well you should be left with an RPM in the cwd.

