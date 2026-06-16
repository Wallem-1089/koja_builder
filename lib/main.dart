import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:image_picker/image_picker.dart';

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
  factory Subject.fromJson(
      Map<String, dynamic> json,
      ) {

        return Subject(
          name: json['subjectName'],

          questions:
              (json['questions'] as List)
                  .map(
                    (q) =>
                        Question.fromJson(q),
                  )
                  .toList(),
        );
      }
}

class Question {
  final String question;

  final Map<String, String> options;

  final String answer;

  final String explanation;

  final String? imagePath;

  Question({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "image": imagePath,
      "options": options,
      "answer": answer,
      "explanation": explanation,
    };
  }

  factory Question.fromJson(
    Map<String, dynamic> json,
  ) {
    return Question(
      question: json["question"],
      imagePath: json["image"],
      options:
          Map<String, String>.from(
        json["options"],
      ),
      answer: json["answer"],
      explanation:
          json["explanation"] ?? "",
    );
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

Future<void> importSubject() async {

  try {

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) {
      return;
    }

    final file =
        File(result.files.single.path!);

    final jsonString =
        await file.readAsString();

    final jsonData =
        jsonDecode(jsonString);

    final subject =
    Subject.fromJson(jsonData);

    final alreadyExists =
        subjects.any(
          (s) =>
              s.name.toLowerCase() ==
              subject.name.toLowerCase(),
        );

    if (alreadyExists) {

    final shouldReplace =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Subject Exists',
          ),
          content: Text(
            '${subject.name} already exists.\n\nReplace it?',
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Replace',
              ),
            ),

          ],
        );
      },
    );

    if (shouldReplace == true) {

      final index =
          subjects.indexWhere(
        (s) =>
            s.name.toLowerCase() ==
            subject.name.toLowerCase(),
      );

      setState(() {
        subjects[index] = subject;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${subject.name} replaced',
          ),
        ),
      );
    }

    return;
  }

    setState(() {
      subjects.add(subject);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${subject.name} imported successfully',
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Import failed: $e',
        ),
      ),
    );
  }
}
Future<void> importFolder() async {

  try {

    String? selectedDirectory =
        await FilePicker.platform
            .getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final folder =
        Directory(selectedDirectory);

    final jsonFiles =
        folder
            .listSync()
            .where(
              (file) =>
                  file is File &&
                  file.path.endsWith('.json'),
            )
            .cast<File>()
            .toList();

    int importedCount = 0;

    for (final file in jsonFiles) {

      try {

        final jsonString =
            await file.readAsString();

        final jsonData =
            jsonDecode(jsonString);

        final subject =
            Subject.fromJson(jsonData);

        final alreadyExists =
            subjects.any(
          (s) =>
              s.name.toLowerCase() ==
              subject.name.toLowerCase(),
        );

        if (!alreadyExists) {

          subjects.add(subject);

          importedCount++;
        }

      } catch (_) {

        // Skip invalid JSON files

      }
    }

    setState(() {});

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$importedCount subjects imported',
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Import failed: $e',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koja Question Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: importSubject,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: importFolder,
          ),
        ],
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

      setState(() {widget.subject.questions.add(question);

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

    final documentsDir =
        await getApplicationDocumentsDirectory();

    final rootFolder = Directory(
      '${documentsDir.path}/Koja Question Banks/questions',
    );

    if (!await rootFolder.exists()) {
      await rootFolder.create(
        recursive: true,
      );
    }

    /*final subjectFolder = Directory(
      '${rootFolder.path}/${widget.subject.name}',
    );

    await subjectFolder.create(
      recursive: true,
    );*/

    final imagesFolder = Directory(
      '${documentsDir.path}/Koja Question Banks/images',
    );

    await imagesFolder.create(
      recursive: true,
    );

    List<Map<String, dynamic>>
        exportQuestions = [];

    for (
      int index = 0;
      index < widget.subject.questions.length;
      index++
    ) {

      final question =
          widget.subject.questions[index];

      String? imagePath;

      if (question.imagePath != null &&
          question.imagePath!.isNotEmpty) {

        final extension =
            question.imagePath!
                .split('.')
                .last;

        await File(
          question.imagePath!,
        ).copy(
          '${imagesFolder.path}/q${index + 1}.$extension',
        );

        imagePath =
            'images/q${index + 1}.$extension';
      }

      exportQuestions.add({

        "question":
            question.question,

        "image":
            imagePath,

        "options":
            question.options,

        "answer":
            question.answer,

        "explanation":
            question.explanation,

      });
    }

    final jsonData = {

      "subjectName":
          widget.subject.name,

      "questions":
          exportQuestions,

    };

    final fileName =
        widget.subject.name
            .toLowerCase()
            .replaceAll(' ', '_');

    final jsonFile = File(
      '${documentsDir.path}/Koja Question Banks/questions/$fileName.json',
    );

    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ')
          .convert(jsonData),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Exported to ${rootFolder.path}',
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
    IconButton(
      icon: const Icon(Icons.visibility),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectPreviewPage(
              subject: widget.subject,
            ),
          ),
        );
      },
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

  // NEW
  File? selectedImage;

  // NEW
  Future<void> pickImage() async {

    final picker = ImagePicker();

    final file =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    setState(() {
      selectedImage =
          File(file.path);
    });
  }

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
  if (widget.question?.imagePath != null) {

  selectedImage = File(
    widget.question!.imagePath!,
  );
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

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text(
                "Add Image",
              ),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 12),

              Image.file(
                selectedImage!,
                height: 200,
              ),
            ],

            const SizedBox(height: 20),

            FilledButton(
              onPressed: () {

                final question = Question(
                    question: questionController.text,
                    imagePath: selectedImage?.path,
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

class SubjectPreviewPage extends StatefulWidget {

  final Subject subject;

  const SubjectPreviewPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectPreviewPage> createState() =>
      _SubjectPreviewPageState();
}

class _SubjectPreviewPageState
    extends State<SubjectPreviewPage> {

  int currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {

    if (widget.subject.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.subject.name),
        ),
        body: const Center(
          child: Text(
            "No Questions Available",
          ),
        ),
      );
    }

    final question =
        widget.subject.questions[
            currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject.name} Preview',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

      child: Column(
          children: [

            Expanded(

        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Question ${currentQuestionIndex + 1}'
              ' of ${widget.subject.questions.length}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 24),

            if (question.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: InteractiveViewer(
                  child: Image.file(
                    File(question.imagePath!),
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            LatexText(
              text: question.question,
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                title: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('A. '),
                    Expanded(
                      child: LatexText(
                        text:
                            question.options["A"] ?? "",
                      ),
                    ),
                  ],
                )
              ),
            ),

            Card(
              child: ListTile(
                title: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('B. '),
                    Expanded(
                      child: LatexText(
                        text:
                            question.options["B"] ?? "",
                      ),
                    ),
                  ],
                )
              ),
            ),

            Card(
              child: ListTile(
                title: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('C. '),
                    Expanded(
                      child: LatexText(
                        text:
                            question.options["C"] ?? "",
                      ),
                    ),
                  ],
                )
              ),
            ),

            Card(
              child: ListTile(
                title: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('D. '),
                    Expanded(
                      child: LatexText(
                        text:
                            question.options["D"] ?? "",
                      ),
                    ),
                  ],
                )
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Correct Answer: '
                      '${question.answer}',
                    ),

                    const SizedBox(height: 8),

                    LatexText(
                      text: question.explanation,
                      fontSize: 16,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: FilledButton(
                    onPressed:
                        currentQuestionIndex > 0
                            ? () {
                                setState(() {
                                  currentQuestionIndex--;
                                });
                              }
                            : null,
                    child: const Text(
                      "Previous",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed:
                        currentQuestionIndex <
                                widget.subject
                                        .questions
                                        .length -
                                    1
                            ? () {
                                setState(() {
                                  currentQuestionIndex++;
                                });
                              }
                            : null,
                    child: const Text(
                      "Next",
                    ),
                  ),
                ),

              ],
            ),

          ],
        ),
        ),
      ),
          ],
      ),
      ),
    );
  }
}

