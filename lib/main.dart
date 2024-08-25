import 'package:flutter/material.dart';
import 'package:freelanced/create_project_screen.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Freelance Marketplace",
      home: FreelanceMarketplaceHome(),
    );
  }
}

class FreelanceMarketplaceHome extends StatefulWidget {
  const FreelanceMarketplaceHome({super.key});

  @override
  _FreelanceMarketplaceHomeState createState() =>
      _FreelanceMarketplaceHomeState();
}

class _FreelanceMarketplaceHomeState extends State<FreelanceMarketplaceHome> {
  // Mock Project Data
  List<Project> projects = [
    Project(
      title: 'Design a Mobile App UI',
      budget: 0.5,
      deadline: DateTime.now().add(const Duration(days: 14)),
      status: ProjectStatus.open,
    ),
    Project(
      title: 'Build a Simple Smart Contract',
      budget: 1.2,
      deadline: DateTime.now().add(const Duration(days: 28)),
      status: ProjectStatus.inProgress,
    ),
    Project(
      title: 'Write a Technical Whitepaper',
      budget: 0.8,
      deadline: DateTime.now().add(const Duration(days: 7)),
      status: ProjectStatus.completed,
    ),
  ];

  // Function to get a string representation of the project status
  String getProjectStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return 'Open';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      default: // You might have other statuses (e.g., Disputed)
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelance Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                project.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget: ${project.budget} ETH'),
                  Text('Deadline: ${_formatDate(project.deadline)}'),
                  const SizedBox(height: 4.0), // Add some spacing
                  Chip(
                    label: Text(
                      getProjectStatus(project.status),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _getChipColor(project.status),
                  ),
                ],
              ),
              onTap: () {
                // TODO: Navigate to Project Details screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProjectScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper function to format the date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper function to get chip color based on status
  Color _getChipColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return Colors.green;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

// Mock Project class (replace with your actual data structure)
class Project {
  final String title;
  final double budget;
  final DateTime deadline;
  final ProjectStatus status;

  Project({
    required this.title,
    required this.budget,
    required this.deadline,
    required this.status,
  });
}

// Mock ProjectStatus enum
enum ProjectStatus { open, inProgress, completed }
