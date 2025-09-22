import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final int level;

  const QuizScreen({super.key, required this.categoryId, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> questions = [];
  Map<int, String> selectedAnswers = {}; // questionIndex -> answer
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('categoryId', isEqualTo: widget.categoryId)
          .where('level', isEqualTo: widget.level)
          .limit(5)
          .get();

      questions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      setState(() => _isLoading = false);
    }
  }

  void _submitQuiz() {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        correct++;
      }
    }
    setState(() {
      _submitted = true;
      _score = correct;
    });

    // Update progress in Firestore
    final progress = correct / questions.length;
    FirebaseFirestore.instance
        .collection('contents')
        .doc('${widget.categoryId}_level${widget.level}')
        .set({'progress': progress}, SetOptions(merge: true));
  }

  Color _getOptionColor(int questionIndex, String option) {
    if (!_submitted) {
      return Colors.orange[100]!;
    }
    if (questions[questionIndex]['correctAnswer'] == option) {
      return Colors.greenAccent;
    }
    if (selectedAnswers[questionIndex] == option &&
        selectedAnswers[questionIndex] != questions[questionIndex]['correctAnswer']) {
      return Colors.redAccent;
    }
    return Colors.orange[100]!;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text('Level ${widget.level} Quiz'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _submitted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You scored $_score / ${questions.length}',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicSans'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _score == questions.length ? "🎉 Perfect! Great job!" : "👍 Keep practicing!",
                    style: const TextStyle(fontSize: 22, fontFamily: 'ComicSans'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Lessons'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontFamily: 'ComicSans'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final options = List<String>.from(question['options'] ?? []);
                  return Card(
                    color: Colors.yellow[100],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${question['question']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'ComicSans'),
                          ),
                          const SizedBox(height: 12),
                          ...options.map((option) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ElevatedButton(
                                onPressed: _submitted
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedAnswers[index] = option;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getOptionColor(index, option),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                        fontSize: 16, fontFamily: 'ComicSans'),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: !_submitted
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedAnswers.length == questions.length
                    ? _submitQuiz
                    : null,
                child: const Text('Submit Quiz'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orangeAccent,
                  textStyle: const TextStyle(
                      fontSize: 18, fontFamily: 'ComicSans'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            )
          : null,
    );
  }
}
