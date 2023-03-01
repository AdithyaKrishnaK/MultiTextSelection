import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_text_selection/selector_flow2.dart';
import 'package:multi_text_selection/selector_flow3.dart';
import 'package:multi_text_selection/selector_flow4.dart';
import 'package:multi_text_selection/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<SelectorFlow2State> flow2k = GlobalKey<SelectorFlow2State>();
  GlobalKey<SelectorFlow3State> flow3k = GlobalKey<SelectorFlow3State>();
  GlobalKey<SelectorFlow4State> flow4k = GlobalKey<SelectorFlow4State>();
  static const String flow2 = 'Flow 2';
  static const String flow3 = 'Flow 3';
  static const String flow4 = 'Flow 4';
  String flow = flow3;
  final demoContent = """What is renewable energy? \n

Renewable energy is energy derived from natural sources that are replenished at a higher rate than they are consumed. Sunlight and wind, for example, are such sources that are constantly being replenished. Renewable energy sources are plentiful and all around us.\n
Fossil fuels - coal, oil and gas - on the other hand, are non-renewable resources that take hundreds of millions of years to form. Fossil fuels, when burned to produce energy, cause harmful greenhouse gas emissions, such as carbon dioxide.\n
Generating renewable energy creates far lower emissions than burning fossil fuels. Transitioning from fossil fuels, which currently account for the lion’s share of emissions, to renewable energy is key to addressing the climate crisis.\n
Renewables are now cheaper in most countries, and generate three times more jobs than fossil fuels.\n
Here are a few common sources of renewable energy:\n
Solar Energy\n
Solar energy is the most abundant of all energy resources and can even be harnessed in cloudy weather. The rate at which solar energy is intercepted by the Earth is about 10,000 times greater than the rate at which humankind consumes energy.\n
Solar technologies can deliver heat, cooling, natural lighting, electricity, and fuels for a host of applications. Solar technologies convert sunlight into electrical energy either through photovoltaic panels or through mirrors that concentrate solar radiation.\n
Although not all countries are equally endowed with solar energy, a significant contribution to the energy mix from direct solar energy is possible for every country.\n
The cost of manufacturing solar panels has plummeted dramatically in the last decade, making them not only affordable but often the cheapest form of electricity. Solar panels have a lifespan of roughly 30 years, and come in variety of shades depending on the type of material used in manufacturing.\n
Wind Energy\n
Wind energy harnesses the kinetic energy of moving air by using large wind turbines located on land (onshore) or in sea-  """;
  late SelectorFlow3 selector3 = SelectorFlow3(
    key: flow3k,
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow4 selector4 = SelectorFlow4(
    key: flow4k,
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow2 selector2 = SelectorFlow2(
    key: flow2k,
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [flow2, flow3]
                        .map((e) => ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flow = e;
                              });
                            },
                            child: Text(e)))
                        .toList() +
                    [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (flow == 'Flow 2') {
                                List<SelectionComponents> selections =
                                    flow2k.currentState!.getSelections;
                                String ans = "";
                                for (final sel in selections) {
                                  ans += selector2.text.substring(
                                      sel.baseOffset, sel.extentOffset + 1);
                                }
                                Clipboard.setData(ClipboardData(text: ans));
                              }
                              if (flow == 'Flow 3') {
                                List<SelectionComponents> selections =
                                    flow3k.currentState!.getSelections;
                                String ans = "";
                                for (final sel in selections) {
                                  ans += selector3.text.substring(
                                      sel.baseOffset, sel.extentOffset + 1);
                                }
                                Clipboard.setData(ClipboardData(text: ans));
                              }
                            });
                          },
                          child: const Text('Copy Highlight'))
                    ]),
            Text(
              flow,
              style: const TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: getSelector(flow),
              //  SelectableText(
              //   demoContent,
              // ),
            ),
          ],
        ),
      )), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton(
            child: const Icon(Icons.undo),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Colors.white)),
            backgroundColor: Colors.grey,
            onPressed: () {
              if (flow == "Flow 2" &&
                  flow2k.currentState!.getactionStack.anymoreUndo()) {
                flow2k.currentState!.dostate();
              } else if (flow == "Flow 3" &&
                  flow3k.currentState!.getactionStack.anymoreUndo()) {
                flow3k.currentState!.dostate();
              } else if (flow == 'Flow 4' &&
                  flow4k.currentState!.getactionStack.anymoreUndo()) {
                flow4k.currentState!.dostate();
              }
            }),
        FloatingActionButton(
          child: const Icon(Icons.redo),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Colors.white)),
          backgroundColor: Colors.grey,
          onPressed: () {
            if (flow == "Flow 2" &&
                flow2k.currentState!.getactionStack.anymoreRedo()) {
              flow2k.currentState!.dostate1();
            } else if (flow == "Flow 3" &&
                flow3k.currentState!.getactionStack.anymoreRedo()) {
              flow3k.currentState!.dostate1();
            } else if (flow == 'Flow 4' &&
                flow4k.currentState!.getactionStack.anymoreRedo()) {
              flow4k.currentState!.dostate1();
            }
          },
          // onPressed: actionStack.anymoreRedo()
          //     ? () {
          //         SelectionAction lastAction = actionStack.redo();
          //         setState(() {
          //           selections
          //             ..clear()
          //             ..addAll(lastAction.selectionComponents);
          //         });
          //         print("Adding the selection, ${selections.length}");
          //       }
          //     : null,
        ),
      ]),
    );
  }

  Widget getSelector(String flow) {
    switch (flow) {
      case flow2:
        return selector2;
      case flow3:
        return selector3;
      case flow4:
        return selector4;
    }
    return selector2;
  }

  GlobalKey<State> getSelectorClass(String flow) {
    switch (flow) {
      case flow2:
        return flow2k;
      case flow3:
        return flow3k;
      case flow4:
        return flow4k;
    }
    return flow2k;
  }
}
