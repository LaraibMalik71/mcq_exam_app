import 'package:flutter/material.dart';
import '../main.dart';

class QuizScreen extends StatefulWidget {
  final String name;
  final String email;

  const QuizScreen({super.key, required this.name, required this.email});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final DateTime _startTime;

  final List<Question> _questions = [
    Question(
      questionText: 'What is the capital of France?',
      options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
      type: QuestionType.single,
      correctIndexes: [2],
    ),
    Question(
      questionText: 'Which of these are programming languages?',
      options: ['Python', 'HTML', 'Dart', 'CSS'],
      type: QuestionType.multiple,
      correctIndexes: [0, 2],
    ),
    Question(
      questionText: 'What is 5 + 7?',
      options: ['10', '11', '12', '13'],
      type: QuestionType.single,
      correctIndexes: [2],
    ),
    Question(
      questionText: 'Which of these are prime numbers?',
      options: ['2', '4', '7', '9'],
      type: QuestionType.multiple,
      correctIndexes: [0, 2],
    ),
    Question(
      questionText: 'Which company developed Flutter?',
      options: ['Apple', 'Google', 'Microsoft', 'Amazon'],
      type: QuestionType.single,
      correctIndexes: [1],
    ),
    Question(
      questionText: 'Which of these are fruits?',
      options: ['Carrot', 'Apple', 'Banana', 'Potato'],
      type: QuestionType.multiple,
      correctIndexes: [1, 2],
    ),
    Question(
      questionText: 'What is the largest planet in our solar system?',
      options: ['Earth', 'Jupiter', 'Saturn', 'Mars'],
      type: QuestionType.single,
      correctIndexes: [1],
    ),
    Question(
      questionText: 'Which of these are web browsers?',
      options: ['Chrome', 'Windows', 'Firefox', 'Photoshop'],
      type: QuestionType.multiple,
      correctIndexes: [0, 2],
    ),
  ];

  late List<Set<int>> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _selectedAnswers = List.generate(_questions.length, (_) => <int>{});
  }

  Future<void> _submitExam() async {
    final endTime = DateTime.now();
    int marks = 0;
    for (int i = 0; i < _questions.length; i++) {
      final correct = _questions[i].correctIndexes.toSet();
      if (_selectedAnswers[i].length == correct.length &&
          _selectedAnswers[i].containsAll(correct)) {
        marks++;
      }
    }

    final attempt = Attempt(
      name: widget.name,
      email: widget.email,
      startTime: _startTime,
      endTime: endTime,
      marks: marks,
      totalMarks: _questions.length,
    );

    await StorageService.saveAttempt(attempt);

    if (!mounted) return;
    _showResultDialog(marks);
  }

  void _showResultDialog(int marks) {
    final pct = marks / _questions.length;
    final color = pct >= 0.8
        ? const Color(0xFF17B978)
        : pct >= 0.5
        ? AppColors.sunnyAmber
        : AppColors.coralPink;
    final emoji = pct >= 0.8 ? '🎉' : (pct >= 0.5 ? '👍' : '💪');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Exam Completed',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$marks/${_questions.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vividViolet,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderMist,
      appBar: AppBar(
        title: const Text('Exam', style: TextStyle(color: Colors.white)),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.headerGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length + 1,
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vividViolet.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _submitExam,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        child: Text(
                          'Submit Exam',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final q = _questions[index];
          final typeColor = q.type == QuestionType.single
              ? AppColors.vividViolet
              : AppColors.coralPink;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border(left: BorderSide(color: typeColor, width: 5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: typeColor.withValues(alpha: 0.15),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q.questionText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    margin: const EdgeInsets.only(left: 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.type == QuestionType.single
                          ? 'Select one answer'
                          : 'Select all that apply',
                      style: TextStyle(
                        fontSize: 11,
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...List.generate(q.options.length, (optIndex) {
                    final selected = _selectedAnswers[index].contains(optIndex);
                    if (q.type == QuestionType.single) {
                      return RadioListTile<int>(
                        title: Text(q.options[optIndex]),
                        value: optIndex,
                        activeColor: typeColor,
                        // ignore: deprecated_member_use
                        groupValue: _selectedAnswers[index].isEmpty
                            ? null
                            : _selectedAnswers[index].first,
                        // ignore: deprecated_member_use
                        onChanged: (val) {
                          setState(() {
                            _selectedAnswers[index] = {val!};
                          });
                        },
                        dense: true,
                        tileColor: selected
                            ? typeColor.withValues(alpha: 0.06)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    } else {
                      return CheckboxListTile(
                        title: Text(q.options[optIndex]),
                        value: selected,
                        activeColor: typeColor,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAnswers[index].add(optIndex);
                            } else {
                              _selectedAnswers[index].remove(optIndex);
                            }
                          });
                        },
                        dense: true,
                        tileColor: selected
                            ? typeColor.withValues(alpha: 0.06)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
