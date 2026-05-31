import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const KojaQuestionBuilder());
}

class KojaQuestionBuilder extends StatelessWidget {
  const KojaQuestionBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koja Question Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<Question> questions = [];

  void addQuestion(Question question) {
    setState(() {
      questions.add(question);
    });
  }

  void exportQuestions() {

  final jsonString =
      const JsonEncoder.withIndent('  ')
          .convert(
    questions
        .map((q) => q.toJson())
        .toList(),
  );

  print(jsonString);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koja Question Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportQuestions,
          ),
        ],
      ),

      body: questions.isEmpty
          ? const Center(
              child: Text(
                'No Questions Added',
              ),
            )
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${questions[index].number}',
                    ),
                  ),
                  title: Text(
                    questions[index].question,
                  ),
                  subtitle: Text(
                    'Answer: ${questions[index].answer}',
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {

          final question =
              await Navigator.push<Question>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddQuestionPage(),
            ),
          );

          if (question != null) {
            addQuestion(question);
          }
        },
      ),
    );
  }
}

class Question {
  final int number;
  final String question;

  final Map<String, String> options;

  final String answer;

  final String explanation;

  Question({
    required this.number,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "question": question,
      "options": options,
      "answer": answer,
      "explanation": explanation,
    };
  }
}


class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() =>
      _AddQuestionPageState();
}

class _AddQuestionPageState
    extends State<AddQuestionPage> {

  final questionController =
      TextEditingController();

  final aController =
      TextEditingController();

  final bController =
      TextEditingController();

  final cController =
      TextEditingController();

  final dController =
      TextEditingController();

  final explanationController =
      TextEditingController();

  String answer = "A";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Add Question"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller:
                  questionController,
              decoration:
                  const InputDecoration(
                labelText: "Question",
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: aController,
              decoration:
                  const InputDecoration(
                labelText: "Option A",
              ),
            ),

            TextField(
              controller: bController,
              decoration:
                  const InputDecoration(
                labelText: "Option B",
              ),
            ),

            TextField(
              controller: cController,
              decoration:
                  const InputDecoration(
                labelText: "Option C",
              ),
            ),

            TextField(
              controller: dController,
              decoration:
                  const InputDecoration(
                labelText: "Option D",
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: answer,
              items: const [
                DropdownMenuItem(
                  value: "A",
                  child: Text("A"),
                ),
                DropdownMenuItem(
                  value: "B",
                  child: Text("B"),
                ),
                DropdownMenuItem(
                  value: "C",
                  child: Text("C"),
                ),
                DropdownMenuItem(
                  value: "D",
                  child: Text("D"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  answer = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  explanationController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Explanation",
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            FilledButton(
              onPressed: () {

                final question =
                    Question(
                  number: 1,
                  question:
                      questionController.text,
                  options: {
                    "A":
                        aController.text,
                    "B":
                        bController.text,
                    "C":
                        cController.text,
                    "D":
                        dController.text,
                  },
                  answer: answer,
                  explanation:
                      explanationController.text,
                );

                Navigator.pop(
                  context,
                  question,
                );
              },
              child:
                  const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
