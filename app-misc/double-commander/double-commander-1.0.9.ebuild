# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="Cross Platform file manager."
HOMEPAGE="http://doublecmd.sourceforge.net/"
SRC_URI="https://github.com/doublecmd/doublecmd/releases/download/v${PV}/doublecmd-${PV}-src.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

ABBREV="doublecmd"

RESTRICT="strip"

DEPEND="dev-lang/lazarus:0/2.2
	>=dev-qt/qtcore-5.6
	>=dev-qt/qtgui-5.6
	>=dev-qt/qtnetwork-5.6
	>=dev-qt/qtx11extras-5.6
	dev-libs/libqt5pas:0/2.2"

BDEPEND="net-misc/rsync"

RDEPEND="
	${DEPEND}
	sys-apps/dbus
	dev-libs/glib
	x11-libs/libX11"

S="${WORKDIR}/${ABBREV}-${PV}"

src_prepare(){
	eapply_user
	use amd64 && export CPU_TARGET="x86_64" || export CPU_TARGET="i386"
	export lazpath="/usr/share/lazarus"
	find ./ -type f -name "build.sh" -exec sed -i 's#$lazbuild #$lazbuild --lazarusdir=/usr/share/lazarus #g' {} \;
}

src_compile(){
	./build.sh release qt5 || die
}

src_install(){
	install/linux/install.sh --install-prefix=build

	# Since we're installing a polkit action, let's utilize it. For extra fanciness.
	printf "\nActions=StartAsRoot;\n\n[Desktop Action StartAsRoot]\nExec=/usr/bin/pkexec /usr/bin/doublecmd\nName=Start as root\n" >> \
		${S}/build/usr/share/applications/${ABBREV}.desktop

	# Without the following, the .desktop file doesn't show up in the KDE menu, specifically under the Utility category.
	# Can't figure out why, but you're welcome to try. Absurdly, it works fine in any other category.
	mv "${S}/build/usr/share/applications/${ABBREV}.desktop" "${S}/build/usr/share/applications/${ABBREV}-${PN}.desktop"

	rsync -a "${S}/build/" "${D}/" || die "Unable to copy files"
	dosym ../lib64/${ABBREV}/${ABBREV} /usr/bin/${ABBREV}
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
