import 'package:mcd/app/modules/add_money_module/add_money_module_bindings.dart';
import 'package:mcd/app/modules/add_money_module/add_money_module_page.dart';
import 'package:mcd/app/modules/agent_request_module/agent_request_module_bindings.dart';
import 'package:mcd/app/modules/agent_request_module/agent_request_module_page.dart';
import 'package:mcd/app/modules/agent_request_module/agent_personal_info_page.dart';
import 'package:mcd/app/modules/agent_request_module/agent_document_page.dart';
import 'package:mcd/app/modules/agent_request_module/agent_signature_page.dart';
import 'package:mcd/app/modules/airtime_module/airtime_module_bindings.dart';
import 'package:mcd/app/modules/airtime_module/airtime_module_page.dart';
import 'package:mcd/app/modules/betting_module/betting_module_bindings.dart';
import 'package:mcd/app/modules/betting_module/betting_module_page.dart';
import 'package:mcd/app/modules/cable_module/cable_module_bindings.dart';
import 'package:mcd/app/modules/cable_module/cable_module_page.dart';
import 'package:mcd/app/modules/cable_transaction_module/cable_transaction_module_bindings.dart';
import 'package:mcd/app/modules/cable_transaction_module/cable_transaction_module_page.dart';
import 'package:mcd/app/modules/data_module/data_module_bindings.dart';
import 'package:mcd/app/modules/data_module/data_module_page.dart';
import 'package:mcd/app/modules/electricity_module/electricity_module_bindings.dart';
import 'package:mcd/app/modules/electricity_module/electricity_module_page.dart';
import 'package:mcd/app/modules/electricity_transaction_module/electricity_transaction_module_bindings.dart';
import 'package:mcd/app/modules/electricity_transaction_module/electricity_transaction_module_page.dart';
import 'package:mcd/app/modules/general_payout/general_payout_bindings.dart';
import 'package:mcd/app/modules/general_payout/general_payout_page.dart';
import 'package:mcd/app/modules/jamb_module/jamb_module_bindings.dart';
import 'package:mcd/app/modules/jamb_module/jamb_module_page.dart';
import 'package:mcd/app/modules/jamb_verfy_account_module/jamb_verfy_account_module_bindings.dart';
import 'package:mcd/app/modules/jamb_verfy_account_module/jamb_verfy_account_module_page.dart';
import 'package:mcd/app/modules/kyc_update_module/kyc_update_module_bindings.dart';
import 'package:mcd/app/modules/kyc_update_module/kyc_update_module_page.dart';
import 'package:mcd/app/modules/jamb_payment_module/jamb_payment_module_bindings.dart';
import 'package:mcd/app/modules/jamb_payment_module/jamb_payment_module_page.dart';
import 'package:mcd/app/modules/reward_centre_module/reward_centre_module_bindings.dart';
import 'package:mcd/app/modules/reward_centre_module/reward_centre_module_page.dart';
import 'package:mcd/app/modules/giveaway_module/giveaway_module_bindings.dart';
import 'package:mcd/app/modules/giveaway_module/giveaway_module_page.dart';
import 'package:mcd/app/modules/giveaway_module/giveaway_detail/giveaway_detail_bindings.dart';
import 'package:mcd/app/modules/giveaway_module/giveaway_detail/giveaway_detail_page.dart';
import 'package:mcd/app/modules/giveaway_module/create_giveaway/create_giveaway_page.dart';
import 'package:mcd/app/modules/game_centre_module/game_centre_module_bindings.dart';
import 'package:mcd/app/modules/game_centre_module/game_centre_module_page.dart';
import 'package:mcd/app/modules/spin_win_module/spin_win_module_bindings.dart';
import 'package:mcd/app/modules/spin_win_module/spin_win_module_page.dart';
import 'package:mcd/app/modules/predict_win_module/predict_win_module_bindings.dart';
import 'package:mcd/app/modules/predict_win_module/predict_win_module_page.dart';
import 'package:mcd/app/modules/foreign_airtime_module/country_selection_bindings.dart';
import 'package:mcd/app/modules/foreign_airtime_module/country_selection_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_home/virtual_card_home_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_home/virtual_card_home_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_details/virtual_card_details_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_details/virtual_card_details_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_request/virtual_card_request_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_request/virtual_card_request_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_application/virtual_card_application_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_application/virtual_card_application_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_change_pin/virtual_card_change_pin_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_change_pin/virtual_card_change_pin_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_full_details/virtual_card_full_details_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_full_details/virtual_card_full_details_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_transactions/virtual_card_transactions_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_transactions/virtual_card_transactions_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_limits/virtual_card_limits_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_limits/virtual_card_limits_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_top_up/virtual_card_top_up_bindings.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_top_up/virtual_card_top_up_page.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_top_up/vcard_receipt.dart';
import 'package:mcd/app/modules/nin_validation_module/nin_validation_module_bindings.dart';
import 'package:mcd/app/modules/nin_validation_module/nin_validation_module_page.dart';
import 'package:mcd/app/modules/result_checker_module/result_checker_module_bindings.dart';
import 'package:mcd/app/modules/result_checker_module/result_checker_module_page.dart';
import 'package:mcd/app/modules/transaction_detail_module/transaction_detail_module_bindings.dart';
import 'package:mcd/app/modules/transaction_detail_module/transaction_detail_module_page.dart';
import 'package:mcd/app/modules/recurring_transactions_module/recurring_transactions_module_binding.dart';
import 'package:mcd/app/modules/recurring_transactions_module/recurring_transactions_module_page.dart';
import 'package:mcd/app/modules/plans_module/plans_module_bindings.dart';
import 'package:mcd/app/modules/plans_module/plans_module_page.dart';
import 'package:mcd/app/modules/notification_module/notification_module_bindings.dart';
import 'package:mcd/app/modules/notification_module/notification_module_page.dart';
import 'package:mcd/app/modules/leaderboard_module/leaderboard_module_bindings.dart';
import 'package:mcd/app/modules/leaderboard_module/leaderboard_module_page.dart';
import 'package:mcd/app/modules/number_verification_module/number_verification_module_bindings.dart';
import 'package:mcd/app/modules/number_verification_module/number_verification_module_page.dart';
import 'package:mcd/app/modules/change_pwd_module/change_pwd_module_bindings.dart';
import 'package:mcd/app/modules/change_pwd_module/change_pwd_module_page.dart';
import 'package:mcd/app/modules/change_pin_module/change_pin_module_bindings.dart';
import 'package:mcd/app/modules/change_pin_module/change_pin_module_page.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_module/qrcode_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_module/qrcode_module_page.dart';
import 'package:mcd/app/modules/qr_modules/my_qrcode_module/my_qrcode_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/my_qrcode_module/my_qrcode_module_page.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_transfer_module/qrcode_transfer_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_transfer_module/qrcode_transfer_module_page.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_transfer_details_module/qrcode_transfer_details_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_transfer_details_module/qrcode_transfer_details_module_page.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_request_fund_module/qrcode_request_fund_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_request_fund_module/qrcode_request_fund_module_page.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_request_fund_details_module/qrcode_request_fund_details_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/qrcode_request_fund_details_module/qrcode_request_fund_details_module_page.dart';
import 'package:mcd/app/modules/qr_modules/scan_qrcode_module/scan_qrcode_module_bindings.dart';
import 'package:mcd/app/modules/qr_modules/scan_qrcode_module/scan_qrcode_module_page.dart';
import 'package:mcd/app/modules/a2c_module/a2c_module_bindings.dart';
import 'package:mcd/app/modules/a2c_module/a2c_module_page.dart';
import 'package:mcd/app/modules/withdraw_bonus_module/withdraw_bonus_module_bindings.dart';
import 'package:mcd/app/modules/withdraw_bonus_module/withdraw_bonus_module_page.dart';
import 'package:mcd/app/modules/paystack_payment/paystack_payment_bindings.dart';
import 'package:mcd/app/modules/paystack_payment/paystack_payment_page.dart';
import 'package:mcd/app/modules/momo_module/momo_module_binding.dart';
import 'package:mcd/app/modules/momo_module/momo_module_page.dart';
import 'package:mcd/app/modules/notification_module/notification_detail_page.dart';
import 'package:mcd/app/modules/store_front_module/store_front_page.dart';
import 'package:mcd/app/modules/store_front_module/store_front_binding.dart';

