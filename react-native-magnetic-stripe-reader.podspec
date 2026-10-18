require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-magnetic-stripe-reader"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  "A simple and fully customizable React Native Magnetic Stripe component that implements a function to parse the magnetic stripe data into the JSON object data"
                   DESC
  s.homepage     = package["repository"]["baseUrl"]
  # brief license entry:
  s.license      = "Apache-2.0"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "Apache-2.0", :file => "LICENSE" }
  s.authors      = { "Phu Le" => "phule.macos@gmail.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => package["repository"]["url"].sub("git+", ""), :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React-Core"
end

