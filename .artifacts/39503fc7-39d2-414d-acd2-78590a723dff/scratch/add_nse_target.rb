require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Create the NSE target
target_name = 'OneSignalNotificationServiceExtension'
extension_target = project.new_target(:app_extension, target_name, :ios, '15.5')

# 2. Add files to the target
group = project.main_group.find_subpath(target_name, true)
group.set_source_tree('<group>')

files = [
  'NotificationService.swift',
  'Info.plist',
  'OneSignalNotificationServiceExtension.entitlements'
]

files.each do |file_name|
  file_path = File.join(target_name, file_name)
  file_ref = group.new_file(file_path)
  if file_name.end_with?('.swift')
    extension_target.add_file_references([file_ref])
  elsif file_name == 'Info.plist'
    extension_target.build_configurations.each do |config|
      config.build_settings['INFOPLIST_FILE'] = file_path
    end
  elsif file_name.end_with?('.entitlements')
    extension_target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_ENTITLEMENTS'] = file_path
    end
  end
end

# 3. Set bundle identifier
bundle_id = 'a5starcompany.com.megacheapdata.OneSignalNotificationServiceExtension'
extension_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2' # iPhone and iPad
end

# 4. Embed the extension in the main app target
runner_target = project.targets.find { |t| t.name == 'Runner' }
if runner_target
  # Add dependency
  extension_target_dep = runner_target.add_dependency(extension_target)

  # Add Embed App Extensions build phase if it doesn't exist
  embed_phase = runner_target.build_phases.find { |p| p.display_name == 'Embed Foundation Extensions' }
  unless embed_phase
    embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
    embed_phase.dst_subfolder_spec = '13'
  end

  # Add the extension product to the build phase
  embed_phase.add_file_reference(extension_target.product_reference)
end

project.save
puts "Successfully added #{target_name} target to Xcode project."