// POS Module Imports
import 'package:mcd/app/modules/pos/pos_home_module/pos_home_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_home_module/pos_home_module_page.dart';
import 'package:mcd/app/modules/pos/pos_terminal_details_module/pos_terminal_details_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_terminal_details_module/pos_terminal_details_module_page.dart';
import 'package:mcd/app/modules/pos/pos_request_new_term_module/pos_request_new_term_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_request_new_term_module/pos_request_new_term_module_page.dart';
import 'package:mcd/app/modules/pos/pos_terminal_requests_module/pos_terminal_requests_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_terminal_requests_module/pos_terminal_requests_module_page.dart';
import 'package:mcd/app/modules/pos/pos_map_term_module/pos_map_term_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_map_term_module/pos_map_term_module_page.dart';
import 'package:mcd/app/modules/pos/pos_term_req_form_module/pos_term_req_form_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_term_req_form_module/pos_term_req_form_module_page.dart';
import 'package:mcd/app/modules/pos/pos_term_agreement_module/pos_term_agreement_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_term_agreement_module/pos_term_agreement_module_page.dart';
import 'package:mcd/app/modules/pos/pos_term_otp_module/pos_term_otp_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_term_otp_module/pos_term_otp_module_page.dart';
import 'package:mcd/app/modules/pos/pos_term_submit_doc_module/pos_term_submit_doc_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_term_submit_doc_module/pos_term_submit_doc_module_page.dart';
import 'package:mcd/app/modules/pos/pos_upload_location_module/pos_upload_location_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_upload_location_module/pos_upload_location_module_page.dart';
import 'package:mcd/app/modules/pos/pos_withdrawal_module/pos_withdrawal_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_withdrawal_module/pos_withdrawal_module_page.dart';
import 'package:mcd/app/modules/pos/pos_authorize_withdrawal_module/pos_authorize_withdrawal_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_authorize_withdrawal_module/pos_authorize_withdrawal_module_page.dart';
import 'package:mcd/app/modules/pos/pos_terminal_settings_module/pos_terminal_settings_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_terminal_settings_module/pos_terminal_settings_module_page.dart';
import 'package:mcd/app/modules/pos/pos_terminal_transaction_history_module/pos_terminal_transaction_history_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_terminal_transaction_history_module/pos_terminal_transaction_history_module_page.dart';
import 'package:mcd/app/modules/pos/pos_terminal_change_pin_module/pos_terminal_change_pin_module_bindings.dart';
import 'package:mcd/app/modules/pos/pos_terminal_change_pin_module/pos_terminal_change_pin_module_page.dart';
import 'package:mcd/app/modules/add_referral_module/add_referral_module_bindings.dart';
import 'package:mcd/app/modules/add_referral_module/add_referral_module_page.dart';
import 'package:mcd/app/modules/referral_list_module/referral_list_module_bindings.dart';
import 'package:mcd/app/modules/referral_list_module/referral_list_module_page.dart';
import 'package:mcd/app/modules/ussd_topup_module/ussd_topup_module_binding.dart';
import 'package:mcd/app/modules/ussd_topup_module/ussd_topup_module_page.dart';
import 'package:mcd/app/modules/card_topup_module/card_topup_module_binding.dart';
// import 'package:mcd/app/modules/card_topup_module/card_topup_module_page.dart';
import 'package:mcd/app/modules/card_topup_module/card_topup_amount_page.dart';
import 'package:mcd/app/modules/airtime_pin_module/airtime_pin_module_binding.dart';
import 'package:mcd/app/modules/airtime_pin_module/airtime_pin_module_page.dart';
import 'package:mcd/app/modules/epin_module/epin_binding.dart';
import 'package:mcd/app/modules/epin_module/epin_page.dart';
import 'package:mcd/app/modules/epin_module/data_pin/data_pin_binding.dart';
import 'package:mcd/app/modules/epin_module/data_pin/data_pin_page.dart';
import 'package:mcd/app/modules/epin_module/data_pin/data_pin_full_page.dart';
import 'package:mcd/app/modules/epin_module/epin_transaction_detail_binding.dart';
import 'package:mcd/app/modules/epin_module/epin_transaction_detail_page.dart';

