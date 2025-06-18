enum RequestState {
  loading,
  done,
  error,
  empty,
  initial;

  bool get isLoading => this == RequestState.loading;
  bool get isDone => this == RequestState.done;
  bool get isError => this == RequestState.error;
  bool get isInitial => this == RequestState.initial;
}

enum ErrorType {
  network,
  server,
  backEndValidation,
  unknown,
  none,
  unAuth,
  canceled,
  empty;

  bool get isNetwork => this == ErrorType.network;
  bool get isServer => this == ErrorType.server;
  bool get isBackEndValidation => this == ErrorType.backEndValidation;
  bool get isUnknown => this == ErrorType.unknown;
  bool get isCanceled => this == ErrorType.canceled;

  bool get isEmpty => this == ErrorType.empty;
  bool get isUnAuth => this == ErrorType.unAuth;
  bool get isNone => this == ErrorType.none;
}

enum UserType {
  client,
  agent,
  freeAgent,
  productAgent,
  technician;

  bool get isClient => this == UserType.client;
  bool get isAgent => this == UserType.agent;
  bool get isFreeAgent => this == UserType.freeAgent;
  bool get isProductAgent => this == UserType.productAgent;
  bool get isTechnician => this == UserType.technician;
}

enum StaticType { privacy, terms, about }

enum VerifyType { resetPassword, register }

enum CompanyServiceType { supply, maintenance }

enum FactoryServiceType { factory, accessory }

enum OrderType {
  distibution,
  recaharge,
  supply,
  maintenance;

  String get type {
    switch (this) {
      case OrderType.distibution:
        return 'distibution';
      case OrderType.recaharge:
        return 'recaharge';
      case OrderType.supply:
        return 'supply';
      case OrderType.maintenance:
        return 'maintenance';
    }
  }
}

