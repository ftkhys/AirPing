#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Called when the overlay window is realized. Sets an empty input shape so
// the ENTIRE window becomes click-through: no clicks, scrolls, or hovers
// are captured by it at all — they pass straight through to whatever is
// behind it on the desktop. This replaces window_manager's
// setIgnoreMouseEvents, which does NOT work for desktop_multi_window's
// secondary windows on Linux (documented incompatibility between the two
// plugins — see leanflutter/window_manager issue #192).

static void on_overlay_window_realize(GtkWidget* widget, gpointer user_data) {
  cairo_region_t* empty_region = cairo_region_create();
  gtk_widget_input_shape_combine_region(widget, empty_region);
  cairo_region_destroy(empty_region);
}

// TRUE if this process launch is for a secondary overlay window spawned by
// desktop_multi_window (its first dart entrypoint argument is
// "multi_window" — matches the check in main.dart's Dart code).
static gboolean is_overlay_window(MyApplication* self) {
  return self->dart_entrypoint_arguments != nullptr && self->dart_entrypoint_arguments[0] != nullptr && g_strcmp0(self->dart_entrypoint_arguments[0], "multi_window") == 0; }

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  gboolean overlay = is_overlay_window(self);

  if (overlay) {
    // Overlay ping window: no title bar / borders at all.
    gtk_window_set_decorated(window, FALSE);

    // Keep it above every other window, including other apps.
    gtk_window_set_keep_above(window, TRUE);

    // Make it fully click-through so the user can still interact with
    // whatever app is underneath while the ping animation plays.
    g_signal_connect(window, "realize",
                      G_CALLBACK(on_overlay_window_realize), NULL);

    // Must request an alpha-capable (RGBA) visual BEFORE the widget is realized, otherwise a transparent background can never actually show through later - it just renders as opaque.
    GdkScreen* screen = gtk_window_get_screen(window);
    GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
    gboolean composited = gdk_screen_is_composited(screen);
    g_print("DEBUG overlay window: rgba_visual=%s composited=%s\n",
      visual != NULL ? "found" : "NULL",
      composited ? "TRUE" : "FALSE");
    if (visual != NULL && composited) {
      gtk_widget_set_visual(GTK_WIDGET(window), visual);
      g_print("DEBUG overlay window: RGBA visual applied\n");
    } else {
      g_print("DEBUG overlay window: RGBA visual SKIPPED (falling back to default, opaque)\n");
    }

    gtk_window_set_default_size(window, 1280, 720);
  } else {
    // Main AirPing window - unchanged from before.
    gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
    GdkScreen* screen = gtk_window_get_screen(window);
    if (GDK_IS_X11_SCREEN(screen)) {
      const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);

      if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
        use_header_bar = FALSE;
      }
    }
#endif
    if (use_header_bar){
      GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
      gtk_widget_show(GTK_WIDGET(header_bar));
      gtk_header_bar_set_title(header_bar, "airping");
      gtk_header_bar_set_show_close_button(header_bar, TRUE);
      gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
    } else {
      gtk_window_set_title(window, "airping");
    }
  gtk_window_set_default_size(window, 1280, 720);
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);

  GdkRGBA background_color;
  if (overlay)
  {
    // Fully transparent (alpha channel = 0), instead of the default
    // opaque black used by the main window.
    gdk_rgba_parse(&background_color, "#00000000");
  } else {
    gdk_rgba_parse(&background_color, "#000000");
  }
  fl_view_set_background_color(view, &background_color);
 
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
