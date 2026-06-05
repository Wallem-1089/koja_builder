import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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
class Subject {
  final String name;
  final List<Question> questions;

  Subject({
    required this.name,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      "subjectName": name,
      "questions": questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  //final int? number;
  final String question;

  final Map<String, String> options;

  final String answer;

  final String explanation;

  Question({
    //this.number,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      // "number": number,
      "question": question,
      "options": options,
      "answer": answer,
      "explanation": explanation,
    };
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //final List<Question> questions = [];
  final List<Subject> subjects = [];
  void addSubject() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Add Subject"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Subject Name",
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          FilledButton(
            onPressed: () {

              if (controller.text.trim().isEmpty) {
                return;
              }

              setState(() {
                subjects.add(
                  Subject(
                    name: controller.text.trim(),
                    questions: [],
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}
void deleteSubject(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Subject'),

        content: Text(
          'Delete "${subjects[index].name}" and all its questions?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () {
              setState(() {
                subjects.removeAt(index);
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

 /* void addQuestion(Question question) {
    setState(() {
      questions.add(question);
    });
  }*/

  /*void exportQuestions() {

  final jsonString =
      const JsonEncoder.withIndent('  ')
          .convert(
    questions
        .map((q) => q.toJson())
        .toList(),
  );

  print(jsonString);
}*/
/*void exportSubject(Subject subject) {

  final jsonString =
      const JsonEncoder.withIndent('  ')
          .convert(
    subject.toJson(),
  );

  print(jsonString);
}*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koja Question Builder'),
        /*actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => exportSubject, //exportQuestions,
          ),
        ],*/
      ),

      body: subjects.isEmpty
    ? const Center(
        child: Text(
          'No Subjects Added',
        ),
      )
    : ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {

          final subject = subjects[index];

          return ListTile(
            leading: const Icon(Icons.book),

            title: Text(subject.name),

            subtitle: Text(
              '${subject.questions.length} Questions',
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    deleteSubject(index);
                  },
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectPage(
                    subject: subject,
                  ),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: addSubject,
      child: const Icon(Icons.add),
    ),
      /*floatingActionButton: FloatingActionButton(
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
      ),*/
    );
  }
}
class SubjectPage extends StatefulWidget {
  final Subject subject;

  const SubjectPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectPage> createState() =>
      _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {

  Future<void> addQuestion() async {

    final question =
        await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddQuestionPage(),
      ),
    );

    if (question != null) {

      setState(() {
        widget.subject.questions.add(question);

      });
    }
  }
  Future<void> editQuestion(int index) async {

  final updatedQuestion =
      await Navigator.push<Question>(
    context,
    MaterialPageRoute(
      builder: (_) => AddQuestionPage(
        question:
            widget.subject.questions[index],
      ),
    ),
  );

  if (updatedQuestion != null) {

    setState(() {
      widget.subject.questions[index] =
          updatedQuestion;
    });

  }
}
  void deleteQuestion(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Question'),
        content: const Text(
          'Are you sure you want to delete this question?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                widget.subject.questions.removeAt(index);

                // Renumber remaining questions
                /*for (int i = 0;
                    i < widget.subject.questions.length;
                    i++) {

                  final old =
                      widget.subject.questions[i];

                  widget.subject.questions[i] =
                      Question(
                    //number: i + 1,
                    question: old.question,
                    options: old.options,
                    answer: old.answer,
                    explanation: old.explanation,
                  );
                }*/
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
Future<void> exportSubjectToFile() async {
  try {

    final jsonString =
        const JsonEncoder.withIndent('  ')
            .convert(widget.subject.toJson());

    final documentsDir =
        await getApplicationDocumentsDirectory();

    final kojaFolder = Directory(
      '${documentsDir.path}/Koja Question Banks',
    );

    if (!await kojaFolder.exists()) {
      await kojaFolder.create(
        recursive: true,
      );
    }

    final fileName =
        widget.subject.name
            .toLowerCase()
            .replaceAll(' ', '_');

    final file = File(
      '${kojaFolder.path}/$fileName.json',
    );

    await file.writeAsString(
      jsonString,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Exported to ${file.path}',
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Export failed: $e',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
  appBar: AppBar(
  title: Text(
    widget.subject.name,
  ),

  actions: [
    IconButton(
      icon: const Icon(
        Icons.download,
      ),
      onPressed: exportSubjectToFile,
    ),
  ],
),

      body: widget.subject.questions.isEmpty
          ? const Center(
              child: Text(
                "No Questions Added",
              ),
            )
          : ListView.builder(
              itemCount:
                  widget.subject.questions.length,

              itemBuilder: (context, index) {

                final question =
                    widget.subject.questions[index];

                return ListTile(
  leading: CircleAvatar(
    child: Text(
      '${index + 1}',
    ),
  ),

  title: Text(
    question.question,
  ),

  subtitle: Text(
    "Answer: ${question.answer}",
  ),

  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          editQuestion(index);
        },
      ),

      IconButton(
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          deleteQuestion(index);
        },
      ),

    ],
  ),
);
              },
            ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: addQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddQuestionPage extends StatefulWidget {
  final Question? question;

  const AddQuestionPage({
    super.key,
    this.question,
  });

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
void initState() {
  super.initState();

  if (widget.question != null) {
    questionController.text =
        widget.question!.question;

    aController.text =
        widget.question!.options["A"] ?? "";

    bController.text =
        widget.question!.options["B"] ?? "";

    cController.text =
        widget.question!.options["C"] ?? "";

    dController.text =
        widget.question!.options["D"] ?? "";

    answer = widget.question!.answer;

    explanationController.text =
        widget.question!.explanation;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        widget.question == null
            ? "Add Question"
            : "Edit Question",
      ),
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

                final question = Question(
                    question: questionController.text,
                    options: {
                      "A": aController.text,
                      "B": bController.text,
                      "C": cController.text,
                      "D": dController.text,
                    },
                    answer: answer,
                    explanation: explanationController.text,
                  );

                Navigator.pop(
                  context,
                  question,
                );
              },
              child: Text(
                widget.question == null
                    ? "Save"
                    : "Update",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
