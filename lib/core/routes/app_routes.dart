import 'package:flutter/widgets.dart';
import '../../features/client/orders/views/select_payment_method.dart';

import '../../features/agent/car_info/view.dart';
import '../../features/agent/order_details/view/order_details_view.dart';
import '../../features/agent/select_merchent/view/select_merchent_view.dart';
import '../../features/auth/complete_data/view/complete_data.dart';
import '../../features/auth/complete_data/view/success.dart';
import '../../features/auth/forget_password/view/forget_password_view.dart';
import '../../features/auth/login/view/login_view.dart';
import '../../features/auth/register/view/register_view.dart';
import '../../features/auth/reset_password/view/reset_password_view.dart';
import '../../features/auth/verify_phone/view/verify_phone_view.dart';
import '../../features/client/addresses/view/addresses.dart';
import '../../features/client/addresses/view/pick_location_view.dart';
import '../../features/client/cart/view/cart_details.dart';
import '../../features/client/cart/view/order_summary.dart';
import '../../features/client/cart/view/select_payment_method.dart';
import '../../features/client/central_gas_filling/view.dart';
import '../../features/client/company_details/views/choose_address.dart';
import '../../features/client/company_details/views/company_details.dart';
import '../../features/client/factories_accessories/view/factories_view.dart';
import '../../features/client/factory_details/view/factory_details.dart';
import '../../features/client/gas_distributing/view/buy_cylinder_view.dart';
import '../../features/client/gas_distributing/view/choose_service_view.dart';
import '../../features/client/gas_distributing/view/create_order.dart';
import '../../features/client/home/view/story_view.dart';
import '../../features/client/maintenance_supply/companies.dart';
import '../../features/client/orders/views/order_details.dart';
import '../../features/client/orders/views/rate_agent.dart';
import '../../features/client/orders_history/view.dart';
import '../../features/client/product_details/product_details.dart';
import '../../features/client/refill/view.dart';
import '../../features/intro/onboarding.dart';
import '../../features/intro/splash_view.dart';
import '../../features/product_agent/order_details/view/order_details_view.dart';
import '../../features/shared/pages/contact_us/view/contact_us_view.dart';
import '../../features/shared/pages/edit_profile/view.dart';
import '../../features/shared/pages/faq/view.dart';
import '../../features/shared/pages/information/view.dart';
import '../../features/shared/pages/navbar/view.dart';
import '../../features/shared/pages/order_counts/view.dart';
import '../../features/shared/pages/profits/view.dart';
import '../../features/shared/pages/settings/view.dart';
import '../../features/shared/pages/static_pages/view.dart';
import '../../features/shared/pages/wallet/view/transactions_view.dart';
import '../../features/shared/pages/wallet/view/wallet_view.dart';
import '../../features/shared/pages/wallet/view/withdrow_view.dart';
import '../../features/shared/pages/notifications/view/notifications_view.dart';
import '../../features/technician/order_details/view/order_details_view.dart';
import '../services/my_fatoora.dart';
import '../utils/extensions.dart';
import 'routes.dart';

