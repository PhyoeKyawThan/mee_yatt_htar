import 'package:flutter/material.dart';

class TrainingChipsInput extends StatefulWidget {
  // Callback function to inform the parent widget of the final list of courses
  final ValueChanged<List<String>> onChipsChanged;

  // Optional initial list of courses
  final List<String> initialCourses;

  const TrainingChipsInput({
    super.key,
    required this.onChipsChanged,
    this.initialCourses = const [],
  });

  @override
  State<TrainingChipsInput> createState() => _TrainingChipsInputState();
}

class _TrainingChipsInputState extends State<TrainingChipsInput> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // The list holding the final, confirmed course names
  late List<String> _courseChips;

  @override
  void initState() {
    super.initState();
    _courseChips = List.from(widget.initialCourses);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- Core Logic Functions ---

  void _addChip(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !_courseChips.contains(trimmedName)) {
      setState(() {
        _courseChips.add(trimmedName);
        _inputController.clear();
        widget.onChipsChanged(_courseChips); // Notify parent
      });
      _focusNode.requestFocus(); // Keep focus for quick adding
    } else if (trimmedName.isNotEmpty) {
      // Clear if the input is a duplicate
      _inputController.clear();
      _focusNode.requestFocus();
    }
  }

  void _removeChip(String name) {
    setState(() {
      _courseChips.remove(name);
      widget.onChipsChanged(_courseChips); // Notify parent
    });
  }

  // --- UI Builders ---

  Widget _buildChip(String courseName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Chip(
        label: Text(courseName),
        backgroundColor: Colors.teal.shade100,
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => _removeChip(courseName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Display Area for Chips
        if (_courseChips.isNotEmpty)
          Wrap(
            spacing: 4.0, // horizontal space between chips
            runSpacing: 4.0, // vertical space between lines of chips
            children: _courseChips.map(_buildChip).toList(),
          ),

        // 2. Input Field for Adding New Chips
        TextFormField(
          controller: _inputController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'သင်တန်းအမည် ထည့်သွင်းပါ', // Enter Course Name
            hintText: 'ဥပမာ: ေရ ှာင်းကကြီး', // Example: 'Course Name'
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.teal),
              onPressed: () => _addChip(_inputController.text),
            ),
          ),
          // Add chip when user presses 'Done' or 'Enter' on the keyboard
          onFieldSubmitted: _addChip,
        ),
      ],
    );
  }
}

// --- Example Usage ---

class TrainingInputDemoScreen extends StatefulWidget {
  const TrainingInputDemoScreen({super.key});

  @override
  State<TrainingInputDemoScreen> createState() =>
      _TrainingInputDemoScreenState();
}

class _TrainingInputDemoScreenState extends State<TrainingInputDemoScreen> {
  List<String> _finalTrainingList = [];

  void _updateTrainingList(List<String> newList) {
    setState(() {
      _finalTrainingList = newList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Chip Input Demo'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'တက်ရောက်ပြီး သင်တန်းများ (Course Chips)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // The Reusable Component
            TrainingChipsInput(
              onChipsChanged: _updateTrainingList,
              initialCourses: const [
                'မိတ္ထီလာ',
                'အခေ ါ်',
              ], // Optional starting data
            ),

            const SizedBox(height: 30),
            const Text(
              'Final Data for Submission:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Display the final output list
            Text(
              _finalTrainingList.isEmpty
                  ? 'No courses added.'
                  : _finalTrainingList.join(', '),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: TrainingInputDemoScreen()));
}
