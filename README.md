
# **BRYCEN Chatbot**
Flutter Chatbot with OpenAI (GPT3.5 & Whisper) made by [@STkong](https://github.com/congltk1234/)

|Description|Click below to download APK|
|--|--|
|This Flutter application integrates OpenAI's ChatGPT 3.5 LLM model to enable interactive conversations<br> and provides a feature to summarize uploaded documents and audio files. The app serves as a powerful tool for engaging conversations and efficient content summarization.<br>The app was developed during my internship at [BRYCEN Vietnam company](https://brycen.com.vn/en/)|[![logoApp](https://github-production-user-asset-6210df.s3.amazonaws.com/73183412/260543335-34b0c872-831a-417b-8341-d7c03efe1289.jpg)](https://github.com/congltk1234/BrycenChatbot/raw/main/output/release/app-release.apk)|



## Table of Contents

- [Features](#features-and-demo)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Error](#error)
- [Update](#update)
- [Future Work](#future-work)
- [License](#license)



## Features and Demo

1. **Conversations with ChatGPT 3.5 LLM:**
   Engage in dynamic and natural conversations with OpenAI's ChatGPT 3.5 LLM model. Enjoy real-time responses and experience the capabilities of advanced language processing.

2. **Summarize File Upload:**
   Easily upload documents and audio files to generate concise summaries. The app utilizes cutting-edge summarization techniques to extract the most important information from your content.

<h4><details>
<summary>Home Screen</summary>

|Login & Validation|Update & Logout|Drawer|Internet Status|
|--|--|--|--|
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Login.gif"  height="300"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif"  height="300"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/drawer.gif"  height="300"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/InternetConnection.gif"  height="300"/>|

</details></h4>


<h4><details>
<summary>Chat Screen</summary>

|Memory Chatbot|Speech2Text|Copy & Audio|
|--|--|--|
|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/ChatMemory.jpg"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/Change_Logout.gif" height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/copy.gif" height="400"/>|



</details></h4>


<h4><details>
<summary>Summarize Screen</summary>

|Summarize|View File|Question Suggest|
|--|--|--|
|Support Files<br>Document:`txt, pdf, docx`<br>Audio:`mp3, wav, mpga, mpeg`|Can view <br>`pdf, docx, txt`|Generate Related questions<br> about the document |
<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/summarizeTxt.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/viewFile.gif"  height="400"/>|<img src="https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/QuestionChip.gif"  height="400"/>|

</details></h4>


## Prerequisites

- **INSTALLED:** [npm](https://nodejs.org/en), [Flutter](https://docs.flutter.dev/get-started/install), [Git](https://git-scm.com/downloads), [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
- **OPENAI API KEY:**  You must have an OpenAI API key in order to use this application. 

<details>
<summary> API Key Setup </summary>
<br>
   To use the ChatGPT 3.5 LLM model, you need to set up an API key from OpenAI:

   1. Go to the [OpenAI website](https://openai.com) and sign in or create an account.
   2. Generate an API key for ChatGPT 3.5 LLM.
   3. Copy the API key and input to the app.

</details>


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
![FirebaseStorage](https://raw.githubusercontent.com/congltk1234/BrycenChatbot/main/docs/assets/gif/flutterfire_configure.gif)



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

## Error

<details>
   
<summary>Command not found: flutterfire</summary>

https://bobbyhadz.com/blog/flutterfire-is-not-recognized-as-internal-or-external-command

   - In your terminal and run this code to open <b>Advanced system settings</b>
   
   ```
      SystemPropertiesAdvanced
   ```
   - Click Environment Variables. In the section System Variables find the PATH environment variable and select it. Click Edit. If the PATH environment variable does not exist, click New.
   
   - In the Edit System Variable (or New System Variable) window, specify the value of the PATH environment variable
   ```
   C:\Users\YourUsername\AppData\Local\Pub\Cache\bin
   ```
   - Click OK. Close all remaining windows by clicking OK.
   - You might have to restart your computer to active path

</details>

## Update
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
|15.08.2023|Add logout<br>Update README|Refine the app, removing any redundant lines of code<br>Finish README|

##### Future Work

- [ ] Add provider, update app structure, optimize and clean code.
- [ ] Audio Handler: Try package [just_audio](https://pub.dev/packages/just_audio) or [audioplayers](https://pub.dev/packages/audioplayers) for split long audio, play audio in file view
- [ ] Markdown display: Try [flutter_markdown](https://pub.dev/packages/flutter_markdown) in chat screen
- [ ] Migrate database: from FireStore(firebase) to [SQLite](https://pub.dev/packages/sqflite)
- [ ] User Config model: Let user decide the model they want
- [ ] Adjust Speech recognition: Show [glowing animation](https://pub.dev/packages/avatar_glow) of the sentence listening
- [ ] Manage usage: Use [tiktoken](https://pub.dev/packages/tiktoken/) to calculate Token used
- [ ] [Reduce tokens prompt](https://aiprimer.substack.com/p/gpt-prompt-compression-save-tokens): Preprocessing prompt and Parser response with [text_analysis](https://pub.dev/packages/text_analysis)


</details>


## License

This project is licensed under the [MIT License](LICENSE).

