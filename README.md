
# Project Title

A brief description of what this project does and who it's for


## Features

- Light/dark mode toggle
- Live previews
- Fullscreen mode
- Cross platform

| Home|Chat|Summarize|
|--|--|--|
| ![Home UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) | ![Chat UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) | ![Summarize UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) |


| Home|Chat|Summarize|
|--|--|--|
| ![Home UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) | ![Chat UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) | ![Summarize UI](https://raw.githubusercontent.com/22T1020362/Chatbot-Summary-ntq/master/screenshots/screenshot1.png) |


## Prerequisites

**Installed:** [npm](https://nodejs.org/en), [Flutter](https://docs.flutter.dev/get-started/install), 



## Installation
### 1. Settup Firebase for Flutter app
#### Init Firebase
- Create new project:

![Init Firebase project](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/1_initProject.gif)

- Set Up FireStore Database for store app data:

![FirestoreDatabase](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/2_FirestoreDatabase.gif)

- Set Up Firebase Storage for store files:

![FirebaseStorage](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/3_firebaseStorage.gif)

#### Login with Firebase CLI
Install [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli) via npm by running the following command:
```bash
  npm install -g firebase-tools
```

Then login your google account

```bash
  firebase login
```

![FirebaseStorage](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/4_firebaseLogin.gif)

#### Install FlutterFire CLI 
Running the following command from any directory:
```bash
  dart pub global activate flutterfire_cli
```

### 2. Clone Flutter project:
- Open Terminal and point to folder which will contain your project:
```bash
  git clone https://github.com/congltk1234/BrycenChatbot.git
```
- Change working directory:
```bash
  cd BrycenChatbot
```
- Adding package dependency to project:
```bash
  flutter pub get
```
- Connect Firebase to project:
```bash
  flutterfire configure
```
![firebaseLogin](https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif)


<details>
<summary>Build file APK</summary>
<br>
This is how you dropdown.


```bash
  flutter build apk
```

</details>

<details>
<summary>Install APK on a device</summary>
<br>
Follow these steps to install the APK on a connected Android device. From the command line connect your Android device to your computer with a USB cable.

```bash
  flutter install
```
</details>

## Authors

- [@octokatherine](https://www.github.com/octokatherine)

## Badges

Add badges from somewhere like: [shields.io](https://shields.io/)

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

