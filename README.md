
# Project Title

A brief description of what this project does and who it's for


## Prerequisites

**Installed:** [npm](https://nodejs.org/en), [Flutter](https://docs.flutter.dev/get-started/install), 



## Installation
### 1. Settup Firebase for Flutter app
#### Init Firebase
- Create new project:
![Flutter](https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif)
- Set Up FireStore Database for store app data:
![Flutter](https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif)
- Set Up Firebase Storage for store files:
![Flutter](https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif)

#### Login with Firebase CLI
Install [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli) via npm by running the following command:
```bash
  npm install -g firebase-tools
```

Then login your google account
```bash
  firebase login
```
![firebaseLogin](https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif)

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


<details open>
<summary>Build file APK</summary>
<br>
This is how you dropdown.
<br><br>
<pre>
&lt;details&gt;
&lt;summary&gt;How do I dropdown?&lt;&#47;summary&gt;
&lt;br&gt;
This is how you dropdown.
&lt;&#47;details&gt;

```bash
  flutter build apk
```
</pre>
</details>

<details>
<summary>Install APK on a device</summary>
<br>
Follow these steps to install the APK on a connected Android device. From the command line connect your Android device to your computer with a USB cable.
<br><br>
<pre>
&lt;details&gt;
&lt;summary&gt;How do I dropdown?&lt;&#47;summary&gt;
&lt;br&gt;
This is how you dropdown.
&lt;&#47;details&gt;

```bash
  flutter install
```
</pre>
</details>
