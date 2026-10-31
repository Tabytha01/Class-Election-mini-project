import 'package:flutter/material.dart';
import 'models/candidate.dart';
import 'clean_name.dart';

class CandidatesScreen extends StatefulWidget {
  final List<Candidate> candidates;
  final VoidCallback onUpdate;

  const CandidatesScreen({
    super.key,
    required this.candidates,
    required this.onUpdate,
  });

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final nameController = TextEditingController();

  void addCandidate() {
    final cleaned = cleanName(nameController.text);

    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate name cannot be empty.')),
      );
      return;
    }

    // Check for duplicate candidate (case-insensitive)
    final exists = widget.candidates
        .any((c) => c.name.toLowerCase() == cleaned.toLowerCase());

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$cleaned already exists!')),
      );
      return;
    }

    setState(() {
      widget.candidates.add(Candidate(name: cleaned));
      nameController.clear();
    });
    widget.onUpdate();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$cleaned added as candidate.')),
    );
  }

  void removeCandidate(Candidate candidate) {
    // Cannot remove a candidate with votes
    if (candidate.votes > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove a candidate who already has votes!'),
        ),
      );
      return;
    }

    setState(() {
      widget.candidates.remove(candidate);
    });
    widget.onUpdate();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${candidate.name} removed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Candidates')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'New Candidate Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: addCandidate,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: widget.candidates.isEmpty
                  ? const Center(child: Text('No candidates added.'))
                  : ListView.builder(
                      itemCount: widget.candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = widget.candidates[index];
                        return ListTile(
                          title: Text(candidate.name),
                          subtitle: Text('${candidate.votes} votes'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeCandidate(candidate),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
