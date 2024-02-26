# smart_swipe_local

Smart Swipe Full Local Implementation, in Flutter

## Running the Software

First download this entire repository to your computer.

The built linux binary is in
```
./build/linux/x64/release/bundle/smart_swipe_local 
```

## Modifying the Software

### Development Setup

To edit and compile the binary, follow the flutter installation tutorial for Linux at https://docs.flutter.dev/get-started/install/linux

Then get the Flutter extension on Visual Studio Code, and open the project folder.

Then, install all the dependencies by running

```
flutter pub get
```

Then, you can run the app on your device by running

```
    flutter run
```

### Building Binary

Add Desktop support to the Flutter App by Running

```
flutter create --platforms=windows,macos,linux .
```

Then clear previous build artifacts by running
```
flutter clean
```

To build the binary, run

```
flutter build linux
```


After building, the built linux binary is in
```
./build/linux/x64/release/bundle/smart_swipe_local 
```


