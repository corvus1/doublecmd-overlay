# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/doublecmd/doublecmd"

inherit xdg-utils git-r3

ABBREV="doublecmd"
DESCRIPTION="Cross Platform file manager."
HOMEPAGE="http://${ABBREV}.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="gtk qt5"
REQUIRED_USE=" ^^ ( gtk qt5 )"
RESTRICT="strip"

DEPEND=">=dev-lang/lazarus-1.8
	dev-libs/libqt5pas"
RDEPEND="
	${DEPEND}
	sys-apps/dbus
	dev-libs/glib
	x11-libs/libX11
	gtk? ( x11-libs/gtk+:2 )
	qt5? ( >=dev-qt/qtcore-5.6 )
"

S="${WORKDIR}/${PN}-${PV}"

src_prepare(){
	eapply_user
	use gtk && export lcl="gtk2"
	use qt5 && export lcl="qt5"
	use amd64 && export CPU_TARGET="x86_64" || export CPU_TARGET="i386"
	export lazpath="/usr/share/lazarus"
	find ./ -type f -name "build.sh" -exec sed -i 's#$lazbuild #$lazbuild --lazarusdir=/usr/share/lazarus #g' {} \;
}

src_compile(){
	./build.sh release || die
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
