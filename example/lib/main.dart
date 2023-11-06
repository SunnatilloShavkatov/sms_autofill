import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.light(),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _code = '';
  String signature = '{{ app signature }}';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const PhoneFieldHint(),
                const Spacer(),
                PinFieldAutoFill(
                  decoration: UnderlineDecoration(
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.black),
                    colorBuilder:
                        FixedColorBuilder(Colors.black.withOpacity(0.3)),
                  ),
                  currentCode: _code,
                  onCodeSubmitted: (code) {},
                  onCodeChanged: (code) {
                    if (code!.length == 6) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  },
                ),
                const Spacer(),
                TextFieldPinAutoFill(
                  currentCode: _code,
                ),
                const Spacer(),
                ElevatedButton(
                  child: const Text('Listen for sms code'),
                  onPressed: () async {
                    await SmsAutoFill().listenForCode();
                  },
                ),
                ElevatedButton(
                  child: const Text('Set code to 123456'),
                  onPressed: () async {
                    setState(() {
                      _code = '123456';
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 4),
                Text('App Signature : $signature'),
                const SizedBox(height: 4),
                ElevatedButton(
                  child: const Text('Get app signature'),
                  onPressed: () async {
                    signature = await SmsAutoFill().getAppSignature;
                    setState(() {});
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CodeAutoFillTestPage(),
                      ),
                    );
                  },
                  child: const Text('Test CodeAutoFill mixin'),
                )
              ],
            ),
          ),
        ),
      );
}

class CodeAutoFillTestPage extends StatefulWidget {
  const CodeAutoFillTestPage({super.key});

  @override
  State<CodeAutoFillTestPage> createState() => _CodeAutoFillTestPageState();
}

class _CodeAutoFillTestPageState extends State<CodeAutoFillTestPage>
    with CodeAutoFill {
  String? appSignature;
  String? otpCode;

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code;
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening for code'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Text(
              'This is the current app signature: $appSignature',
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Builder(
              builder: (_) {
                if (otpCode == null) {
                  return const Text('Listening for code...', style: textStyle);
                }
                return Text('Code Received: $otpCode', style: textStyle);
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
