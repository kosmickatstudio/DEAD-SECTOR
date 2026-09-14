# Android build

## Local Godot editor

Open the project in Godot 4.7.x and select the Android export preset.

For desktop Godot, configure the Java SDK and Android SDK paths in Editor Settings. Godot's current documentation recommends OpenJDK 17 for stable compatibility. The Android SDK must provide the required platform tools/build tools packages.

For an installable development APK, export with debugging enabled. For a store release, create and protect a non-debug keystore, configure it through Godot's Android export settings, and keep credentials outside version control.

## CI

The repository includes a headless Godot validation workflow. A later release workflow can reuse the Android preset once signing credentials are supplied through GitHub Actions secrets.

Do not commit a keystore, password, or export credential file to the repository.
