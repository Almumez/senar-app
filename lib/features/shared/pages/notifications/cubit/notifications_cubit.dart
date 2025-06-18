import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/widgets/flash_helper.dart';
import '../../../../../core/widgets/loading.dart';
import '../../../../../models/notification_model.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsState());
  List<NotificationModel> notifications = [];
  String? next;

  final scrollController = ScrollController();

  getNotifications() async {
    emit(state.copyWith(getNotifications: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/notifications');
    if (result.success) {
      notifications = List<NotificationModel>.from(result.data['data'].map((x) => NotificationModel.fromJson(x)));
      next = result.data?['links']?['next'];
      addListener();
      emit(state.copyWith(getNotifications: RequestState.done));
    } else {
      emit(state.copyWith(getNotifications: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  getNotificationsPaging() async {
    emit(state.copyWith(getNotificationsPaging: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: next!);
    if (result.success) {
      final list = List<NotificationModel>.from(result.data['data'].map((x) => NotificationModel.fromJson(x)));
      notifications = notifications + list;
      next = result.data?['links']?['next'];
      refreshList();
      emit(state.copyWith(getNotificationsPaging: RequestState.done));
    } else {
      emit(state.copyWith(getNotificationsPaging: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  deleteAll() async {
    LoadingDialog.show();
    emit(state.copyWith(deleteAllNotifications: RequestState.loading));
    final result = await ServerGate.i.deleteFromServer(url: 'general/notifications');
    LoadingDialog.hide();
    if (result.success) {
      notifications = [];
      next = null;
      refreshList();
      emit(state.copyWith(deleteAllNotifications: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(deleteAllNotifications: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  deleteItem(String id) async {
    LoadingDialog.show();
    emit(state.copyWith(deleteAllNotifications: RequestState.loading));
    final result = await ServerGate.i.deleteFromServer(url: 'general/notifications/$id');
    LoadingDialog.hide();
    if (result.success) {
      notifications = notifications.where((x) => x.id != id).toList();
      refreshList();
      emit(state.copyWith(deleteAllNotifications: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(deleteAllNotifications: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  refreshList() {
    emit(state.copyWith(getNotifications: RequestState.loading));
    emit(state.copyWith(getNotifications: RequestState.done));
  }

  addListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (next == null) return;
        if ([state.getNotifications, state.getNotificationsPaging].contains(RequestState.loading)) return;
        getNotificationsPaging();
      }
    });
  }
}
