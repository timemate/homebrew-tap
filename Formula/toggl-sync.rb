class TogglSync < Formula
  desc "Tiny service to sync time entries from toggl to jira"
  homepage "https://github.com/timemate/toggl-sync"
  url "https://github.com/timemate/toggl-sync/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "3323c13667e535e09d541ef4adb0b48a0e8afa872e88c2c9920190cb18593c3d"

  depends_on "go"

  def install
    (etc/"toggl-sync").mkpath unless File.exists? etc/"toggl-sync"
    prefix.install_symlink etc/"toggl-sync" => "config"
    (var/"log/toggl-sync").mkpath unless File.exists? var/"log/toggl-sync"
    prefix.install_symlink var/"log/toggl-sync" => "logs"
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
        <string>sync</string>
        <string>-period</string>
        <string>1w</string>
        <string>--service</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
      <key>StandardErrorPath</key>
      <string>#{var}/log/toggl-sync/toggl-sync.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/toggl-sync/toggl-sync.log</string>
    </dict>
    </plist>
    EOS
  end
end
