// ignore_for_file: avoid_print

import 'package:langchain/langchain.dart';

void main() async {
  // final chatPrompt = ChatPromptTemplate(
  //   promptMessages: ,
  //   partialVariables: {'foo': 'UserName', 'bar': 'Lovely'},
  //   inputVariables: {"Hello {foo}, I'm {bar}. Thanks for the"},
  // );
  final llm_test = FakeListLLM(
    responses: ['Why did the AI go on a diet? Because it had too many bytes!'],
  );
  final prompt = PromptTemplate.fromTemplate('');

  final memory = ConversationBufferMemory(memoryKey: 'context');
  // await memory.saveContext(
  //     inputValues: {'User': 'Hello'}, outputValues: {'bot': 'Res'});
  // await memory
  //     .saveContext(inputValues: {'User': 'bar'}, outputValues: {'bot': 'foo'});

  final chain = LLMChain(
    llm: llm_test,
    prompt: prompt,
    memory: memory,
  );

  // final query = 'meomeomeo';
  // final res = await chain.run(query);
  // print(res);
  // print(chain.prompt.format({'adjective': query, 'verb': 'dick'}));
  // print(chain.prompt.format({'userInput': query}));
  // final chatPrompt = ChatPromptTemplate.fromTemplate(
  //   "Hello {foo}, I'm {bar}. Thanks for the {context}",
  //   partialVariables: {'foo': 'foo', 'bar': 'bar'},
  // );
  // final prompt = chatPrompt.format({'context': 'Party'});

  // final promptTemplate = PromptTemplate.fromTemplate(
  //   'tell me a joke about {subject}',
  // );
  // // final prompt = promptTemplate.format({'subject': 'AI'});
  // final result = await llm_test(prompt);

  // final chain_conv = ConversationChain(
  //   llm: llm_test,
  //   memory: memory,
  // );
  // var res = await chain.run('Hello world!');

  final res =
      await chain.run({'topic': 'sport', 'userInput': 'aaaaaaaaaaaaaaaaaaaa!'});
  print(res);

  final a = await chain.memory!.loadMemoryVariables();

  print(a);
  // Why did the AI go on a diet? Because it had too many bytes!
}
