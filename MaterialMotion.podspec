Pod::Spec.new do |s|
  s.name         = "MaterialMotion"
  s.summary      = "Reactive motion driven by Core Animation."
  s.version      = "2.0.0"
  s.authors      = "The Material Motion Authors"
  s.license      = "Apache 2.0"
  s.homepage     = "https://github.com/material-motion/material-motion-swift"
  s.source       = { :git => "https://github.com/material-motion/material-motion-swift.git", :tag => "v" + s.version.to_s }
  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source_files = "src/**/*.{swift}"

  s.dependency "IndefiniteObservable", "~> 4.0"
end
