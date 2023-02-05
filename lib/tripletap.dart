import 'package:flutter/material.dart';

class longselect extends StatefulWidget {
  const longselect({Key? key}) : super(key: key);

  @override
  _longselectState createState() => _longselectState();
}

class _longselectState extends State<longselect> {
  final contentText ="A computer is a machine that can be programmed to carry out sequences of arithmetic or logical operations (computation) automatically. Modern digital electronic computers can perform generic sets of operations known as programs. These programs enable computers to perform a wide range of tasks. A computer system is a nominally complete computer that includes the hardware, operating system (main software), and peripheral equipment needed and used for full operation. This term may also refer to a group of computers that are linked and function together, such as a computer network or computer cluster.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MultiSelection"),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SelectableText(
                      contentText,
                      style:TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.all(10),
                    child: SelectableText(
                      contentText,
                      style:TextStyle(
                        fontSize: 20,
                      ),
                    ),)
                ],
              ),
            ),
          ) // This,
        )
    );
  }
}
