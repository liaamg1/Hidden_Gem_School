import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool private = true;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Upload Hidden Gem"),

      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder(), prefixIcon: Icon(Icons.diamond, color: Colors.blue)),
          ),
          SizedBox(height: 10),
          TextField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
          ),
          SizedBox(height: 20),
          Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.my_location),
                      label: const Text("Use current location"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: const Text("Choose location on map"),
                    ),
                  ),
                ],
              ),
          //Grabbed switch code from https://api.flutter.dev/flutter/material/Switch-class.html and changed a little
          SwitchListTile(
            title: Text(private ? "Private" : "Public"),
            value: private,
            activeThumbColor: Colors.lightBlueAccent,
            onChanged: (bool value) {
              setState(() {
                private = value;
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 110.0),

          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.upload_file, size: 30),
            label: const Text("Upload"),
            onPressed: (){
            },
          )
          ],
        )
        )
        
        
      )
    );
  }
}