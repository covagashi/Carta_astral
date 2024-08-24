import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomWheelDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  CustomWheelDatePicker({required this.onDateSelected});

  @override
  _CustomWheelDatePickerState createState() => _CustomWheelDatePickerState();
}

class _CustomWheelDatePickerState extends State<CustomWheelDatePicker> {
  late DateTime _selectedDate;
  final DateFormat _monthFormat = DateFormat('MMMM', 'es_ES');
  final List<int> _years = List.generate(124, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Row(
        children: [
          _buildPicker(
            count: 12,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, index + 1, _selectedDate.day);
              });
              widget.onDateSelected(_selectedDate);
            },
            itemBuilder: (context, index) {
              final month = DateTime(_selectedDate.year, index + 1);
              return Center(
                child: Text(
                  _monthFormat.format(month),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
          _buildPicker(
            count: 31,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
              });
              widget.onDateSelected(_selectedDate);
            },
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
          _buildPicker(
            count: _years.length,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedDate = DateTime(_years[index], _selectedDate.month, _selectedDate.day);
              });
              widget.onDateSelected(_selectedDate);
            },
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  '${_years[index]}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required int count,
    required void Function(int) onSelectedItemChanged,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Expanded(
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        itemExtent: 32,
        squeeze: 1.2,
        onSelectedItemChanged: onSelectedItemChanged,
        children: List<Widget>.generate(count, (index) => itemBuilder(context, index)),
      ),
    );
  }
}