class TogglSync < Formula
  desc "Tiny service to sync time entries from toggl to jira"
  homepage "https://github.com/timemate/toggl-sync"
  url "https://github.com/timemate/toggl-sync/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "1bbd53f7a3f80b31544f079a389bb49ede735f40c3a1533ddcac807f9f10692b"

  depends_on "go"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    ENV["GOFLAGS"] = "-mod=vendor"
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/timemate/toggl-sync").install buildpath.children
    cd "src/github.com/timemate/toggl-sync" do
      system "go", "build", "-o", bin/"toggl-sync", "."
    end
  end

  test do
    assert_match /Tiny service to sync time entries from toggl to jira/, shell_output("#{bin}/toggl-sync -h", 0)
  end
end
