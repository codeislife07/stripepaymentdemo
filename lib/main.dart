import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() {
  Stripe.publishableKey='pk_test_51MC3R0SHTdXGB1RcjwtAiAae7Vju43DOpP1WVQTcN7MJixNiACHzPvg5KulqjzMzOtptpIxjJzxmWldSUID2I3Ik00TyHfx8MP';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.title});

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ElevatedButton(onPressed: () {
          makepayment("100", "INR");
        }, child: Text("Pay"),),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Map<String,dynamic>? paymentIntentData;
  Future<void> makepayment(String amount,String currency)async{
    try{
      paymentIntentData=await createPaymentIntent(amount,currency);
      if(paymentIntentData!=null){
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              // applePay: true,
                googlePay: PaymentSheetGooglePay(merchantCountryCode: 'IN'),
                merchantDisplayName: "Prospects",
                customerId: paymentIntentData!['customer'],
                paymentIntentClientSecret: paymentIntentData!['client_secret'],
                customerEphemeralKeySecret: paymentIntentData!['ephemeralkey']
            ));
        displayPaymentSheet();
      }
    }catch(e,s){
      print("EXCEPTION ===$e$s");

    }

  }

  createPaymentIntent(String amount, String currency) async{
    try{
      Map<String,dynamic> body={
        'amount':calculateAmount(amount),
        'currency':currency,
        'payment_method_types[]':'card'
      };
      var response=await http.post(Uri.parse("https://api.stripe.com/v1/payment_intents"),
      body: body,headers: {
        'Authorization':"Bearer sk_test_51MC3R0SHTdXGB1RcRuFxkKbRHgcwkhKQRoQPfU4QGTzIIZVsuwsOTOt8XNbrNeX6lX9PAZ3GU5FuWi9UTywW29lB00xTPFmaJe",
            'Content-Type':'application/x-www-form-urlencoded'
          }
      );
      return jsonDecode(response.body);
    }catch(err){
      print("err charging user $err");
    }
  }


  void displayPaymentSheet()async {
    try{
      await Stripe.instance.presentPaymentSheet();
      Get.snackbar("Payment info", "pay successful");
    }on Exception catch(e){
      if(e is StripeException){
        print("error from stripe $e");
      }else{
        print("Unforeseen error $e");
      }
    }catch(e){
      print("exception===$e");
    }
  }

  calculateAmount(String amount) {
    final a=(int.parse(amount))*100;
    return a.toString();
  }



}
