class TogglSync < Formula
  desc "Tiny service to sync time entries from toggl to jira"
  homepage "https://github.com/timemate/toggl-sync"
  url "https://github.com/timemate/toggl-sync/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "1bbd53f7a3f80b31544f079a389bb49ede735f40c3a1533ddcac807f9f10692b"

  depends_on "go"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/timemate/toggl-sync").install buildpath.children
    cd "src/github.com/timemate/toggl-sync" do
      system "go", "build", "-o", bin/"toggl-sync", "."
    end
  end

  test do
    assert_match /Tiny service to sync time entries from toggl to jira/, shell_output("#{bin}/toggl-sync -h", 0)
  end

  ## Plist handling
  # Does your plist need to be loaded at startup?
  # plist_options :startup => true
  # Or only when necessary or desired by the user?
  plist_options :manual => "toggl-sync"
  # Or perhaps you'd like to give the user a choice? Ooh fancy.
  #  plist_options :startup => "true", :manual => "toggl-sync --service"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
        <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/toggl-sync</string>
        <string>-period 1w</string>
        <string>--service</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
      <key>StandardErrorPath</key>
      <string>/dev/null</string>
      <key>StandardOutPath</key>
      <string>/dev/null</string>
    </plist>
    EOS
  end
end
