#!/bin/bash
PKG="btop"
SRC_NAME="btop"
PKG_NAME="btop"
DESTDIR="usr/local"
SRC=${HOME}/src
SUDO=sudo
GCI=

[ -f "${SRC}/${SRC_NAME}/VERSION" ] || {
  [ -f "/builds/doctorfree/${SRC_NAME}/VERSION" ] || {
    echo "$SRC/$SRC_NAME/VERSION does not exist. Exiting."
    exit 1
  }
  SRC="/builds/doctorfree"
  SUDO=
  GCI=1
}

. "${SRC}/${SRC_NAME}/VERSION"
PKG_VER=${VERSION}
PKG_REL=${RELEASE}

umask 0022

# Subdirectory in which to create the distribution files
OUT_DIR="${SRC}/${SRC_NAME}/dist/${PKG_NAME}_${PKG_VER}"

[ -d "${SRC}/${SRC_NAME}" ] || {
    echo "$SRC/$SRC_NAME does not exist or is not a directory. Exiting."
    exit 1
}

cd "${SRC}/${SRC_NAME}"

# Build btop
./build btop

${SUDO} rm -rf dist
mkdir dist

[ -d ${OUT_DIR} ] && rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}

for dir in "usr" "${DESTDIR}" "${DESTDIR}/share" "${DESTDIR}/share/man" \
           "${DESTDIR}/share/applications" "${DESTDIR}/share/${PKG}"
do
    [ -d ${OUT_DIR}/${dir} ] || ${SUDO} mkdir ${OUT_DIR}/${dir}
    ${SUDO} chown root:root ${OUT_DIR}/${dir}
done

for dir in bin
do
    [ -d ${OUT_DIR}/${DESTDIR}/${dir} ] && ${SUDO} rm -rf ${OUT_DIR}/${DESTDIR}/${dir}
done

${SUDO} cp bin/btop ${OUT_DIR}/${DESTDIR}/bin/btop

${SUDO} cp *.desktop "${OUT_DIR}/${DESTDIR}/share/applications"
${SUDO} cp LICENSE ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp CHANGELOG.md ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp README.md ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} pandoc -f gfm README.md | ${SUDO} tee ${OUT_DIR}/${DESTDIR}/share/${PKG}/README.html > /dev/null
${SUDO} cp VERSION ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp -a themes ${OUT_DIR}/${DESTDIR}/share/btop/themes
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons/hicolor
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons/hicolor/48x48
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons/hicolor/48x48/apps
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons/hicolor/scalable
${SUDO} mkdir -p ${OUT_DIR}/${DESTDIR}/share/icons/hicolor/scalable/apps
${SUDO} cp Img/icon.png "${OUT_DIR}/${DESTDIR}/share/icons/hicolor/48x48/apps/btop.png"
${SUDO} cp Img/icon.svg "${OUT_DIR}/${DESTDIR}/share/icons/hicolor/scalable/apps/btop.svg"
${SUDO} gzip -9 ${OUT_DIR}/${DESTDIR}/share/${PKG}/CHANGELOG.md

${SUDO} cp -a man/man1 ${OUT_DIR}/${DESTDIR}/share/man/man1

${SUDO} chmod 644 ${OUT_DIR}/${DESTDIR}/share/man/*/*
${SUDO} chmod 755 ${OUT_DIR}/${DESTDIR}/bin/* \
                  ${OUT_DIR}/${DESTDIR}/bin \
                  ${OUT_DIR}/${DESTDIR}/share/man \
                  ${OUT_DIR}/${DESTDIR}/share/man/*
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type d | while read dir
do
  ${SUDO} chmod 755 "${dir}"
done
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type f | while read f
do
  ${SUDO} chmod 644 "${f}"
done
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type d | while read dir
do
  ${SUDO} chmod 755 "${dir}"
done
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type f | while read f
do
  ${SUDO} chmod 644 "${f}"
done
${SUDO} chown -R root:root ${OUT_DIR}/${DESTDIR}/share
${SUDO} chown -R root:root ${OUT_DIR}/${DESTDIR}/bin

echo "Building ${PKG_NAME}_${PKG_VER} rpm package"

[ -d pkg/rpm ] && cp -a pkg/rpm ${OUT_DIR}/rpm
[ -d ${OUT_DIR}/rpm ] || mkdir ${OUT_DIR}/rpm

have_rpm=`type -p rpmbuild`
[ "${have_rpm}" ] || {
  have_dnf=`type -p dnf`
  if [ "${have_dnf}" ]
  then
    ${SUDO} dnf install rpm-build
  else
    ${SUDO} apt-get update
    export DEBIAN_FRONTEND=noninteractive
    ${SUDO} ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
    ${SUDO} apt-get install rpm -y
    ${SUDO} dpkg-reconfigure --frontend noninteractive tzdata
  fi
}

ARCH=`rpm --eval '%{_arch}'`

rpmbuild -ba --build-in-place \
         --define "_topdir ${OUT_DIR}" \
         --define "_sourcedir ${OUT_DIR}" \
         --define "_version ${PKG_VER}" \
         --define "_release ${PKG_REL}" \
         --buildroot ${SRC}/${SRC_NAME}/${OUT_DIR}/BUILDROOT \
         ${OUT_DIR}/rpm/${PKG_NAME}.spec

# Rename RPMs if necessary
for rpmfile in ${OUT_DIR}/RPMS/*/*.rpm
do
  [ "${rpmfile}" == "${OUT_DIR}/RPMS/*/*.rpm" ] && continue
  rpmbas=`basename ${rpmfile}`
  rpmdir=`dirname ${rpmfile}`
  newnam=`echo ${rpmbas} | sed -e "s/${PKG_NAME}-${PKG_VER}-${PKG_REL}/${PKG_NAME}_${PKG_VER}-${PKG_REL}/"`
  [ "${rpmbas}" == "${newnam}" ] && continue
  mv ${rpmdir}/${rpmbas} ${rpmdir}/${newnam}
done

${SUDO} cp ${OUT_DIR}/RPMS/*/*.rpm dist

cd ${OUT_DIR}
echo "Creating compressed tar archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} tar cf - usr/local/*/* | gzip -9 > ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.tgz

have_zip=`type -p zip`
[ "${have_zip}" ] || {
  ${SUDO} yum install zip -y
}
echo "Creating zip archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} zip -q -r ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.zip usr/local/*/*
cd ../..

[ "${GCI}" ] || {
  [ -d releases ] || mkdir releases
  [ -d releases/${PKG_VER} ] || mkdir releases/${PKG_VER}
  ${SUDO} cp ${OUT_DIR}/RPMS/*/*.rpm releases/${PKG_VER}
  ${SUDO} cp dist/*.tgz dist/*.zip releases/${PKG_VER}
}
