# AirPing

#### Video Demo: https://youtu.be/gF2LcoCMLvU?si=VFDmyuJewMqxvbeT

#### Description:

AirPing is a Windows desktop application designed to gently interrupt people when they become too deeply focused on an activity, especially while studying or working at a computer.

The idea behind AirPing comes from a simple problem: being productive can sometimes turn into being *too* focused. When someone becomes deeply absorbed in studying or working, ordinary reminders and notifications can be easy to ignore. A notification may appear in the corner of the screen, but the user can continue looking at the application they are using without really noticing it. AirPing was created to solve this problem in a different way: instead of simply telling the user that it is time to do something, AirPing intentionally interrupts their visual focus.

The main feature of AirPing is its visual **Ping**. When a scheduled event or timer is triggered, AirPing can display an animated ping overlay that crosses the screen and appears above other applications. The purpose is not to aggressively interrupt the user, but to make them consciously notice the reminder and momentarily "wake up" from their current focus. AirPing currently provides two ping styles: a **Bird** and a **Paper Plane**.

AirPing has two main ways to create these interruptions: **Scheduler** and **Timer**.

The Scheduler allows users to create, edit, and delete scheduled events. An event can contain a title, agenda, start time, and end time. Users can also optionally enable a **pre-reminder**, which triggers a ping before the scheduled event begins. The pre-reminder is intentionally integrated into the Scheduler rather than being implemented as a separate reminder feature, because it belongs directly to the context of the scheduled event.

The Timer provides a countdown based on hours, minutes, and seconds. When the countdown reaches its end, AirPing can trigger a visual ping. This makes the Timer useful for activities where the user wants to work for a certain amount of time without continuously checking a clock.

### Project Structure

The main source code is contained in the `lib/` directory.

* `main.dart` is the entry point of the application and handles the initial application setup.
* `app.dart` contains the main application configuration.
* `core/` contains shared application configuration such as colors, routes, theme, and text styles.
* `features/home/` contains the main home screen and the page used to view scheduled items.
* `features/schedule/scheduler_page.dart` contains the Scheduler interface and logic for creating, editing, and deleting scheduled events, including their optional pre-reminders.
* `features/timer/timer_page.dart` contains the Timer interface and countdown functionality.
* `features/overlay/` contains the desktop overlay implementation. `overlay_launcher.dart` launches the overlay, while the Bird and Paper Plane overlay files define the two available ping experiences.
* `shared/models/` contains the data models used by the application, including scheduled events, timers, and calendar items.
* `shared/services/` contains services responsible for database access, scheduled-event operations, timer operations, and scheduling logic.

AirPing uses SQLite for persistent local storage. The application uses `sqflite_common_ffi` so that SQLite can be used in a desktop environment. Scheduled events and timers are stored locally so that application data does not exist only temporarily in memory.

### Design Choices

One of the most important design decisions in AirPing was making the reminder a **visual interruption rather than a conventional notification**. The problem AirPing is trying to solve is not simply that users forget their schedules. A user can know that they have a schedule and still fail to notice a normal notification because they are deeply focused on another task. Therefore, AirPing's reminder needs to reach the user's visual attention.

This is why the ping is implemented as a separate desktop overlay window rather than only as a widget inside the main application. The overlay allows the ping to appear above the application currently being used by the user. The animation then moves across the screen, making the reminder difficult to overlook while still keeping the interaction short and simple.

Another design decision was to use SQLite for local storage instead of keeping schedules and timers only in application state. Reminders need to remain available when the application is reopened, so persistent storage is necessary.

The project also separates its features, models, and services rather than placing the entire application in a single file. This makes the Scheduler, Timer, overlay system, database operations, and shared data models easier to maintain independently.

The project is primarily targeted at Windows desktop because the central concept of AirPing depends on desktop overlay behavior. Implementing this behavior required working with Flutter together with desktop window functionality and native Windows code. This was also one of the most technically challenging parts of the project, particularly when handling transparent windows and ensuring that the overlay could appear above other applications.

### Development and AI Usage

AirPing was developed as an individual CS50 Final Project.

During development, AI-based programming tools, including ChatGPT and other AI coding assistants, were used as development aids. They were used to discuss ideas, break down technical problems, investigate possible approaches, assist with debugging, and help write or improve portions of code.

The core concept of AirPing, the problem it addresses, its feature decisions, design direction, testing, debugging decisions, and final integration were developed and directed by the author. AI tools were used as assistants rather than as substitutes for the author's work. AI usage is also documented in the relevant source-code comments where applicable, in accordance with CS50's Final Project policy.

### Goal

AirPing is built around a simple idea:

**It does not just remind you. It interrupts your focus.**

The goal is to create a reminder experience that gives users a small moment to step out of their current digital world, notice what is happening around them, and move on to the activity they intended to do.

AirPing combines Flutter, SQLite, desktop window management, scheduling logic, timers, and animated overlays to turn that idea into a working desktop application.
