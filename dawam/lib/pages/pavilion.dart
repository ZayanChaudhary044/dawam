import 'package:flutter/material.dart';

class ThePavilion extends StatelessWidget {
  const ThePavilion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 5),
          Text("Welcome To The Pavilion",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              height: 150,
              width: 500,
              child: Card(
                color: Colors.brown[100],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Selected Set:"),

                      ],
                    )
                  ],
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              height: 300,
              width: 500,
              child: Card(
                color: Colors.brown[100],
                child: Center(
                  child: Icon(Icons.add),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