import '../../app/modules/assistant_screen_module/assistant_screen_page.dart';
import '../../app/modules/assistant_screen_module/assistant_screen_bindings.dart';
import '../../app/modules/shop_screen_module/shop_screen_page.dart';
import '../../app/modules/shop_screen_module/shop_screen_bindings.dart';
import '../../app/modules/history_screen_module/history_screen_page.dart';
import '../../app/modules/history_screen_module/history_screen_bindings.dart';
import '../../app/modules/home_screen_module/home_screen_page.dart';
import '../../app/modules/home_screen_module/home_screen_bindings.dart';
import 'package:mcd/app/modules/account_info_module/account_info_module_bindings.dart';
import 'package:mcd/app/modules/account_info_module/account_info_module_page.dart';
import 'package:mcd/app/modules/more_module/more_module_bindings.dart';
import 'package:mcd/app/modules/more_module/more_module_page.dart';
import 'package:mcd/app/modules/reset_password_module/change_reset_pwd_screen.dart';
import 'package:mcd/app/modules/reset_password_module/verify_reset_pwd_otp_screeen.dart';
import 'package:mcd/app/modules/settings_module/settings_module_bindings.dart';
import 'package:mcd/app/modules/settings_module/settings_module_page.dart';
import 'package:mcd/app/modules/splash_screen_module/splash_screen_bindings.dart';

