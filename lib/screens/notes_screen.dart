import 'package:flutter/material.dart';
import 'package:keep_notes/database/notes_database.dart';
import 'package:keep_notes/screens/note_card.dart';
import 'package:keep_notes/screens/note_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await NotesDatabase.instance.getNotes();
    setState(() {
      notes = fetchedNotes;
    });
  }

  final List<Color> noteColors = [
    const Color.fromARGB(255, 0, 118, 197),
    const Color.fromARGB(255, 138, 230, 110),
    const Color.fromARGB(255, 34, 89, 99),
    const Color.fromARGB(255, 102, 102, 235),
    const Color.fromARGB(255, 0, 0, 0),
    const Color.fromARGB(255, 219, 231, 111),
    const Color.fromARGB(255, 211, 100, 80),
    const Color.fromARGB(255, 243, 165, 208),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 0, 153, 255),
    const Color.fromARGB(255, 130, 81, 138),
    const Color.fromARGB(255, 255, 0, 242),
    const Color.fromARGB(255, 241, 2, 162),
    const Color.fromARGB(255, 12, 247, 255),
  ];

  void showNoteDialog({
    int? id,
    String? title,
    String? content,
    int colorIndex = 0,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NoteDialog(
          colorIndex: colorIndex,
          noteColors: noteColors,
          noteId: id,
          title: title,
          content: content,
          onNoteSaved:
              (
                newTitle,
                newDescription,
                selectedColorIndex,
                currentDate,
              ) async {
                if (id == null) {
                  await NotesDatabase.instance.addNote(
                    newTitle,
                    newDescription,
                    currentDate, // ✅ Corrected order
                    selectedColorIndex,
                  );
                } else {
                  await NotesDatabase.instance.updateNotes(
                    newTitle,
                    newDescription,
                    currentDate,
                    selectedColorIndex,
                    id,
                  );
                }
                fetchNotes();
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notes App',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNoteDialog(); // ✅ No sample note insert
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    'No Notes Found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteCard(
                    note: note,
                    onDelete: () async {
                      await NotesDatabase.instance.deleteNote(note['id']);
                      fetchNotes();
                    },
                    onTap: () {
                      showNoteDialog(
                        id: note['id'],
                        title: note['title'],
                        content: note['description'],
                        colorIndex: note['color'],
                      );
                    },
                    noteColors: noteColors,
                  );
                },
              ),
            ),
    );
  }
}
