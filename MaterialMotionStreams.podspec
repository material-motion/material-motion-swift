Pod::Spec.new do |s|
  s.name         = "MaterialMotionStreams"
  s.summary      = "Material Motion streams for Apple devices"
  s.version      = "1.0.0"
  s.authors      = "The Material Motion Authors"
  s.license      = "Apache 2.0"
  s.homepage     = "https://github.com/material-motion/streams-swift"
  s.source       = { :git => "https://github.com/material-motion/streams-swift.git", :tag => "v" + s.version.to_s }
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.source_files = "src/**/*.{swift}"

  s.dependency "IndefiniteObservable", "~> 3.0"
  s.dependency "pop"
end
