import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/candidate.dart';
import 'clean_name.dart';
import 'results_screen.dart';
import 'candidates_screen.dart';
import 'live_data_screen.dart';

void main() {
  runApp(const ClassElectionApp());
}

class ClassElectionApp extends StatelessWidget {
  const ClassElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Election',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ElectionHomeScreen(),
    );
  }
}

class ElectionHomeScreen extends StatefulWidget {
  const ElectionHomeScreen({super.key});

  @override
  State<ElectionHomeScreen> createState() => _ElectionHomeScreenState();
}

class _ElectionHomeScreenState extends State<ElectionHomeScreen> {
  // Three sample candidates to start
  final List<Candidate> candidates = [
    Candidate(name: 'Bernice Niyokuri'),
    Candidate(name: 'Ruthy Izukondi'),
    Candidate(name: 'Lama Suleiman'),
  ];

  // Keeps track of voters (stores cleaned names in lowercase)
  final Set<String> votedUsers = {};

  final TextEditingController voterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('names', candidates.map((c) => c.name).toList());
    await prefs.setStringList(
        'votes', candidates.map((c) => c.votes.toString()).toList());
    await prefs.setStringList('voters', votedUsers.toList());
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('names');
    final votes = prefs.getStringList('votes');
    final voters = prefs.getStringList('voters');
    if (names == null || votes == null) return;
    if (!mounted) return;
    setState(() {
      candidates.clear();
      for (var i = 0; i < names.length; i++) {
        candidates.add(Candidate(name: names[i], votes: int.parse(votes[i])));
      }
      votedUsers.clear();
      votedUsers.addAll(voters ?? []);
    });
  }

  int get totalVotes => candidates.fold(0, (sum, c) => sum + c.votes);

  void voteFor(Candidate candidate) {
    final cleaned = cleanName(voterController.text);

    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to vote.')),
      );
      return;
    }

    // Each voter votes only once (compared in lowercase after cleaning)
    if (votedUsers.contains(cleaned.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$cleaned has already voted!')),
      );
      return;
    }

    setState(() {
      candidate.votes++;
      votedUsers.add(cleaned.toLowerCase());
      voterController.clear();
    });
    saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vote cast successfully for ${candidate.name}!')),
    );
  }

  void resetElection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Election?'),
        content: const Text(
          'Are you sure you want to clear all votes? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                for (var c in candidates) {
                  c.votes = 0;
                }
                votedUsers.clear();
              });
              saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Election has been reset.')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Election'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            tooltip: 'Live weather',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LiveDataScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Results',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsScreen(candidates: candidates),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Manage Candidates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CandidatesScreen(
                    candidates: candidates,
                    onUpdate: () {
                      setState(() {});
                      saveData();
                    },
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: resetElection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total Votes Cast: $totalVotes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: voterController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name (Voter)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Candidates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: candidates.isEmpty
                  ? const Center(child: Text('No candidates available.'))
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            title: Text(
                              candidate.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text('${candidate.votes} votes'),
                            trailing: ElevatedButton.icon(
                              onPressed: () => voteFor(candidate),
                              icon: const Icon(Icons.how_to_vote),
                              label: const Text('Vote'),
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
