import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soroban Contract Interaction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SorobanServer sorobanServer =
      SorobanServer("https://soroban-testnet.stellar.org");
  final String contractId =
      "CDXDRYQKWAPOOWZFIOIAVEWVTSH6MCOWSIAFH5MCJ37VKUOWYVUILJIP";
  late KeyPair accountKeyPair;
  late AccountResponse account;

  @override
  void initState() {
    super.initState();
    _initializeAccount();
  }

  Future<void> _initializeAccount() async {
    accountKeyPair = KeyPair.random();

    await FriendBot.fundTestAccount(accountKeyPair.accountId);

    account = await StellarSDK.TESTNET
        .accounts.account(accountKeyPair.accountId);

    setState(() {});
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueGrey,
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _buyTicket(BuildContext context) async {
    String functionName = "buy_ticket";
    InvokeContractHostFunction hostFunction =
        InvokeContractHostFunction(contractId, functionName);
    InvokeHostFunctionOperation operation =
        InvokeHostFuncOpBuilder(hostFunction).build();

    Transaction transaction = TransactionBuilder(account)
        .addOperation(operation)
        .build();

    var simulateResponse = await sorobanServer
        .simulateTransaction(SimulateTransactionRequest(transaction));

    transaction.sorobanTransactionData = simulateResponse.transactionData;
    transaction.addResourceFee(simulateResponse.minResourceFee!);
    transaction.sign(accountKeyPair, Network.TESTNET);

    SendTransactionResponse sendResponse = await sorobanServer
        .sendTransaction(transaction);
    if (sendResponse.error == null) {
      _showSnackBar(context, 'Ticket booked. Transaction ID: ${sendResponse.hash}');
    }
  }

  Future<void> _donate(BuildContext context, int amount) async {
    String functionName = "donate";
    XdrSCVal arg = XdrSCVal.forU32(amount);
    InvokeContractHostFunction hostFunction = InvokeContractHostFunction(
        contractId, functionName,
        arguments: [arg]);
    InvokeHostFunctionOperation operation =
        InvokeHostFuncOpBuilder(hostFunction).build();

    Transaction transaction = TransactionBuilder(account)
        .addOperation(operation)
        .build();

    var simulateResponse = await sorobanServer
        .simulateTransaction(SimulateTransactionRequest(transaction));

    transaction.sorobanTransactionData = simulateResponse.transactionData;
    transaction.addResourceFee(simulateResponse.minResourceFee!);
    transaction.sign(accountKeyPair, Network.TESTNET);

    SendTransactionResponse sendResponse = await sorobanServer
        .sendTransaction(transaction);
    if (sendResponse.error == null) {
      _showSnackBar(context, 'Donation successful. Transaction ID: ${sendResponse.hash}');
    }
  }

  @override
  Widget build(BuildContext context) {
    int height = MediaQuery.of(context).size.height.toInt();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Image.network(
              'https://img.freepik.com/premium-photo/astonishingly-beautiful-keshava-temple-somnathpur-karnataka-india_268419-342.jpg',
              height: height/2,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keshava Temple',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'The Keshava Temple, also known as the Chennakeshava Temple, is an ancient Hindu temple located in the village of Somanathapura, Karnataka, India. It is renowned for its exquisite Hoysala architecture and intricate stone carvings, making it one of the finest examples of Hoysala craftsmanship',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _buyTicket(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Book Ticket'),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _donate(context, 50),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Donate 50 units'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
