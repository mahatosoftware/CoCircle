// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CoCircle';

  @override
  String get login => 'Login';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email to receive a password reset link.';

  @override
  String get cancel => 'Cancel';

  @override
  String get invalidEmailError => 'Please enter a valid email';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! check your inbox.';

  @override
  String get sendLink => 'Send Link';

  @override
  String get joinCoCircle => 'Join CoCircle';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signUpDescription => 'Create an account to get started';

  @override
  String get signInDescription => 'Sign in to continue';

  @override
  String get name => 'Name';

  @override
  String get enterNameError => 'Please enter name';

  @override
  String get enterEmailError => 'Enter a valid email';

  @override
  String get passwordLengthError => 'Password must be at least 6 chars';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orSeparator => 'OR';

  @override
  String get verificationEmailSent =>
      'Verification email sent! Check your inbox.';

  @override
  String get accountCreatedVerifyEmail =>
      'Account created! Please verify your email before logging in. If you don\'t see it, check your spam folder.';

  @override
  String get resend => 'Resend';

  @override
  String get profile => 'Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get userNotFound => 'User not found';

  @override
  String get displayName => 'Display Name';

  @override
  String get nameEmptyError => 'Name cannot be empty';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get noCircles => 'No circles yet';

  @override
  String get getStarted => 'Get Started';

  @override
  String pendingRequest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pending Requests',
      one: '1 Pending Request',
    );
    return '$_temp0';
  }

  @override
  String get createCircleTitle => 'Create Circle';

  @override
  String get createCircleButton => 'Create Circle';

  @override
  String get joinCircleTitle => 'Join Circle';

  @override
  String get circleName => 'Circle Name';

  @override
  String get enterCircleNameError => 'Please enter a name';

  @override
  String get description => 'Description';

  @override
  String get currency => 'Currency';

  @override
  String get joinCircleDescription =>
      'Enter the 7-character code shared by your admin.';

  @override
  String get circleCode => 'Circle Code';

  @override
  String get circleCodeHint => 'e.g. X7Y2Z9A';

  @override
  String get enterCodeError => 'Please enter code';

  @override
  String get codeTooShortError => 'Code is too short';

  @override
  String get requestToJoinButton => 'Request to Join';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get tripsAndEvents => 'Trips & Events';

  @override
  String get noTripsYet => 'No trips or events yet';

  @override
  String get planATrip => 'Plan a Trip';

  @override
  String get noDateSet => 'No date set';

  @override
  String get circleSettingsTitle => 'Circle Settings';

  @override
  String get renameCircle => 'Rename Circle';

  @override
  String get save => 'Save';

  @override
  String codePrefix(String code) {
    return 'Code: $code';
  }

  @override
  String get shareInviteLink => 'Share Invite Link';

  @override
  String shareInviteMessage(String circleName, String code, String link) {
    return 'Join my circle \"$circleName\" on CoCircle! Use code: $code or click here: $link';
  }

  @override
  String get generateOneTimeLink => 'Generate One-Time Invite Link';

  @override
  String oneTimeInviteMessage(String circleName, String code, String link) {
    return 'Special invite to join \"$circleName\"! Use this one-time link: $link or code: $code';
  }

  @override
  String get activeOneTimeInvites => 'Active One-Time Invites';

  @override
  String pendingRequestsCount(int count) {
    return 'Pending Requests ($count)';
  }

  @override
  String membersCount(int count) {
    return 'Members ($count)';
  }

  @override
  String get adminLabel => 'Admin';

  @override
  String get makeAdmin => 'Make Admin';

  @override
  String get demoteToMember => 'Demote to Member';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirmTitle => 'Remove Member?';

  @override
  String removeMemberConfirmMessage(String name) {
    return 'Are you sure you want to remove $name from this circle?';
  }

  @override
  String get remove => 'Remove';

  @override
  String loadMembersError(String error) {
    return 'Error loading members: $error';
  }

  @override
  String get cannotLeaveCircleTitle => 'Cannot Leave Circle';

  @override
  String get onlyAdminError =>
      'You are the only admin. Please promote another member to admin before leaving.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCircleConfirmTitle => 'Leave Circle?';

  @override
  String get leaveCircleConfirmMessage =>
      'Are you sure you want to leave this circle?';

  @override
  String get leave => 'Leave';

  @override
  String get leaveCircleButton => 'Leave Circle';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get addExpense => 'Add Expense';

  @override
  String totalPaidError(double totalPaid, double amount) {
    return 'Total paid ($totalPaid) must equal expense amount ($amount)';
  }

  @override
  String totalSplitError(double totalSplit, double amount) {
    return 'Split amounts ($totalSplit) must sum to total amount ($amount)';
  }

  @override
  String percentageSumError(double total) {
    return 'Percentages must sum to 100% (Current: $total%)';
  }

  @override
  String loadCircleError(String error) {
    return 'Error loading circle: $error';
  }

  @override
  String loadTripError(String error) {
    return 'Error loading trip: $error';
  }

  @override
  String get expenseTitleLabel => 'What is this for?';

  @override
  String get enterTitleError => 'Enter a title';

  @override
  String get amount => 'Amount';

  @override
  String get enterAmountError => 'Enter amount';

  @override
  String get invalidAmountError => 'Invalid amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get updateExpenseButton => 'Update Expense';

  @override
  String get saveExpenseButton => 'Save Expense';

  @override
  String get paidBy => 'Paid By';

  @override
  String get selectPayers => 'Select Payers';

  @override
  String payersSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payers selected',
      one: '1 payer selected',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Done';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get requiredError => 'Required';

  @override
  String get invalidError => 'Invalid';

  @override
  String get splitTypeExact => 'Exact';

  @override
  String get splitTypePercentage => 'Percentage';

  @override
  String get splitTypeRatio => 'Ratio';

  @override
  String get splitTypeEqual => 'Equal';

  @override
  String get splitBetween => 'Split Between';

  @override
  String get selectParticipants => 'Select Participants';

  @override
  String participantsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants selected',
      one: '1 participant selected',
    );
    return '$_temp0';
  }

  @override
  String get noParticipantsSelected => 'No participants selected.';

  @override
  String get dividedEquallyDescription =>
      'Divided equally among selected participants:';

  @override
  String get percent => 'Percent';

  @override
  String get share => 'Share';

  @override
  String amountLabelWithCurrency(String currency, String amount) {
    return 'Amount: $currency $amount';
  }

  @override
  String get expenseDetailsTitle => 'Expense Details';

  @override
  String splitDetailsWithType(String type) {
    return 'Split Details ($type)';
  }

  @override
  String get notes => 'Notes';

  @override
  String get loadMemberError => 'Error loading member';

  @override
  String get loadSplitDetailsError => 'Error loading split details';

  @override
  String ratioLabel(double value) {
    return 'Ratio: $value';
  }

  @override
  String get exactAmount => 'Exact Amount';

  @override
  String get equalShare => 'Equal Share';

  @override
  String get deleteExpenseTitle => 'Delete Expense';

  @override
  String deleteExpenseConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get noExpensesYet => 'No expenses recorded yet.';

  @override
  String paidBySummary(String payer, String date) {
    return 'Paid by $payer • $date';
  }

  @override
  String get you => 'You';

  @override
  String get member => 'Member';

  @override
  String plusMore(int count) {
    return '+ $count more';
  }

  @override
  String get edit => 'Edit';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get spendingByMember => 'Spending by Member (Who Paid)';

  @override
  String get liabilityTitle => 'Liability (Who Owes what)';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get activeSettlements => 'Active Settlements';

  @override
  String get settlementHistory => 'Settlement History';

  @override
  String calculateSettlementsError(String error) {
    return 'Error calculating settlements: $error';
  }

  @override
  String get allSettledUp => 'All settled up!';

  @override
  String get allSettledUpDescription =>
      'Everyone is even. Any new expenses added will show up here if settlements are needed.';

  @override
  String paysLabel(String from, String to) {
    return '$from pays $to';
  }

  @override
  String get settleUp => 'Settle Up';

  @override
  String settledWithLabel(String from, String to) {
    return '$from settled with $to';
  }

  @override
  String confirmPaidMessage(String currency, double amount, String to) {
    return 'Confirm that you have paid $currency$amount to $to?';
  }

  @override
  String confirmReceivedMessage(String currency, double amount, String from) {
    return 'Confirm that you have received $currency$amount from $from?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get newTripTitle => 'New Trip / Event';

  @override
  String get location => 'Location';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get create => 'Create';

  @override
  String get expenses => 'Expenses';

  @override
  String get settlements => 'Settlements';

  @override
  String get insights => '📊 Insights';

  @override
  String get audit => '🔍 Audit';

  @override
  String get editTripName => 'Edit Trip Name';

  @override
  String get tripName => 'Trip Name';

  @override
  String settlementPlanWithCurrency(String currency) {
    return 'Settlement Plan ($currency)';
  }

  @override
  String copyright(int year) {
    return '© $year CoCircle. All rights reserved.';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get circleRequests => 'Circle Requests';

  @override
  String waitingSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persons waiting',
      one: '1 person waiting',
    );
    return '$_temp0';
  }

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get noAuditHistory => 'No audit history available.';

  @override
  String activityByUser(String name) {
    return 'By $name';
  }

  @override
  String get viewSpecificChanges => 'View Specific Changes';

  @override
  String get auditActionCreate => 'CREATED';

  @override
  String get auditActionUpdate => 'UPDATED';

  @override
  String get auditActionDelete => 'DELETED';

  @override
  String get changeDetailsTitle => 'Change Details';

  @override
  String get specificChanges => 'Specific Changes';

  @override
  String get noSpecificChanges =>
      'No specific field changes recorded for this action.';

  @override
  String get fromLabel => 'FROM';

  @override
  String get toLabel => 'TO';

  @override
  String get noneValue => 'None';

  @override
  String get newTripEvent => 'New Trip / Event';

  @override
  String get nameLabel => 'Name';

  @override
  String get typeLabel => 'Type';

  @override
  String get locationLabel => 'Location';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get createButton => 'Create';

  @override
  String get expensesTab => 'Expenses';

  @override
  String get settlementsTab => 'Settlements';

  @override
  String get insightsTab => 'Insights';

  @override
  String get auditTab => 'Audit';

  @override
  String get tripNameLabel => 'Trip Name';

  @override
  String settlementPlanTitle(String currency) {
    return 'Settlement Plan ($currency)';
  }

  @override
  String get finance => 'Finance';

  @override
  String get overview => 'Overview';

  @override
  String get polls => 'Polls';

  @override
  String get expense => 'Expense';

  @override
  String get settlement => 'Settlement';

  @override
  String get createPoll => 'Create Poll';

  @override
  String get pollQuestion => 'Question';

  @override
  String get enterQuestionError => 'Please enter a question';

  @override
  String get pollOptions => 'Options';

  @override
  String get addOption => 'Add Option';

  @override
  String get createPollButton => 'Create Poll';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
      zero: 'No votes',
    );
    return '$_temp0';
  }

  @override
  String get noPollsYet => 'No polls created';

  @override
  String get closePoll => 'Close Poll';

  @override
  String get pollClosed => 'Poll Closed';

  @override
  String get optionLimitError => 'Minimum 2 options required';

  @override
  String get allowMultipleSelections => 'Allow multiple selections';

  @override
  String get viewResults => 'View Results';

  @override
  String get editPoll => 'Edit Poll';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deletePoll => 'Delete Poll';

  @override
  String get confirmDeletePoll => 'Are you sure you want to delete this poll?';

  @override
  String copyrightText(String year) {
    return '© $year CoCircle. All rights reserved.';
  }
}
