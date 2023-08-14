
# Project Title

A brief description of what this project does and who it's for

## Features

<h4><details open>
<summary>Home Screen</summary>

|Login & Validation|Update & Logout|
|--|--|
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Login.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="400"/>|


|Drawer|Internet Status|
|--|--|
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Login.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="400"/>|

</details></h4>


<h4><details open>
<summary>Chat Screen</summary>

|Memory Chatbot|Speech2Text|Copy & Audio|
|--|--|--|
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Login.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="400"/>|



</details></h4>


<h4><details open>
<summary>Summarize Screen</summary>

|Summarize|View File|Question Suggest|
|--|--|--|
|Support Files<br>Document:`txt, pdf, docx`<br>Audio:`mp3, wav, mpga, mpeg`|Can view <br>`pdf, docx, txt`|Generate Related questions<br> about the document |
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Login.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/QuestionChip.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/QuestionChip.gif"  height="400"/>|

</details></h4>


## Prerequisites

**Installed:** [npm](https://nodejs.org/en), [Flutter](https://docs.flutter.dev/get-started/install), 



## Installation
### 1. Settup Firebase for Flutter app
#### Init Firebase project

<details open>
<summary>Step1: Create new Firebase project</summary>

![Init Firebase project](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/1_initProject.gif)

</details>

<details>
<summary>Step2: Set Up FireStore Database</summary>

![FirestoreDatabase](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/2_FirestoreDatabase.gif)

</details>


<details>
<summary>Step3: Set Up Firebase Storage for store files</summary>

![FirebaseStorage](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/3_firebaseStorage.gif)

</details>


#### Login with Firebase CLI
Install [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli) via npm by running the following command:
```bash
  npm install -g firebase-tools
```

Then Log into Firebase using your Google account

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




### 3. Export the App

[Download App APK](https://github.com/congltk1234/BrycenChatbot/raw/main/output/release/app-release.apk)

<details>
<summary>Build file APK</summary>
<br>

```bash
  flutter build apk
```
or
```bash
  flutter build apk --no-pub --no-shrink
```
![](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/BuildAPK.jpg)

</details>

<details>
<summary>Install the APK on a connected Android device</summary>
<br>
Connect your Android device to your computer with a USB cable, then run the command line

```bash
  flutter install
```
</details>




## Time Tracking
<details open>
<summary>From 20.07.2023 to 14.08.2023</summary>

|Date|Task|Notes|
|--|--|--|
|20.07.2023| Init Project |Init simple HomeScreen, ChatScreen and Summarize.<br>Setup Themes and ColorSchemes.|
|21.07.2023|Route setup| Navigation between screens via route setting using `Navigator.pushNamed`.|
|22.07.2023| HomeScreen UI|Init FormWidget for input Username OpenAI key.|
|23.07.2023|Store User input values|Implement packages SharePreferences to store locally on device.|
|24.07.2023|UserForm|Username and API key validation (sending test request).|
|25.07.2023|UserForm Submit |Submit for store value to SharePreferences and switch to welcome widget.|
|26.07.2023| ChatScreen UI| Update ChatScreen UI: ListView chatMessages and ChatInput.|
|27.07.2023| Voice feature| Implement speech_to_text packages in ChatScreen, Switch between sendVoice function and sendText function.|
|28.07.2023| Firebase Connection| Set up Firebase project and implemented messages upload and get with FireStore Database.|
|29.07.2023| OpenAPI request| Chat response and test with these packages: dart_openai, langchain, langchain_openai.<br> Implement MemoryBuffer.|
|30.07.2023<br>31.07.2023| Update ChatScreen UI| Display: TimeStamp, tokenUsed.<br>Add more features: Copy , Text2Speech.<br>Animation: AutoScrolltoEnd.<br>TyperAnimatedText.|
|01.08.2023| Fix Chat Stream error|Change DataModel, add SwitchCase for StreamBuild, update condition.|
|02.08.2023|Summarize feature|Summarize UI: Upload file button, read file txt.<br>Test response with embedding, retriveQA and StuffSummarize.|
|03.08.2023| Update Summarize feature| Store and Retrive sumamrize content, file’s embedded vector with FireStore Database.|
|04.08.2023|Dynamic Drawer|Retrive and display ChatTitle on Drawer with List StreamBuilder|
|05.08.2023| ChatDrawer<br>SummarizeDrawer| Control Drawer with button<br>Update Drawer UI<br>SurfixIcon for hide/show password|
|06.08.2023|App Provider| Passing data between Screens with flutter_riverpod, notifiListener and consumer|
|07.08.2023|Prompt Template| Prompt and use Regex to extract information from response: Detect language, auto genarate chatTitle (chat topic) for Chat and summarize|
|08.08.2023| ChatItem Navigation| Linked MenuChat Drawler with chat button.<br>Open and load chat history by click on ChatTitle in drawer.|
|09.08.2023|NewChat button| Add new converstion function<br>Generate topic for chat title, update menu chat UI|
|10.08.2023|Delete ChatItem| Wrapped ChatTile with Dismissible<br>Delete confirmation with AlertDialog|
|11.08.2023| Suggest Question| Display interactable Suggest Question chips and update Chat UI.|
|12.08.2023| File handler<br>InternetConnection Status| SwitchCase for handle file picked<br>Add more funtion: PDF2text, Docx2text<br>Add feature: View uploaded file on SummarizeScreen|
|13.08.2023|Audio handler| Audio handle for `mp3, wav, mpga, mpeg`.<br>Add funtion: Speech2text using OpenAPI (whisper model).|
|14.08.2023| Config App Name&Icon<br>README file|Delete unnecessary code<br>Testing, build APK<br>Write document…|

</details>



## Authors

- [@Kongg](https://www.github.com/congltk1234)

## Badges

Add badges from somewhere like: [shields.io](https://shields.io/)

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

