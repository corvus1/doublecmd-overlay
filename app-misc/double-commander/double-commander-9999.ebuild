# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg git-r3

ABBREV="doublecmd"

DESCRIPTION="Cross Platform file manager"
HOMEPAGE="http://doublecmd.sourceforge.net/"
EGIT_REPO_URI="https://github.com/doublecmd/doublecmd"

LICENSE="GPL-2"
SLOT="0"
RESTRICT="strip" #FreePascal does its own stripping

DEPEND="
	dev-libs/libqt5pas:0/2.3"
RDEPEND="
	${DEPEND}
	sys-apps/dbus
	dev-libs/glib
	x11-libs/libX11
	>=dev-qt/qtcore-5.6"
BDEPEND="
	dev-lang/lazarus:0/2.3
	net-misc/rsync"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
	default
	use amd64 && export CPU_TARGET="x86_64" || export CPU_TARGET="i386"
	find ./ -type f -name "build.sh" -exec \
		sed -i 's#$lazbuild #$lazbuild --lazarusdir=/usr/share/lazarus #g' {} \; || die
}

src_compile() {
	./build.sh release qt5 || die "build.sh failed
}

src_install() {
	install/linux/install.sh --install-prefix=build || die #install.sh failed

	# Since we're installing a polkit action, let's utilize it. For extra fanciness.
	printf "\nActions=StartAsRoot;\n\n[Desktop Action StartAsRoot]\nExec=/usr/bin/pkexec /usr/bin/doublecmd\nName=Start as root\n" >> \
		${S}/build/usr/share/applications/${ABBREV}.desktop || die

	# Without the following, the .desktop file doesn't show up in the KDE menu, specifically under the Utility category.
	# Can't figure out why, but you're welcome to try. Absurdly, it works fine in any other category.
	mv "${S}/build/usr/share/applications/${ABBREV}.desktop" \
		"${S}/build/usr/share/applications/${ABBREV}-${PN}.desktop" || die

	#using rsync to speed things up
	rsync -a "${S}/build/" "${D}/" || die "Unable to copy files"
	dosym ../lib64/${ABBREV}/${ABBREV} /usr/bin/${ABBREV}
}
