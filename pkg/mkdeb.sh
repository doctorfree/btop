#!/bin/bash
PKG="btop"
SRC_NAME="btop"
PKG_NAME="btop"
DEBFULLNAME="Ronald Record"
DEBEMAIL="ronaldrecord@gmail.com"
DESTDIR="usr/local"
SRC=${HOME}/src
ARCH=amd64
SUDO=sudo
GCI=

dpkg=`type -p dpkg-deb`
[ "${dpkg}" ] || {
    echo "Debian packaging tools do not appear to be installed on this system"
    echo "Are you on the appropriate Linux system with packaging requirements ?"
    echo "Exiting"
    exit 1
}

dpkg_arch=`dpkg --print-architecture`
[ "${dpkg_arch}" == "${ARCH}" ] || ARCH=${dpkg_arch}

[ -f "${SRC}/${SRC_NAME}/VERSION" ] || {
  [ -f "/builds/doctorfree/${SRC_NAME}/VERSION" ] || {
    echo "$SRC/$SRC_NAME/VERSION does not exist. Exiting."
    exit 1
  }
  SRC="/builds/doctorfree"
  GCI=1
# SUDO=
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
if [ -x build ]
then
  ./build btop
else
  cd btop
  make distclean
  make STATIC=true STRIP=true
  chmod +x bin/btop
  cd ..
fi

${SUDO} rm -rf dist
mkdir dist

[ -d ${OUT_DIR} ] && rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}
mkdir ${OUT_DIR}/DEBIAN
chmod 755 ${OUT_DIR} ${OUT_DIR}/DEBIAN

echo "Package: ${PKG}
Version: ${PKG_VER}-${PKG_REL}
Section: misc
Priority: optional
Architecture: ${ARCH}
Depends: libncurses-dev
Maintainer: ${DEBFULLNAME} <${DEBEMAIL}>
Installed-Size: 2000
Build-Depends: debhelper (>= 11)
Homepage: https://github.com/doctorfree/btop
Description: Resource monitor that shows usage and stats for processor, memory, disks, network and processes" > ${OUT_DIR}/DEBIAN/control

chmod 644 ${OUT_DIR}/DEBIAN/control

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
${SUDO} cp VERSION ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} pandoc -f gfm README.md | ${SUDO} tee ${OUT_DIR}/${DESTDIR}/share/${PKG}/README.html > /dev/null
${SUDO} cp -a themes ${OUT_DIR}/${DESTDIR}/share/${PKG}/themes
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

cd dist
echo "Building ${PKG_NAME}_${PKG_VER} Debian package"
${SUDO} dpkg --build ${PKG_NAME}_${PKG_VER} ${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.deb
cd ${PKG_NAME}_${PKG_VER}
echo "Creating compressed tar archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} tar cf - usr/local/*/* | gzip -9 > ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.tgz

have_zip=`type -p zip`
[ "${have_zip}" ] || {
  ${SUDO} apt-get update
  ${SUDO} apt-get install zip -y
}
echo "Creating zip archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} zip -q -r ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.zip usr/local/*/*
cd ..

[ "${GCI}" ] || {
  [ -d ../releases ] || mkdir ../releases
  [ -d ../releases/${PKG_VER} ] || mkdir ../releases/${PKG_VER}
  ${SUDO} cp *.deb *.tgz *.zip ../releases/${PKG_VER}
}
