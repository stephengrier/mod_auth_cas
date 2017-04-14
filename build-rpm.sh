#!/bin/bash
# build-rpm.sh - run this script inside docker to package the mod_auth_cas software.
#
# Run like so:
# sudo docker run --rm -v $(pwd):/host --hostname="centos6.build.ucl.ac.uk" centos:centos6 /host/tools/build-rpm.sh
#
# Stephen Grier <s.grier at ucl.ac.uk>
set -x
set -e

name="mod_auth_cas";
workdir="/tmp";
hostdir="/host";
#sourceUrl="https://github.com/Jasig/mod_auth_cas.git";
sourceUrl="https://github.com/rohajda/mod_auth_cas-1.git";

# Install build dependencies.
yum -y install rpm-build tar git redhat-rpm-config \
               make openssl-devel httpd-devel libcurl-devel \
               gcc pcre-devel;

# Get the source.
cd ${workdir};
git clone $sourceUrl ${name};

# Construct a release number from the current date + the git rev.
cd ${name}/;
date=$(date +'%Y%m%d');
rev=$(git rev-parse --short HEAD);
release="${date}git${rev}";

# Get the version number from the configure script.
version=$(grep 'PACKAGE_VERSION=' configure | cut -d\' -f2);

# Copy in our spec file.
cp -p ${hostdir}/${name}.spec .;
sed -i "s/^Version:.*/Version: ${version}/" ${name}.spec;
sed -i "s/^Release:.*/Release: ${release}/" ${name}.spec;
sed -i "s/^Source0:.*/Source0:        ${name}-${version}.tar.gz/" ${name}.spec;

#echo Before APX
#repoquery -ql httpd-devel


sed -i "s/^%configure .*/%configure  --with-apxs=\/usr\/bin\/apxs/" ${name}.spec;

# Now build the tarball.
cd ../ && mv ${name} ${name}-${version};
tar czvf ${name}-${version}.tar.gz ${name}-${version};

# Create the rpmbuild dir structure.
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Move the tarball to the sources directory.
mv ${name}-${version}.tar.gz ~/rpmbuild/SOURCES/;
cp ${hostdir}/auth_cas.conf ~/rpmbuild/SOURCES/;

# Set rpmmacros file.
echo "%_topdir %(echo $HOME)/rpmbuild" > ~/.rpmmacros
cat ~/.rpmmacros;

# Now run rpmbuild.
cd ~/rpmbuild;
rpmbuild -ta SOURCES/${name}-${version}.tar.gz

if [ "$?" != "0" ]; then
  echo "rpmbuild has failed!!!";
  exit 1;
fi;

# Copy the resulting RPM to the host dir.
cp -p RPMS/x86_64/${name}-${version}-${release}.x86_64.rpm $hostdir;
cp -p SRPMS/${name}-${version}-${release}.src.rpm $hostdir;

exit 0;

