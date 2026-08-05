# Pinned to 0.21.1 so local dev machines and CI resolve msgfmt/xgettext to the same
# version. Extracted via `brew extract` from homebrew/core. See platform/server/Brewfile
# in Graici/platform for where this is consumed.
class GettextAT021 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftpmirror.gnu.org/gnu/gettext/gettext-0.21.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.21.1.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.21.1.tar.gz"
  sha256 "e8c3650e1d8cee875c4f355642382c1df83058bd5a11ee8555c0cf276d646d45"
  license "GPL-3.0-or-later"

  uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  def install
    args = [
      "--disable-silent-rules",
      "--with-included-glib",
      "--with-included-libcroco",
      "--with-included-libunistring",
      "--with-included-libxml",
      "--with-emacs",
      "--with-lispdir=#{elisp}",
      "--disable-java",
      "--disable-csharp",
      # Don't use VCS systems to create these archives
      "--without-git",
      "--without-cvs",
      "--without-xz",
    ]
    args << if OS.mac?
      # Ship libintl.h. Disabled on linux as libintl.h is provided by glibc
      # https://gcc-help.gcc.gnu.narkive.com/CYebbZqg/cc1-undefined-reference-to-libintl-textdomain
      # There should never be a need to install gettext's libintl.h on
      # GNU/Linux systems using glibc. If you have it installed you've borked
      # your system somehow.
      "--with-included-gettext"
    else
      "--with-libxml2-prefix=#{formula_opt_prefix("libxml2")}"
    end

    # Sonoma iconv() has a regression w.r.t. transliteration, which happens to
    # break gettext's configure check. Force it.
    # Reported to Apple as FB13163914
    args << "am_cv_func_iconv_works=y" if OS.mac? && MacOS.version == :sonoma

    system "./configure", *std_configure_args, *args
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system bin/"gettext", "test"
  end
end
