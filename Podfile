platform :ios, '12.1'

target 'schematix' do

use_frameworks!

#pod 'FHIRHose', :path => '../deps/FHIRHose'
pod 'SMART', :path => '../deps/Swift-SMART'
pod 'ExtensionKit', :path => '../deps/ExtensionKit'
pod 'Textile'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end

    if ['FHIRHose'].include? target.name
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end


    if ['SMART'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
      end
    end


  end
end
