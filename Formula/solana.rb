class Solana < Formula
  desc "Web-Scale Blockchain for decentralized apps and marketplaces"
  homepage "https://solana.com"
  url "https://github.com/solana-labs/solana/archive/v1.10.31.tar.gz"
  sha256 "149cd41137725f248fc945f8c4a9e1ccb4ba495e192e4e225f980f8cea120a90"
  license "Apache-2.0"

  # This formula tracks the stable channel but the "latest" release on GitHub
  # varies between Mainnet and Testnet releases. This identifies versions by
  # checking the releases page and only matching Mainnet releases.
  livecheck do
    url "https://github.com/solana-labs/solana/releases?q=prerelease%3Afalse"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >][^>]*?>[^<]*?Mainnet}i)
    strategy :page_match
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e6dcb90645eefcf9c5aa3be0bce373bc1ca3a04806325e07889a0adb12865bd1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "4e7d45cde99dcf7e0b6224f0ae916f95cc4dd5c9b3b74157f89a7d1106d3c76b"
    sha256 cellar: :any_skip_relocation, monterey:       "9615197e908b6c8600faf250a7c733329a519e91290641e18803cda1afca01a8"
    sha256 cellar: :any_skip_relocation, big_sur:        "4ab3571f528afeb69a9ab0f521cfc5fdb91853fca6c283d49a73673c82f649be"
    sha256 cellar: :any_skip_relocation, catalina:       "ba3d92425e6db9ca8c5e4da2bc94eff479e414836602dc0c833731a3049da283"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0949a9526d5b84a8f899fb8f6707e20eac3dee3b8576b4cc3093ddebbbac6708"
  end

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  uses_from_macos "zlib"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "openssl@1.1"
    depends_on "systemd"
  end

  def install
    # Fix for error: cannot find derive macro `Deserialize` in this scope. Already fixed on 1.11.x.
    # Can remove if backported to 1.10.x or when 1.11.x has a stable release.
    # Ref: https://github.com/solana-labs/solana/commit/12e24a90a009d7b8ab1ed5bb5bd42e36a4927deb
    inreplace "net-shaper/Cargo.toml", /^serde = ("[\d.]+")$/, "serde = { version = \\1, features = [\"derive\"] }"

    %w[
      cli
      bench-streamer
      faucet
      keygen
      log-analyzer
      net-shaper
      stake-accounts
      sys-tuner
      tokens
      watchtower
    ].each do |bin|
      system "cargo", "install", "--no-default-features", *std_cargo_args(path: bin)
    end
  end

  test do
    assert_match "Generating a new keypair",
      shell_output("#{bin}/solana-keygen new --no-bip39-passphrase --no-outfile")
    assert_match version.to_s, shell_output("#{bin}/solana-keygen --version")
  end
end
