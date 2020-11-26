class Aom < Formula
  desc "Codec library for encoding and decoding AV1 video streams"
  homepage "https://aomedia.googlesource.com/aom"
  url "https://aomedia.googlesource.com/aom.git",
      tag:      "v2.0.1",
      revision: "b52ee6d44adaef8a08f6984390de050d64df9faa"
  license "BSD-2-Clause"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "a8e7c5f46fa775fa055c5c906dcc0919cc8336bbba9f5babb146b1d3351e17d7" => :big_sur
    sha256 "c4a83e9bc36bc1fe6633d8a4fef10436e5c79e825352e6562d776dcff6dbcd08" => :catalina
    sha256 "96537ef620ea5035ffbb643db83edc9fc7e7995fbcd08ebd16fef74d5e17b411" => :mojave
    sha256 "39d14687b9a45a50f921a19e23b935799d052686854bb247ed59235bcc28c59d" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "yasm" => :build

  resource "bus_qcif_15fps.y4m" do
    url "https://media.xiph.org/video/derf/y4m/bus_qcif_15fps.y4m"
    sha256 "868fc3446d37d0c6959a48b68906486bd64788b2e795f0e29613cbb1fa73480e"
  end

  def install
    mkdir "macbuild" do
      args = std_cmake_args.concat(["-DENABLE_DOCS=off",
                                    "-DENABLE_EXAMPLES=on",
                                    "-DENABLE_TESTDATA=off",
                                    "-DENABLE_TESTS=off",
                                    "-DENABLE_TOOLS=off"])
      # Runtime CPU detection is not currently enabled for ARM on macOS.
      args << "-DCONFIG_RUNTIME_CPU_DETECT=0" if Hardware::CPU.arm?
      system "cmake", "..", *args

      system "make", "install"
    end
  end

  test do
    resource("bus_qcif_15fps.y4m").stage do
      system "#{bin}/aomenc", "--webm",
                              "--tile-columns=2",
                              "--tile-rows=2",
                              "--cpu-used=8",
                              "--output=bus_qcif_15fps.webm",
                              "bus_qcif_15fps.y4m"

      system "#{bin}/aomdec", "--output=bus_qcif_15fps_decode.y4m",
                              "bus_qcif_15fps.webm"
    end
  end
end
