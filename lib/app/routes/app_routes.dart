// ignore_for_file: constant_identifier_names

part of './app_pages.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

abstract class Routes {
  static const SPLASH_SCREEN = '/splash_screen'; // SplashScreen page
  static const LOGIN_SCREEN = '/login_screen'; // SplashScreen page
  static const CREATEACCOUNT = '/createaccount'; // createaccount page
  static const RESET_PASSWORD = '/reset_password'; // ResetPassword page
  static const VERIFY_RESET_PASSWORD_OTP = '/verify_reset_pwd_otp';
  static const CHANGE_RESET_PASSWORD = '/change_reset_pwd';
  static const PIN_VERIFY = '/pin_verify'; // PinVerify page
  static const NEW_DEVICE_VERIFY = '/new_device_verify'; // NewDeviceVerify page
  static const VERIFY_OTP = '/verify_otp'; // VerifyOtp page
  static const MORE = '/more';
  static const ACCOUNT_INFO = '/account_info';
  static const KYC_UPDATE_MODULE = '/kyc_update_module';
  static const AGENT_REQUEST_MODULE = '/agent_request_module';
  static const AGENT_PERSONAL_INFO = '/agent_personal_info';
  static const AGENT_DOCUMENT = '/agent_document';
  static const AGENT_SIGNATURE = '/agent_signature';
  static const SETTINGS_SCREEN = '/settings_screen';
  static const HOME_SCREEN = '/home_screen'; // HomeScreen page
  static const HISTORY_SCREEN = '/history_screen'; // HistoryScreen page
  static const SHOP_SCREEN = '/shop_screen'; // ShopScreen page
  static const ASSISTANT_SCREEN = '/assistant_screen'; // AssistantScreen page
  static const MORE_MODULE = '/more_module'; // MoreModule page
  static const TRANSACTION_DETAIL_MODULE = '/transaction_detail_module';
  static const RECURRING_TRANSACTIONS_MODULE = '/recurring_transactions_module';
  static const GENERAL_PAYOUT = '/general_payout';
  static const AIRTIME_MODULE = '/airtime_module';
  static const AIRTIME_PAYOUT_MODULE = '/airtime_payout_module';
  static const COUNTRY_SELECTION = '/country_selection';
  static const DATA_MODULE = '/data_module';
  static const DATA_PAYOUT_MODULE = '/data_payout_module';
  static const BETTING_MODULE = '/betting_module';
  static const ELECTRICITY_MODULE = '/electricity_module';
  static const ELECTRICITY_PAYOUT_MODULE = '/electricity_payout_module';
  static const ELECTRICITY_TRANSACTION_MODULE =
      '/electricity_transaction_module';
  static const CABLE_MODULE = '/cable_module';
  static const CABLE_PAYOUT_MODULE = '/cable_payout_module';
  static const CABLE_TRANSACTION_MODULE = '/cable_transaction_module';
  static const NUMBER_VERIFICATION_MODULE = '/number_verification_module';
  static const NIN_VALIDATION_MODULE = '/nin_validation_module';
  static const NIN_VALIDATION_PAYOUT = '/nin_validation_payout';
  static const ADD_MONEY_MODULE = '/add_money_module';
  static const RESULT_CHECKER_MODULE = '/result_checker_module';
  static const RESULT_CHECKER_PAYOUT = '/result_checker_payout';
  static const JAMB_MODULE = '/jamb_module';
  static const JAMB_VERIFY_ACCOUNT_MODULE = '/jamb_verify_account_module';
  static const JAMB_PAYMENT_MODULE = '/jamb_payment_module';
  static const REWARD_CENTRE_MODULE = '/reward_centre_module';
  static const GIVEAWAY_MODULE = '/giveaway_module';
  static const CREATE_GIVEAWAY = '/create_giveaway';
  static const GIVEAWAY_DETAIL = '/giveaway_detail';
  static const GAME_CENTRE_MODULE = '/game_centre_module';
  static const SPIN_WIN_MODULE = '/spin_win_module';
  static const PREDICT_WIN_MODULE = '/predict_win_module';
  static const VIRTUAL_CARD_HOME = '/virtual_card_home';
  static const VIRTUAL_CARD_DETAILS = '/virtual_card_details';
  static const VIRTUAL_CARD_REQUEST = '/virtual_card_request';
  static const VIRTUAL_CARD_APPLICATION = '/virtual_card_application';
  static const VIRTUAL_CARD_TRANSACTIONS = '/virtual_card_transactions';
  static const VIRTUAL_CARD_LIMITS = '/virtual_card_limits';
  static const VIRTUAL_CARD_CHANGE_PIN = '/virtual_card_change_pin';
  static const VIRTUAL_CARD_TOP_UP = '/virtual_card_top_up';
  static const VIRTUAL_CARD_RECEIPT = '/virtual_card_receipt';
  static const VIRTUAL_CARD_FULL_DETAILS = '/virtual_card_full_details';
  static const PLANS_MODULE = '/plans_module';
  static const NOTIFICATION_MODULE = '/notification_module';
  static const LEADERBOARD_MODULE = '/leaderboard_module';
  static const CHANGE_PWD_MODULE = '/change_pwd_module';
  static const CHANGE_PIN_MODULE = '/change_pin_module';
  static const QRCODE_MODULE = '/qrcode_module';
  static const MY_QRCODE_MODULE = '/my_qrcode_module';
  static const QRCODE_TRANSFER_MODULE = '/qrcode_transfer_module';
  static const QRCODE_TRANSFER_DETAILS_MODULE =
      '/qrcode_transfer_details_module';
  static const QRCODE_REQUEST_FUND_MODULE = '/qrcode_request_fund_module';
  static const QRCODE_REQUEST_FUND_DETAILS_MODULE =
      '/qrcode_request_fund_details_module';
  static const SCAN_QRCODE_MODULE = '/scan_qrcode_module';
  static const A2C_MODULE = '/a2c_module';
  static const WITHDRAW_BONUS_MODULE = '/withdraw_bonus_module';
  static const ADD_REFERRAL_MODULE = '/add_referral_module';
  static const REFERRAL_LIST_MODULE = '/referral_list_module';
  static const USSD_TOPUP_MODULE = '/ussd_topup_module';
  static const CARD_TOPUP_MODULE = '/card_topup_module';
  static const AIRTIME_PIN_MODULE = '/airtime_pin_module';
  static const AIRTIME_PIN_PAYOUT = '/airtime_pin_payout';
  static const DATA_PIN_MODULE = '/data_pin_module';
  static const EPIN_MODULE = '/epin_module';
  static const DATA_PIN = '/data_pin';
  static const DATA_PIN_FULL = '/data_pin_full';
  static const EPIN_PAYOUT = '/epin_payout';
  static const DATA_PIN_PAYOUT = '/data_pin_payout';
  static const EPIN_TRANSACTION_DETAIL = '/epin_transaction_detail';
  static const RECHARGE_CARD_MODULE = '/recharge_card_module';

