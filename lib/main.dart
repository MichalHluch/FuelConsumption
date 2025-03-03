import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

TimeOfDay selectedTime = TimeOfDay.now();

// Model class for the data
class Data {
  static int idCounter = 0;

  final int id = idCounter++;
  final DateTime dateTime;
  final int fuelAmount;
  final double odometerStart;
  final double odometerEnd;
  final int pricePerLitre;
  final String notes;

  Data({required this.dateTime, required this.fuelAmount, required this.odometerStart,
    required this.odometerEnd, required this.pricePerLitre, required this.notes});
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

  static Data? findByID(int id) {
    return dataList.firstWhere(
      (data) => data.id == id,
      orElse: () => Data(dateTime: DateTime.now(), fuelAmount: 0, pricePerLitre: 0, odometerStart: 0.0, odometerEnd: 0.0, notes: ""),
    );
  }

  static void removeById(int id) {
    dataList.removeWhere((data) => data.id == id);
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
  final TextEditingController odometerStart = TextEditingController();
  final TextEditingController odometerEnd = TextEditingController();
  final TextEditingController fuelAmount = TextEditingController();
  final TextEditingController pricePerLitre = TextEditingController();
  final TextEditingController notes = TextEditingController();

  // Key for the form validation
  final formKey = GlobalKey<FormState>();

  // Function to handle form submission and data addition
  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {

      DataStorage.add(Data(dateTime: _DatePickerState.selectedDate ?? DateTime.now(),
      fuelAmount: int.tryParse(fuelAmount.text) ?? 0,
      odometerStart: double.tryParse(odometerStart.text) ?? 0.0,
      odometerEnd: double.tryParse(odometerEnd.text) ?? 0.0,
      pricePerLitre: int.tryParse(pricePerLitre.text) ?? 0,
      notes: notes.text));

      // Clear the input fields
      odometerStart.clear();
      odometerEnd.clear();
      fuelAmount.clear();
      pricePerLitre.clear();
      notes.clear();

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
              vehicleOdometerStart: odometerStart,
              vehicleOdometerEnd: odometerEnd,
              fuelAmount: fuelAmount,
              pricePerLitre: pricePerLitre,
              notes: notes,
              submitForm: submitForm,
            ),
          ),
          // Expanded widget to make ListView take available space
          Expanded(
            child: ListView.builder(
              itemCount: DataStorage.getAll().length,
              itemBuilder: (context, index) {
                final data = DataStorage.getAll()[index];
                final consumption = calculateFuelConsumption(data);
                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(data.dateTime)),
                  subtitle: Text('Consumption: $consumption litres/100km'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Remove the data from the list
                      DataStorage.removeById(data.id);
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

  String calculateFuelConsumption(Data data) {
    double distance = data.odometerEnd - data.odometerStart;

    if (distance <= 0) {
      return "0.0";
    }

    return format((data.fuelAmount / distance) * 100);
  }

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

class MyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController vehicleOdometerStart;
  final TextEditingController vehicleOdometerEnd;
  final TextEditingController fuelAmount;
  final TextEditingController pricePerLitre;
  final TextEditingController notes;
  final VoidCallback submitForm;

  const MyForm({
    super.key,
    required this.formKey,
    required this.vehicleOdometerStart,
    required this.vehicleOdometerEnd,
    required this.fuelAmount,
    required this.pricePerLitre,
    required this.notes,
    required this.submitForm,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: vehicleOdometerStart,
            decoration: InputDecoration(labelText: 'Odometer start'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d+)?$')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: vehicleOdometerEnd,
            decoration: InputDecoration(labelText: 'Odometer end'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d+)?$')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: fuelAmount,
            decoration: InputDecoration(labelText: 'Fuel amount'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: pricePerLitre,
            decoration: InputDecoration(labelText: 'price/litre'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: notes,
            decoration: InputDecoration(labelText: 'Notes'),
            keyboardType: TextInputType.text,
          ),

          Padding(padding: EdgeInsets.symmetric(vertical: 25.0)),
          const DatePicker(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
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

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  static DateTime? selectedDate;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: <Widget>[
          Text("Refuel date"),
          ElevatedButton(
              onPressed: _selectDate,
              child: Text(selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'No date selected')),
        ]);
  }
}
