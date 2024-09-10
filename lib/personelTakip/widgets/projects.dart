import 'package:deneme/personelTakip/modal/project.dart';
import 'package:deneme/personelTakip/modal/task.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class Projects extends StatefulWidget {
  final String loggedInUserName;

  Projects({required this.loggedInUserName});

  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  // Fetch projects from the backend
  Future<void> _fetchProjects() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/projects'));
      if (response.statusCode == 200) {
        final List<dynamic> projectList = json.decode(response.body);
        setState(() {
          projects = projectList.map((data) => Project.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  // Build the progress item with tasks
Widget _buildProgressItem(Project project) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: ListTile(
      leading: Icon(Icons.description, color: Colors.purple),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name),
          SizedBox(height: 5),
          Text(
            'Owner: ${project.ownerName}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          // Display tasks
          ...project.tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                '• ${task.name}',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }).toList(),
        ],
      ),
      subtitle: Text(timeago.format(project.createdAt)),
      trailing: PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'Complete') {
            // Mark as complete logic (if needed)
          } else if (result == 'Delete') {
            _deleteProject(project.id);
          } else if (result == 'Edit') {
            _showEditProjectDialog(project);
          }
        },
        itemBuilder: (BuildContext context) => <String>[
          
          'Delete',
          'Edit',
        ].map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList(),
      ),
    ),
  );
}
  // Show add project dialog
  void _showAddProjectDialog() {
    final _titleController = TextEditingController();
    final _taskControllers = <TextEditingController>[];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(20),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._taskControllers.map((controller) {
                      return TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Task',
                          border: OutlineInputBorder(),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _taskControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add Task Field'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final newProject = Project(
                          id: 0, // The ID will be assigned by the backend
                          name: _titleController.text,
                          progress: 0.0,
                          ownerName: widget.loggedInUserName,
                          tasks: _taskControllers.map((controller) => Task(name: controller.text)).toList(),
                          createdAt: DateTime.now(),
                        );

                        _createProject(newProject);
                        Navigator.of(context).pop();
                      },
                      child: Text('Add Project'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Show edit project dialog
  void _showEditProjectDialog(Project project) {
    final _titleController = TextEditingController(text: project.name);
    final _taskControllers = project.tasks.map((task) => TextEditingController(text: task.name)).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(20),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._taskControllers.map((controller) {
                      return TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Task',
                          border: OutlineInputBorder(),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _taskControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add Task Field'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final updatedProject = Project(
                          id: project.id,
                          name: _titleController.text,
                          progress: project.progress,
                          ownerName: project.ownerName,
                          tasks: _taskControllers.map((controller) => Task(name: controller.text)).toList(),
                          createdAt: project.createdAt,
                        );

                        _updateProject(updatedProject);
                        Navigator.of(context).pop();
                      },
                      child: Text('Update Project'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Create a new project
Future<void> _createProject(Project project) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/projects'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': project.name,
        'progress': project.progress,
        'ownerName': project.ownerName,
        'tasks': project.tasks.map((task) => {'name': task.name}).toList(),
        'createdAt': project.createdAt.toIso8601String(),
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {  // Assuming 201 is the success status code
      final newProject = Project.fromJson(json.decode(response.body));
      setState(() {
        projects.add(newProject);
      });
    } else {
      throw Exception('Failed to create project: ${response.body}');
    }
  } catch (e) {
    print('Error creating project: $e');
  }
}


  // Update an existing project
  Future<void> _updateProject(Project project) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/projects/${project.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(project.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedProject = Project.fromJson(json.decode(response.body));
        setState(() {
          final index = projects.indexWhere((p) => p.id == updatedProject.id);
          if (index != -1) {
            projects[index] = updatedProject;
          }
        });
      } else {
        throw Exception('Failed to update project');
      }
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  // Delete a project
  Future<void> _deleteProject(int projectId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/projects/$projectId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          projects.removeWhere((project) => project.id == projectId);
        });
      } else {
        throw Exception('Failed to delete project');
      }
    } catch (e) {
      print('Error deleting project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        automaticallyImplyLeading: false, // Removes the back button

      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildProgressItem(projects[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
