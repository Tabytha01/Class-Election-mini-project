import 'package:flutter/material.dart';
import 'models/candidate.dart';

class ResultsScreen extends StatelessWidget {
  final List<Candidate> candidates;

  const ResultsScreen({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    final totalVotes = candidates.fold(0, (sum, c) => sum + c.votes);

    // Sort candidates descending by votes for display
    final sortedCandidates = List<Candidate>.from(candidates)
      ..sort((a, b) => b.votes.compareTo(a.votes));

    String bannerText = '';
    Color bannerColor = Colors.deepPurple;

    // Winner, Tie, or No votes banner
    if (totalVotes == 0) {
      bannerText = 'No votes yet';
      bannerColor = Colors.grey;
    } else {
      final topVotes = sortedCandidates.first.votes;
      final winners =
          sortedCandidates.where((c) => c.votes == topVotes).toList();

      if (winners.length > 1) {
        final winnerNames = winners.map((w) => w.name).join(' and ');
        bannerText = 'Tie between $winnerNames ($topVotes votes each)';
        bannerColor = Colors.orange;
      } else {
        bannerText = 'Winner: ${winners.first.name}';
        bannerColor = Colors.green;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Election Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bannerText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: sortedCandidates.isEmpty
                  ? const Center(child: Text('No candidates to display'))
                  : ListView.builder(
                      itemCount: sortedCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = sortedCandidates[index];
                        final pct = totalVotes == 0
                            ? 0.0
                            : (candidate.votes / totalVotes);
                        final pctString = (pct * 100).toStringAsFixed(1);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${candidate.votes} votes ($pctString%)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ],
                            ),
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
