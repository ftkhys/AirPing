//
// Created by yangbin on 2022/1/11.
//

#include "flutter_window.h"
#include <iostream>
#include "include/desktop_multi_window/desktop_multi_window_plugin.h"
#include "desktop_multi_window_plugin_internal.h"

namespace {
WindowCreatedCallback _g_window_created_callback = nullptr;
}

gboolean on_close_clicked(GtkWidget *widget, GdkEvent *event, gpointer user_data) {
    gtk_widget_destroy(widget);
    return TRUE;
}

// AirPing: makes the whole window click-through once it's realized — no
// clicks/scrolls/hovers are captured by it at all, they pass straight
// through to whatever is behind it on the desktop.
static void airping_apply_click_through(GtkWidget *widget) {
  cairo_region_t *empty_region = cairo_region_create();
  gtk_widget_input_shape_combine_region(widget, empty_region);
  cairo_region_destroy(empty_region);
}

static void airping_on_overlay_realize(GtkWidget *widget, gpointer user_data) {
  airping_apply_click_through(widget);
}

static gboolean airping_on_overlay_configure(GtkWidget *widget,
                                              GdkEventConfigure *event,
                                              gpointer user_data) {
  airping_apply_click_through(widget);
  return FALSE;
}

FlutterWindow::FlutterWindow(
    int64_t id,
    const std::string &args,
    const std::shared_ptr<FlutterWindowCallback> &callback
) : callback_(callback), id_(id) {
  // AirPing: detect the ping overlay window via a substring match on the
  // JSON args sent from Dart (OverlayLauncher.showPing() always includes
  // "type":"ping_overlay"). Deliberately a substring check instead of a
  // full JSON parse, to avoid adding a JSON dependency to this file.
  bool is_ping_overlay = args.find("\"type\":\"ping_overlay\"") != std::string::npos;

  window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_default_size(GTK_WINDOW(window_), 1280, 720);
  gtk_window_set_title(GTK_WINDOW(window_), "");
  gtk_window_set_position(GTK_WINDOW(window_), GTK_WIN_POS_CENTER);

  if (is_ping_overlay) {
    // No title bar / borders at all.
    gtk_window_set_decorated(GTK_WINDOW(window_), FALSE);
    // Stay above every other window, including other apps.
    gtk_window_set_keep_above(GTK_WINDOW(window_), TRUE);

    // Must request an alpha-capable (RGBA) visual BEFORE the widget is
    // realized/shown, otherwise a transparent background can never
    // actually show through later — it just renders as opaque.
    GdkScreen *screen = gtk_widget_get_screen(window_);
    GdkVisual *visual = gdk_screen_get_rgba_visual(screen);
    if (visual != NULL && gdk_screen_is_composited(screen)) {
      gtk_widget_set_visual(window_, visual);
    }

    g_signal_connect(window_, "realize",
                      G_CALLBACK(airping_on_overlay_realize), NULL);
    g_signal_connect(window_, "configurate-event",
                      G_CALLBACK(airping_on_overlay_configure), NULL);
  }

  gtk_widget_show(GTK_WIDGET(window_));
  g_signal_connect(G_OBJECT(window_), "delete-event", G_CALLBACK(on_close_clicked), NULL);
  g_signal_connect(window_, "destroy", G_CALLBACK(+[](GtkWidget *, gpointer arg) {
    auto *self = static_cast<FlutterWindow *>(arg);
    if (auto callback = self->callback_.lock()) {
      callback->OnWindowClose(self->id_);
      callback->OnWindowDestroy(self->id_);
    }
  }), this);
  g_autoptr(FlDartProject)
      project = fl_dart_project_new();
  const char *entrypoint_args[] = {"multi_window", g_strdup_printf("%ld", id_), args.c_str(), nullptr};
  fl_dart_project_set_dart_entrypoint_arguments(project, const_cast<char **>(entrypoint_args));
  auto fl_view = fl_view_new(project);

  if (is_ping_overlay) {
    // fully transparent (alpha channel = 0) Flutter background, instead of the default opaque one.
    GdkRGBA background_color;
    gdk_rgba_parse(&background_color, "#00000000");
    fl_view_set_background_color(fl_view, &background_color);
  }

  gtk_widget_show(GTK_WIDGET(fl_view));
  gtk_container_add(GTK_CONTAINER(window_), GTK_WIDGET(fl_view));
  if (_g_window_created_callback) {
    _g_window_created_callback(FL_PLUGIN_REGISTRY(fl_view));
  }
  g_autoptr(FlPluginRegistrar)
      desktop_multi_window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(FL_PLUGIN_REGISTRY(fl_view), "DesktopMultiWindowPlugin");
  desktop_multi_window_plugin_register_with_registrar_internal(desktop_multi_window_registrar);

  window_channel_ = WindowChannel::RegisterWithRegistrar(desktop_multi_window_registrar, id_);

  gtk_widget_grab_focus(GTK_WIDGET(fl_view));
  gtk_widget_hide(GTK_WIDGET(window_));
}

WindowChannel *FlutterWindow::GetWindowChannel() {
  return window_channel_.get();
}

FlutterWindow::~FlutterWindow() = default;

void desktop_multi_window_plugin_set_window_created_callback(WindowCreatedCallback callback) {
  _g_window_created_callback = callback;
}