class LatexText extends StatelessWidget {
  final String text;
  final double fontSize;

  const LatexText({
    super.key,
    required this.text,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
final regex = RegExp(r'\$(.*?)\$');

    final underlineRegex =
        RegExp(r'<u>(.*?)<\/u>');

    if (!regex.hasMatch(text) &&
        !underlineRegex.hasMatch(text)) {

      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
        ),
      );
    }

    List<InlineSpan> spans = [];

    int lastIndex = 0;

    final combinedRegex =
        RegExp(r'\$(.*?)\$|<u>(.*?)<\/u>');

    for (final match
        in combinedRegex.allMatches(text)) {

      if (match.start > lastIndex) {

        spans.add(
          TextSpan(
            text: text.substring(
              lastIndex,
              match.start,
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: fontSize,
            ),
          ),
        );
      }

      if (match.group(1) != null) {

        spans.add(
          WidgetSpan(
            alignment:
                PlaceholderAlignment.middle,

            child: Math.tex(
              match.group(1)!,
              textStyle: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        );
      }

      else if (match.group(2) != null) {

        spans.add(
          TextSpan(
            text: match.group(2)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: fontSize,
              decoration:
                  TextDecoration.underline,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {

      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: fontSize,
          ),
        ),
      );
    }

    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(
        children: spans,
      ),
    );
  }
}