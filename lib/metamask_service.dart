// metamask_service.dart
import 'package:web3dart/web3dart.dart';

class MetamaskService {
  final EthereumAddress _defaultAddress;

  MetamaskService(this._defaultAddress);

  Future<BigInt> getBalance() async {
    // Method to fetch account balance from Metamask
  }

  Future<TransactionHash> sendTransaction(
    EthereumAddress recipient,
    BigInt amount,
  ) async {
    // Method to send transaction via Metamask
  }
}
