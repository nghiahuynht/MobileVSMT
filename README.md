![screenshot](assets/images/Google-flutter-logo.svg.png)

# trash_pay

A **Flutter Boilerplate** project to kickstart your Flutter app development with best practices, pre-configured dependencies, and a scalable architecture.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [Built With](#built-with)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Boilerplate Features

- State Management: Bloc
- Networking: Dio
- Localization:
- Theming (Light/Dark mode support)

## Code structure

Here is the core folder structure which flutter provides.

```
flutter-app/
|- android
|- ios
|- web
|- assets
|- lib
|- test
```

Here is the folder structure we have been using in this project

```
lib/
|- constants/
|- domain/
|- presentation/
    |- home/
        |- widgets/
        |- logics
        |- home_screen.dart
    |- login/
    |- widgets/
        |- button/
        |- image/
        |- view/
    my_app.dart
|- router/
|- services/
|- utils/
|- locator.dart
|- main.dart
```

## Prerequisites

Before setting up the project, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.29.0
- Dart 3.7.0
- VS Code or Android Studio with Flutter & Dart plugins
- Android Emulator / iOS Simulator

Run the following command to check dependencies:

```sh
flutter doctor
```

## Getting Started

1. Download or clone this repo by using the link below:

   ```
   https://github.com/TruongThaiNgan/trash_pay.git
   ```

2. Go to project root and install Dependencies:

   ```
   flutter pub get
   ```

3. Generate localizations, assets

   ```
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run staging project

   ```
   flutter run --flavor staging --target lib/main_staging.dart
   ```

5. To run production project

   ```
   flutter run --flavor production --target lib/main_production.dart
   ```

## Conclusion

We encourage you to explore, customize, and contribute to enhance this project further. If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

Happy coding! 🚀
