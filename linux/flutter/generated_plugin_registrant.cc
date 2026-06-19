//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <advert/advert_plugin.h>
#include <file_selector_linux/file_selector_plugin.h>
#include <flutter_secure_storage_linux/flutter_secure_storage_linux_plugin.h>
#include <gtk/gtk_plugin.h>
#include <sprint_check/sprint_check_plugin.h>
#include <sprintliveness/sprintliveness_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) advert_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AdvertPlugin");
  advert_plugin_register_with_registrar(advert_registrar);
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_secure_storage_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterSecureStorageLinuxPlugin");
  flutter_secure_storage_linux_plugin_register_with_registrar(flutter_secure_storage_linux_registrar);
  g_autoptr(FlPluginRegistrar) gtk_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "GtkPlugin");
  gtk_plugin_register_with_registrar(gtk_registrar);
  g_autoptr(FlPluginRegistrar) sprint_check_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SprintCheckPlugin");
  sprint_check_plugin_register_with_registrar(sprint_check_registrar);
  g_autoptr(FlPluginRegistrar) sprintliveness_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SprintlivenessPlugin");
  sprintliveness_plugin_register_with_registrar(sprintliveness_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
