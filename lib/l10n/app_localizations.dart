import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'CoCircle'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get resetPasswordDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! check your inbox.'**
  String get passwordResetEmailSent;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @joinCoCircle.
  ///
  /// In en, this message translates to:
  /// **'Join CoCircle'**
  String get joinCoCircle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started'**
  String get signUpDescription;

  /// No description provided for @signInDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInDescription;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Error message when name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get enterNameError;

  /// No description provided for @enterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterEmailError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 chars'**
  String get passwordLengthError;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @accountCreatedVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please verify your email before logging in. If you don\'t see it, check your spam folder.'**
  String get accountCreatedVerifyEmail;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @nameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameEmptyError;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @noCircles.
  ///
  /// In en, this message translates to:
  /// **'No circles yet'**
  String get noCircles;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Pending Request} other{{count} Pending Requests}}'**
  String pendingRequest(int count);

  /// No description provided for @createCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Circle'**
  String get createCircleTitle;

  /// No description provided for @createCircleButton.
  ///
  /// In en, this message translates to:
  /// **'Create Circle'**
  String get createCircleButton;

  /// No description provided for @joinCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Circle'**
  String get joinCircleTitle;

  /// No description provided for @circleName.
  ///
  /// In en, this message translates to:
  /// **'Circle Name'**
  String get circleName;

  /// No description provided for @enterCircleNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enterCircleNameError;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @joinCircleDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 7-character code shared by your admin.'**
  String get joinCircleDescription;

  /// No description provided for @circleCode.
  ///
  /// In en, this message translates to:
  /// **'Circle Code'**
  String get circleCode;

  /// No description provided for @circleCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. X7Y2Z9A'**
  String get circleCodeHint;

  /// No description provided for @enterCodeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter code'**
  String get enterCodeError;

  /// No description provided for @codeTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Code is too short'**
  String get codeTooShortError;

  /// No description provided for @requestToJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Request to Join'**
  String get requestToJoinButton;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tripsAndEvents.
  ///
  /// In en, this message translates to:
  /// **'Trips & Events'**
  String get tripsAndEvents;

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips or events yet'**
  String get noTripsYet;

  /// No description provided for @planATrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a Trip'**
  String get planATrip;

  /// No description provided for @noDateSet.
  ///
  /// In en, this message translates to:
  /// **'No date set'**
  String get noDateSet;

  /// No description provided for @circleSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Circle Settings'**
  String get circleSettingsTitle;

  /// No description provided for @renameCircle.
  ///
  /// In en, this message translates to:
  /// **'Rename Circle'**
  String get renameCircle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @codePrefix.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String codePrefix(String code);

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @shareInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my circle \"{circleName}\" on CoCircle! Use code: {code} or click here: {link}'**
  String shareInviteMessage(String circleName, String code, String link);

  /// No description provided for @generateOneTimeLink.
  ///
  /// In en, this message translates to:
  /// **'Generate One-Time Invite Link'**
  String get generateOneTimeLink;

  /// No description provided for @oneTimeInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Special invite to join \"{circleName}\"! Use this one-time link: {link} or code: {code}'**
  String oneTimeInviteMessage(String circleName, String code, String link);

  /// No description provided for @activeOneTimeInvites.
  ///
  /// In en, this message translates to:
  /// **'Active One-Time Invites'**
  String get activeOneTimeInvites;

  /// No description provided for @pendingRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests ({count})'**
  String pendingRequestsCount(int count);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String membersCount(int count);

  /// No description provided for @adminLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminLabel;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// No description provided for @demoteToMember.
  ///
  /// In en, this message translates to:
  /// **'Demote to Member'**
  String get demoteToMember;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member?'**
  String get removeMemberConfirmTitle;

  /// No description provided for @removeMemberConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from this circle?'**
  String removeMemberConfirmMessage(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @loadMembersError.
  ///
  /// In en, this message translates to:
  /// **'Error loading members: {error}'**
  String loadMembersError(String error);

  /// No description provided for @cannotLeaveCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot Leave Circle'**
  String get cannotLeaveCircleTitle;

  /// No description provided for @onlyAdminError.
  ///
  /// In en, this message translates to:
  /// **'You are the only admin. Please promote another member to admin before leaving.'**
  String get onlyAdminError;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @leaveCircleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Circle?'**
  String get leaveCircleConfirmTitle;

  /// No description provided for @leaveCircleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this circle?'**
  String get leaveCircleConfirmMessage;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveCircleButton.
  ///
  /// In en, this message translates to:
  /// **'Leave Circle'**
  String get leaveCircleButton;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @totalPaidError.
  ///
  /// In en, this message translates to:
  /// **'Total paid ({totalPaid}) must equal expense amount ({amount})'**
  String totalPaidError(double totalPaid, double amount);

  /// No description provided for @totalSplitError.
  ///
  /// In en, this message translates to:
  /// **'Split amounts ({totalSplit}) must sum to total amount ({amount})'**
  String totalSplitError(double totalSplit, double amount);

  /// No description provided for @percentageSumError.
  ///
  /// In en, this message translates to:
  /// **'Percentages must sum to 100% (Current: {total}%)'**
  String percentageSumError(double total);

  /// No description provided for @loadCircleError.
  ///
  /// In en, this message translates to:
  /// **'Error loading circle: {error}'**
  String loadCircleError(String error);

  /// No description provided for @loadTripError.
  ///
  /// In en, this message translates to:
  /// **'Error loading trip: {error}'**
  String loadTripError(String error);

  /// No description provided for @expenseTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'What is this for?'**
  String get expenseTitleLabel;

  /// No description provided for @enterTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitleError;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountError;

  /// No description provided for @invalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmountError;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @updateExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpenseButton;

  /// No description provided for @saveExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpenseButton;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid By'**
  String get paidBy;

  /// No description provided for @selectPayers.
  ///
  /// In en, this message translates to:
  /// **'Select Payers'**
  String get selectPayers;

  /// No description provided for @payersSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payer selected} other{{count} payers selected}}'**
  String payersSelectedCount(int count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @requiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredError;

  /// No description provided for @invalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalidError;

  /// No description provided for @splitTypeExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get splitTypeExact;

  /// No description provided for @splitTypePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get splitTypePercentage;

  /// No description provided for @splitTypeRatio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get splitTypeRatio;

  /// No description provided for @splitTypeEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get splitTypeEqual;

  /// No description provided for @splitBetween.
  ///
  /// In en, this message translates to:
  /// **'Split Between'**
  String get splitBetween;

  /// No description provided for @selectParticipants.
  ///
  /// In en, this message translates to:
  /// **'Select Participants'**
  String get selectParticipants;

  /// No description provided for @participantsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant selected} other{{count} participants selected}}'**
  String participantsSelectedCount(int count);

  /// No description provided for @noParticipantsSelected.
  ///
  /// In en, this message translates to:
  /// **'No participants selected.'**
  String get noParticipantsSelected;

  /// No description provided for @dividedEquallyDescription.
  ///
  /// In en, this message translates to:
  /// **'Divided equally among selected participants:'**
  String get dividedEquallyDescription;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get percent;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @amountLabelWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Amount: {currency} {amount}'**
  String amountLabelWithCurrency(String currency, String amount);

  /// No description provided for @expenseDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetailsTitle;

  /// No description provided for @splitDetailsWithType.
  ///
  /// In en, this message translates to:
  /// **'Split Details ({type})'**
  String splitDetailsWithType(String type);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @loadMemberError.
  ///
  /// In en, this message translates to:
  /// **'Error loading member'**
  String get loadMemberError;

  /// No description provided for @loadSplitDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading split details'**
  String get loadSplitDetailsError;

  /// No description provided for @ratioLabel.
  ///
  /// In en, this message translates to:
  /// **'Ratio: {value}'**
  String ratioLabel(double value);

  /// No description provided for @exactAmount.
  ///
  /// In en, this message translates to:
  /// **'Exact Amount'**
  String get exactAmount;

  /// No description provided for @equalShare.
  ///
  /// In en, this message translates to:
  /// **'Equal Share'**
  String get equalShare;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteExpenseConfirmMessage(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet.'**
  String get noExpensesYet;

  /// No description provided for @paidBySummary.
  ///
  /// In en, this message translates to:
  /// **'Paid by {payer} • {date}'**
  String paidBySummary(String payer, String date);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @plusMore.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String plusMore(int count);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @spendingByMember.
  ///
  /// In en, this message translates to:
  /// **'Spending by Member (Who Paid)'**
  String get spendingByMember;

  /// No description provided for @liabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Liability (Who Owes what)'**
  String get liabilityTitle;

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get totalSpending;

  /// No description provided for @activeSettlements.
  ///
  /// In en, this message translates to:
  /// **'Active Settlements'**
  String get activeSettlements;

  /// No description provided for @settlementHistory.
  ///
  /// In en, this message translates to:
  /// **'Settlement History'**
  String get settlementHistory;

  /// No description provided for @calculateSettlementsError.
  ///
  /// In en, this message translates to:
  /// **'Error calculating settlements: {error}'**
  String calculateSettlementsError(String error);

  /// No description provided for @allSettledUp.
  ///
  /// In en, this message translates to:
  /// **'All settled up!'**
  String get allSettledUp;

  /// No description provided for @allSettledUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyone is even. Any new expenses added will show up here if settlements are needed.'**
  String get allSettledUpDescription;

  /// No description provided for @paysLabel.
  ///
  /// In en, this message translates to:
  /// **'{from} pays {to}'**
  String paysLabel(String from, String to);

  /// No description provided for @settleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle Up'**
  String get settleUp;

  /// No description provided for @settledWithLabel.
  ///
  /// In en, this message translates to:
  /// **'{from} settled with {to}'**
  String settledWithLabel(String from, String to);

  /// No description provided for @confirmPaidMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you have paid {currency}{amount} to {to}?'**
  String confirmPaidMessage(String currency, double amount, String to);

  /// No description provided for @confirmReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you have received {currency}{amount} from {from}?'**
  String confirmReceivedMessage(String currency, double amount, String from);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @newTripTitle.
  ///
  /// In en, this message translates to:
  /// **'New Trip / Event'**
  String get newTripTitle;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @settlements.
  ///
  /// In en, this message translates to:
  /// **'Settlements'**
  String get settlements;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'📊 Insights'**
  String get insights;

  /// No description provided for @audit.
  ///
  /// In en, this message translates to:
  /// **'🔍 Audit'**
  String get audit;

  /// Title for edit trip name dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Trip Name'**
  String get editTripName;

  /// No description provided for @tripName.
  ///
  /// In en, this message translates to:
  /// **'Trip Name'**
  String get tripName;

  /// No description provided for @settlementPlanWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Settlement Plan ({currency})'**
  String settlementPlanWithCurrency(String currency);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} CoCircle. All rights reserved.'**
  String copyright(int year);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @circleRequests.
  ///
  /// In en, this message translates to:
  /// **'Circle Requests'**
  String get circleRequests;

  /// No description provided for @waitingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person waiting} other{{count} persons waiting}}'**
  String waitingSummary(int count);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @noAuditHistory.
  ///
  /// In en, this message translates to:
  /// **'No audit history available.'**
  String get noAuditHistory;

  /// No description provided for @activityByUser.
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String activityByUser(String name);

  /// No description provided for @viewSpecificChanges.
  ///
  /// In en, this message translates to:
  /// **'View Specific Changes'**
  String get viewSpecificChanges;

  /// No description provided for @auditActionCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATED'**
  String get auditActionCreate;

  /// No description provided for @auditActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'UPDATED'**
  String get auditActionUpdate;

  /// No description provided for @auditActionDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETED'**
  String get auditActionDelete;

  /// No description provided for @changeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Details'**
  String get changeDetailsTitle;

  /// No description provided for @specificChanges.
  ///
  /// In en, this message translates to:
  /// **'Specific Changes'**
  String get specificChanges;

  /// No description provided for @noSpecificChanges.
  ///
  /// In en, this message translates to:
  /// **'No specific field changes recorded for this action.'**
  String get noSpecificChanges;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get toLabel;

  /// No description provided for @noneValue.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneValue;

  /// Title for the create trip screen
  ///
  /// In en, this message translates to:
  /// **'New Trip / Event'**
  String get newTripEvent;

  /// Label for name input
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Label for type dropdown
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// Label for location input
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// Label for start date picker
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// Label for end date picker
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// Text for create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// Label for expenses tab
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTab;

  /// Label for settlements tab
  ///
  /// In en, this message translates to:
  /// **'Settlements'**
  String get settlementsTab;

  /// Label for insights tab
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTab;

  /// Label for audit tab
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get auditTab;

  /// Label for trip name input
  ///
  /// In en, this message translates to:
  /// **'Trip Name'**
  String get tripNameLabel;

  /// Title for the settlement plan section
  ///
  /// In en, this message translates to:
  /// **'Settlement Plan ({currency})'**
  String settlementPlanTitle(String currency);

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @polls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get polls;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @createPoll.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get createPoll;

  /// No description provided for @pollQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get pollQuestion;

  /// No description provided for @enterQuestionError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a question'**
  String get enterQuestionError;

  /// No description provided for @pollOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get pollOptions;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// No description provided for @createPollButton.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get createPollButton;

  /// No description provided for @votesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No votes} =1{1 vote} other{{count} votes}}'**
  String votesCount(int count);

  /// No description provided for @noPollsYet.
  ///
  /// In en, this message translates to:
  /// **'No polls created'**
  String get noPollsYet;

  /// No description provided for @closePoll.
  ///
  /// In en, this message translates to:
  /// **'Close Poll'**
  String get closePoll;

  /// No description provided for @pollClosed.
  ///
  /// In en, this message translates to:
  /// **'Poll Closed'**
  String get pollClosed;

  /// No description provided for @optionLimitError.
  ///
  /// In en, this message translates to:
  /// **'Minimum 2 options required'**
  String get optionLimitError;

  /// No description provided for @allowMultipleSelections.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple selections'**
  String get allowMultipleSelections;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @editPoll.
  ///
  /// In en, this message translates to:
  /// **'Edit Poll'**
  String get editPoll;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deletePoll.
  ///
  /// In en, this message translates to:
  /// **'Delete Poll'**
  String get deletePoll;

  /// No description provided for @confirmDeletePoll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this poll?'**
  String get confirmDeletePoll;

  /// Copyright text in the footer
  ///
  /// In en, this message translates to:
  /// **'© {year} CoCircle. All rights reserved.'**
  String copyrightText(String year);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
