class Mx < Formula
  desc "Command-line tool used for the development of Graal projects"
  homepage "https://github.com/graalvm/mx"
  url "https://github.com/graalvm/mx/archive/refs/tags/6.20.0.tar.gz"
  sha256 "75e81fdfed39079afaa70c50b123173b6271b94b34eea4aac577e5cc5ee03b04"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "cfe3fafe0b7f20add08685b24efe60782dc88d6ad6a212c5b9c15377f8b1578f"
  end

  depends_on "openjdk" => :test
  depends_on "python@3.11"

  resource "homebrew-testdata" do
    url "https://github.com/oracle/graal/archive/refs/tags/vm-22.3.0.tar.gz"
    sha256 "410a003b8bab17af86fbc072d549e02e795b862a8396d08af9794febee17bad4"
  end

  def install
    libexec.install Dir["*"]
    (bin/"mx").write_env_script libexec/"mx", MX_PYTHON: "#{Formula["python@3.11"].opt_libexec}/bin/python"
    bash_completion.install libexec/"bash_completion/mx" => "mx"
  end

  def post_install
    # Run a simple `mx` command to create required empty directories inside libexec
    Dir.mktmpdir do |tmpdir|
      system bin/"mx", "--user-home", tmpdir, "version"
    end
  end

  test do
    ENV["JAVA_HOME"] = Language::Java.java_home
    ENV["MX_ALT_OUTPUT_ROOT"] = testpath

    testpath.install resource("homebrew-testdata")
    cd "vm" do
      output = shell_output("#{bin}/mx suites")
      assert_match "distributions:", output
    end
  end
end
