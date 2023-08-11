String chat_prompt(String username, String memory, String message) {
  final prompt =
      "Here's a conversation between user $username and AI: \n From given context \n $memory \n response this message: $message";
  return prompt;
}

const summarize_template = '''
Detect language, Give a short Topic (no more 10 words) and Write a concise summary of the following context:

"{context}"

then give 3 short related questions. the Response Use Detected language with following:

"TOPIC
<br>
SUMMARY

<br>
QUESTION 1

<br>
QUESTION 2

<br>
QUESTION 3"
 ''';
