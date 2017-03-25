workspace 'MaterialMotion.xcworkspace'
use_frameworks!

target "MaterialMotionCatalog" do
  pod 'CatalogByConvention'
  pod 'MaterialMotion', :path => './'

  project 'examples/apps/Catalog/MaterialMotionCatalog.xcodeproj'
end

target "UnitTests" do
  pod 'MaterialMotion', :path => './'

  project 'examples/apps/Catalog/MaterialMotionCatalog.xcodeproj'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
      if target.name.start_with?("Material")
        configuration.build_settings['WARNING_CFLAGS'] ="$(inherited) -Wall -Wcast-align -Wconversion -Werror -Wextra -Wimplicit-atomic-properties -Wmissing-prototypes -Wno-sign-conversion -Wno-unused-parameter -Woverlength-strings -Wshadow -Wstrict-selector-match -Wundeclared-selector -Wunreachable-code"
      end
    end
  end
end
