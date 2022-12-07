# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit git-r3 desktop

RESTRICT="strip" #269221

SLOT="0/2.3" # Note: Slotting Lazarus needs slotting fpc, see DEPEND.
LICENSE="GPL-2 LGPL-2.1 LGPL-2.1-linking-exception"
KEYWORDS=""
DESCRIPTION="Lazarus IDE is a feature rich visual programming environment emulating Delphi."
HOMEPAGE="http://www.lazarus.freepascal.org/"
IUSE="gtk2 +gui"
REQUIRED_USE="gtk2? ( gui )"
REQUIRED_USE="!gui? ( !gtk2 )"

EGIT_REPO_URI="https://gitlab.com/freepascal.org/lazarus/lazarus.git"

FPCVER="3.2.2"

DEPEND="~dev-lang/fpc-${FPCVER}"
BDEPEND="net-misc/rsync"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	>=sys-devel/binutils-2.19.1-r1
	gui? ( 
	    !gtk2? ( dev-libs/libqt5pas:0/2.3 )
	    gtk2? ( x11-libs/gtk+:2 )
)"

src_prepare() {
	ewarn
	ewarn "you've selected to use fpc-$FPCVER !"
	ewarn
	eapply_user

	# Use default configuration (minus stripping) unless specifically requested otherwise
	if ! test ${PPC_CONFIG_PATH+set} ; then
		local FPCVER=$(fpc -iV)
		export PPC_CONFIG_PATH="${WORKDIR}"
		sed -e 's/^FPBIN=/#&/' /usr/lib/fpc/${FPCVER}/samplecfg |
			sh -s /usr/lib/fpc/${FPCVER} "${PPC_CONFIG_PATH}" || die
		#sed -i -e '/^-Xs/d' "${PPC_CONFIG_PATH}"/fpc.cfg || die
	fi



}

src_compile() {
	if ( use gui ) && ( use !gtk2 ) ; then
		export LCL_PLATFORM=qt5
	fi
	use gtk2 && export LCL_PLATFORM=gtk2
	if ( use gui ) ; then
		emake -j1 || die "make failed!"
	else
		emake lazbuild -j1 || die "make failed!"
	fi
}

src_install() {
	diropts -m0755
	dodir /usr/share/lazarus
	# Using rsync to avoid unnecessary copies and cleaning...
	# Note: *.o and *.ppu are needed
	rsync -a \
		--exclude="CVS"     --exclude=".cvsignore" \
		--exclude=".git" \
		--exclude="*.ppw"   --exclude="*.ppl" \
		--exclude="*.ow"    --exclude="*.a"\
		--exclude="*.rst"   --exclude=".#*" \
		--exclude="*.~*"    --exclude="*.bak" \
		--exclude="*.orig"  --exclude="*.rej" \
		--exclude=".xvpics" --exclude="*.compiled" \
		--exclude="killme*" --exclude=".gdb_hist*" \
		--exclude="debian"  --exclude="COPYING*" \
		--exclude="*.app" \
		"${S}"/* "${D}"/usr/share/lazarus \
	|| die "Unable to copy files!"

	if ( use gui ) ; then
	dosym ../share/lazarus/startlazarus /usr/bin/startlazarus
	dosym ../share/lazarus/startlazarus /usr/bin/lazarus
	fi
	dosym ../share/lazarus/lazbuild /usr/bin/lazbuild
	dosym ../lazarus/images/ide_icon48x48.png /usr/share/pixmaps/lazarus.png

	make_desktop_entry startlazarus "Lazarus IDE" "lazarus" || die "Failed making desktop entry!"
}
