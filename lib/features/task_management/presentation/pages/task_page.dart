import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({Key? key}) : super(key: key);

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late TextEditingController _descriptionController;
  bool _isContentFocused = false;
  bool _isDescriptionFocused = false;

  TaskEntity? _taskEntity;
  String? projectId;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _descriptionController = TextEditingController();

    _contentController.addListener(_updateContentFocus);
    _descriptionController.addListener(_updateDescriptionFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_taskEntity == null) {
      _taskEntity = ModalRoute.of(context)?.settings.arguments as TaskEntity?;
      if (_taskEntity != null) {
        projectId = _taskEntity!.projectId;
        _contentController.text = _taskEntity!.content ?? '';
        _descriptionController.text = _taskEntity!.description ?? '';
      }
    }
  }

  void _updateContentFocus() {
    setState(() {
      _isContentFocused = _contentController.text.isNotEmpty;
    });
  }

  void _updateDescriptionFocus() {
    setState(() {
      _isDescriptionFocused = _descriptionController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateContentFocus);
    _descriptionController.removeListener(_updateDescriptionFocus);
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final newTask = TaskEntity(
        id: DateTime.now().toString(),
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        projectId: _taskEntity!.projectId!,
      );

      if (_taskEntity != null) {
        context.read<TaskBloc>().add(UpdateTaskEvent(task: newTask));
      } else {
        context.read<TaskBloc>().add(CreateTaskEvent(task: newTask));
      }

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
              'Task',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField(
                  controller: _contentController,
                  label: 'Task Content',
                  hint: 'What needs to be done?',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task content is required';
                    }
                    return null;
                  },
                  isFocused: _isContentFocused,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Add more details (optional)',
                  maxLines: 4,
                  isFocused: _isDescriptionFocused,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    bool isFocused = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isFocused ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: isFocused ? Colors.blue : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
