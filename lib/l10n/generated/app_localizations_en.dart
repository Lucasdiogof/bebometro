// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountAllConfirmed => 'Everything confirmed in the cloud';

  @override
  String get accountAllSentNow => 'Everything uploaded. You can sign out now.';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountCloud => 'Cloud';

  @override
  String get accountCodeField => 'Code received by e-mail';

  @override
  String get accountCodeSent => 'We sent a code to your e-mail.';

  @override
  String accountConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes to resolve',
      one: '1 change to resolve',
    );
    return '$_temp0';
  }

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountEditName => 'Edit name';

  @override
  String get accountEmailConfirmed => 'E-mail confirmed';

  @override
  String get accountEmailNotConfirmed => 'E-mail not confirmed';

  @override
  String get accountHistoryNotDone =>
      'The cloud history hasn\'t finished arriving on this device.';

  @override
  String accountLastSync(String when) {
    return 'Last completed sync: $when';
  }

  @override
  String get accountLastSyncNever => 'Last completed sync: not yet.';

  @override
  String get accountName => 'Name';

  @override
  String get accountNameUpdated => 'Name updated';

  @override
  String get accountNoName => 'No name';

  @override
  String get accountNothingWaiting => 'Nothing waiting to upload.';

  @override
  String accountOnlyHerePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Also $count photos waiting to upload.',
      one: 'Also 1 photo waiting to upload.',
    );
    return '$_temp0';
  }

  @override
  String accountOnlyHereRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved only on this device for now: $count records.',
      one: 'Saved only on this device for now: 1 record.',
    );
    return '$_temp0';
  }

  @override
  String get accountPasswordChanged => 'Password changed';

  @override
  String get accountResendCode => 'Send the code again';

  @override
  String get accountRestoring => 'Restoring…';

  @override
  String get accountSaveNewPassword => 'Save new password';

  @override
  String get accountSession => 'Session';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutClean =>
      'Your data is in the cloud and comes back when you sign in again. On this device it stays saved only for this account.';

  @override
  String accountSignOutConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'There are also $count changes to resolve.',
      one: 'There is also 1 change to resolve.',
    );
    return '$_temp0';
  }

  @override
  String accountSignOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes haven\'t been uploaded yet.',
      one: '1 change hasn\'t been uploaded yet.',
    );
    return '$_temp0 They stay on this device, tied to this account, and only come back when you sign in to it again.';
  }

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountStillPending =>
      'Some items are still pending: they stay saved on this device.';

  @override
  String get accountSyncFirst => 'Sync first';

  @override
  String get accountYourData => 'Your data';

  @override
  String get accountYourName => 'Your name';

  @override
  String get appName => 'Bebômetro';

  @override
  String get authCancelAndLeave => 'Cancel and sign out';

  @override
  String get authCheckEmail => 'Check the e-mail you typed.';

  @override
  String get authCloudDown =>
      'Couldn\'t reach the server right now. Check the internet and try again in a moment.';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authDifferentAccount =>
      'This is a different account from the current session.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authEmailExists =>
      'An account with this e-mail already exists. Sign in or recover the password.';

  @override
  String get authEmailNotConfirmed =>
      'Confirm your e-mail before signing in. Look for the link in your inbox (and spam).';

  @override
  String get authEnterEmail => 'Enter your e-mail.';

  @override
  String get authEnterPassword => 'Enter your password.';

  @override
  String get authForgot => 'I forgot my password';

  @override
  String get authGenericError => 'Couldn\'t finish right now. Try again.';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authLinkInvalid =>
      'This link has expired or was already used. Ask for another one and open it on this device. If you confirmed your e-mail on another device, just sign in with e-mail and password.';

  @override
  String get authNameMissing => 'What should we call you?';

  @override
  String get authNeedsCode =>
      'For security, confirm with the code sent to your e-mail.';

  @override
  String get authNewPassword => 'New password';

  @override
  String authNewPasswordFor(String email) {
    return 'Create a new password for $email.';
  }

  @override
  String get authNewPasswordTitle => 'New password';

  @override
  String get authNoConnection =>
      'No connection. Check the internet and try again.';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHelper => 'At least 8 characters.';

  @override
  String get authPasswordMin => 'Use at least 8 characters.';

  @override
  String get authPasswordMix => 'Mix letters and numbers.';

  @override
  String get authPasswordsDiffer => 'The passwords don\'t match.';

  @override
  String get authCodeTitle => 'Enter the code';

  @override
  String authCodeBody(String email) {
    return 'We sent a 6-digit code to $email. Enter it below; it is valid for a short time.';
  }

  @override
  String get authCodeLabel => '6-digit code';

  @override
  String get authCodeVerify => 'Confirm code';

  @override
  String get authCodeInvalid =>
      'Invalid or expired code. Check the 6 digits or ask for a new code.';

  @override
  String get authCodeIncomplete => 'Enter the 6 digits of the code.';

  @override
  String get authHaveCode => 'I already have a code';

  @override
  String get authRecoverBody =>
      'We\'ll send a 6-digit code to your e-mail. You type it here in the app, on any device.';

  @override
  String get authRecoverSent =>
      'If there is an account with this e-mail, the code arrives in a moment. Check the spam folder too.';

  @override
  String get authRecoverTitle => 'Recover password';

  @override
  String get authResend => 'Resend e-mail';

  @override
  String authResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String authResendWait(int seconds) {
    return 'Wait $seconds s to ask for another e-mail.';
  }

  @override
  String get authSamePassword =>
      'The new password must be different from the current one.';

  @override
  String get authSavePassword => 'Save password';

  @override
  String get authSendLink => 'Send code';

  @override
  String get authServerUnreachable =>
      'Can\'t reach the server right now. Try again in a moment.';

  @override
  String get authSessionEnded => 'Your session ended. Sign in again.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInAgainBody =>
      'Your session ended on the server. Your records are still on this device and come back when you sign in to the same account.';

  @override
  String get authSignInAgainTitle => 'Sign in again';

  @override
  String get authSignInAgainToContinue => 'Sign in again to continue.';

  @override
  String get authSignInBody =>
      'Your outings are saved in your account and come back on any device.';

  @override
  String get authSignUpNote =>
      'Your name and e-mail are only used for your account. You sign in right away, with no e-mail confirmation.';

  @override
  String get authSignupDisabled =>
      'Sign-up is turned off on the server right now.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authTooManyShort => 'Too many attempts. Wait a few minutes.';

  @override
  String get authWeakPassword => 'Weak password. Use at least 8 characters.';

  @override
  String get authWrongCredentials => 'Wrong e-mail or password.';

  @override
  String get authYourAccount => 'your account';

  @override
  String get budgetDialogTitle => 'Drinks budget';

  @override
  String get budgetEdit => 'Edit budget';

  @override
  String budgetLeft(String amount) {
    return '$amount of the budget left.';
  }

  @override
  String budgetLeftIncomplete(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Based on entered spending, $amount of the budget is left (partial: $count drinks have no price).',
      one:
          'Based on entered spending, $amount of the budget is left (partial: 1 drink has no price).',
    );
    return '$_temp0';
  }

  @override
  String budgetLine(String budget, String spent) {
    return 'Budget $budget · entered spending $spent';
  }

  @override
  String get budgetMustBePositive => 'Enter an amount greater than zero';

  @override
  String get budgetOptionalNote =>
      'Optional. It only compares with the spending entered on your own drinks; what the table spends stays in the bill.';

  @override
  String budgetOver(String amount) {
    return '$amount over budget.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'The entered spending is already $amount over budget and some prices are still missing.';
  }

  @override
  String budgetReached(int percent, String spent, String budget) {
    return 'Entered spending reached $percent% of the budget ($spent of $budget).';
  }

  @override
  String get budgetReachedIncomplete =>
      'Some drinks have no price: the real total may be higher.';

  @override
  String get budgetSet => 'Set budget';

  @override
  String get budgetValue => 'Amount';

  @override
  String get commonAdjust => 'Adjust';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonLater => 'Later';

  @override
  String get commonMoreOptions => 'More options';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonOptional => '(optional)';

  @override
  String get commonOptions => 'Options';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonUndo => 'Undo';

  @override
  String get conflictAcceptDeletion => 'Accept the deletion';

  @override
  String get conflictApplyFailed => 'Couldn\'t apply. Nothing was lost.';

  @override
  String get conflictCloud => 'In the cloud';

  @override
  String get conflictCloudDeleted => 'In the cloud (deleted)';

  @override
  String get conflictCustomDrink => 'Personal drink changed on two devices';

  @override
  String get conflictDeletionAccepted => 'Deletion accepted';

  @override
  String get conflictDrink => 'Drink edited on two devices';

  @override
  String conflictEditedAt(String when) {
    return 'Edited $when';
  }

  @override
  String conflictEnd(String when) {
    return 'End: $when';
  }

  @override
  String get conflictEndHere => 'Finish this device\'s outing';

  @override
  String get conflictEndOther => 'Finish the other device\'s outing';

  @override
  String get conflictFromHere => 'From this device';

  @override
  String get conflictFromOther => 'From the other device';

  @override
  String get conflictHere => 'On this device';

  @override
  String get conflictIntro =>
      'These changes were made on more than one device at the same time. Choose which version counts. The other is discarded only when you choose.';

  @override
  String get conflictItem => 'Item changed on two devices';

  @override
  String get conflictKeepLocal => 'Keep this device\'s';

  @override
  String get conflictKeptLocal => 'Kept this device\'s version';

  @override
  String get conflictNone => 'Nothing to resolve. All good.';

  @override
  String get conflictOuting => 'Outing changed on two devices';

  @override
  String get conflictOutingEnded => 'Outing finished';

  @override
  String conflictOutingLine(String label, String name) {
    return '$label: $name';
  }

  @override
  String conflictPaid(String amount) {
    return 'Paid: $amount';
  }

  @override
  String get conflictPlace => 'Place changed on two devices';

  @override
  String get conflictRemoteUnreadable =>
      'Couldn\'t read the cloud version right now. You can keep this device\'s version or try later.';

  @override
  String get conflictRestore => 'Restore with this device\'s version';

  @override
  String get conflictRestored => 'Restored with your version';

  @override
  String conflictSince(String when) {
    return 'since $when';
  }

  @override
  String conflictStart(String when) {
    return 'Start: $when';
  }

  @override
  String get conflictTab => 'Tab changed on two devices';

  @override
  String conflictTabPayments(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments recorded: $amount',
      one: '1 payment recorded: $amount',
      zero: 'No payments recorded',
    );
    return '$_temp0';
  }

  @override
  String conflictTabPeople(int people, int extras) {
    String _temp0 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people participants',
      one: '1 participant',
    );
    String _temp1 = intl.Intl.pluralLogic(
      extras,
      locale: localeName,
      other: '$extras extra items',
      one: '1 extra item',
      zero: 'no extra items',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get conflictTitle => 'Changes to resolve';

  @override
  String get conflictTwoActiveBody =>
      'One was started on this device and another on a different device, offline. Both were kept with their drinks. Choose which one to finish now.';

  @override
  String get conflictUseRemote => 'Use the cloud one';

  @override
  String get conflictUsedRemote => 'Used the cloud version';

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get deleteBody =>
      'This permanently deletes your account, all outings, drinks, places, tabs and photos stored in the cloud, and this account\'s data on this device. It can\'t be undone.';

  @override
  String get deleteConfirmPassword => 'Confirm your password.';

  @override
  String get deleteConfirmPasswordAgain => 'Confirm your password again.';

  @override
  String get deleteExportFirst =>
      'If you want to keep a copy, export your data first (Settings > Export my data).';

  @override
  String get deleteOffline => 'No connection. Nothing was deleted.';

  @override
  String get deletePartial =>
      'The deletion started but didn\'t finish. Nothing on this device was deleted. Tap \"Delete account\" again to continue.';

  @override
  String get deleteTickFirst => 'Tick the confirmation to continue.';

  @override
  String get deleteUnavailable =>
      'Deletion isn\'t available on the server yet. Nothing was deleted. Try later.';

  @override
  String get deleteUnderstand => 'I understand that deletion is permanent.';

  @override
  String get deleteYourPassword => 'Your password';

  @override
  String drinkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks',
      one: '1 drink',
    );
    return '$_temp0';
  }

  @override
  String get drinkFallbackName => 'Drink';

  @override
  String get drinkShared => 'shared';

  @override
  String get drinkWater => 'Water';

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get entryCorrect => 'Correct';

  @override
  String get entryRepeat => 'Repeat';

  @override
  String get entryOptions => 'Record options';

  @override
  String get feedbackDontAsk => 'Don\'t ask';

  @override
  String get feedbackFreeNote => 'Free note';

  @override
  String get feedbackFreeNoteHint =>
      'Something you want to remember about this outing';

  @override
  String get feedbackHangover => 'Hangover';

  @override
  String get feedbackHowItWent => 'How it went';

  @override
  String get feedbackNote =>
      'It\'s just your account of how the night went. It doesn\'t measure anything or say how much is safe to drink.';

  @override
  String get feedbackOptional =>
      'All optional. It\'s just a personal note, no score and no comparison.';

  @override
  String get feedbackReviewForgotten => 'Review forgotten drinks';

  @override
  String get feedbackSave => 'Save account';

  @override
  String get feedbackTellMore => 'Want to tell more?';

  @override
  String get feedbackTitle => 'How was the last outing?';

  @override
  String get feedbackWake => 'How you woke up';

  @override
  String get feedbackYourAccount => 'Your account';

  @override
  String get fileGenerationFailed => 'Couldn\'t create the file.';

  @override
  String financeInformed(String amount) {
    return '$amount entered';
  }

  @override
  String get financeNoRecords => 'No records yet';

  @override
  String get financeNoValue => 'No amount entered';

  @override
  String financeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks without a price',
      one: '1 drink without a price',
    );
    return '$_temp0';
  }

  @override
  String get finishAndSummary => 'Finish and see summary';

  @override
  String finishBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records.',
      one: '1 record.',
      zero: 'No records.',
    );
    return '$_temp0 You can still correct records later from the history.';
  }

  @override
  String finishEnd(String when) {
    return 'End: $when';
  }

  @override
  String get finishKeepGoing => 'Keep the outing going';

  @override
  String get finishTitle => 'Finish outing?';

  @override
  String get glassTipPlay => 'Play tipping the glass';

  @override
  String groupTimes(int count) {
    return '$count×';
  }

  @override
  String get hangoverMild => 'Mild';

  @override
  String get hangoverModerate => 'Moderate';

  @override
  String get hangoverNone => 'None';

  @override
  String get hangoverStrong => 'Strong';

  @override
  String get homeContinueOuting => 'Continue outing';

  @override
  String get homeFirstBody =>
      'When you finish an outing, the month\'s summary shows up here, only with what you logged.';

  @override
  String get homeFirstTitle => 'Your first outing starts here';

  @override
  String get homeIdleBody => 'Note what you drank and what you spent, no fuss.';

  @override
  String get homeIdleTitle => 'Heading out?';

  @override
  String get homeInformedSpent => 'Your reported spend';

  @override
  String get homeLastOuting => 'Last outing';

  @override
  String get homeNoneThisMonth => 'No outing finished this month yet.';

  @override
  String get homeOutingRunning => 'Outing in progress';

  @override
  String get homeOutings => 'Outings';

  @override
  String get homeSpent => 'Your spend';

  @override
  String get homeStartOuting => 'Start outing';

  @override
  String get homeThisMonth => 'This month';

  @override
  String get homeTime => 'Time';

  @override
  String homeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count without price',
      one: '1 without price',
    );
    return '$_temp0';
  }

  @override
  String get itemFallbackName => 'Item';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get languageMoneyNote =>
      'Amounts stay in Brazilian reais (R\$) in every language.';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageSystemHint =>
      'Portuguese, English or Spanish as on the device; other languages use Portuguese.';

  @override
  String get legacyTwoActiveTitle => 'Two outings in progress';

  @override
  String get moneyFieldHelper =>
      'Amounts in Brazilian reais (R\$). E.g. 15 or 15.50.';

  @override
  String get moodCheerful => 'Cheerful';

  @override
  String get moodDrunk => 'Drunk';

  @override
  String get moodSmooth => 'Mellow';

  @override
  String get moodWasted => 'Wasted';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navGames => 'Games';

  @override
  String get navHistory => 'History';

  @override
  String get navHome => 'Home';

  @override
  String noticeAnotherOne(String name) {
    return 'One more: $name';
  }

  @override
  String get noticeEntryDeleted => 'Record deleted';

  @override
  String get noticeWater => 'Water logged';

  @override
  String get numberAmbiguous =>
      'Ambiguous format. Use a comma or dot only before cents (e.g. 1500 or 15.50).';

  @override
  String get numberInvalid => 'Invalid number.';

  @override
  String get outingAddDrink => 'Add drink';

  @override
  String get outingAlreadyEnded => 'This outing has already finished.';

  @override
  String outingConfirmAnother(String drink) {
    return 'Log one more: $drink?';
  }

  @override
  String get outingConfirmWater => 'Log a glass of water?';

  @override
  String get outingDrinkLogged => 'Drink logged';

  @override
  String get outingEntryUpdated => 'Record updated';

  @override
  String get outingFallbackName => 'Outing';

  @override
  String get outingFinish => 'Finish outing';

  @override
  String get outingFirstDrinkHint =>
      'Log the first drink and the \"One more\" button appears down here.';

  @override
  String get outingHideHere => 'Hide for this outing';

  @override
  String get outingInProgress => 'In progress';

  @override
  String get outingLockScreenRequest => 'Request from the lock screen';

  @override
  String get outingLog => 'Log';

  @override
  String get outingNoDrinks => 'No drinks yet';

  @override
  String get outingNoDrinksBody =>
      'Log the first one and the \"One more\" button appears down here.';

  @override
  String get outingNotFound => 'This outing wasn\'t found.';

  @override
  String get trackingOutingGone =>
      'This outing no longer exists on this device.';

  @override
  String get outingNothingToRepeat =>
      'There is no drink to repeat in this outing.';

  @override
  String get outingOpenScan =>
      'There is an open label or menu reading. It stays tied to this outing and shows up in its summary.';

  @override
  String outingRecords(int count) {
    return 'Records ($count)';
  }

  @override
  String get outingRunningFor => 'Going for';

  @override
  String get outingShowOnLock => 'Show on the lock screen';

  @override
  String get outingTrackingBack => 'Lock-screen tracking is back.';

  @override
  String get outingTrackingHidden =>
      'Hidden from the lock screen for this outing.';

  @override
  String get outingTypeBar => 'Bar';

  @override
  String get outingTypeBarbecue => 'Barbecue';

  @override
  String get outingTypeBeach => 'Beach';

  @override
  String get outingTypeClub => 'Club';

  @override
  String get outingTypeHome => 'Home';

  @override
  String get outingTypeOther => 'Other';

  @override
  String get outingTypeRestaurant => 'Restaurant';

  @override
  String outingTypeSince(String type, String time) {
    return '$type · since $time';
  }

  @override
  String get placeCorrect => 'Correct place';

  @override
  String get placeOpenInMaps => 'Open in maps';

  @override
  String get priceComplimentary => 'On the house';

  @override
  String get priceNone => 'No price';

  @override
  String get priceUnknown => 'no price';

  @override
  String get repeatButton => 'One more';

  @override
  String repeatSemantics(String drink) {
    return 'One more: $drink';
  }

  @override
  String get repoAbvRange => 'ABV goes from 0 to 100%.';

  @override
  String get repoActiveExists => 'There is already an outing in progress.';

  @override
  String repoCopyName(String name) {
    return '$name (copy)';
  }

  @override
  String get repoDrinkName => 'Give the drink a name.';

  @override
  String get repoDrinkVolume => 'Enter the volume in ml.';

  @override
  String get repoEndBeforeStart => 'The end can\'t be before the start.';

  @override
  String get repoEndFuture => 'The end can\'t be in the future.';

  @override
  String get repoNicknameOrAddress => 'Enter a nickname or an address.';

  @override
  String get repoPlaceMissing =>
      'Enter a nickname or an address for the place.';

  @override
  String get repoPointNeedsName => 'Give this point a nickname to save it.';

  @override
  String get repoRecipeIngredient => 'Add at least one ingredient.';

  @override
  String get repoRecipeName => 'Give the recipe a name.';

  @override
  String get repoStateFormat => 'The state code has 2 letters (e.g. SP).';

  @override
  String get settingsAccount => 'My account';

  @override
  String get settingsBudget => 'Budget';

  @override
  String get settingsBudgetAlerts => 'Budget alerts';

  @override
  String get settingsBudgetAlertsHint =>
      'One alert at 80% and at 100% of the outing budget, once per level.';

  @override
  String get settingsDrinkRecords => 'Drink records';

  @override
  String get settingsExport => 'Export my data';

  @override
  String get settingsLanguage => 'Language';

  @override
  String settingsLastSync(String when) {
    return 'Last sync: $when';
  }

  @override
  String get settingsLastSyncNever => 'Last sync: not yet.';

  @override
  String get settingsLocalRisk =>
      'Meanwhile, if you uninstall the app or clear the browser data, what is only on this device will be lost.';

  @override
  String get settingsLockScreen => 'Outing on the lock screen';

  @override
  String get settingsMyDrinks => 'My drinks';

  @override
  String get settingsMyDrinksAndRecipes => 'My drinks and recipes';

  @override
  String get settingsNotYetInCloud =>
      'Some data hasn\'t reached the cloud yet.';

  @override
  String get settingsOutingsHere => 'Outings on this device';

  @override
  String settingsPendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to upload.',
      one: '1 change waiting to upload.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavedPlaces => 'Saved places';

  @override
  String get settingsStorage => 'STORAGE';

  @override
  String get settingsSync => 'SYNC';

  @override
  String get settingsSyncDone => 'Everything is synced.';

  @override
  String settingsSyncDoneConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uploaded, but $count changes need resolving in My account.',
      one: 'Uploaded, but 1 change needs resolving in My account.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncFailed => 'Couldn\'t sync right now.';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncState => 'Status';

  @override
  String settingsSyncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes still to upload.',
      one: '1 change still to upload.',
    );
    return '$_temp0';
  }

  @override
  String get settingsTable => 'Outing table';

  @override
  String get settingsTableAnimations => 'Table animations';

  @override
  String get settingsTableAnimationsHint =>
      'Containers empty as an illustration. When off, the table stays still.';

  @override
  String get settingsTableDefault => 'Show the table by default';

  @override
  String get settingsTableDefaultHint =>
      'On the outing screen, the illustrated table opens before the list.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get shareUnavailableCopied =>
      'Sharing isn\'t available here. The content was copied: paste it into a file to keep it.';

  @override
  String get shellBackToOuting => 'Back to outing';

  @override
  String shellOutingRunning(String name) {
    return 'Outing in progress · $name';
  }

  @override
  String staleBody(String name, String start, String duration) {
    return '$name started $start and has been open for $duration.';
  }

  @override
  String get staleEndOtherTime => 'Finish at another time';

  @override
  String get staleNote =>
      'When finishing you choose the end time. Nothing is finished automatically.';

  @override
  String get staleTitle => 'Is this outing still going on?';

  @override
  String get startFailed => 'Couldn\'t start the outing. Try again.';

  @override
  String get startFuture => 'The start can\'t be in the future.';

  @override
  String get startPlaceError =>
      'Enter a nickname (e.g. Samara\'s place) or an address';

  @override
  String get stateTwoLetters => 'The state code has 2 letters';

  @override
  String get summaryAccountNote =>
      'Personal account: it doesn\'t measure anything or set a drinking limit.';

  @override
  String get summaryAddAccount => 'Add account';

  @override
  String get summaryAddForgotten => 'Add a forgotten drink';

  @override
  String get summaryConsumption => 'Consumption';

  @override
  String get summaryDone => 'Done';

  @override
  String get summaryDuration => 'Duration';

  @override
  String get summaryEditAccount => 'Edit account';

  @override
  String get summaryEnd => 'End';

  @override
  String get summaryFillPrices => 'Fill in missing prices';

  @override
  String summaryHangover(String level) {
    return 'Hangover: $level';
  }

  @override
  String get summaryNoAccount => 'No account yet.';

  @override
  String get summaryNoRecords => 'No records in this outing';

  @override
  String get summaryRetro =>
      'Illustrative replay of the records. The real numbers are below.';

  @override
  String get summaryShare => 'Share summary';

  @override
  String get summarySpending => 'Spending';

  @override
  String get summarySpentOnDrinks => 'Your spending logged on drinks';

  @override
  String get summaryStart => 'Start';

  @override
  String get summaryTab => 'Tab';

  @override
  String get summaryTapToCorrect =>
      'Tap a record to correct it; the summary is recalculated.';

  @override
  String get summaryTitle => 'Outing summary';

  @override
  String summaryUnpricedPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks without a price: the total may be higher',
      one: '1 drink without a price: the total may be higher',
    );
    return '$_temp0';
  }

  @override
  String get summaryUpdated => 'Record updated, summary recalculated';

  @override
  String summaryWoke(String feeling) {
    return 'Woke up: $feeling';
  }

  @override
  String get summaryYourAccount => 'Your account';

  @override
  String get summaryYourAccountTag => 'your account';

  @override
  String syncLabelConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to resolve',
      one: '1 to resolve',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelFailed => 'Sync failed';

  @override
  String get syncLabelLocalOnly => 'Only on this device';

  @override
  String syncLabelPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting to upload',
      one: '1 waiting to upload',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelSynced => 'Synced';

  @override
  String get syncLabelSyncing => 'Syncing…';

  @override
  String get syncNoticeActiveConflict =>
      'The server already has another outing in progress. Nothing was deleted: the data is still saved on the device.';

  @override
  String get syncNoticeLocalOnly =>
      'The cloud isn\'t available yet. Your records are saved only on this device and will be uploaded when possible.';

  @override
  String get syncNoticeOffline => 'No connection. We\'ll try again.';

  @override
  String get syncNoticePhotos =>
      'Some photos haven\'t been uploaded yet. They\'re still saved on the device and the upload will be retried.';

  @override
  String get syncNoticePlaceLink =>
      'The server didn\'t accept linking an outing to its saved place. Nothing was changed: the data is still saved on the device.';

  @override
  String get syncNoticeRejected =>
      'The server refused some changes. Your data is still saved on the device.';

  @override
  String get syncNoticeSchemaGap =>
      'Some new data is waiting for a server update. The rest was uploaded and nothing was lost.';

  @override
  String get syncNoticeSignInAgain =>
      'Sign in to your account again to upload and receive data. Everything is still saved on this device.';

  @override
  String get syncNoticeWaitingPlace =>
      'Some outings are waiting for their saved place to upload. Nothing was lost.';

  @override
  String get tableAboutMenu => 'Illustrative animation of the logged drinks';

  @override
  String get tableChangeScene => 'Change scene';

  @override
  String get tableOptions => 'Table options';

  @override
  String get tableViewList => 'List';

  @override
  String get tableViewTable => 'Table';

  @override
  String unitGrams(String value) {
    return '$value g';
  }

  @override
  String unitMl(String value) {
    return '$value ml';
  }

  @override
  String get wakeBad => 'Bad';

  @override
  String get wakeGreat => 'Good';

  @override
  String get wakeOk => 'Okay';

  @override
  String get wakeTired => 'Tired';

  @override
  String get startTitle => 'Start outing';

  @override
  String get startWhatKind => 'What kind of outing?';

  @override
  String get startWhere => 'Where?';

  @override
  String get startSearchPlace => 'Search for a bar or address';

  @override
  String get startSearchPlaceHint =>
      'Or use your location and check it on the map';

  @override
  String get startSavedPlaces => 'Saved places';

  @override
  String get startOrNickname => 'Or just a nickname';

  @override
  String get startNicknameLabel => 'Place nickname';

  @override
  String get startNicknameHint => 'E.g. Joe\'s Bar, Sam\'s place';

  @override
  String get startAddAddress => 'Type an address (optional)';

  @override
  String get startAddressLabel => 'Address (optional)';

  @override
  String get startAddressHint => 'Street, number, neighborhood';

  @override
  String get startAddressHelper => 'A nickname or an address is enough.';

  @override
  String get startCityLabel => 'City (optional)';

  @override
  String get startStateLabel => 'State';

  @override
  String get startSavePlace => 'Save this place';

  @override
  String get startSavePlaceHint =>
      'To pick it again in future outings. It stays private on your profile.';

  @override
  String get startWhen => 'When did it start?';

  @override
  String get startBudgetSection => 'Budget (optional)';

  @override
  String get startBudgetLabel => 'Drinks budget';

  @override
  String get startBudgetHelper =>
      'You can set or change it later, during the outing. Amounts in Brazilian reais (R\$).';

  @override
  String get startBegin => 'Start the outing';

  @override
  String get startWillSavePlace => 'It will be saved to your places';

  @override
  String get startChangePlace => 'Change';

  @override
  String priceFixApplyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Apply to $count records?',
      one: 'Apply to 1 record?',
    );
    return '$_temp0';
  }

  @override
  String priceFixReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already had a price and will be replaced.',
      one: '1 already had a price and will be replaced.',
    );
    return '$_temp0';
  }

  @override
  String get priceFixYourShare => 'your share';

  @override
  String get priceFixUpdated => 'Prices updated';

  @override
  String get priceFixPaidLabel => 'Price paid';

  @override
  String get priceFixPaidShared => 'How much you paid';

  @override
  String get priceFixSharedNote =>
      'Shared drink: enter your share, not the bottle price. Consumption does not change.';

  @override
  String get priceFixEnterValue => 'Enter an amount';

  @override
  String get priceFixTitle => 'Missing prices';

  @override
  String get priceFixNoneTitle => 'No missing prices';

  @override
  String get priceFixNoneBody =>
      'Every record of this outing has a price or a complimentary mark.';

  @override
  String get priceFixIntro =>
      'Fill them in one by one, or pick several equal records and apply the same price after seeing the preview. Prices already entered do not change unless you include and select them on purpose.';

  @override
  String get priceFixIncludePriced =>
      'Also include records that already have a price';

  @override
  String get priceFixForSelected => 'Price for the selected';

  @override
  String get priceFixSharedHint =>
      'For a shared drink, what counts is what you paid (your share), never the bottle price.';

  @override
  String priceFixSelectAll(String count) {
    return 'Select all $count';
  }

  @override
  String get priceFixClear => 'Clear';

  @override
  String priceFixCurrent(String price) {
    return 'Current price: $price';
  }

  @override
  String get priceFixOnlyThis => 'Set only this price';

  @override
  String get priceFixSelectRecords => 'Select records';

  @override
  String priceFixPreview(String count) {
    return 'Preview ($count)';
  }

  @override
  String get originGeneric => 'Generic';

  @override
  String get originUser => 'Created by you';

  @override
  String get originVerified => 'Manufacturer data';

  @override
  String get originMixed => 'Manufacturer + label (secondary source)';

  @override
  String get originSecondary => 'Label from a secondary source';

  @override
  String get originRecipe => 'Reference recipe';

  @override
  String get kindCan => 'Can';

  @override
  String get kindLongNeck => 'Long neck';

  @override
  String get kindBottle => 'Bottle';

  @override
  String get kindGlass => 'Glass';

  @override
  String get kindShot => 'Shot';

  @override
  String get presCan => 'Can';

  @override
  String get presBottle => 'Bottle';

  @override
  String get presGlass => 'Glass';

  @override
  String get presMug => 'Mug';

  @override
  String get presTulip => 'Tulip glass';

  @override
  String get presWineGlass => 'Wine glass';

  @override
  String get presShot => 'Shot';

  @override
  String get presDoubleShot => 'Double shot';

  @override
  String unitLiters(String value) {
    return '$value L';
  }

  @override
  String get abvVaries => 'ABV varies';

  @override
  String get categoryBeer => 'Beer';

  @override
  String get categoryDraft => 'Draft beer';

  @override
  String get categoryCocktail => 'Cocktail';

  @override
  String get categorySpirit => 'Spirit/shot';

  @override
  String get categoryReadyToDrink => 'Ready-to-drink';

  @override
  String get categoryWine => 'Wine';

  @override
  String get categoryNonAlcoholic => 'Non-alcoholic';

  @override
  String get categoryWater => 'Water';

  @override
  String get abvSourceLabel => 'Label (photo), checked by you';

  @override
  String get abvSourceMenu => 'Menu (photo), checked by you';

  @override
  String get abvSourceTyped => 'Entered by you';

  @override
  String get abvSourceCatalog => 'Copied from the catalog';

  @override
  String get styleLagerPilsen => 'Lager/Pilsner';

  @override
  String get styleDark => 'Dark';

  @override
  String get styleWhiteRum => 'White rum';

  @override
  String get styleAperitif => 'Aperitif';

  @override
  String get styleBitterAperitif => 'Bitter aperitif';

  @override
  String get styleSweetVermouth => 'Sweet vermouth';

  @override
  String get styleDryVermouth => 'Dry vermouth';

  @override
  String get styleAgaveTequila => '100% agave tequila';

  @override
  String get roleCachaca => 'Cachaça';

  @override
  String get roleVodka => 'Vodka';

  @override
  String get roleGin => 'Gin';

  @override
  String get roleRum => 'Rum';

  @override
  String get roleTequila => 'Tequila';

  @override
  String get roleWhisky => 'Whisky';

  @override
  String get roleOrangeLiqueur => 'Orange liqueur';

  @override
  String get roleCampari => 'Campari';

  @override
  String get roleAperol => 'Aperol';

  @override
  String get roleSweetVermouth => 'Sweet vermouth';

  @override
  String get roleDryVermouth => 'Dry vermouth';

  @override
  String get roleSparklingWine => 'Sparkling wine';

  @override
  String get roleBitters => 'Bitters';

  @override
  String get recipeUnitMl => 'ml (milliliters)';

  @override
  String get recipeUnitG => 'g (grams)';

  @override
  String get recipeUnitUnit => 'unit';

  @override
  String get recipeUnitTsp => 'teaspoon';

  @override
  String get recipeUnitTbsp => 'tablespoon';

  @override
  String get recipeUnitLeaf => 'leaf';

  @override
  String get recipeUnitDrop => 'drop';

  @override
  String get recipeUnitToTaste => 'to taste';

  @override
  String get recipeUnitOther => 'recipe wording';

  @override
  String get recipeShortUnit => 'unit';

  @override
  String get recipeShortTsp => 'tsp';

  @override
  String get recipeShortTbsp => 'tbsp';

  @override
  String get recipeShortLeaf => 'leaf/leaves';

  @override
  String get recipeShortDrop => 'drop(s)';

  @override
  String get recipeAmountUnknown => 'amount not given';

  @override
  String get recipeGapAbv => 'unknown ABV';

  @override
  String get recipeGapNotMl => 'amount is not in ml';

  @override
  String get recipeGapAmount => 'unknown amount';

  @override
  String get addDrinkTitle => 'Add drink';

  @override
  String get catalogMyDrinksTooltip => 'My drinks and recipes';

  @override
  String get catalogSearchHint => 'Search brand, product or style';

  @override
  String get catalogMoreFilters => 'More filters';

  @override
  String get catalogAll => 'All';

  @override
  String get catalogScanLabel => 'Scan label';

  @override
  String get catalogScanMenu => 'Scan menu';

  @override
  String get catalogCreate => 'Create a drink';

  @override
  String get catalogCreateOuting => 'Create a drink for this outing';

  @override
  String get catalogNeedOutingTitle => 'You need an outing in progress';

  @override
  String get catalogNeedOutingBody =>
      'Drinks read from a label or menu are kept in the outing where they were created. Start one now?';

  @override
  String get catalogSavedToOuting => 'Saved in \"Drinks of this outing\"';

  @override
  String catalogMenuSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in \"Drinks of this outing\". Pick one to log.',
      one: '1 item in \"Drinks of this outing\". Pick one to log.',
    );
    return '$_temp0';
  }

  @override
  String get catalogDrinkSaved => 'Drink saved in My drinks';

  @override
  String get catalogDeleteTitle => 'Delete this drink?';

  @override
  String get catalogDeleteBody =>
      'It leaves the catalog. Records you already made with it stay as they are.';

  @override
  String get catalogClearFilters => 'Clear filters';

  @override
  String get catalogRemoveFilter => 'Remove filter';

  @override
  String get catalogFilters => 'Filters';

  @override
  String get catalogOnlyNoAlcohol => 'Non-alcoholic only';

  @override
  String get catalogStyle => 'Style';

  @override
  String get catalogPresentation => 'Package';

  @override
  String get catalogBrand => 'Brand';

  @override
  String catalogSeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See $count drinks',
      one: 'See 1 drink',
    );
    return '$_temp0';
  }

  @override
  String get catalogRecents => 'Recent';

  @override
  String get catalogFavorites => 'Favorites';

  @override
  String get catalogAllDrinks => 'All drinks';

  @override
  String catalogResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get catalogEmptyTitle => 'No drinks found';

  @override
  String get catalogEmptyOuting =>
      'Create a drink just for this outing, or scan a label or a menu.';

  @override
  String get catalogEmptyNoFilter =>
      'Create yours and it stays saved for future outings.';

  @override
  String get catalogEmptyFilter => 'Try removing a filter or create yours.';

  @override
  String catalogSizes(String count) {
    return '$count sizes';
  }

  @override
  String get catalogDetails => 'Details';

  @override
  String get catalogUnfavorite => 'Remove from favorites';

  @override
  String get catalogFavorite => 'Add to favorites';

  @override
  String get entryDiscardTitle => 'Discard changes?';

  @override
  String get entryDiscardBody => 'What you filled in here will be lost.';

  @override
  String get entryKeepEditing => 'Keep editing';

  @override
  String get entryDiscard => 'Discard';

  @override
  String get entryFix => 'Edit record';

  @override
  String get entryLogDrink => 'Log drink';

  @override
  String get entryShared => 'Shared';

  @override
  String get entryTimeSection => 'Time';

  @override
  String get entrySaveChanges => 'Save changes';

  @override
  String get entryPriceValue => 'Amount';

  @override
  String get entryPriceDontKnow => 'Don\'t know';

  @override
  String entryComplimentaryNote(String amount) {
    return 'Complimentary counts as $amount entered.';
  }

  @override
  String get entryNoPriceNote =>
      'No price: shown as \"no price\" in the summary.';

  @override
  String get commonAdd => 'Add';

  @override
  String get entryAmount => 'Amount';

  @override
  String draftBeforeStart(String time) {
    return 'Before the outing started ($time)';
  }

  @override
  String get draftNotFuture => 'The time cannot be in the future';

  @override
  String draftAfterEnd(String time) {
    return 'After the outing ended ($time)';
  }

  @override
  String get detailNotGiven => 'Not given';

  @override
  String get detailAbv => 'Alcohol content';

  @override
  String get detailIngredients => 'Declared ingredients (original wording)';

  @override
  String get detailPresentations => 'Packages';

  @override
  String get detailBottleNotDose =>
      'Bottle size is not shot size. When logging, you pick a suggested shot (editable) or share the bottle.';

  @override
  String get detailUnverifiedPackages =>
      'Packages not verified for this product. When logging, you can pick a suggested size or type the volume.';

  @override
  String get detailPackagesNote =>
      'Packages cited by the manufacturer. The package size is not what you drank: you set that when logging.';

  @override
  String get detailCopyAddress => 'Copy address';

  @override
  String get detailAddressCopied => 'Address copied';

  @override
  String get detailMayVary =>
      'Data may vary by version and market. Always check the package label.';

  @override
  String get customEditTitle => 'Edit drink';

  @override
  String get customSaveFailed => 'Could not save. Your data is still here.';

  @override
  String get customEditNote =>
      'Changes apply to future records. What you already logged stays as it was.';

  @override
  String get customNewNote =>
      'Saved so you can use it again in future outings.';

  @override
  String get customType => 'Type';

  @override
  String get customIdentification => 'Identification';

  @override
  String get customName => 'Drink name';

  @override
  String get customNameRequired => 'Give the drink a name';

  @override
  String get customSaveUse => 'Save and use';

  @override
  String get myDrinksNeedOuting => 'Start an outing to log a drink.';

  @override
  String get myDrinksLogged => 'Drink logged';

  @override
  String get myDrinksCopied => 'Copy created';

  @override
  String myDrinksDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get myDrinksDeleteBody =>
      'It leaves your catalog. Records you already made stay as they are.';

  @override
  String get myDrinksDeleted => 'Deleted';

  @override
  String get myDrinksTitle => 'My drinks and recipes';

  @override
  String get myDrinksEmptyTitle => 'Nothing here yet';

  @override
  String get myDrinksEmptyBody =>
      'Drinks and recipes you create stay here to reuse in future outings.';

  @override
  String get myDrinksStartFirst => 'To log, start an outing first.';

  @override
  String get myDrinksActionLog => 'Log';

  @override
  String get myDrinksActionDuplicate => 'Duplicate';

  @override
  String get myDrinksNewDrink => 'New drink';

  @override
  String get scanLabelPhotoGone =>
      'The photo for this reading is no longer available on this device. The text was kept: take another photo or continue without it.';

  @override
  String get scanPhotoSaveFailed => 'Could not store the photo on the device.';

  @override
  String get scanRotateFailed => 'Could not rotate the image.';

  @override
  String get scanPhotoUnavailableToRead =>
      'The photo is not available for reading. Take another.';

  @override
  String get scanNoTextFound =>
      'No text was found. Try another photo, closer and with good light, or type the text.';

  @override
  String get scanLabelTip =>
      'Frame the whole label from the front, in good light and without glare. Volume and ABV are often on another side of the package: photograph that side or fill them in during review. You check everything before saving.';

  @override
  String get scanLabelEnded =>
      'This outing has already ended. What you scan is saved in it.';

  @override
  String get scanWebPhotoSession =>
      'In the browser the photo is only kept during this session.';

  @override
  String get scanPhoto => 'Photo';

  @override
  String get scanTakePhoto => 'Take photo';

  @override
  String get scanChooseGallery => 'Choose from gallery';

  @override
  String get scanRotateLeft => 'Rotate left';

  @override
  String get scanRotateRight => 'Rotate right';

  @override
  String get scanNewPhoto => 'New photo';

  @override
  String get scanReplacePhoto => 'Replace';

  @override
  String get scanDiscardReading => 'Discard reading';

  @override
  String get scanReadingOnDevice =>
      'Reading the text from the photo on this device…';

  @override
  String get scanCancelReading => 'Cancel reading';

  @override
  String get scanReadAgain => 'Read again';

  @override
  String get scanOcrUnavailable =>
      'Automatic reading is not available here (only in the Android and iOS app). Look at the photo and type or paste the label text, or fill it in directly.';

  @override
  String get scanLabelText => 'Label text';

  @override
  String get scanTextHintCanRead =>
      'The text read appears here. You can correct it.';

  @override
  String get scanTextHintManual => 'Type or paste the label text (optional)';

  @override
  String get scanInterpret => 'Interpret text';

  @override
  String get scanFillManually => 'Fill in manually';

  @override
  String get photoUnavailable =>
      'Photo unavailable right now: not yet uploaded by the other device, or no connection. The record is still saved.';

  @override
  String get photoDelete => 'Delete photo';

  @override
  String get photoDeleteTitle => 'Delete this photo?';

  @override
  String get photoDeleteBody =>
      'Only the photo goes. The drinks and data you confirmed stay in the outing.';

  @override
  String get captureCameraUnavailable =>
      'The camera is not available here. Choose a photo from the gallery.';

  @override
  String get captureGalleryUnavailable => 'The gallery is not available here.';

  @override
  String get capturePermissionCamera =>
      'No permission to use the camera. Allow it in the device settings or choose another option.';

  @override
  String get capturePermissionGallery =>
      'No permission to use the gallery. Allow it in the device settings or choose another option.';

  @override
  String get captureOpenCameraFailed => 'Could not open the camera.';

  @override
  String get captureOpenGalleryFailed => 'Could not open the gallery.';

  @override
  String get captureFailed => 'Could not open image capture.';

  @override
  String get captureUnreadable => 'Could not read this image.';

  @override
  String get captureTooBig => 'The image is too large. Try a smaller photo.';

  @override
  String get captureNotImage => 'This file does not look like a valid image.';

  @override
  String get ocrUnavailable =>
      'Automatic reading is not available on this device.';

  @override
  String get ocrReadFailed => 'Could not read the text in this photo.';

  @override
  String matchOtherCategory(String category) {
    return 'Different category (catalog: $category)';
  }

  @override
  String matchSameSize(String size) {
    return 'Same size ($size)';
  }

  @override
  String matchOtherSize(String sizes) {
    return 'Different size (catalog: $sizes)';
  }

  @override
  String matchSameAbv(String abv) {
    return 'Same ABV ($abv)';
  }

  @override
  String matchOtherAbv(String catalog, String yours) {
    return 'Different ABV (catalog: $catalog, yours: $yours)';
  }

  @override
  String get matchAbvVaries => 'The catalog ABV varies by source';

  @override
  String get matchNoAbv => 'Catalog has no ABV to compare';

  @override
  String matchOtherBrand(String brand) {
    return 'Different brand ($brand)';
  }

  @override
  String get matchRecipe => 'Reference recipe: the cocktail served may differ';

  @override
  String get matchSimilar => 'Similar by name: confirm it is the same product';

  @override
  String parseManyVolumes(String list) {
    return 'More than one volume in the text ($list). Pick the one on the package.';
  }

  @override
  String parseManyAbvs(String list) {
    return 'More than one ABV in the text ($list). Check the label.';
  }

  @override
  String get parseCheckName =>
      'Check the name and brand. Tap the suggestions to change them.';

  @override
  String menuNoteColumns(String count) {
    return 'The menu seems to have $count columns. Check that each price is on the right item.';
  }

  @override
  String menuNoteOrphans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count prices with no clear item were ignored. Add the item manually if you need them.',
      one: '1 price with no clear item was ignored. Add the item manually if you need it.',
    );
    return '$_temp0';
  }

  @override
  String get menuNoteNone =>
      'No item was identified. Paste or type the text, or add the items manually.';

  @override
  String get scanMenuReviewTitle => 'Menu items';

  @override
  String scanMenuLostPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos of this reading are no longer available. Their items were kept for you to check.',
      one: 'One photo of this reading is no longer available. Its items were kept for you to check.',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoItemsRead =>
      'No item was identified. Rotate the photo, try it closer or paste the menu text.';

  @override
  String get scanMenuNoItems => 'No item was identified.';

  @override
  String get scanMenuNoneSelected => 'No item selected.';

  @override
  String get scanMenuUnnamed => 'An item has no name. Fix it or discard it.';

  @override
  String get scanMenuNeedType =>
      'Choose the type of the items marked \"Type?\".';

  @override
  String get scanMenuSaveFailed => 'Could not save. Your items are still here.';

  @override
  String get scanMenuDiscardTitle => 'Discard this reading?';

  @override
  String get scanMenuDiscardBody =>
      'The photos and the items not yet confirmed will be deleted.';

  @override
  String get scanMenuTip =>
      'Photograph one page at a time, from the front and in good light, without cutting off the prices. You can add several photos. You check and correct each item before saving.';

  @override
  String get scanMenuEnded =>
      'This outing has already ended. The items are saved in it.';

  @override
  String get scanMenuWebPhotos =>
      'In the browser the photos are only kept during this session.';

  @override
  String scanMenuPhotos(String count) {
    return 'Photos ($count)';
  }

  @override
  String scanMenuPhotoN(String number) {
    return 'Photo $number';
  }

  @override
  String get scanMenuRead => 'Read';

  @override
  String get scanMenuUnread => 'Not read yet';

  @override
  String get scanRemovePhoto => 'Remove photo';

  @override
  String get scanAnotherPhoto => 'Another photo';

  @override
  String get scanMenuReadingMany =>
      'Reading the text from the photos on this device…';

  @override
  String get scanMenuSeeRead => 'See items read';

  @override
  String get scanMenuOcrUnavailable =>
      'Automatic reading is not available here (only in the Android and iOS app). Look at the photos and type or paste the menu text, or add the items by hand.';

  @override
  String get scanMenuPastedSection => 'Menu text (optional)';

  @override
  String get scanMenuPastedHint =>
      'One item per line, with the price on the same line or the next one. E.g.: Caipirinha R\$ 18.00';

  @override
  String get scanMenuAddManual => 'Add an item by hand';

  @override
  String scanMenuSeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See $count items',
      one: 'See 1 item',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuReviewIntro =>
      'Tick the items you want available in this outing. Nothing is logged as consumed now: you pick the drink and confirm the price when you order.';

  @override
  String get scanMenuPhotosAndReading => 'Photos and reading';

  @override
  String get scanMenuAddItem => 'Add item';

  @override
  String scanMenuSave(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count items in this outing',
      one: 'Save 1 item in this outing',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoName => '(no name)';

  @override
  String get scanMenuEditItem => 'Edit item';

  @override
  String get scanMenuTypeHint => 'Type?';

  @override
  String get scanMenuDuplicate => 'Repeated in another photo';

  @override
  String get scanMenuPromo => 'Possible promotion: confirm the amount';

  @override
  String scanMenuPriceOnMenu(String price) {
    return '$price on the menu';
  }

  @override
  String get scanMenuNoPriceRead => 'No price read';

  @override
  String get scanMenuPriceUnsure =>
      'The price could not be read with certainty. Pick the right one or leave it without a price:';

  @override
  String get scanMenuChangePrice => 'Change price';

  @override
  String get scanMenuNewItem => 'New item';

  @override
  String get scanMenuName => 'Name';

  @override
  String get scanMenuDescription => 'Description (optional)';

  @override
  String get scanMenuPriceOptional => 'Price (optional)';

  @override
  String get scanMenuNeedName => 'Give the item a name.';

  @override
  String get scanMenuInvalidPrice => 'Invalid price.';

  @override
  String get commonApply => 'Apply';

  @override
  String get originManual => 'Created in this outing';

  @override
  String get originPhotoLabel => 'Label photo';

  @override
  String get originMenu => 'Menu photo';

  @override
  String get outingReviewEditTitle => 'Edit outing drink';

  @override
  String get outingReviewTitle => 'Drink of this outing';

  @override
  String get outingReviewIsolation =>
      'This drink exists only in this outing. It does not enter the catalog, My drinks or other outings.';

  @override
  String get outingReviewEnded =>
      'This outing has already ended. The item is saved in it.';

  @override
  String get outingReviewDrinkSection => 'Drink';

  @override
  String get outingReviewNeedName => 'Give the drink a name.';

  @override
  String get outingReviewNeedType => 'Choose the drink type.';

  @override
  String get outingReviewOtherLines => 'Other lines read (tap to use):';

  @override
  String get outingReviewPickType => 'Choose the drink type';

  @override
  String get outingReviewTypeUnknown => 'Type not identified: choose one.';

  @override
  String get outingReviewDescription => 'Menu description (optional)';

  @override
  String get outingReviewAdvertisedSection => 'Advertised price';

  @override
  String get outingReviewMenuPriceOptional => 'Menu price (optional)';

  @override
  String get outingReviewMenuPriceHelper =>
      'Only a suggestion: when logging you confirm what you paid. Amounts in Brazilian reais (R\$).';

  @override
  String get outingReviewOriginSection => 'Data source';

  @override
  String get outingReviewOriginManual => 'Filled in by you.';

  @override
  String get outingReviewOriginPhoto =>
      'Read from the photo and checked by you. Automatic reading can be wrong: check every field.';

  @override
  String get outingReviewSourceText => 'Text read from the photo';

  @override
  String get outingReviewConfirmContinue => 'Confirm and continue';

  @override
  String get outingReviewSaveOnly => 'Save only in this outing';

  @override
  String get outingDrinksSectionTitle => 'Drinks of this outing';

  @override
  String get outingDrinksTapToLog =>
      'They exist only in this outing. Tap to log one.';

  @override
  String get outingDrinksRemoveTitle => 'Remove from the outing list?';

  @override
  String get outingDrinksRemoveBody =>
      'It leaves \"Drinks of this outing\". Records you already made stay in the history.';

  @override
  String get outingDrinksRemove => 'Remove';

  @override
  String get outingDrinksMoreActions => 'More actions';

  @override
  String get outingDrinksRemoveFromList => 'Remove from list';

  @override
  String outingDrinksMenuPrice(String price) {
    return 'menu $price';
  }

  @override
  String get outingScanUnfinishedMenu => 'Menu reading not finished';

  @override
  String get outingScanUnfinishedLabel => 'Label reading not finished';

  @override
  String get outingScanUnfinishedNote =>
      'It stays linked to this outing. If you finish it now, the result is saved in it, not in another.';

  @override
  String get outingScanOnlyHere => 'They exist only in this outing.';

  @override
  String get outingScanPhotosTitle => 'Photos of the outing';

  @override
  String get outingScanAllUploaded =>
      'Photos are also kept in the cloud, in a private file.';

  @override
  String outingScanPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos are still only on this device; the upload is retried automatically.',
      one: '1 photo is still only on this device; the upload is retried automatically.',
    );
    return '$_temp0';
  }

  @override
  String outingScanLocalOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos only on this device.',
      one: '1 photo only on this device.',
    );
    return '$_temp0';
  }

  @override
  String get photoKindLabel => 'Label';

  @override
  String get photoKindMenu => 'Menu';

  @override
  String get pickerStartTitle => 'Where is the outing?';

  @override
  String get pickerChangeTitle => 'Correct place';

  @override
  String get pickerLocateTitle => 'Place location';

  @override
  String get pickerAlreadySavedTitle => 'Place already saved';

  @override
  String pickerAlreadySavedBody(String name) {
    return 'This place is already in your places as \"$name\". Use it here too?';
  }

  @override
  String get pickerUseAnyway => 'Use anyway';

  @override
  String get pickerSearchHint => 'Search a bar, restaurant or address';

  @override
  String get pickerClearSearch => 'Clear search';

  @override
  String get pickerUseLocation => 'Use my location';

  @override
  String get pickerApproximate =>
      'Approximate location: check the place in the list or on the map.';

  @override
  String get pickerLocationHint =>
      'Shows places nearby. You always confirm where you are.';

  @override
  String get pickerNicknameOnly => 'Enter just a nickname';

  @override
  String get pickerNicknameOnlyExample =>
      'No map or address. E.g. Sam\'s place';

  @override
  String get pickerNicknameOnlyShort => 'No map or address.';

  @override
  String get pickerYourPlaces => 'Your places';

  @override
  String get pickerNotConfiguredFull =>
      'Place search and the map are not set up in this version. Nicknames, typed addresses and saved places work normally.';

  @override
  String get pickerNearYou => 'Near you';

  @override
  String get pickerNothingNearby =>
      'No bar or restaurant found very close. You can search by name or just mark the point.';

  @override
  String get pickerPinOnly => 'Mark just this point on the map';

  @override
  String get pickerPinOnlyHint => 'You can give it a nickname next.';

  @override
  String get pickerNotConfigured =>
      'Place search is not set up in this version.';

  @override
  String get pickerMinChars => 'Type at least 3 letters to search.';

  @override
  String get pickerNothingFound =>
      'Nothing found. Try the name with the neighborhood or city, or enter just a nickname.';

  @override
  String get pickerResults => 'Results';

  @override
  String get pickerErrorOffline =>
      'No internet right now. You can still use a saved place or enter a nickname.';

  @override
  String get pickerErrorUnavailable =>
      'Search is unavailable at the moment. You can still use a saved place or enter a nickname.';

  @override
  String get pickerLocServiceOff => 'The device location is turned off.';

  @override
  String get pickerOpenSettings => 'Open settings';

  @override
  String get pickerLocDenied =>
      'No location permission. You can still search by name or address.';

  @override
  String get pickerLocDeniedForever =>
      'Location was denied for Bebômetro. To use it, allow it in the device settings. Search works without it.';

  @override
  String get pickerLocTimeout => 'Could not get the location in time.';

  @override
  String get pickerLocUnavailable =>
      'Location is not available here. Search by name or address.';

  @override
  String pickerSavedAs(String name) {
    return 'Saved as \"$name\"';
  }

  @override
  String get pickerManualNickname => 'Nickname';

  @override
  String get pickerManualHint => 'E.g. Sam\'s place';

  @override
  String get pickerManualHelper => 'The nickname alone is enough.';

  @override
  String get pickerAddAddress => 'Add address (optional)';

  @override
  String get pickerNeedNicknameOrAddress =>
      'Enter a nickname (e.g. Sam\'s place) or an address';

  @override
  String get pickerStateTwoLetters => 'The state code has 2 letters';

  @override
  String get placeSaveToMine => 'Save to my places';

  @override
  String get placeSaveToMineHint =>
      'To pick it again in future outings. It stays private.';

  @override
  String get pickerUseThisPlace => 'Use this place';

  @override
  String distanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get confirmTitle => 'Check place';

  @override
  String get confirmTapMap => 'Tap the map to adjust the point, if needed.';

  @override
  String get confirmMapFailed =>
      'The map did not load. You can confirm using the details below.';

  @override
  String get confirmNoAddress => 'No confirmed address for this point.';

  @override
  String confirmAdjustedWas(String name) {
    return 'Point adjusted: \"$name\" and its address no longer apply to this point.';
  }

  @override
  String get confirmAdjusted => 'Point adjusted by you.';

  @override
  String get confirmLookUp => 'Look up this point\'s address';

  @override
  String get confirmNoAddressFound => 'No address found for this point.';

  @override
  String get confirmOfflinePointKept => 'No internet. The point stays marked.';

  @override
  String get confirmLookUpFailed => 'Could not look up the address right now.';

  @override
  String confirmAlreadySaved(String name) {
    return 'You already saved this place as \"$name\". It will be reused.';
  }

  @override
  String confirmAlreadySavedNick(String name) {
    return 'You already saved this place as \"$name\". It will be reused and the nickname stays.';
  }

  @override
  String get confirmNicknameSection => 'Nickname (optional)';

  @override
  String get confirmNicknameHelper =>
      'Shown instead of the name. The address stays in the details.';

  @override
  String confirmUseAsNickname(String name) {
    return 'Use \"$name\" as nickname';
  }

  @override
  String get confirmNeedNickname => 'Give it a nickname to save this point.';

  @override
  String get placeFallbackName => 'Place';

  @override
  String get placePointOnMap => 'Point on the map';

  @override
  String get changePlaceTitle => 'Change this outing\'s place?';

  @override
  String changePlaceBody(String name) {
    return 'The outing becomes \"$name\". Only this outing changes: its drinks, photos and tab stay in it, and other outings are not changed.';
  }

  @override
  String get changePlaceConfirm => 'Change place';

  @override
  String get changePlaceDone => 'Outing place updated';

  @override
  String get changePlaceFailed =>
      'Could not change the place. Nothing was changed.';

  @override
  String get openMapsFailed => 'Could not open a maps app.';

  @override
  String get mapSemantics => 'Map with the place\'s point';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapCenter => 'Center on the point';

  @override
  String get placeNotFound => 'This place was not found.';

  @override
  String get placeScreenTitle => 'Place';

  @override
  String get placeReactivated => 'Place reactivated';

  @override
  String get placeArchivedToast => 'Place archived';

  @override
  String get placeReactivate => 'Reactivate';

  @override
  String get placeArchive => 'Archive';

  @override
  String get placeArchivedPill => 'Archived';

  @override
  String get placeStatOutings => 'Outings';

  @override
  String get placeStatDrinks => 'Your drinks';

  @override
  String get placeStatSpent => 'Your reported spend';

  @override
  String placeLastVisit(String date) {
    return 'Last visit: $date';
  }

  @override
  String get placeStartHere => 'Start an outing here';

  @override
  String get placeOpenMap => 'Open in maps';

  @override
  String get placeSpendNote =>
      'Reported spend: what you logged on your drinks here. The table total and the tab payments are in each outing summary and are not part of this sum.';

  @override
  String get placePriceHistory => 'Your price history';

  @override
  String get placePriceHistoryNone =>
      'There are no prices entered by you here yet. When there are, the latest price and the observed range appear in this place.';

  @override
  String get placePriceHistoryNote =>
      'Your history: only what you entered yourself at this place, by drink and size. It is not a market, city or state average.';

  @override
  String placeVisits(String count) {
    return 'Outings at this place ($count)';
  }

  @override
  String get placeNoVisits => 'No outing logged here yet.';

  @override
  String get placeVisitInProgress => 'in progress';

  @override
  String get placeNoValues => 'no amounts';

  @override
  String rangeTo(String from, String to) {
    return '$from to $to';
  }

  @override
  String placePriceLast(String price, String date) {
    return 'Latest: $price on $date';
  }

  @override
  String placePriceLastShared(String price, String date) {
    return 'Latest: $price on $date (bottle/serving total)';
  }

  @override
  String placePriceRangeLine(String range, int count, String period) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return 'Observed range: $range · $_temp0 · $period';
  }

  @override
  String get placeAlreadyActive =>
      'There is already an outing in progress. End it first.';

  @override
  String get placeFieldMapName => 'Name on the map';

  @override
  String get placeFieldAddress => 'Address';

  @override
  String get placeFieldCity => 'City';

  @override
  String get placeFieldOrigin => 'Source';

  @override
  String get placeSourceSearch => 'Chosen from search (OpenStreetMap)';

  @override
  String get placeSourceLocation => 'Your location, checked on the map';

  @override
  String get placeSourceAdjusted => 'Point adjusted by you';

  @override
  String get placeSourceManual => 'Entered by you';

  @override
  String get placeDetailsTitle => 'Details';

  @override
  String get placeNoPointNoAddress =>
      'No address or map point. You can search in \"Edit\".';

  @override
  String get placesEmptyTitle => 'No saved places';

  @override
  String get placesEmptyBody =>
      'Save the places you usually go to so you can pick them quickly when starting an outing. They stay private on your profile.';

  @override
  String get placesArchivedSection => 'Archived';

  @override
  String get placesNew => 'New place';

  @override
  String placesVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outings',
      one: '1 outing',
    );
    return '$_temp0';
  }

  @override
  String get placeEditTitle => 'Edit place';

  @override
  String get placeEditorNote =>
      'Changes apply to future outings. Outings that already happened keep the name and address they had when they were made.';

  @override
  String get placeEditorLocation => 'Location';

  @override
  String get placeEditorSourceSearch =>
      'Chosen from search (OpenStreetMap data)';

  @override
  String get placeEditorSourceAdjusted => 'Point adjusted by you on the map';

  @override
  String get placeEditorNoPointHint =>
      'Optional. A nickname or an address is enough.';

  @override
  String get placeEditorPointSaved => 'Point saved';

  @override
  String get placeEditorNoPoint => 'No point on the map';

  @override
  String get placeEditorSearchMap => 'Search on the map';

  @override
  String get placeEditorSearchAdjust => 'Search or adjust';

  @override
  String get placeEditorRemoveFromMap => 'Remove from map';

  @override
  String get placeEditorAddressHelper =>
      'A nickname, place name or address is enough.';

  @override
  String get placeEditorPrivate =>
      'Your places and addresses are private: only you see them.';

  @override
  String get placeEditorSave => 'Save place';

  @override
  String get tabMe => 'You';

  @override
  String get tabCatFood => 'Snack / food';

  @override
  String get tabCatSoft => 'Water / soft drink';

  @override
  String get tabCatCover => 'Cover charge';

  @override
  String get tabCatStarter => 'Entry fee';

  @override
  String get tabCatTransport => 'Transport';

  @override
  String get tabCatOther => 'Other';

  @override
  String get tabCatDrink => 'Tab-only drink';

  @override
  String get tabSplitEqual => 'Equally';

  @override
  String get tabSplitItem => 'By item';

  @override
  String get tabSplitCustom => 'Custom amounts';

  @override
  String get tabShared => 'shared';

  @override
  String tabShareHeader(String title) {
    return 'Tab · $title';
  }

  @override
  String get tabShareNoItems => 'No items on the tab.';

  @override
  String get tabShareItems => 'Items';

  @override
  String tabShareLineGroup(
    String title,
    String count,
    String unit,
    String sum,
  ) {
    return '• $title · $count × $unit = $sum';
  }

  @override
  String tabShareLineQty(String title, String qty, String total) {
    return '• $title · $qty× = $total';
  }

  @override
  String tabShareLineGroupNoPrice(String title, String count) {
    return '• $title · $count × no price';
  }

  @override
  String tabShareLine(String title, String price) {
    return '• $title · $price';
  }

  @override
  String tabShareLineNoPrice(String title) {
    return '• $title · no price';
  }

  @override
  String tabShareSubtotalKnown(String amount) {
    return 'Known subtotal: $amount';
  }

  @override
  String tabShareSubtotal(String amount) {
    return 'Subtotal: $amount';
  }

  @override
  String tabShareDiscount(String amount) {
    return 'Discount: -$amount';
  }

  @override
  String tabShareService(String pct, String base, String amount) {
    return 'Service ($pct on $base): $amount';
  }

  @override
  String tabShareTotalKnown(String amount) {
    return 'Known total: $amount';
  }

  @override
  String tabShareTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String tabSharePartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Partial bill: $count items without a price.',
      one: 'Partial bill: 1 item without a price.',
    );
    return '$_temp0';
  }

  @override
  String tabShareSplitHeader(String mode) {
    return 'Split ($mode)';
  }

  @override
  String tabShareSplitLine(String name, String amount) {
    return '• $name: $amount';
  }

  @override
  String tabSharePaid(String amount) {
    return ' · paid $amount';
  }

  @override
  String get tabShareCovered => ' · covered by another payment';

  @override
  String tabShareMissing(String amount) {
    return ' · owes $amount';
  }

  @override
  String tabShareOver(String amount) {
    return ' · paid $amount extra';
  }

  @override
  String tabShareUnassigned(String amount) {
    return 'Not split yet: $amount';
  }

  @override
  String tabShareOverTotal(String amount) {
    return 'Above the total: $amount';
  }

  @override
  String get tabShareSplitPartial => 'Partial split: the amounts may change.';

  @override
  String get tabTitle => 'Tab';

  @override
  String get tabShareSplitTooltip => 'Share the split';

  @override
  String get tabIntro =>
      'Optional. The tab does not log consumption: what you drank stays in your records.';

  @override
  String get tabEnded =>
      'Outing ended. The tab is still editable; ending does not mark the bill as paid.';

  @override
  String tabItemsTitle(String count) {
    return 'Items ($count)';
  }

  @override
  String get tabEmptyTitle => 'Empty tab';

  @override
  String get tabEmptyBody =>
      'Add snacks and other expenses, or include the drinks you already logged.';

  @override
  String get tabNoDrinksToLink => 'No logged drinks to include';

  @override
  String tabLinkDrinks(String count) {
    return 'Include logged drinks ($count)';
  }

  @override
  String get tabSplitBill => 'Split the bill';

  @override
  String get tabSubtotalKnown => 'Known subtotal';

  @override
  String get tabSubtotal => 'Subtotal';

  @override
  String get tabDiscount => 'Discount';

  @override
  String tabServiceLine(String pct, String base) {
    return 'Service $pct on $base';
  }

  @override
  String get tabTotalKnown => 'Known total';

  @override
  String get tabTotalTab => 'Tab total';

  @override
  String tabPartialPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items without a price: the bill and the split are partial.',
      one: '1 item without a price: the bill and the split are partial.',
    );
    return '$_temp0';
  }

  @override
  String get tabYourShareProvisional => 'Your share (provisional)';

  @override
  String get tabYourShare => 'Your share';

  @override
  String get tabOrderNote =>
      'Order: subtotal → discount → service on the items with service, already discounted → total.';

  @override
  String get tabServiceAndDiscount => 'Service and discount';

  @override
  String tabServiceSummary(String pct) {
    return 'service $pct';
  }

  @override
  String get tabNoService => 'no service';

  @override
  String tabDiscountSummary(String amount) {
    return 'discount $amount';
  }

  @override
  String get tabChargeService => 'Charge service';

  @override
  String get tabChargeServiceHint =>
      'Only on items marked with service. Transport and entry start without it.';

  @override
  String get tabPercent => 'Percentage';

  @override
  String tabServiceBase(String base, String service) {
    return 'Base $base → $service';
  }

  @override
  String get tabDiscountNone => 'None';

  @override
  String get tabDiscountAmountLabel => 'Discount amount';

  @override
  String get tabDiscountPercentLabel => 'Discount percentage';

  @override
  String tabDiscountCapped(String amount) {
    return 'Capped at the subtotal: $amount';
  }

  @override
  String get tabDiscountHelper => 'On the items subtotal, spread across them.';

  @override
  String tabGroupHeaderMulti(
    String title,
    String count,
    String unit,
    String sum,
  ) {
    return '$title · $count × $unit = $sum';
  }

  @override
  String tabGroupHeaderNoPrice(String title, String count) {
    return '$title · $count × no price';
  }

  @override
  String tabGroupQtyNoPrice(String title, String qty) {
    return '$title · $qty× no price';
  }

  @override
  String tabGroupQtyTotal(String title, String qty, String total) {
    return '$title · $qty× = $total';
  }

  @override
  String get tabComplimentary => 'complimentary';

  @override
  String get tabNoPrice => 'no price';

  @override
  String tabPersonalOnly(String amount) {
    return 'only your share ($amount) is known · bottle total unknown';
  }

  @override
  String get tabPersonalOnlyShort =>
      'only the personal share is known; total unknown';

  @override
  String tabLineOnlyYourShare(String amount) {
    return 'only your share $amount';
  }

  @override
  String tabLineDiscount(String amount) {
    return 'disc. −$amount';
  }

  @override
  String tabLineService(String amount) {
    return 'service +$amount';
  }

  @override
  String get tabLineRegisteredDrink => 'Logged drink';

  @override
  String get tabLineItem => 'Tab item';

  @override
  String get tabActions => 'Actions';

  @override
  String get tabFillTotalTitle => 'Bottle/pitcher total';

  @override
  String get tabFillPriceTitle => 'Price';

  @override
  String get tabFillTotalLabel => 'Bill total for this item';

  @override
  String get tabFillTotal => 'Enter total';

  @override
  String get tabFillPrice => 'Enter price';

  @override
  String get tabNoServiceItem => 'No service on this item';

  @override
  String get tabRemoveFromTab => 'Remove from the tab';

  @override
  String get tabDeleteItem => 'Delete item';

  @override
  String get splitTitle => 'Split the bill';

  @override
  String get splitRename => 'Rename';

  @override
  String splitRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String splitRemoveBody(String name, String share) {
    return '$name has $share assigned. Choose what happens to them:';
  }

  @override
  String splitRemoveBodyPay(String name, String share, int count, String paid) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$name has $share assigned and $_temp0 ($paid). Choose what happens to them:';
  }

  @override
  String get splitPassTo => 'Pass to';

  @override
  String get splitNobody => 'Nobody (redistribute)';

  @override
  String get splitRedistributeNote =>
      'The items only this person had are split among everyone again and their payments are deleted.';

  @override
  String get splitTransferNote =>
      'Items, amounts and payments move to that person.';

  @override
  String get splitRegisterPayment => 'Log payment';

  @override
  String get splitEditPayment => 'Edit payment';

  @override
  String get splitWhoPaid => 'Who paid';

  @override
  String get splitPaidAmount => 'Amount paid';

  @override
  String get splitNoteOptional => 'Note (optional)';

  @override
  String get splitPaymentPositive => 'Enter an amount greater than zero.';

  @override
  String splitTotalKnown(String amount) {
    return 'Known total $amount';
  }

  @override
  String splitTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String splitPendingPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items without a price: the split and balances are provisional.',
      one: '1 item without a price: the split and balances are provisional.',
    );
    return '$_temp0';
  }

  @override
  String get splitComplete => 'Split complete: the shares add up to the total.';

  @override
  String splitMissing(String amount) {
    return '$amount still to distribute.';
  }

  @override
  String splitOver(String amount) {
    return 'Distributed $amount more than the total.';
  }

  @override
  String get splitPeople => 'People';

  @override
  String get splitAddPerson => 'Add a person (nickname)';

  @override
  String get splitNicknamesOnly =>
      'Nicknames only, no login or invitation. They stay only in this tab.';

  @override
  String get splitHow => 'How to split';

  @override
  String get splitModeEqualShort => 'Equal';

  @override
  String get splitModeItemShort => 'By item';

  @override
  String get splitModeValuesShort => 'Amounts';

  @override
  String get splitModeEqualNote =>
      'Active mode: equally. The total is split among the people ticked.';

  @override
  String get splitModeItemNote =>
      'Active mode: by item. Each order is split among those who take part in it, with the service and discount of that item.';

  @override
  String get splitModeCustomNote =>
      'Active mode: custom amounts. You type each person\'s share; it only closes when the sum matches the total.';

  @override
  String get splitAddItemsHint => 'Add items to the tab to split by item.';

  @override
  String get splitFillEqually => 'Fill equally';

  @override
  String get splitAllDistributed => 'Everything distributed.';

  @override
  String splitNotDistributed(String amount) {
    return 'Not distributed yet: $amount';
  }

  @override
  String splitPassedTotal(String amount) {
    return 'Over the total by $amount';
  }

  @override
  String get splitResult => 'Result';

  @override
  String get splitProvisionalNote =>
      'Provisional: the amounts change if the bill changes.';

  @override
  String get splitAttributedNote =>
      'Assigned is what falls to each person; paid is what the person said they paid the venue.';

  @override
  String splitPaidLine(String paid, String balance) {
    return 'Paid $paid · $balance';
  }

  @override
  String get splitBalanceCovered =>
      'covered by another payment (venue settled)';

  @override
  String splitBalanceMissing(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'still owes $amount$_temp0';
  }

  @override
  String splitBalanceOver(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'paid $amount extra$_temp0';
  }

  @override
  String splitBalanceEven(String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'settled$_temp0';
  }

  @override
  String get splitPayments => 'Payments';

  @override
  String get splitNoPayments => 'No payment logged.';

  @override
  String get splitRemovedPerson => 'Removed person';

  @override
  String get splitDeletePayment => 'Delete payment';

  @override
  String get splitPaymentNote =>
      'Logging a payment does not change the total, the consumption or the budget: only the balance. The app does not charge, run Pix or transfer money, and does not say who should pay whom. The price of a drink does not count as a payment.';

  @override
  String get splitAssignEveryone => 'Everyone splits';

  @override
  String get splitAssignNobody => 'Nobody';

  @override
  String get splitAssignIntro =>
      'Who takes part and with what weight. Whoever does not take part gets no share of this item.';

  @override
  String splitWeight(String number) {
    return 'weight $number';
  }

  @override
  String get tabExtraNew => 'New tab item';

  @override
  String get tabExtraNote =>
      'Only on this outing\'s tab. It does not become consumption or enter the catalog.';

  @override
  String get tabExtraDescription => 'Description';

  @override
  String get tabExtraHintTransport => 'E.g. ride home (optional)';

  @override
  String get tabExtraHint => 'E.g. plate of fries';

  @override
  String get tabBasisUnit => 'Price of each';

  @override
  String tabBasisTotal(String qty) {
    return 'Total of $qty';
  }

  @override
  String get tabValueEach => 'Amount for each unit';

  @override
  String tabValueTotalQty(String qty) {
    return 'Total amount for $qty';
  }

  @override
  String get tabExtraServiceItem => 'Charge service on this item';

  @override
  String get tabExtraServiceHint => 'Only applies if service is on.';

  @override
  String get tabExtraWho => 'Who shares this item';

  @override
  String get tabExtraAll => 'Everyone';

  @override
  String tabExtraSome(String count, String total) {
    return '$count of $total';
  }

  @override
  String get tabExtraWhoNote => 'Applies in the \"By item\" split mode.';

  @override
  String get tabExtraSave => 'Save item';

  @override
  String get tabExtraNeedValue =>
      'Enter the amount, or choose Complimentary / Don\'t know.';

  @override
  String tabExtraHelperUnit(String qty, String unit, String total) {
    return '$qty × $unit = $total';
  }

  @override
  String tabExtraHelperLine(String amount) {
    return 'Line total: $amount';
  }

  @override
  String get tabExtraNoPrice =>
      'No price: the bill stays partial until you fill it in.';

  @override
  String tabLinkSharedTotal(String amount) {
    return 'shared · total $amount';
  }

  @override
  String tabLinkSharedPersonal(String amount) {
    return 'shared · only your share ($amount) is known';
  }

  @override
  String get tabLinkSameBottleTitle => 'Same bottle or another?';

  @override
  String tabLinkSameBottleBody(String count, String name, String total) {
    return '$count shared records of \"$name\" have the same total ($total). Was it the same bottle/pitcher or $count separate ones?\n\nThe total goes on the tab once per bottle; the app does not guess.';
  }

  @override
  String tabLinkSeparate(String count) {
    return '$count separate';
  }

  @override
  String get tabLinkSame => 'Same bottle';

  @override
  String get tabLinkTitle => 'Drinks already logged';

  @override
  String get tabLinkNote =>
      'They are only linked to the tab: the price stays on the record and a correction there applies here. Your records do not show everything the table ordered.';

  @override
  String get tabLinkAll => 'All';

  @override
  String get tabLinkNone => 'None';

  @override
  String tabLinkInclude(String count) {
    return 'Include $count on the tab';
  }

  @override
  String get tabSharePreview =>
      'Text preview. Nothing is sent until you tap Share.';

  @override
  String get tabShareIncludePayments => 'Include payments and balances';

  @override
  String get tabShareOffDefault => 'Off by default.';

  @override
  String get tabShareExcludes =>
      'It does not include address, photos, personal notes or any drunkenness report.';

  @override
  String get tabShareButton => 'Share';

  @override
  String get tabCopyText => 'Copy text';

  @override
  String get tabTextCopied => 'Text copied';

  @override
  String get tabShareSubject => 'Bill split';

  @override
  String get tabShareFailed => 'Could not open sharing. Copy the text.';

  @override
  String get tabCardHint => 'Optional: snacks, service and bill splitting.';

  @override
  String tabCardTotalPartial(String amount) {
    return 'Tab total (partial): $amount';
  }

  @override
  String tabCardTotal(String amount) {
    return 'Tab total: $amount';
  }

  @override
  String tabCardShareProv(String amount) {
    return 'Your share of the tab (provisional): $amount';
  }

  @override
  String tabCardShare(String amount) {
    return 'Your share of the tab: $amount';
  }

  @override
  String tabCardLineTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String tabCardLineKnown(String amount) {
    return 'Known total $amount';
  }

  @override
  String tabCardLineTotalShare(String amount, String mine) {
    return 'Total $amount · your share $mine';
  }

  @override
  String tabCardLineKnownShare(String amount, String mine) {
    return 'Known total $amount · your share $mine';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String statsPresetDays(String days) {
    return '$days days';
  }

  @override
  String get statsPresetCustom => 'Custom';

  @override
  String statsRangeLine(String from, String to, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$from to $to · $_temp0';
  }

  @override
  String get statsEmptyTitle => 'Nothing logged in this period';

  @override
  String get statsEmptyBody =>
      'It only means there are no records here, not that there was no outing.';

  @override
  String get statsSummary => 'Summary';

  @override
  String get statsOutingsOfPeriod => 'Outings in the period';

  @override
  String get statsDrinksLogged => 'Your logged drinks';

  @override
  String get statsDrinksOfPeriod => 'Your drinks in the period';

  @override
  String get statsPricedRecords => 'Records with a price';

  @override
  String get statsAlcoholByCategory => 'With alcohol, by category';

  @override
  String get statsNonAlcoholicSection => 'Water and non-alcoholic, separately';

  @override
  String get statsTopPlaces => 'Most visited places';

  @override
  String get statsPlacesNote =>
      'Places are only grouped when they are the same saved place; similar names are not merged.';

  @override
  String get statsMoods => 'After-outing reports';

  @override
  String get statsNoMoods => 'No report in this period.';

  @override
  String statsWithoutMood(String count) {
    return '$count without a report.';
  }

  @override
  String get statsMoodsNote =>
      'Reports are personal: they do not measure tolerance and do not indicate a safe limit.';

  @override
  String get statsPrevious => 'Previous period';

  @override
  String get statsFootnote =>
      'A day without records does not mean a day without drinking: the numbers reflect only what was logged.';

  @override
  String statsNoBaseline(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'No basis for comparison: no outings logged in the $days days before this period.',
      one: 'No basis for comparison: no outings logged on the day before this period.',
    );
    return '$_temp0';
  }

  @override
  String statsComparedTo(int days, String from, String to) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Compared with the $days days immediately before ($from to $to).',
      one: 'Compared with the day immediately before ($from to $to).',
    );
    return '$_temp0';
  }

  @override
  String get statsIncompleteCompare =>
      'Some drinks have no price in one of the periods: the real spend may be higher than reported.';

  @override
  String statsLineBefore(String now, String before) {
    return '$now  (before: $before)';
  }

  @override
  String get statsNoSavedPlace => 'No saved place';

  @override
  String get statsSavedPlaceFallback => 'Saved place';

  @override
  String get historyEmptyTitle => 'No finished outing';

  @override
  String get historyEmptyBody => 'When you end an outing, it shows up here.';

  @override
  String get historySearchHint => 'Search by place, drink or person';

  @override
  String get historyNoMatchTitle => 'No outing with these filters';

  @override
  String get historyNoMatchBody => 'Try another name, period or type.';

  @override
  String get historyPeriodAll => 'All';

  @override
  String get historyPeriodMonth => 'This month';

  @override
  String get historyAllTypes => 'All types';

  @override
  String get historyNoValues => 'No amounts';

  @override
  String get exportTitle => 'Export my data';

  @override
  String get exportIntro =>
      'Your records, as they are on the device. Nothing is sent to anyone: you choose where to keep it. No sign-in or session data goes into the files.';

  @override
  String get exportJsonTitle => 'Everything as JSON';

  @override
  String get exportJsonBody =>
      'Places, outings, drinks, compositions, tabs and your own drinks, with every detail. Fixed keys and codes, independent of the app language.';

  @override
  String get exportOutingsCsvTitle => 'Outings as CSV';

  @override
  String get exportOutingsCsvBody =>
      'One summary per outing. Separator \";\", decimal comma, UTF-8. Fixed columns and codes, independent of the app language.';

  @override
  String get exportDrinksCsvTitle => 'Drinks as CSV';

  @override
  String get exportDrinksCsvBody =>
      'One row per record. Empty field = unknown, never zero. Fixed columns and codes, independent of the app language.';

  @override
  String get exportButton => 'Export';

  @override
  String get exportCopy => 'Copy';

  @override
  String get exportCopied => 'Copied';

  @override
  String get exportShareUnavailable =>
      'Sharing is not available here. Use \"Copy text\" to keep the content.';

  @override
  String get exportFailed => 'Could not create the file.';

  @override
  String get exportJsonNote =>
      'Personal data exported by the person themselves. Amounts in cents (BRL), volumes in ml, times in UTC. Null fields are unknown, not zero.';

  @override
  String get shareCardTitle => 'Share summary';

  @override
  String get shareCardIntro =>
      'Choose what appears. The address and your personal report never go in, and nothing is published on its own.';

  @override
  String get shareCardWhat => 'What to show';

  @override
  String get shareCardPlaceName => 'Place name';

  @override
  String get shareCardPlaceNameHint => 'Just the name, never the address.';

  @override
  String get shareCardSpendHint =>
      'Some drinks have no price: the total is partial.';

  @override
  String get shareCardFailed =>
      'Could not open sharing. You can copy the summary text.';

  @override
  String get shareCardCaptureFailed =>
      'Could not create the image. You can copy the summary text.';

  @override
  String get shareCardMyOuting => 'My outing';

  @override
  String shareCardOthers(String count) {
    return '+ $count more';
  }

  @override
  String shareCardSpendText(String amount) {
    return 'Reported spend: $amount';
  }

  @override
  String shareCardSpendTextPartial(String amount) {
    return 'Reported spend: $amount (some drinks have no price)';
  }

  @override
  String shareCardSpendCard(String amount) {
    return 'Reported spend $amount';
  }

  @override
  String shareCardSpendCardPartial(String amount) {
    return 'Reported spend $amount (partial)';
  }

  @override
  String get trackingWeb =>
      'Not available in the browser: tracking only works inside the app.';

  @override
  String get trackingIosOld =>
      'Not available on this iOS version (it needs iOS 16.2 or newer).';

  @override
  String get trackingUnsupported => 'Not available on this device.';

  @override
  String get trackingDisabled => 'Turned off by you.';

  @override
  String get trackingPermission =>
      'System permission unavailable. Allow Bebômetro notifications in the device settings.';

  @override
  String get trackingSystemOffIos =>
      'Turned off in the iPhone settings (Live Activities).';

  @override
  String get trackingSystemOffAndroid =>
      'Notifications are turned off in the device settings.';

  @override
  String get trackingNoOuting => 'Available during an outing.';

  @override
  String trackingHidden(String action) {
    return 'Hidden for this outing. Use \"$action\" on the outing screen.';
  }

  @override
  String trackingDismissed(String action) {
    return 'You removed it from the lock screen for this outing. Use \"$action\" on the outing screen.';
  }

  @override
  String get trackingActive => 'Active now.';

  @override
  String get trackingPending =>
      'On, but it has not appeared yet. On iPhone it only starts with the app open; open the outing.';

  @override
  String get trackingAwaitingSave => 'waiting to be saved';

  @override
  String get trackingNoPermissionToast =>
      'No notification permission. You can allow it in the device settings.';

  @override
  String get trackingEnable => 'Turn on tracking';

  @override
  String get trackingEnableHint =>
      'Shows the elapsed time and count of the outing in progress on the lock screen. No sound or vibration.';

  @override
  String get trackingShowSpend => 'Show spending';

  @override
  String get trackingShowSpendHint =>
      'How much you reported spending on drinks, not the table total.';

  @override
  String get trackingShowPlace => 'Show place name';

  @override
  String get trackingShowPlaceHint =>
      'Off, it only shows \"Outing in progress\". The address never appears.';

  @override
  String get trackingCountNote =>
      'The counter shows how many alcoholic drink records you made (water does not count; a shared bottle is one record). They are not standard drinks and do not measure blood alcohol. The system may end the display on its own after a few hours, without ending the outing.';

  @override
  String get trackingOfferBody =>
      'See the elapsed time and drink count of the outing without opening the app. By default it shows neither spending nor the place name. No sound or vibration, and you can hide it in each outing or turn it off any time in Settings.';

  @override
  String get trackingOfferActivate => 'Turn on';

  @override
  String get trackingTitleFallback => 'Outing in progress';

  @override
  String trackingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alcoholic drink records',
      one: '1 alcoholic drink record',
      zero: 'No alcoholic drink records',
    );
    return '$_temp0';
  }

  @override
  String trackingSpend(String amount) {
    return '$amount reported';
  }

  @override
  String trackingSpendUnpriced(String amount, String count) {
    return '$amount reported · $count unpriced';
  }

  @override
  String get trackingOpen => 'Open';

  @override
  String get trackingAnother => 'One more';

  @override
  String trackingAnotherWith(String next) {
    return 'One more · $next';
  }

  @override
  String trackingAnotherA11y(String next) {
    return 'One more, $next';
  }

  @override
  String get trackingWater => 'Water';

  @override
  String get trackingChannelDescription =>
      'Elapsed time and count of the outing on the lock screen. No sound or vibration.';

  @override
  String get vesselCan => 'Can';

  @override
  String get vesselLongNeck => 'Long neck';

  @override
  String get vesselBottle => 'Bottle';

  @override
  String get vesselBeerGlass => 'Beer glass';

  @override
  String get vesselDraftMug => 'Draft beer mug';

  @override
  String get vesselShot => 'Shot';

  @override
  String get vesselWineGlass => 'Wine glass';

  @override
  String get vesselCocktailGlass => 'Cocktail glass';

  @override
  String get vesselWaterGlass => 'Water glass';

  @override
  String get vesselGlass => 'Glass';

  @override
  String get scenarioBar => 'Bar/pub';

  @override
  String get scenarioClub => 'Club';

  @override
  String get scenarioBarbecue => 'Barbecue';

  @override
  String get scenarioHome => 'Home';

  @override
  String get scenarioBeach => 'Beach';

  @override
  String get scenarioRestaurant => 'Restaurant';

  @override
  String tableSemanticsMany(String count, String name) {
    return '$count records of $name';
  }

  @override
  String get tableSemanticsTap => 'Tap to see the details.';

  @override
  String tableOthersTitle(String count) {
    return 'Other records ($count)';
  }

  @override
  String tableGroupTitle(String count, String name) {
    return '$count × $name';
  }

  @override
  String tableSemanticsOuting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Outing table with $count records',
      one: 'Outing table with 1 record',
    );
    return '$_temp0';
  }

  @override
  String tableSemanticsTable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Table with $count records',
      one: 'Table with 1 record',
    );
    return '$_temp0';
  }

  @override
  String get tableEmpty => 'The table is empty';

  @override
  String tableOverflowSemantics(String count) {
    return '$count more records. Tap to see the list.';
  }

  @override
  String get tableScenarioTitle => 'Table scenery';

  @override
  String get tableScenarioNote =>
      'Only the illustration changes. The place, the type and the records of the outing stay the same.';

  @override
  String get tableAboutTitle => 'About the table';

  @override
  String get tableAboutBody =>
      'Illustrative animation of the drinks logged.\n\nThe containers empty only as a visual effect, based on the time of the record. This does not measure how much you drank, does not indicate alcohol in the body and does not change any record: the totals come only from what you entered.';

  @override
  String get tableUnderstood => 'Got it';

  @override
  String get tipNoSensor => 'No motion sensor. Drag to tilt.';

  @override
  String get tipHintTilt => 'Tilt the phone to move the beer.';

  @override
  String get tipHintDrag => 'Drag to tilt.';

  @override
  String get tipNoReading => 'No motion reading. Drag to tilt.';

  @override
  String get tipReactMotion => 'React to motion';

  @override
  String get tipWebNote => 'Not available in the browser: drag to tilt.';

  @override
  String get tipOffNote => 'Off, you drag your finger to tilt.';

  @override
  String get tipBubbles => 'Bubbles and waves';

  @override
  String get tipBubblesNote => 'Turn off for a calmer beer.';

  @override
  String get tipLevel => 'Level';

  @override
  String get tipVisualNote =>
      'Visual only: the glass does not measure or log consumption, and filling it is not a goal.';

  @override
  String get tipSemantics =>
      'Beer filling the screen. Tilt the phone to move the liquid. Visual only, it does not log consumption.';

  @override
  String get tipRefill => 'Refill';

  @override
  String get tipRefillAgain => 'Fill again';

  @override
  String get gameNeverTitle => 'Never have I ever';

  @override
  String get gameNeverDesc => 'Whoever has done it, tells. No pressure.';

  @override
  String get gameMostTitle => 'Most likely to';

  @override
  String get gameMostDesc => 'The group points to who fits the sentence best.';

  @override
  String get gameTruthTitle => 'Truth or dare';

  @override
  String get gameTruthDesc => 'Each in their turn, with the option to skip.';

  @override
  String get gameModeLight => 'Light';

  @override
  String get gameModeAdult => '18+';

  @override
  String get gameKindCard => 'Card';

  @override
  String get gameKindTruth => 'Truth';

  @override
  String get gameKindDare => 'Dare';

  @override
  String get resenhaIntro =>
      'Table games that work without internet. The cards never ask you to drink and do not log any drink.';

  @override
  String get resenhaInProgress => 'Game in progress';

  @override
  String resenhaSession(int count, String mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players · $mode mode',
      one: '1 player · $mode mode',
    );
    return '$_temp0';
  }

  @override
  String get resenhaResume => 'Resume';

  @override
  String get resenhaGames => 'Games';

  @override
  String get resenhaPlay => 'Just for fun';

  @override
  String get resenhaTipTitle => 'Tilt the glass';

  @override
  String get resenhaTipBody =>
      'The screen becomes a glass: tilt the phone. Visual only.';

  @override
  String get resenhaCards => 'Cards';

  @override
  String get resenhaMyCards => 'My cards';

  @override
  String resenhaMyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count created by you',
      one: '1 created by you',
      zero: 'None created by you',
    );
    return '$_temp0';
  }

  @override
  String get gameAlreadyPlayer => 'Someone already has that nickname.';

  @override
  String get gameMaxPlayers => 'At most 20 players.';

  @override
  String get gameWhoPlays => 'Who is playing?';

  @override
  String get gameAddPlayerTooltip => 'Add player';

  @override
  String gameNeedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add at least $count players.',
      one: 'Add at least 1 player.',
    );
    return '$_temp0';
  }

  @override
  String gameRemovePlayer(String name) {
    return 'Remove $name';
  }

  @override
  String get gameMode => 'Mode';

  @override
  String get gameLightNote => 'No sexual content. For any group.';

  @override
  String get gameAdultNote =>
      'Mixes the light cards with flirting and humor for adults. Nothing explicit, and everything can be skipped without penalty.';

  @override
  String get gameAdultConfirm =>
      'I confirm that everyone playing is an adult (18+) and agreed to the 18+ mode.';

  @override
  String get gameNoDrinkNote =>
      'The cards never ask you to drink, take shots or pile up drinks, and nothing here logs drinks in your outing.';

  @override
  String get gameStart => 'Start';

  @override
  String get gameFinishTitle => 'End the game?';

  @override
  String get gameFinishBody =>
      'It will not be saved. To just take a break, go back and resume later.';

  @override
  String get gameKeepPlaying => 'Keep playing';

  @override
  String get gameFinish => 'End';

  @override
  String gameModePill(String mode) {
    return '$mode mode';
  }

  @override
  String gameCardsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards left',
      one: '1 card left',
    );
    return '$_temp0';
  }

  @override
  String get gameOutOfCards => 'Out of cards';

  @override
  String get gameOutOfCardsHint =>
      'You can shuffle everything again or end the game.';

  @override
  String get gameReshuffle => 'Shuffle again';

  @override
  String gameReaderCall(String name) {
    return '$name, read the question';
  }

  @override
  String get gameReaderLabel => 'Your turn to read';

  @override
  String gameResponder(String name) {
    return 'Answers: $name';
  }

  @override
  String get gameEveryoneAnswers => 'Everybody answers';

  @override
  String get gamePassTurn => 'Pass the turn';

  @override
  String get gameChangeReader => 'Change reader';

  @override
  String get gameChooseReader => 'Who reads?';

  @override
  String get gameImportFromOuting => 'People from the outing';

  @override
  String get gameImportTitle => 'Who from the outing plays?';

  @override
  String get gameImportUse => 'Use selected';

  @override
  String get bafoStart => 'Start';

  @override
  String get bafoHoldOption => 'I prefer holding a button (no microphone)';

  @override
  String get bafoHoldButton => 'Hold to play';

  @override
  String get bafoDenied =>
      'No microphone access. You can still play by holding the button.';

  @override
  String get bafoUnsupported =>
      'This device cannot use the microphone here. You can still play by holding the button.';

  @override
  String get bafoStop => 'Stop';

  @override
  String get bafoAgain => 'Try again';

  @override
  String get bafoDone => 'Done';

  @override
  String get homeYourDrinks => 'Your drinks';

  @override
  String outingRecordsTable(int count) {
    return 'Table records ($count)';
  }

  @override
  String get summaryPeopleTitle => 'People and bill';

  @override
  String summaryPersonLine(String name, String share, String paid) {
    return '$name · share $share · paid $paid';
  }

  @override
  String summaryPersonDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks',
      one: '1 drink',
      zero: 'No drinks',
    );
    return '$_temp0';
  }

  @override
  String drinkCountYours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks of yours',
      one: '1 drink of yours',
    );
    return '$_temp0';
  }

  @override
  String get outingEditTitle => 'Edit outing';

  @override
  String get outingEditKind => 'Kind of outing';

  @override
  String get outingEditStart => 'Start';

  @override
  String get outingStartFuture => 'The start cannot be in the future.';

  @override
  String get outingStartAfterEnd =>
      'The start must be before the end of the outing.';

  @override
  String get outingStartAfterRecords =>
      'There are drinks logged before that time. Pick a start before the first record.';

  @override
  String get outingDelete => 'Delete outing';

  @override
  String get outingDeleteTitle => 'Delete this outing?';

  @override
  String get outingDeleteBody =>
      'The outing, its drink records, the bill and the people disappear from your lists and your other devices. This cannot be undone.';

  @override
  String get outingDeleted => 'Outing deleted';

  @override
  String gameTurnOf(String name) {
    return 'Turn: $name';
  }

  @override
  String get gameTruthOrDareQ => 'Truth or dare?';

  @override
  String get gameNoTruthLeft => 'Out of truth cards. Pick another.';

  @override
  String get gameNoDareLeft => 'Out of dare cards. Pick another.';

  @override
  String get gameOptional => 'Optional: you can skip it without penalty.';

  @override
  String get gameSkip => 'Skip';

  @override
  String get gameNext => 'Next';

  @override
  String gameSavedNote(String hub) {
    return 'The game is saved: you can leave and resume it in $hub.';
  }

  @override
  String get gameNewCard => 'New card';

  @override
  String get gameCardHintNever => 'Never have I ever…';

  @override
  String get gameCardHintMost => 'Who is most likely to…';

  @override
  String get gameCardText => 'Card text';

  @override
  String get gameCardRules =>
      'No exposure, recording, coercion, driving, violence, dangerous activities or drinking as a penalty.';

  @override
  String get gameCardCreated => 'Card created';

  @override
  String get gameCardDeleteTitle => 'Delete this card?';

  @override
  String get gameCardsEmptyTitle => 'No cards of yours yet';

  @override
  String get gameCardsEmptyBody =>
      'Create cards for your games. They join the draw in the next matches.';

  @override
  String get gameCardDelete => 'Delete card';

  @override
  String gameCardLine(String game, String mode) {
    return '$game · $mode';
  }

  @override
  String gameCardLineKind(String game, String mode, String kind) {
    return '$game · $mode · $kind';
  }

  @override
  String get gameCardNeedText => 'Write the card text.';

  @override
  String get gameCardTooLong => 'Text too long.';

  @override
  String get provenanceOfficial => 'Manufacturer / official sheet';

  @override
  String get provenanceLabel => 'Label in a secondary source';

  @override
  String get provenancePackagingRegistry => 'Public package registry';

  @override
  String get provenanceSecondary => 'Secondary source';

  @override
  String get provenanceRecipe => 'Reference recipe';

  @override
  String get provenanceUser => 'Your information';

  @override
  String get provenanceSuggestion => 'Suggested volume';

  @override
  String get provenanceGeneric => 'Generic reference';

  @override
  String get provenanceGeneral => 'Product\'s general source';

  @override
  String get provenanceSuggestionLine =>
      'Common sizes to make logging easier, not documented packages of this product.';

  @override
  String get aboutDataTitle => 'About this data';

  @override
  String get aboutDataFallback =>
      'No specific source for this field; the product\'s general source applies.';

  @override
  String get aboutDataGeneralTitle => 'Product\'s general source';

  @override
  String get aboutDataVariantsTitle => 'Documented ABVs (not averaged)';

  @override
  String get aboutDataRegistryNote =>
      'The registry shows the package existed on the market; it does not mean it is sold today.';

  @override
  String get aboutDataOpenFailed =>
      'Could not open the address. Copy it and open it in a browser.';

  @override
  String aboutDataMarket(String market) {
    return 'Market: $market';
  }

  @override
  String aboutDataConsulted(String date) {
    return 'Consulted on $date';
  }

  @override
  String get pendingTitle => 'Pending records';

  @override
  String get pendingIntro =>
      '\"One more\" taps on the lock screen that could not be saved on their own. Nothing goes into your history until you confirm it here.';

  @override
  String get pendingEmpty => 'No pending records.';

  @override
  String get pendingReasonEnded =>
      'The outing ended before this was saved. Review it to add it there.';

  @override
  String get pendingReasonOutside =>
      'The tap time is outside the outing\'s period. Adjust the time in the review.';

  @override
  String get pendingReasonNoDrink =>
      'It is not possible to tell which drink to repeat. Choose the drink and review it.';

  @override
  String get pendingReasonNotPersonal =>
      'The order the button showed was given to someone else or became a shared bottle. Choose what to log for you and review it.';

  @override
  String get pendingReasonFailed => 'It could not be saved. You can try again.';

  @override
  String get pendingReasonUnsupported =>
      'This version of the app does not recognise this request. You can discard it.';

  @override
  String get pendingReasonInReview => 'Being reviewed.';

  @override
  String get pendingDrinkUnknown => 'Unidentified drink';

  @override
  String get pendingRetry => 'Try again';

  @override
  String get pendingRetryFailed => 'It still could not be saved.';

  @override
  String get pendingSaved => 'Saved.';

  @override
  String get pendingDiscard => 'Discard';

  @override
  String get pendingDiscardTitle => 'Discard this tap?';

  @override
  String get pendingDiscardBody =>
      'The request leaves this list. No record already saved is deleted.';

  @override
  String get pendingDiscarded => 'Discarded.';

  @override
  String get pendingNoDrinkToChoose =>
      'This outing has no alcoholic drink recorded to repeat.';

  @override
  String get pendingChooseTitle => 'Which drink was it?';

  @override
  String get pendingChooseDrink => 'Choose drink';

  @override
  String get pendingReviewAdd => 'Review and add';

  @override
  String pendingNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lock-screen taps need you',
      one: '1 lock-screen tap needs you',
    );
    return '$_temp0';
  }

  @override
  String pendingOutingOn(String date) {
    return 'Outing on $date';
  }

  @override
  String pendingTappedAt(String time) {
    return 'Tapped on $time';
  }

  @override
  String pendingReviewNote(String time) {
    return 'Original lock-screen tap: $time';
  }

  @override
  String get entryFromLockScreen => 'Added from the lock screen';

  @override
  String entryOriginalTap(String time) {
    return 'Original tap: $time';
  }

  @override
  String entryOriginalTapCorrected(String time) {
    return 'Time corrected. Original tap: $time';
  }

  @override
  String get syncLabelOffline => 'No connection';

  @override
  String get startWho => 'Who is at the table?';

  @override
  String get startWhoHint =>
      'You are already in. Add who will order or split the bill; you can change it later.';

  @override
  String get startWhoName => 'Person\'s name';

  @override
  String get startWhoAdd => 'Add';

  @override
  String startWhoRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get orderTitle => 'New order';

  @override
  String get orderWhat => 'What was ordered?';

  @override
  String get orderNameLabel => 'Order name';

  @override
  String get orderNameHint => 'Type the name or search the catalog';

  @override
  String orderFromCatalog(String name) {
    return 'From the catalog: $name';
  }

  @override
  String get orderUseTextOnly => 'Use the text only';

  @override
  String orderMore(String name) {
    return 'One more for $name';
  }

  @override
  String orderLess(String name) {
    return 'One less for $name';
  }

  @override
  String get orderPrice => 'Price';

  @override
  String get orderPriceEach => 'Each';

  @override
  String get orderPriceTotal => 'Whole order';

  @override
  String get orderPriceEachLabel => 'Price of each';

  @override
  String get orderPriceTotalLabel => 'Total price of the order';

  @override
  String orderLineSummary(int count, String price, String total) {
    return '$count × $price = $total';
  }

  @override
  String orderSummaryFor(String who) {
    return 'For: $who';
  }

  @override
  String get orderSave => 'Add to the outing';

  @override
  String get orderErrName => 'Say what was ordered.';

  @override
  String get orderErrPrice => 'Enter the price or choose another option.';

  @override
  String orderAdded(String summary) {
    return 'Added: $summary';
  }

  @override
  String get actionDrink => 'Drink';

  @override
  String get actionFood => 'Food';

  @override
  String get actionOther => 'Other item';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabPeople => 'By person';

  @override
  String get tabBill => 'Bill';

  @override
  String get tileItems => 'Items';

  @override
  String get tileTableTotal => 'Table total';

  @override
  String get tileYourShare => 'Your share';

  @override
  String get tileTheirShare => 'Share';

  @override
  String billTotalKnownShort(String total) {
    return '$total+';
  }

  @override
  String ordersTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: 'Orders',
    );
    return '$_temp0';
  }

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody =>
      'Use Drink, Food or Other item to log the first one.';

  @override
  String orderEachPrice(String price) {
    return '$price each';
  }

  @override
  String get ordersEveryone => 'Everyone';

  @override
  String get ordersUnassigned => 'no person';

  @override
  String get ordersMoveTo => 'Give to someone else';

  @override
  String get ordersDeleteOne => 'Delete one';

  @override
  String noticeMovedTo(String name) {
    return 'Given to $name';
  }

  @override
  String get moveCustomTitle => 'This order has a typed cost split';

  @override
  String moveCustomBody(String name) {
    return 'Update the cost split to $name or keep it as it is?';
  }

  @override
  String moveFollow(String name) {
    return 'Follow $name';
  }

  @override
  String get moveKeepSplit => 'Keep the split';

  @override
  String repeatFor(String who) {
    return 'One more for $who';
  }

  @override
  String repeatLeftTitle(String names) {
    return '$names left';
  }

  @override
  String get repeatLeftBody =>
      'This order is not repeated for someone who left. Choose who it is for.';

  @override
  String get repeatLeftAdjust => 'Choose people';

  @override
  String get tableIllustrated => 'Illustrated table';

  @override
  String get tableIllustratedHint =>
      'Just a picture of the orders; the list and the amounts are above.';

  @override
  String get legacyTitle => 'This outing already has a bill';

  @override
  String get legacyBody =>
      'To assign orders to people, switch to table mode: every record of the outing goes on the bill, split by who drank it. Current links, extras and payments stay.';

  @override
  String get legacyAction => 'Use the table';

  @override
  String get extraWhoPresent => 'Everyone present';

  @override
  String get peopleTable => 'Table';

  @override
  String get peopleLeftTag => 'left';

  @override
  String get peopleAdd => 'Person';

  @override
  String get peopleAddTitle => 'Add a person';

  @override
  String get peopleRename => 'Rename';

  @override
  String get peopleMarkLeft => 'Mark as left';

  @override
  String get peopleMarkLeftHint =>
      'Stays on past orders and is not picked by default for new items.';

  @override
  String get peopleBack => 'Back at the table';

  @override
  String get peopleBackHint => 'Is picked again for new items.';

  @override
  String get peopleRemove => 'Remove from the table';

  @override
  String get peopleRemoveHint =>
      'Nothing was drunk, split or paid for this person.';

  @override
  String get peopleRemoveBlocked =>
      'It has orders, a share or a payment: mark as left instead.';

  @override
  String peopleUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records belong to people who are not on the table',
      one: '1 record belongs to someone who is not on the table',
    );
    return '$_temp0: they stay unassigned, never yours.';
  }

  @override
  String get peopleDrinksCost => 'Drinks';

  @override
  String get peopleFoodCost => 'Food and other';

  @override
  String get peopleDiscount => 'Discount';

  @override
  String get peopleService => 'Service';

  @override
  String get peopleShare => 'Share';

  @override
  String get peoplePaidToVenue => 'Paid to the venue';

  @override
  String get peopleCoveredByPayment =>
      'Covered by another payment: the venue is settled';

  @override
  String peopleStillOwes(String amount) {
    return '$amount of the share is still unpaid';
  }

  @override
  String peoplePaidMore(String amount) {
    return 'Paid $amount above the share';
  }

  @override
  String get peopleEven => 'Share paid';

  @override
  String peopleSeeOrders(String name) {
    return 'See $name\'s orders';
  }

  @override
  String get billSubtotal => 'Subtotal';

  @override
  String get billSubtotalKnown => 'Known subtotal';

  @override
  String get billDiscount => 'Discount';

  @override
  String billService(String rate, String base) {
    return 'Service $rate on $base';
  }

  @override
  String get billTotal => 'Bill total';

  @override
  String get billTotalKnown => 'Known total';

  @override
  String get billYourShare => 'Your share';

  @override
  String billPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items without a price: the bill is partial',
      one: '1 item without a price: the bill is partial',
    );
    return '$_temp0';
  }

  @override
  String billUnassigned(String amount) {
    return '$amount still unassigned';
  }

  @override
  String billOverAssigned(String amount) {
    return 'Over-assigned by $amount';
  }

  @override
  String get billPaidToVenue => 'Paid to the venue';

  @override
  String get billSettled => 'Venue settled';

  @override
  String get billDue => 'Still due to the venue';

  @override
  String billOverpaid(String amount) {
    return 'Overpaid to the venue by $amount';
  }

  @override
  String get billNoTransfers =>
      'The app does not charge, run Pix or say who should pay whom.';

  @override
  String get billSettings => 'Service, discount and items';

  @override
  String get billSplitAndPay => 'Split and log payments';

  @override
  String get orderOpenCatalog => 'Full catalog, label or menu';

  @override
  String get outingRestoreConflictTitle => 'Another outing is running';

  @override
  String get outingRestoreConflictBody =>
      'This outing was running when it was deleted. It can come back already finished, at the time it was deleted. The current outing is not changed.';

  @override
  String get outingRestoreAsEnded => 'Restore as finished';

  @override
  String get outingRestored => 'Outing restored';

  @override
  String get outingRestoredEnded => 'Outing restored as finished';

  @override
  String get outingRestoreNothing =>
      'Nothing to undo: the outing was already restored or has changed.';

  @override
  String get outingRestoreFailed => 'Could not restore the outing. Try again.';

  @override
  String get conflictFieldName => 'Name';

  @override
  String get conflictFieldType => 'Type';

  @override
  String get conflictFieldAddress => 'Address';

  @override
  String get conflictFieldCity => 'City';

  @override
  String get conflictFieldFavorite => 'Favorite';

  @override
  String get conflictFieldStatus => 'Status';

  @override
  String get conflictFieldMap => 'Map point';

  @override
  String get conflictFieldCategory => 'Category';

  @override
  String get conflictFieldBrand => 'Brand';

  @override
  String get conflictFieldStyle => 'Style';

  @override
  String get conflictFieldVolume => 'Volume';

  @override
  String get conflictFieldAbv => 'Alcohol content';

  @override
  String get conflictFieldIngredients => 'Ingredients';

  @override
  String get conflictFieldRecipe => 'Recipe composition';

  @override
  String get conflictNotInformed => 'not informed';

  @override
  String get conflictYes => 'yes';

  @override
  String get conflictNo => 'no';

  @override
  String get conflictArchived => 'archived';

  @override
  String get conflictActive => 'active';

  @override
  String get conflictPointSet => 'set';

  @override
  String get conflictPointNone => 'no point';

  @override
  String get conflictDiffers => 'different';

  @override
  String get conflictLocalDeleted => 'Deleted on this device';

  @override
  String get conflictKindPlace => 'Place';

  @override
  String get conflictKindDrink => 'Personal drink';

  @override
  String get conflictKindRecipe => 'Personal recipe';

  @override
  String get conflictWhatEdit => 'Edited on two devices.';

  @override
  String get conflictWhatCloudDeleted =>
      'Edited on this device, but deleted in the cloud.';

  @override
  String get conflictWhatLocalDeleted =>
      'Deleted on this device, but edited in the cloud.';

  @override
  String get conflictEffectKeepLocal =>
      'This device\'s version becomes the one in the cloud and on other devices. The cloud version is replaced.';

  @override
  String get conflictEffectUseRemote =>
      'The cloud version becomes the one here. Your edit on this device is discarded.';

  @override
  String get conflictEffectRestore =>
      'Undoes the deletion made in the cloud: it exists again on all devices, with this device\'s version.';

  @override
  String get conflictEffectAcceptDeletion =>
      'The deletion applies here too and your edit is discarded. Records already made keep their own data.';

  @override
  String get conflictEffectKeepDeletion =>
      'Your deletion applies in the cloud and on other devices. The cloud edit is discarded. Records already made keep their own data.';

  @override
  String get conflictEffectUndeleteRemote =>
      'The version edited in the cloud exists again here. Your deletion is discarded.';

  @override
  String get conflictKeepDeletion => 'Keep the deletion';

  @override
  String get conflictDeletionKept => 'Deletion kept';

  @override
  String get conflictUseRemoteRestore => 'Use the cloud one (it exists again)';

  @override
  String get orderEditTitle => 'Edit order';

  @override
  String get orderSaveEdit => 'Save changes';

  @override
  String get orderQuantity => 'Quantity';

  @override
  String get orderKindAlcoholic => 'Drink';

  @override
  String get orderKindSoft => 'No alcohol';

  @override
  String get orderKindFood => 'Food';

  @override
  String get orderKindOther => 'Other';

  @override
  String get orderWhoConsumed => 'Who had it?';

  @override
  String get orderConsumedHint =>
      'Who took part. This does not change who pays.';

  @override
  String get orderWhoPays => 'Who pays?';

  @override
  String get orderPayersHint =>
      'Who bears the cost. This does not change who had it.';

  @override
  String get orderPayEqual => 'Split equally';

  @override
  String get orderPayCustom => 'Custom amounts';

  @override
  String orderPayerAmountLabel(String name) {
    return '$name\'s amount';
  }

  @override
  String orderPayerBears(String name, String amount) {
    return '$name pays $amount';
  }

  @override
  String get orderPayersPending =>
      'No amount yet: who pays is kept and the amount stays pending.';

  @override
  String get orderPayersExact => 'The sum matches the total.';

  @override
  String orderPayersMissing(String amount) {
    return '$amount left to assign.';
  }

  @override
  String orderPayersOver(String amount) {
    return '$amount over the total.';
  }

  @override
  String get orderErrNobodyConsumed => 'Pick who had it.';

  @override
  String get orderErrNobodyPays => 'Pick who pays.';

  @override
  String orderErrUnits(int count) {
    return 'The units per person must add up to $count.';
  }

  @override
  String get orderErrPayersSum => 'The amounts must add up to the order total.';

  @override
  String get orderUnitsPerPerson => 'Set units per person';

  @override
  String get orderUnitsHint => 'Without it, each unit is one shared order.';

  @override
  String orderSummaryPays(String who) {
    return 'Pays: $who';
  }

  @override
  String get orderBalanceTitle => 'Balances updated';

  @override
  String get orderBalanceBody =>
      'Recorded payments were kept. Balance of those who changed (before → after):';

  @override
  String orderBalanceLine(String name, String before, String after) {
    return '$name: $before → $after';
  }

  @override
  String ordersPays(String names) {
    return 'Pays: $names';
  }

  @override
  String get tileOrders => 'Orders';

  @override
  String get tileShared => 'Shared';

  @override
  String get peopleDrankNothing => 'No orders yet.';

  @override
  String peopleOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String peopleSharedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Took part in $count shared orders',
      one: 'Took part in 1 shared order',
    );
    return '$_temp0';
  }

  @override
  String statsSharedNote(String count) {
    return '$count shared';
  }

  @override
  String tableSharedPeople(String count) {
    return 'Order shared by $count people';
  }

  @override
  String get bafoTitle => 'Bafômetro';

  @override
  String get bafoHubBody =>
      'Pick someone from the outing, blow and watch the meter.';

  @override
  String get bafoWho => 'Who is blowing?';

  @override
  String get bafoEmptyTitle => 'No outing yet';

  @override
  String get bafoEmptyBody =>
      'Start an outing and add the people to use the Bafômetro.';

  @override
  String get bafoSimulation => 'Simulation';

  @override
  String get bafoAnother => 'Someone else';

  @override
  String bafoMeterSemantics(String name) {
    return 'Meter of $name';
  }

  @override
  String get bafoBlowPrompt => 'Blow into the microphone';

  @override
  String get bafoHoldPrompt => 'Hold the button';

  @override
  String get bafoHintLouder => 'Get closer to the microphone.';
}
