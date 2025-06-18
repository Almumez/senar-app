import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/flash_helper.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../../models/wallet.dart';
import 'wallet_states.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletState());

  WalletModel? data;
  List<TransactionModel> transcations = [];
  String? next;

  final scrollController = ScrollController();

  Future<void> getWallet() async {
    emit(state.copyWith(getWaletState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/wallet');
    if (result.success) {
      data = WalletModel.fromJson(result.data['data']);
      emit(state.copyWith(getWaletState: RequestState.done));
    } else {
      emit(state.copyWith(getWaletState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  getTranscations() async {
    emit(state.copyWith(getTransactionsState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/wallet/transactions');
    if (result.success) {
      transcations = List<TransactionModel>.from(result.data['data'].map((x) => TransactionModel.fromJson(x)));
      next = result.data?['links']?['next'];
      addListener();
      emit(state.copyWith(getTransactionsState: RequestState.done));
    } else {
      emit(state.copyWith(getTransactionsState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  getTranscationsPaging() async {
    emit(state.copyWith(getTransactionsPagingState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: next!);
    if (result.success) {
      final list = List<TransactionModel>.from(result.data['data'].map((x) => TransactionModel.fromJson(x)));
      transcations = transcations + list;
      next = result.data?['links']?['next'];
      refreshList();
      emit(state.copyWith(getTransactionsPagingState: RequestState.done));
    } else {
      emit(state.copyWith(getTransactionsPagingState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  refreshList() {
    emit(state.copyWith(getTransactionsState: RequestState.loading));
    emit(state.copyWith(getTransactionsState: RequestState.done));
  }

  addListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (next == null) return;
        if ([state.getTransactionsState, state.getTransactionsPagingState].contains(RequestState.loading)) return;
        getTranscationsPaging();
      }
    });
  }

  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final receiverName = TextEditingController();
  withDrow() async {
    if (!formKey.isValid) return;
    emit(state.copyWith(withdrowState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/wallet/withdrawl-request', body: {
      'amount': amount.text,
      'bank_name': bankName.text,
      'account_number': accountNumber.text,
      'receiver_name': receiverName.text,
    });
    if (result.success) {
      emit(state.copyWith(withdrowState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(withdrowState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
