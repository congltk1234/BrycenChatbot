import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:collection/collection.dart';

class SummarizeScreen extends StatefulWidget {
  const SummarizeScreen({super.key});
  static const id = 'summarize_screen';

  @override
  State<StatefulWidget> createState() {
    return _SummarizeScreenstate();
  }
}

class _SummarizeScreenstate extends State<SummarizeScreen> {
  void _uploadedFile(String path) async {
    TextLoader loader = TextLoader(path);
    final documents = await loader.load();
    const textSplitter = CharacterTextSplitter(
      separator: '\n',
      chunkSize: 800,
      chunkOverlap: 0,
    );
    final texts = await textSplitter.splitDocuments(documents);
    // for (var i in texts) {
    //   await FirebaseFirestore.instance.collection("texts").add({
    //     "content": i.pageContent,
    //     // "embed": element.embedding,
    //     // 'metadata': element.metadata
    //   });
    // }
    final textsWithSources = texts
        .mapIndexed(
          (final i, final d) => d.copyWith(
            metadata: {
              ...d.metadata,
              'source': '$i-pl',
            },
          ),
        )
        .toList(growable: false);

    // for (var i in textsWithSources) {
    //   await FirebaseFirestore.instance.collection("textsWithSources").add({
    //     "content": i.pageContent,
    //     // "embed": element.embedding,
    //     // 'metadata': element.metadata
    //   });
    // }
    final embeddings = OpenAIEmbeddings(
        apiKey: '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');
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: texts,
      embeddings: embeddings,
    );
    // MemoryVectorStore
// embeddings
    for (var element in docSearch.memoryVectors) {
      print(element.embedding);
      await FirebaseFirestore.instance.collection("embedding").add({
        "content": element.content,
        "embed": element.embedding,
        'metadata': element.metadata
      });
    }

    final llm = ChatOpenAI(
      apiKey: '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',
      model: 'gpt-3.5-turbo-0613',
      temperature: 0,
    );
    final qaChain = OpenAIQAWithSourcesChain(llm: llm);
    final docPrompt = PromptTemplate.fromTemplate(
      'Please use the content from the txt file below to answer my question. Please answer in Vietnamese unless the question is asked in English.\ncontent: {page_content}\nSource: {source}',
    );
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );

    final retrievalQA = RetrievalQAChain(
      retriever: docSearch.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );

    /// Question
    final res = await retrievalQA('Whats the main topic?');
    FirebaseFirestore.instance.collection("chatSummarize").add({
      "text": res["result"].toString(),
      "createdAt": Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ConfigAppBar(title: 'Summarize Screen'),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(
                        200,
                        70,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.cloud_upload,
                    size: 30,
                  ),
                  label: const Text(
                    "Upload File",
                    style: TextStyle(fontSize: 25),
                  ),
                  onPressed: () async {
                    final result =
                        await FilePicker.platform.pickFiles(withData: true);

                    if (result == null) return;
                    PlatformFile file = result.files.first;
                    // FirebaseFirestore.instance.collection("memory").add(
                    //   {
                    //     "FilePath": file.path,
                    //   },
                    // );
                    final path = file.path;
                    _uploadedFile(path!);
                    // TextLoader loader = TextLoader(path.toString());
                    // // /print(loader.);
                    // final documents = await loader.load();
                    // Future.delayed(const Duration(seconds: 20), () {
                    //   print('delay for 20sec');
                    // });
                    // for (var i in documents) {
                    //   print(i.pageContent);
                    //   print('----------PAGE CONTENT ------------------');
                    // }
                    // const textSplitter = CharacterTextSplitter(
                    //   chunkSize: 800,
                    //   chunkOverlap: 0,
                    // );
                    // final texts = textSplitter.splitDocuments(documents);

                    // final textsWithSources = texts
                    //     .mapIndexed(
                    //       (final i, final d) => d.copyWith(
                    //         metadata: {
                    //           ...d.metadata,
                    //           'source': '$i-pl',
                    //         },
                    //       ),
                    //     )
                    //     .toList(growable: false);
                    // for (var i in texts) {
                    //   print(i.metadata);
                    //   print('+++++++++++++');
                    //   print(i.pageContent);
                    //   print('-----------------------');
                    // }
                    // print('END');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