class AppRoutes {
  static AppRoutes get init => AppRoutes._internal();
  String initial = NamedRoutes.splash;
  AppRoutes._internal();
  Map<String, Widget Function(BuildContext)> appRoutes = {
    NamedRoutes.splash: (c) => const SplashView(),
    NamedRoutes.verifyPhone: (c) => VerifyPhoneView(
        type: c.arg['type'],
        phone: c.arg['phone'],
        phoneCode: c.arg['phone_code']),
    NamedRoutes.completeData: (c) =>
        CompleteDataView(phone: c.arg['phone'], phoneCode: c.arg['phone_code']),
    NamedRoutes.forgetPassword: (c) => ForgetPasswordView(),
    NamedRoutes.login: (c) => LoginView(),
    NamedRoutes.register: (c) => RegisterView(userType: c.arg['type']),
    NamedRoutes.resetPassword: (c) => ResetPasswordView(
        phone: c.arg['phone'],
        phoneCode: c.arg['phone_code'],
        code: c.arg['code']),
    NamedRoutes.onboarding: (c) => OnboardingView(),
    NamedRoutes.navbar: (c) => NavbarView(),
    NamedRoutes.successCompleteData: (c) => SuccessCompleteDataView(),
    NamedRoutes.editProfile: (c) => EditProfileView(),
    NamedRoutes.settings: (c) => SettingsView(),
    NamedRoutes.information: (c) => InformationView(),
    NamedRoutes.freeAgentCarInfo: (c) => FreeAgentCarInfoView(),
    NamedRoutes.static: (c) => StaticView(type: c.arg['type']),
    NamedRoutes.contactUs: (c) => ContactUsView(),
    NamedRoutes.faq: (c) => FaqView(),
    NamedRoutes.profits: (c) => ProfitsView(),
    NamedRoutes.ordersCount: (c) => OrdersCountView(),
    NamedRoutes.wallet: (c) => WalletView(),
    NamedRoutes.notifications: (c) => NotificationsView(),
    NamedRoutes.clientChooseDistributingMethod: (c) =>
        ClientChooseDistributingService(),
    NamedRoutes.buyCylinder: (c) => BuyCylinderView(),
    NamedRoutes.clientDistributingCreateOrder: (c) =>
        ClientDistributingCreateOrderView(),
    NamedRoutes.clientRefill: (c) => ClientRefillView(),
    NamedRoutes.clientMaintenanceCompanies: (c) =>
        ClientMaintenanceCompaniesView(type: c.arg['type']),
    NamedRoutes.companyDetails: (c) => CompanyDetailsView(
        title: c.arg['title'], type: c.arg['type'], id: c.arg['id']),
    NamedRoutes.chooseAddress: (c) => ChooseAddressView(),
    NamedRoutes.centralGasFilling: (c) => CentralGasFillingView(),
    NamedRoutes.addresses: (c) => AddressesView(),
    NamedRoutes.pickLocation: (c) => PickLocationView(data: c.arg['data']),
    NamedRoutes.clientFactoryAccessory: (c) =>
        ClientFactoryAccessoryView(type: c.arg['type']),
    NamedRoutes.factoryDetails: (c) =>
        FactoryDetailsView(data: c.arg['data'], type: c.arg['type']),
    NamedRoutes.productDetails: (c) => ProductDetailsView(data: c.arg['data']),
    NamedRoutes.orderDetails: (c) =>
        ClientOrderDetailsView(id: c.arg['id'], type: c.arg['type']),
    NamedRoutes.cart: (c) => const CartView(),
    NamedRoutes.clientCreateProductOrder: (c) =>
        const ClientCreateProductOrderView(),
    NamedRoutes.clientCreateOrderSelectPayment: (c) =>
        ClientCreateOrderSelectPaymentView(cubit: c.arg['cubit']),
    NamedRoutes.clientOrdersHistory: (c) => const ClientOrdersHistoryView(),
    NamedRoutes.agentShowOrder: (c) =>
        OrderDetailsView(id: c.arg['id'], type: c.arg['type']),
    NamedRoutes.selectMerchent: (c) => SelectMerchentView(),
    NamedRoutes.transactions: (c) => TransactionsView(),
    NamedRoutes.story: (c) => StoryView(
        galleryItems: c.arg['gallery_items'], initPage: c.arg['init_page']),
    NamedRoutes.withdrow: (c) => WithdrowView(amount: c.arg['amount']),
    NamedRoutes.technicianOrderDetails: (c) =>
        TechnicianOrderDetailsView(id: c.arg['id'], isOffer: c.arg['isOffer']),
    NamedRoutes.clientOrderDetailsSelectPayment: (c) =>
        ClientOrderDetailsSelectPaymentView(cubit: c.arg['cubit']),
    NamedRoutes.productAgentOrderDetails: (c) =>
        ProductAgentOrderDetailsView(id: c.arg['id'], type: c.arg['type']),
    NamedRoutes.rateAgent: (c) =>
        RateAgentView(orderId: c.arg['order_id'], callback: c.arg['callback']),
    NamedRoutes.paymentService: (c) => PaymentService(amount: c.arg['amount'], onSuccess:c.arg['on_success'])
  };
}