import '../../app/modules/verify_otp_module/verify_otp_page.dart';
import '../../app/modules/verify_otp_module/verify_otp_bindings.dart';
import '../../app/modules/new_device_verify_module/new_device_verify_page.dart';
import '../../app/modules/new_device_verify_module/new_device_verify_bindings.dart';
import '../../app/modules/pin_verify_module/pin_verify_page.dart';
import '../../app/modules/pin_verify_module/pin_verify_bindings.dart';
import '../../app/modules/reset_password_module/reset_password_page.dart';
import '../../app/modules/reset_password_module/reset_password_bindings.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/createaccount_module/createaccount_bindings.dart';
import 'package:mcd/app/modules/createaccount_module/createaccount_page.dart';
import 'package:mcd/app/modules/login_screen_module/login_screen_bindings.dart';
import 'package:mcd/app/modules/login_screen_module/login_screen_page.dart';
import 'package:mcd/app/modules/splash_screen_module/splash_screen_page.dart';

part './app_routes.dart';
/**
 * GetX Generator - fb.com/htngu.99
 * */

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH_SCREEN,
      page: () => SplashScreenPage(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: Routes.LOGIN_SCREEN,
      page: () => LoginScreenPage(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: Routes.CREATEACCOUNT,
      page: () => createaccountPage(),
      binding: createaccountBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => ResetPasswordPage(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.VERIFY_RESET_PASSWORD_OTP,
      page: () => VerifyResetPwdOtpPage(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_RESET_PASSWORD,
      page: () => ChangeResetPwdPage(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.PIN_VERIFY,
      page: () => PinVerifyPage(),
      binding: PinVerifyBinding(),
    ),
    GetPage(
      name: Routes.NEW_DEVICE_VERIFY,
      page: () => NewDeviceVerifyPage(),
      binding: NewDeviceVerifyBinding(),
    ),
    GetPage(
      name: Routes.VERIFY_OTP,
      page: () => VerifyOtpPage(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: Routes.MORE,
      page: () => MoreModulePage(),
      binding: MoreModuleBindings(),
    ),
    GetPage(
      name: Routes.ACCOUNT_INFO,
      page: () => AccountInfoModulePage(),
      binding: AccountInfoModuleBindings(),
    ),
    GetPage(
      name: Routes.KYC_UPDATE_MODULE,
      page: () => const KycUpdateModulePage(),
      binding: KycUpdateModuleBindings(),
    ),
    GetPage(
      name: Routes.AGENT_REQUEST_MODULE,
      page: () => AgentRequestModulePage(),
      binding: AgentRequestModuleBindings(),
    ),
    GetPage(
      name: Routes.AGENT_PERSONAL_INFO,
      page: () => const AgentPersonalInfoPage(),
      binding: AgentRequestModuleBindings(),
    ),
    GetPage(
      name: Routes.AGENT_DOCUMENT,
      page: () => const AgentDocumentPage(),
      binding: AgentRequestModuleBindings(),
    ),
    GetPage(
      name: Routes.AGENT_SIGNATURE,
      page: () => const AgentSignaturePage(),
      binding: AgentRequestModuleBindings(),
    ),
    GetPage(
      name: Routes.SETTINGS_SCREEN,
      page: () => SettingsModulePage(),
      binding: SettingsModuleBindings(),
    ),
    GetPage(
      name: Routes.HOME_SCREEN,
      page: () => HomeScreenPage(),
      binding: HomeScreenBinding(),
    ),
    GetPage(
      name: Routes.HISTORY_SCREEN,
      page: () => HistoryScreenPage(),
      binding: HistoryScreenBinding(),
    ),
    GetPage(
      name: Routes.SHOP_SCREEN,
      page: () => ShopScreenPage(),
      binding: ShopScreenBinding(),
    ),
    GetPage(
      name: Routes.ASSISTANT_SCREEN,
      page: () => AssistantScreenPage(),
      binding: AssistantScreenBinding(),
    ),
    GetPage(
      name: Routes.MORE_MODULE,
      page: () => MoreModulePage(),
      binding: MoreModuleBindings(),
    ),
    GetPage(
      name: Routes.AIRTIME_MODULE,
      page: () => AirtimeModulePage(),
      binding: AirtimeModuleBindings(),
    ),
    GetPage(
      name: Routes.COUNTRY_SELECTION,
      page: () => const CountrySelectionPage(),
      binding: CountrySelectionBindings(),
    ),
    GetPage(
      name: Routes.TRANSACTION_DETAIL_MODULE,
      page: () => TransactionDetailModulePage(),
      binding: TransactionDetailModuleBindings(),
    ),
    GetPage(
      name: Routes.RECURRING_TRANSACTIONS_MODULE,
      page: () => const RecurringTransactionsModulePage(),
      binding: RecurringTransactionsModuleBinding(),
    ),
    GetPage(
      name: Routes.DATA_MODULE,
      page: () => DataModulePage(),
      binding: DataModuleBindings(),
    ),
    GetPage(
        name: Routes.BETTING_MODULE,
        page: () => BettingModulePage(),
        binding: BettingModuleBindings()),
    GetPage(
        name: Routes.ELECTRICITY_MODULE,
        page: () => ElectricityModulePage(),
        binding: ElectricityModuleBindings()),
    GetPage(
        name: Routes.ELECTRICITY_TRANSACTION_MODULE,
        page: () => ElectricityTransactionPage(),
        binding: ElectricityTransactionModuleBindings()),
    GetPage(
        name: Routes.GENERAL_PAYOUT,
        page: () => GeneralPayoutPage(),
        binding: GeneralPayoutBindings()),
    GetPage(
        name: Routes.CABLE_MODULE,
        page: () => CableModulePage(),
        binding: CableModuleBindings()),
    GetPage(
        name: Routes.CABLE_TRANSACTION_MODULE,
        page: () => CableTransactionPage(),
        binding: CableTransactionModuleBindings()),
    GetPage(
        name: Routes.NIN_VALIDATION_MODULE,
        page: () => NinValidationModulePage(),
        binding: NinValidationModuleBindings()),
    GetPage(
        name: Routes.ADD_MONEY_MODULE,
        page: () => AddMoneyModulePage(),
        binding: AddMoneyModuleBindings()),
    GetPage(
        name: Routes.RESULT_CHECKER_MODULE,
        page: () => const ResultCheckerModulePage(),
        binding: ResultCheckerModuleBindings()),
    GetPage(
        name: Routes.JAMB_MODULE,
        page: () => const JambModulePage(),
        binding: JambModuleBindings()),
    GetPage(
        name: Routes.JAMB_VERIFY_ACCOUNT_MODULE,
        page: () => const JambVerfyAccountModulePage(),
        binding: JambVerfyAccountModuleBindings()),
    GetPage(
        name: Routes.JAMB_PAYMENT_MODULE,
        page: () => const JambPaymentModulePage(),
        binding: JambPaymentModuleBindings()),
    GetPage(
        name: Routes.REWARD_CENTRE_MODULE,
        page: () => const RewardCentreModulePage(),
        binding: RewardCentreModuleBindings()),
    GetPage(
        name: Routes.GIVEAWAY_MODULE,
        page: () => const GiveawayModulePage(),
        binding: GiveawayModuleBindings()),
    GetPage(
        name: Routes.CREATE_GIVEAWAY,
        page: () => const CreateGiveawayPage(),
        binding: GiveawayModuleBindings()),
    GetPage(
        name: Routes.GIVEAWAY_DETAIL,
        page: () => GiveawayDetailPage(),
        binding: GiveawayDetailBindings()),
    GetPage(
        name: Routes.GAME_CENTRE_MODULE,
        page: () => const GameCentreModulePage(),
        binding: GameCentreModuleBindings()),
    GetPage(
        name: Routes.SPIN_WIN_MODULE,
        page: () => const SpinWinModulePage(),
        binding: SpinWinModuleBindings()),
    GetPage(
        name: Routes.PREDICT_WIN_MODULE,
        page: () => const PredictWinModulePage(),
        binding: PredictWinModuleBindings()),
    GetPage(
        name: Routes.VIRTUAL_CARD_HOME,
        page: () => const VirtualCardHomePage(),
        binding: VirtualCardHomeBindings()),
    GetPage(
        name: Routes.VIRTUAL_CARD_DETAILS,
        page: () => const VirtualCardDetailsPage(),
        binding: VirtualCardDetailsBindings()),
    GetPage(
        name: Routes.VIRTUAL_CARD_REQUEST,
        page: () => const VirtualCardRequestPage(),
        binding: VirtualCardRequestBindings()),
    GetPage(
        name: Routes.VIRTUAL_CARD_APPLICATION,
        page: () => const VirtualCardApplicationPage(),
        binding: VirtualCardApplicationBindings()),
    GetPage(
        name: Routes.VIRTUAL_CARD_CHANGE_PIN,
        page: () => const VirtualCardChangePinPage(),
        binding: VirtualCardChangePinBinding()),
    GetPage(
        name: Routes.VIRTUAL_CARD_TRANSACTIONS,
        page: () => const VirtualCardTransactionsPage(),
        binding: VirtualCardTransactionsBinding()),
    GetPage(
        name: Routes.VIRTUAL_CARD_LIMITS,
        page: () => const VirtualCardLimitsPage(),
        binding: VirtualCardLimitsBinding()),
    GetPage(
        name: Routes.VIRTUAL_CARD_TOP_UP,
        page: () => const VirtualCardTopUpPage(),
        binding: VirtualCardTopUpBinding()),
    GetPage(
        name: Routes.VIRTUAL_CARD_RECEIPT,
        page: () => const VcardReceipt(),
        binding: VirtualCardTopUpBinding()),
    GetPage(
        name: Routes.VIRTUAL_CARD_FULL_DETAILS,
        page: () => const VirtualCardFullDetailsPage(),
        binding: VirtualCardFullDetailsBinding()),
    GetPage(
        name: Routes.PLANS_MODULE,
        page: () => const PlansModulePage(),
        binding: PlansModuleBindings()),
    GetPage(
        name: Routes.NOTIFICATION_MODULE,
        page: () => const NotificationModulePage(),
        binding: NotificationModuleBindings()),
    GetPage(
        name: Routes.LEADERBOARD_MODULE,
        page: () => const LeaderboardModulePage(),
        binding: LeaderboardModuleBindings()),
    GetPage(
        name: Routes.NUMBER_VERIFICATION_MODULE,
        page: () => const NumberVerificationModulePage(),
        binding: NumberVerificationModuleBindings()),
    GetPage(
        name: Routes.CHANGE_PWD_MODULE,
        page: () => const ChangePwdModulePage(),
        binding: ChangePwdModuleBindings()),
    GetPage(
        name: Routes.CHANGE_PIN_MODULE,
        page: () => const ChangePinModulePage(),
        binding: ChangePinModuleBindings()),
    GetPage(
        name: Routes.QRCODE_MODULE,
        page: () => const QrcodeModulePage(),
        binding: QrcodeModuleBindings()),
    GetPage(
        name: Routes.MY_QRCODE_MODULE,
        page: () => const MyQrcodeModulePage(),
        binding: MyQrcodeModuleBindings()),
    GetPage(
        name: Routes.QRCODE_TRANSFER_MODULE,
        page: () => const QrcodeTransferModulePage(),
        binding: QrcodeTransferModuleBindings()),
    GetPage(
        name: Routes.QRCODE_TRANSFER_DETAILS_MODULE,
        page: () => const QrcodeTransferDetailsModulePage(),
        binding: QrcodeTransferDetailsModuleBindings()),
    GetPage(
        name: Routes.QRCODE_REQUEST_FUND_MODULE,
        page: () => const QrcodeRequestFundModulePage(),
        binding: QrcodeRequestFundModuleBindings()),
    GetPage(
        name: Routes.QRCODE_REQUEST_FUND_DETAILS_MODULE,
        page: () => const QrcodeRequestFundDetailsModulePage(),
        binding: QrcodeRequestFundDetailsModuleBindings()),
    GetPage(
        name: Routes.SCAN_QRCODE_MODULE,
        page: () => ScanQrcodeModulePage(),
        binding: ScanQrcodeModuleBindings()),
    GetPage(
        name: Routes.A2C_MODULE,
        page: () => const A2CModulePage(),
        binding: A2CModuleBindings()),
    GetPage(
        name: Routes.WITHDRAW_BONUS_MODULE,
        page: () => const WithdrawBonusModulePage(),
        binding: WithdrawBonusModuleBindings()),

    // POS Module Routes
    GetPage(
        name: Routes.POS_HOME,
        page: () => const PosHomeModulePage(),
        binding: PosHomeModuleBinding()),
    GetPage(
        name: Routes.POS_TERMINAL_DETAILS,
        page: () => const PosTerminalDetailsModulePage(),
        binding: PosTerminalDetailsModuleBinding()),
    GetPage(
        name: Routes.POS_REQUEST_NEW_TERM,
        page: () => const PosRequestNewTermModulePage(),
        binding: PosRequestNewTermModuleBinding()),
    GetPage(
        name: Routes.POS_TERMINAL_REQUESTS,
        page: () => const PosTerminalRequestsModulePage(),
        binding: PosTerminalRequestsModuleBinding()),
    GetPage(
        name: Routes.POS_MAP_TERM,
        page: () => const PosMapTermModulePage(),
        binding: PosMapTermModuleBinding()),
    GetPage(
        name: Routes.POS_TERM_REQ_FORM,
        page: () => const PosTermReqFormModulePage(),
        binding: PosTermReqFormModuleBinding()),
    GetPage(
        name: Routes.POS_TERM_AGREEMENT,
        page: () => const PosTermAgreementModulePage(),
        binding: PosTermAgreementModuleBinding()),
    GetPage(
        name: Routes.POS_TERM_OTP,
        page: () => const PosTermOtpModulePage(),
        binding: PosTermOtpModuleBinding()),
    GetPage(
        name: Routes.POS_TERM_SUBMIT_DOC,
        page: () => const PosTermSubmitDocModulePage(),
        binding: PosTermSubmitDocModuleBinding()),
    GetPage(
        name: Routes.POS_UPLOAD_LOCATION,
        page: () => const PosUploadLocationModulePage(),
        binding: PosUploadLocationModuleBinding()),
    GetPage(
        name: Routes.POS_WITHDRAWAL,
        page: () => const PosWithdrawalModulePage(),
        binding: PosWithdrawalModuleBinding()),
    GetPage(
        name: Routes.POS_AUTHORIZE_WITHDRAWAL,
        page: () => const PosAuthorizeWithdrawalModulePage(),
        binding: PosAuthorizeWithdrawalModuleBinding()),
    GetPage(
        name: Routes.POS_TERMINAL_SETTINGS,
        page: () => const PosTerminalSettingsModulePage(),
        binding: PosTerminalSettingsModuleBinding()),
    GetPage(
        name: Routes.POS_TERMINAL_TRANSACTION_HISTORY,
        page: () => const PosTerminalTransactionHistoryModulePage(),
        binding: PosTerminalTransactionHistoryModuleBinding()),
    GetPage(
        name: Routes.POS_TERMINAL_CHANGE_PIN,
        page: () => const PosTerminalChangePinModulePage(),
        binding: PosTerminalChangePinModuleBinding()),
    GetPage(
        name: Routes.ADD_REFERRAL_MODULE,
        page: () => const AddReferralModulePage(),
        binding: AddReferralModuleBindings()),
    GetPage(
        name: Routes.REFERRAL_LIST_MODULE,
        page: () => const ReferralListModulePage(),
        binding: ReferralListModuleBindings()),
    GetPage(
        name: Routes.USSD_TOPUP_MODULE,
        page: () => const UssdTopupModulePage(),
        binding: UssdTopupModuleBinding()),
    GetPage(
        name: Routes.CARD_TOPUP_MODULE,
        page: () => const CardTopupAmountPage(),
        binding: CardTopupModuleBinding()),
    GetPage(
        name: Routes.AIRTIME_PIN_MODULE,
        page: () => const AirtimePinModulePage(),
        binding: AirtimePinModuleBinding()),
    GetPage(
        name: Routes.EPIN_MODULE,
        page: () => const EpinPage(),
        binding: EpinBinding()),
    GetPage(
        name: Routes.DATA_PIN,
        page: () => const DataPinPage(),
        binding: DataPinBinding()),
    GetPage(
        name: Routes.DATA_PIN_FULL,
        page: () => const DataPinFullPage(),
        binding: DataPinBinding()),
    GetPage(
        name: Routes.EPIN_TRANSACTION_DETAIL,
        page: () => const EpinTransactionDetailPage(),
        binding: EpinTransactionDetailBinding()),
    GetPage(
        name: Routes.PAYSTACK_PAYMENT,
        page: () => const PaystackPaymentPage(),
        binding: PaystackPaymentBindings()),
    GetPage(
        name: Routes.MOMO_MODULE,
        page: () => const MomoModulePage(),
        binding: MomoModuleBinding()),
    GetPage(
        name: Routes.NOTIFICATION_DETAIL,
        page: () => const NotificationDetailPage()),
    GetPage(
        name: Routes.STORE_FRONT,
        page: () => const StoreFrontPage(),
        binding: StoreFrontBinding()),
  ];
}
