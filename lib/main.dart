import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bluetoothIsConnected = false;
  bool ledIsOn = false;
  bool showDevices = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? currentDevice;
  List<BluetoothDevice> devices = [];
  BluetoothService? currentService;
  BluetoothCharacteristic? currentCharacteristic;
  String statusTexto = "";
  @override
  void initState() {
    super.initState();
  }

  readCharacteristic() async {
    List<int> values = await currentCharacteristic!.read();
    setState(() {
      statusTexto = values.toString();
    });
  }

  Future<void> connect(BluetoothDevice dev) async {
    setState(() {
      currentDevice = dev;
      statusTexto = "Conectando ao dispositivo ${dev.name}";
    });
    await currentDevice!.connect();
    List<BluetoothService> services = await currentDevice!.discoverServices();

    setState(() {
      statusTexto = "Procurando os serviços";
    });
    services.forEach((element) {
      if (element.uuid == "12ec422f-6f69-4cdf-b017-943eb4d9f2a4") {
        setState(() {
          statusTexto =
              "Serviço de uuid 12ec422f-6f69-4cdf-b017-943eb4d9f2a4 encontrado";
          currentService = element;
        });
      }
      setState(() {
        statusTexto = "Procurando características";
      });
      currentService!.characteristics.forEach((element) {
        if (element.uuid == "457f377f-3597-40a3-9484-fdc50a68af76") {
          setState(() {
            statusTexto =
                "Característica de uuid 457f377f-3597-40a3-9484-fdc50a68af76 encontrado";
            currentCharacteristic = element;
          });
        }
      });
    });
  }

  void getAlldevices() {
    setState(() {
      devices.clear();
      statusTexto = "Conectando aos dispositivos";
    });
// Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      setState(() {
        statusTexto = "Adicionando dispositivos";
      });

      for (ScanResult r in results) {
        setState(() {
          devices.add(r.device);
        });
      }
    });
    flutterBlue.stopScan();
    statusTexto = "Lista de dispositivos criada";
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
        textStyle:
            MaterialStateProperty.all<TextStyle>(const TextStyle(fontSize: 20)),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue));
    ButtonStyle desconnectedButtonStyle = ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
        textStyle:
            MaterialStateProperty.all<TextStyle>(const TextStyle(fontSize: 20)),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey));

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "IMD",
                  style: TextStyle(
                      fontSize: 120,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          getAlldevices();
                          setState(() {
                            showDevices = true;
                          });
                        },
                        child: const Text("Conectar"),
                        style: !bluetoothIsConnected
                            ? buttonStyle
                            : desconnectedButtonStyle,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Desconectar"),
                      style: bluetoothIsConnected
                          ? buttonStyle
                          : desconnectedButtonStyle,
                    ))
                  ],
                ),
                Visibility(
                    visible: showDevices,
                    child: devices.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onLongPress: () {
                                  setState(() {
                                    showDevices = false;
                                    currentDevice = devices[index];
                                  });
                                },
                                child: ListTile(
                                  title: Text(devices[index].name),
                                ),
                              );
                            })
                        : CircularProgressIndicator()),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Enviar texto"),
                        style: buttonStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Ligar"),
                        style: !ledIsOn ? buttonStyle : desconnectedButtonStyle,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Desligar"),
                      style: ledIsOn ? buttonStyle : desconnectedButtonStyle,
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "STATUS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(statusTexto)
              ],
            ),
          )),
        ));
  }
}
