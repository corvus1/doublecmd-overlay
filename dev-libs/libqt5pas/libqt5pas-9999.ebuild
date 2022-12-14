# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils

MY_P="lazarus-2.2.4-0"

if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="https://gitlab.com/freepascal.org/lazarus/lazarus.git"
	inherit git-r3
else
	SRC_URI="mirror://sourceforge/lazarus/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Free Pascal Qt5 bindings library updated by lazarus IDE"
HOMEPAGE="https://gitlab.com/freepascal.org/lazarus/lazarus"
LICENSE="LGPL-3"
SLOT="0/2.3"

DEPEND="
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtx11extras:5
"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/lazarus/lcl/interfaces/qt5/cbindings"

src_unpack () {
	if [[ ${PV} = 9999* ]]; then
		git-r3_fetch ${EGIT_REPO_URI}
		git-r3_checkout ${EGIT_REPO_URI} "${WORKDIR}/lazarus" "" "lcl/interfaces/qt5/cbindings"
	else
		unpack ${P}.tar.gz
	fi
}

src_configure() {
	eqmake5 "QT += x11extras" Qt5Pas.pro
}

src_install() {
	emake INSTALL_ROOT="${D}" install
}
