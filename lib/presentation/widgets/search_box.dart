import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool showClear;
  final String? hinText;

  const SearchBox(
      {Key? key,
      required this.controller,
      this.onChanged,
      this.showClear = false,
      this.hinText})
      : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withOpacity(0.2),
        ),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          controller: widget.controller,
          onChanged: widget.onChanged,
          maxLines: 1,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(width: 1, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              size: 24,
              color: Colors.grey,
            ),
            suffixIcon: widget.showClear
                ? InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      widget.controller.clear();
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 20,
                      color: Colors.grey,
                    ),
                  )
                : null,
            hintText: widget.hinText,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
