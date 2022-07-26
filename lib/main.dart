import 'dart:ffi';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Converter'),
        ),
        body: const Center(
          child: InputForm(),
        ),
      ),
    );
  }
}
class InputForm extends StatefulWidget {
  const InputForm({super.key});
  @override
  InputFormState createState() {
    return InputFormState();
  }
}
class InputFormState extends State<InputForm> {
  final formKey = GlobalKey<FormState>();
  String leftDropdownValue = 'RUB';
  String rightDropdownValue = 'EUR';
  String formValue = '';
  double? result = 0;
  String finalResult = '0';
  bool isLoading = false;
  Future fetchCurrency(double amount, String from, String to) async {
    final response = await Dio().get('https://api.apilayer.com/exchangerates_data/convert',
      queryParameters: {'apikey': 'AiR9QOh3ssvJOQ9SYM1r4IGCKt1HAY9u',
        'amount': amount.toString(),
        'to': to, 'from': from,
      },
      onReceiveProgress: (received, total) {
        isLoading = true;
      }
    );
    isLoading = false;
    if (response.statusCode == 200) {
      return response.data['result'];
    } else {
      return null;
    }
  }
  changeResult(double? res) {
    setState(() {
      if (res == null) {
        finalResult = '';
        return;
      }
      fetchCurrency(res, leftDropdownValue, rightDropdownValue).then((value) =>
        finalResult = value.toString()
      );
    });
  }
  @override
  Widget build(BuildContext context)  {
    return Form(
      key: formKey,
      child: Row(
        children: <Widget> [
          Expanded(
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                formValue = value;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
          DropdownButton(
            value: leftDropdownValue,
              items: <String>['RUB', 'EUR', 'USD']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  leftDropdownValue = newValue!;
                });
              },
          ),
          Expanded(child: Text(finalResult, textAlign: TextAlign.center,)),
          DropdownButton(
            value: rightDropdownValue,
            items: <String>['RUB', 'EUR', 'USD']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                rightDropdownValue = newValue!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                result = double.tryParse(formValue);
                if (result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Input only numbers')),
                  );
                  changeResult(null);
                }
                else {
                  changeResult(result);
                }
              }
            },
            child: isLoading == true ? const Text("Loading") : const Text("Convert"),
          ),
        ],
      )
    );
  }
}