  // POS Module Routes
  static const POS_HOME = '/pos_home';
  static const POS_TERMINAL_DETAILS = '/pos_terminal_details';
  static const POS_REQUEST_NEW_TERM = '/pos_request_new_term';
  static const POS_TERMINAL_REQUESTS = '/pos_terminal_requests';
  static const POS_MAP_TERM = '/pos_map_term';
  static const POS_TERM_REQ_FORM = '/pos_term_req_form';
  static const POS_TERM_AGREEMENT = '/pos_term_agreement';
  static const POS_TERM_OTP = '/pos_term_otp';
  static const POS_TERM_SUBMIT_DOC = '/pos_term_submit_doc';
  static const POS_UPLOAD_LOCATION = '/pos_upload_location';
  static const POS_WITHDRAWAL = '/pos_withdrawal';
  static const POS_AUTHORIZE_WITHDRAWAL = '/pos_authorize_withdrawal';
  static const POS_TERMINAL_SETTINGS = '/pos_terminal_settings';
  static const POS_TERMINAL_TRANSACTION_HISTORY =
      '/pos_terminal_transaction_history';
  static const POS_TERMINAL_CHANGE_PIN = '/pos_terminal_change_pin';
  static const PAYSTACK_PAYMENT = '/paystack_payment';
  static const MOMO_MODULE = '/momo_module';
  static const STORE_FRONT = '/store_front';
  static const NOTIFICATION_DETAIL = '/notification_detail';
}
