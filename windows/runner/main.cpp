#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <mutex>
#include <thread>

#include <vector>
#include <string>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
  {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // desktop_multi_window launches this executable again for secondary
  // overlay windows. Those windows must NOT be blocked by the
  // single-instance check.
  bool is_secondary_window =
      !command_line_arguments.empty() &&
      command_line_arguments.front() == "multi_window";

  HANDLE single_instance_mutex = nullptr;
  HANDLE reopen_event = nullptr;

  if (!is_secondary_window)
  {
    single_instance_mutex = CreateMutexW(
        nullptr,
        TRUE,
        L"Global\\AirPing_SingleInstance");

    if (single_instance_mutex == nullptr)
    {
      ::CoUninitialize();
      return EXIT_FAILURE;
    }

    if (GetLastError() == ERROR_ALREADY_EXISTS)
    {
      reopen_event = OpenEventW(
          EVENT_MODIFY_STATE,
          FALSE,
          L"Global\\AirPing_Reopen");

      if (reopen_event != nullptr)
      {
        SetEvent(reopen_event);
        CloseHandle(reopen_event);
      }

      CloseHandle(single_instance_mutex);
      ::CoUninitialize();
      return EXIT_SUCCESS;
    }

    reopen_event = CreateEventW(
        nullptr,
        FALSE,
        FALSE,
        L"Global\\AirPing_Reopen");
  }

  flutter::DartProject project(L"data");

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"airping", origin, size))
  {
    if (reopen_event != nullptr)
    {
      CloseHandle(reopen_event);
    }

    if (single_instance_mutex != nullptr)
    {
      CloseHandle(single_instance_mutex);
    }

    ::CoUninitialize();
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(false);

  if (reopen_event != nullptr)
  {
    std::thread([&window, reopen_event]()
                {
      while (true)
      {
        DWORD result = WaitForSingleObject(reopen_event, INFINITE);

        if (result == WAIT_OBJECT_0)
        {
          window.Show();
          HWND hwnd = window.GetHandle();

          if (hwnd != nullptr)
          {
            ShowWindow(hwnd, SW_RESTORE);
            SetForegroundWindow(hwnd);
          }
        }
      } })
        .detach();
  }

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0))
  {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (single_instance_mutex != nullptr)
  {
    CloseHandle(single_instance_mutex);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
