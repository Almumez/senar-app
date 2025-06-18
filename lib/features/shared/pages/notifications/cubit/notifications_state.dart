import '../../../../../core/utils/enums.dart';

class NotificationsState {
  final RequestState deleteAllNotifications;
  final RequestState getNotifications;
  final RequestState getNotificationsPaging;
  final RequestState deleteNotification;
  final String msg;
  final ErrorType errorType;

  NotificationsState({
    this.deleteAllNotifications = RequestState.initial,
    this.getNotifications = RequestState.initial,
    this.getNotificationsPaging = RequestState.initial,
    this.deleteNotification = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  NotificationsState copyWith({
    RequestState? deleteAllNotifications,
    RequestState? getNotificationsPaging,
    RequestState? getNotifications,
    RequestState? deleteNotification,
    String? msg,
    ErrorType? errorType,
  }) =>
      NotificationsState(
        getNotificationsPaging: getNotificationsPaging ?? this.getNotificationsPaging,
        deleteAllNotifications: deleteAllNotifications ?? this.deleteAllNotifications,
        getNotifications: getNotifications ?? this.getNotifications,
        deleteNotification: deleteNotification ?? this.deleteNotification,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
