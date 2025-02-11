import 'package:flutter/material.dart';

// Model class for the data
class Data {
  final String name;
  final int number;

  Data({required this.name, required this.number});
}

// Static DataStorage class to hold the data
class DataStorage {
  static List<Data> dataList = [];

  static void add(Data data) {
    dataList.add(data);
  }

  static List<Data> getAll() {
    return dataList;
  }

  static Data? findByName(String name) {
    return dataList.firstWhere(
          (data) => data.name == name,
      orElse: () => Data(name: '', number: 0),
    );
  }

  static void removeByName(String name) {
    dataList.removeWhere((data) => data.name == name);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for the form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  // Key for the form validation
  final formKey = GlobalKey<FormState>();

  // Function to handle form submission and data addition
  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      String name = nameController.text;
      int number = int.tryParse(numberController.text) ?? 0;

      // Add data to storage
      DataStorage.add(Data(name: name, number: number));

      // Clear the input fields
      nameController.clear();
      numberController.clear();

      // Update the UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Storage Example')),
      body: Column(
        children: [
          // MyForm widget for the form input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyForm(
              formKey: formKey,
              nameController: nameController,
              numberController: numberController,
              submitForm: submitForm,
            ),
          ),
          // Expanded widget to make ListView take available space
          Expanded(
            child: ListView.builder(
              itemCount: DataStorage.getAll().length,
              itemBuilder: (context, index) {
                final data = DataStorage.getAll()[index];
                return ListTile(
                  title: Text(data.name),
                  subtitle: Text('Number: ${data.number}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Remove the data from the list
                      DataStorage.removeByName(data.name);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final VoidCallback submitForm;

  const MyForm({super.key,
    required this.formKey,
    required this.nameController,
    required this.numberController,
    required this.submitForm,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: numberController,
            decoration: InputDecoration(labelText: 'Number'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: submitForm,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
