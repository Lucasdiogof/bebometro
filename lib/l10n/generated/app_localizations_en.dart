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
  String get accountLegacy => 'Old records on this device';

  @override
  String get accountLegacyDecide =>
      'Old records on this device: import or export';

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
  String alcoholAtLeast(String amount) {
    return 'at least $amount';
  }

  @override
  String get alcoholDeclared => 'Declared pure alcohol';

  @override
  String get alcoholExplain =>
      'Calculated only from what was entered: volume × ABV for simple drinks and amount × ABV of each component for cocktails. For cocktails the declared recipe counts, not what the bar served. It is not blood alcohol concentration and doesn\'t tell whether you can drive.';

  @override
  String alcoholIncompletePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records with unknown ABV or amount: the total is a minimum',
      one: '1 record with unknown ABV or amount: the total is a minimum',
    );
    return '$_temp0';
  }

  @override
  String alcoholNoVolumePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records without volume (not counted in the volume)',
      one: '1 record without volume (not counted in the volume)',
    );
    return '$_temp0';
  }

  @override
  String get appName => 'Bebômetro';

  @override
  String get authAlreadyConfirmed => 'I\'ve confirmed: sign in';

  @override
  String get authCancelAndLeave => 'Cancel and sign out';

  @override
  String get authCheckEmail => 'Check the e-mail you typed.';

  @override
  String authCheckInboxBody(String email) {
    return 'We sent a link to $email. Open it on this device to finish.';
  }

  @override
  String get authCheckInboxTitle => 'Check your e-mail';

  @override
  String get authChoosePassword => 'Choose your password';

  @override
  String get authChoosePasswordBody =>
      'E-mail confirmed. Now choose the password to sign in on other devices.';

  @override
  String get authCloudDown =>
      'Couldn\'t reach the server right now. Check the internet and try again in a moment.';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConvertBody =>
      'Your records on this device stay with you. After confirming the e-mail, you choose the password.';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateWithRecords => 'Create an account with your records';

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
  String get authLinkingDisabled =>
      'Converting the old account isn\'t enabled on the server yet. You can create a new account and import the records later.';

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
  String get authNoOldSession => 'There is no old session to convert.';

  @override
  String get authNotArrived =>
      'Didn\'t arrive? Check the spam folder and that the address is right. The link is valid for a limited time.';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHelper =>
      'At least 8 characters, with letters and numbers.';

  @override
  String get authPasswordMin => 'Use at least 8 characters.';

  @override
  String get authPasswordMix => 'Mix letters and numbers.';

  @override
  String get authPasswordsDiffer => 'The passwords don\'t match.';

  @override
  String get authRecoverBody =>
      'We\'ll send a link to create a new password. Open it on this device.';

  @override
  String get authRecoverSent =>
      'If there is an account with this e-mail, the link arrives in a moment. Check the spam folder too.';

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
  String get authResent => 'We sent another e-mail. Check the spam folder too.';

  @override
  String get authSamePassword =>
      'The new password must be different from the current one.';

  @override
  String get authSavePassword => 'Save password';

  @override
  String get authSendAgain => 'Send again';

  @override
  String get authSendConfirmation => 'Send confirmation';

  @override
  String get authSendLink => 'Send link';

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
      'We\'ll send a link to confirm the e-mail. Your name and e-mail are only used for your account.';

  @override
  String get authSignupDisabled =>
      'Sign-up is turned off on the server right now.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authTooManyShort => 'Too many attempts. Wait a few minutes.';

  @override
  String get authUseOtherEmail => 'Use another e-mail';

  @override
  String get authUseOtherEmailBack => 'Go back and use another e-mail';

  @override
  String get authWeakPassword =>
      'Weak password. Use at least 8 characters, mixing letters and numbers.';

  @override
  String get authWrongCredentials => 'Wrong e-mail or password.';

  @override
  String get authYourAccount => 'your account';

  @override
  String get authYourEmail => 'your e-mail';

  @override
  String get budgetDialogTitle => 'Drinks budget';

  @override
  String get budgetEdit => 'Edit budget';

  @override
  String budgetLeft(String amount) {
    return '$amount of the budget left.';
  }

  @override
  String budgetLeftIncomplete(String amount, int count) {
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
      'Optional. It only compares with the spending you entered.';

  @override
  String budgetOver(String amount) {
    return '$amount over budget.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'The entered spending is already $amount over budget and some prices are still missing.';
  }

  @override
  String budgetReached(String budget, int percent, String spent) {
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
  String conflictTabPayments(String amount, int count) {
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
  String conflictTabPeople(int extras, int people) {
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
  String get entryAlcoholIncomplete => 'incomplete alcohol';

  @override
  String get entryCorrect => 'Correct';

  @override
  String get entryOptions => 'Record options';

  @override
  String entrySharedPart(int count, String mine, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'your part $mine of $total ($count people)',
      one: 'your part $mine of $total (1 person)',
    );
    return '$_temp0';
  }

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
  String get glassBigSubtitle => 'The entered volume, added up in one glass.';

  @override
  String get glassBigTitle => 'Big glass (optional)';

  @override
  String get glassTipPlay => 'Play tipping the glass';

  @override
  String get groupRecipeAdjusted => 'adjusted recipe';

  @override
  String groupSharedPart(String mine, String total) {
    return '$mine yours of $total';
  }

  @override
  String groupTimes(int count) {
    return '$count×';
  }

  @override
  String get groupVolumeUnknown => 'unknown volume';

  @override
  String get groupVolumeUnknownShort => 'volume ?';

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
  String get homeDrinks => 'Drinks';

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
  String get homeInformedSpent => 'Entered spending';

  @override
  String get homeLastOuting => 'Last outing';

  @override
  String get homeNoneThisMonth => 'No outing finished this month yet.';

  @override
  String get homeOutingRunning => 'Outing in progress';

  @override
  String get homeOutings => 'Outings';

  @override
  String get homeSpent => 'Spent';

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
  String get legacyAnonBody =>
      'If you already used the app on this device, your records were kept. Create your account to keep them and get them back on another device.';

  @override
  String get legacyAnonCreate => 'Create an account with my records';

  @override
  String get legacyAnonHaveAccount => 'I already have an account';

  @override
  String get legacyAnonHaveAccountHint =>
      'The old records stay apart on this device; you decide later whether to import them into the account.';

  @override
  String get legacyAnonTitle => 'Bebômetro now uses accounts';

  @override
  String get legacyAnonView => 'View or export the old records';

  @override
  String get legacyDrinks => 'Drinks';

  @override
  String get legacyExport => 'Export old records (JSON)';

  @override
  String get legacyImport => 'Import into my account';

  @override
  String get legacyImportAsEnded => 'Import as finished';

  @override
  String get legacyImportExplain =>
      'Importing copies the records into the current account with new identifiers (photos are uploaded again). An old anonymous account can\'t be recovered without its session: what is imported is what is on this device.';

  @override
  String get legacyImportFailed =>
      'The import didn\'t finish. Nothing was deleted; try again.';

  @override
  String legacyImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Import finished: $count records copied into your account. The old copy is still kept on this device.',
      one: 'Import finished: 1 record copied into your account. The old copy is still kept on this device.',
    );
    return '$_temp0';
  }

  @override
  String get legacyKeep => 'Keep apart for now';

  @override
  String get legacyKept =>
      'The old records stay apart on this device. You can import them any time from \"My account\".';

  @override
  String get legacyNeverSent => 'Never uploaded';

  @override
  String get legacyNone => 'There are no old records on this device.';

  @override
  String get legacyNotice =>
      'There are old records on this device. They are kept: after signing in you can import them. Tap to view or export.';

  @override
  String legacyOfferBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'There are $count outings from before Bebômetro used accounts. They\'re kept and won\'t go into your account unless you choose.',
      one: 'There is 1 outing from before Bebômetro used accounts. It\'s kept and won\'t go into your account unless you choose.',
    );
    return '$_temp0';
  }

  @override
  String get legacyOfferOpen => 'Review and decide';

  @override
  String get legacyOfferTitle => 'Old records on this device';

  @override
  String get legacyOutings => 'Outings';

  @override
  String get legacyStatusAdopted =>
      'These records already belong to your account (created from them).';

  @override
  String get legacyStatusImported =>
      'These records were already imported into an account. The old copy stays here for safety.';

  @override
  String get legacyStatusKept => 'You chose to keep these records apart.';

  @override
  String get legacyStatusPending =>
      'Records made before Bebômetro used accounts. They weren\'t deleted.';

  @override
  String get legacyTitle => 'Old records';

  @override
  String get legacyTwoActiveBody =>
      'Your account already has an outing in progress and so do the old records. To import, the old outing comes in as finished now. Its drinks stay with it, without mixing.';

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
  String outingAlcoholIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count with incomplete alcohol',
      one: '1 with incomplete alcohol',
    );
    return '$_temp0';
  }

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
  String outingNoVolume(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count without volume',
      one: '1 without volume',
    );
    return '$_temp0';
  }

  @override
  String get outingNotFound => 'This outing wasn\'t found.';

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
  String outingTypeSince(String time, String type) {
    return '$type · since $time';
  }

  @override
  String get outingYourVolume => 'Your volume';

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
  String repeatAdjusted(String name) {
    return '$name (adjusted)';
  }

  @override
  String get repeatButton => 'One more';

  @override
  String repeatSemantics(String drink) {
    return 'One more: $drink';
  }

  @override
  String repeatYourPart(String amount) {
    return 'your part $amount';
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
  String get restoreBody =>
      'Bringing your outings, drinks, places and tabs from the cloud.';

  @override
  String get restoreConnecting => 'Connecting…';

  @override
  String get restoreFailedBody =>
      'No connection to the cloud. Nothing was lost: try again when you have internet.';

  @override
  String get restoreFailedTitle => 'Couldn\'t restore right now';

  @override
  String restoreReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records received so far',
      one: '1 record received so far',
    );
    return '$_temp0';
  }

  @override
  String get restoreTitle => 'Restoring your history';

  @override
  String get restoreUseApp => 'Use the app meanwhile';

  @override
  String get restoreUseAppHint =>
      'If you continue now, the history shows up as it arrives. New records are saved on this device and uploaded later.';

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
  String staleBody(String duration, String name, String start) {
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
  String get summarySpentOnDrinks => 'Spending logged on drinks';

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
  String volumeKnownPlusUnknown(int count, String known) {
    return '$known (+$count without volume)';
  }

  @override
  String get volumeUnknown => 'unknown';

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
  String get catalogRecipeSaved => 'Recipe saved in My drinks';

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
  String get entryDeleteTitle => 'Delete record?';

  @override
  String get entryDeleteBody => 'It leaves the outing and the summary.';

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
  String get entryLogCocktail => 'Log cocktail';

  @override
  String get entryLogDrink => 'Log drink';

  @override
  String get entryDrinkAndSize => 'Drink and size';

  @override
  String get entryGenericSpirit =>
      'Suggested shots, editable: they are not official measures of any venue. The bottle is the package, not your shot.';

  @override
  String get entryGenericSizes =>
      'Suggested sizes: this product has no verified packages in the catalog. Check the package.';

  @override
  String get entryVolume => 'Volume (ml)';

  @override
  String get entryOtherSize => 'Other size (ml)';

  @override
  String get entryAbvOptional => 'Alcohol content (optional)';

  @override
  String get entryAbvBlank => 'Blank = unknown (not counted as zero).';

  @override
  String get entryAbvCheck => 'Check the label if you can.';

  @override
  String get entryAbvVariantsIntro =>
      'Sources disagree. Pick what is on your label or type it:';

  @override
  String get entryBottleShared =>
      'Bottle being shared (fills in the bottle volume):';

  @override
  String entryBottlesInfo(String list) {
    return 'Product packages: $list. To split a bottle, choose \"Shared\" below.';
  }

  @override
  String get entryIndividualOrShared => 'Individual or shared';

  @override
  String get entryOnlyMine => 'Just mine';

  @override
  String get entryShared => 'Shared';

  @override
  String get entryPriceSection => 'Price (optional)';

  @override
  String get entryTimeSection => 'Time';

  @override
  String entryYourShare(String amount) {
    return 'Your share: $amount';
  }

  @override
  String get entryYourShareUnknown => 'Your share: —';

  @override
  String get entrySaveChanges => 'Save changes';

  @override
  String entryIngredients(String list) {
    return 'Ingredients (original wording): $list';
  }

  @override
  String entrySharedLine(String count, String total) {
    return 'of $total · $count people, including you';
  }

  @override
  String get entryPeople => 'People (including you)';

  @override
  String get entryFewerPeople => 'One fewer person';

  @override
  String get entryMorePeople => 'One more person';

  @override
  String get entryAdjustShare => 'Adjust share and leftover';

  @override
  String get entryYourShareMl => 'Your share (ml)';

  @override
  String get entryEqualSplit => 'Equal split by default.';

  @override
  String get entryLeftover => 'Left in the bottle (ml)';

  @override
  String get entryOptionalDot => 'Optional.';

  @override
  String entryOthersEach(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'for each of the other $count people',
      one: 'for the other person',
    );
    return '$amount left $_temp0.';
  }

  @override
  String get entryPriceValue => 'Amount';

  @override
  String get entryPriceDontKnow => 'Don\'t know';

  @override
  String get entryBillTotal => 'Bill/bottle total (optional)';

  @override
  String get entryPaidHelper => 'What you paid, not what you drank.';

  @override
  String entrySplitEqually(String count) {
    return 'Split equally ($count people)';
  }

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
  String get entryAddIngredient => 'Add ingredient';

  @override
  String get entryIngredientField => 'Ingredient';

  @override
  String get entryHasAlcohol => 'Contains alcohol';

  @override
  String get entrySaveRecipeTitle => 'Save as my recipe';

  @override
  String entryMineSuffix(String name) {
    return '$name (mine)';
  }

  @override
  String get entryRecipeName => 'Recipe name';

  @override
  String get entrySaveRecipeBody =>
      'Keeps ingredients, amounts and ABV for reuse. Old records do not change.';

  @override
  String get entryRecipeSaved => 'Recipe saved to your catalog';

  @override
  String get entryCompositionTitle => 'Composition';

  @override
  String get entryCompositionSimple => 'Enter only what you know.';

  @override
  String entryCompositionReference(String source) {
    return 'Reference recipe ($source). Adjust it to what was actually served.';
  }

  @override
  String get entryCompositionAdjusted => 'Adjusted composition';

  @override
  String get entryCompositionView => 'View and adjust composition';

  @override
  String get entryNoIngredients => 'No ingredients yet';

  @override
  String get entryDrinkVolumeSection => 'Cocktail volume (optional)';

  @override
  String get entryServedVolume => 'Served volume (ml)';

  @override
  String get entryServedVolumeHelper =>
      'If you do not know, leave it blank: the summary shows it as unknown. Glass size and ice do not count as volume drunk.';

  @override
  String get entryPureAlcohol => 'Pure alcohol in the composition above';

  @override
  String entryAtLeast(String amount) {
    return 'at least $amount';
  }

  @override
  String entryMissingParts(String list) {
    return 'Missing ABV or amount for: $list';
  }

  @override
  String get entryDeclaredNote =>
      'The declared composition counts, assuming the whole serving. It is not blood concentration.';

  @override
  String entryOptionalMark(String name) {
    return '$name (optional)';
  }

  @override
  String get entryRemoveIngredient => 'Remove ingredient';

  @override
  String entryInRecipe(String text) {
    return 'In the recipe: $text';
  }

  @override
  String get entryAmount => 'Amount';

  @override
  String get entryAmountUnknown => 'Blank = unknown.';

  @override
  String get entryChooseProduct => 'Choose brand/product';

  @override
  String get entryComponentAbv => 'Alcohol content (% vol.)';

  @override
  String get entryComponentAbvUnknown =>
      'Unknown: without it the total alcohol is incomplete.';

  @override
  String entryComponentAlcoholNone(String reason) {
    return 'Alcohol in this ingredient: not calculated ($reason).';
  }

  @override
  String entryComponentAlcohol(String amount) {
    return 'Alcohol in this ingredient: $amount';
  }

  @override
  String get entryIncompleteData => 'incomplete data';

  @override
  String entryWhichProduct(String name) {
    return 'Which $name?';
  }

  @override
  String get entryNoBrand => 'No brand: enter the ABV';

  @override
  String entryProductAbv(String abv) {
    return 'ABV $abv';
  }

  @override
  String get entryProductAbvVaries => 'ABV varies by source';

  @override
  String get entryProductAbvUnknown => 'ABV not given';

  @override
  String get entryMenuPrice => 'Menu price';

  @override
  String entryMenuPriceBody(String price) {
    return 'The menu advertised $price. It is only a suggestion: confirm what was actually paid, as there may be a promotion or a different order. If it is a shared bottle or pitcher, choose \"Shared\": the amount becomes the bill total, not your share.';
  }

  @override
  String get entryUseAsBillTotal => 'Use as the bill total';

  @override
  String get entryUseAsPaid => 'Use as what I paid';

  @override
  String get entryHistory => 'Your history';

  @override
  String entryHistoryShare(String date, String price, String scope) {
    return 'Your share was $price $scope on $date.';
  }

  @override
  String entryHistoryPaid(String date, String price, String scope) {
    return 'You paid $price $scope on $date.';
  }

  @override
  String get entryUseAsShare => 'Use as my share';

  @override
  String get entryUseValue => 'Use this amount';

  @override
  String entryHistoryTotal(String date, String price) {
    return 'The bottle/serving total was $price on $date.';
  }

  @override
  String get entryUseAsTotal => 'Use as total';

  @override
  String get entryScopeAtPlace => 'at this place';

  @override
  String get entryScopeAtOuting => 'in this outing';

  @override
  String get draftVolumeInvalid => 'Invalid volume';

  @override
  String get draftAbvRange => 'ABV must be between 0 and 100%';

  @override
  String get draftAmountInvalid => 'Invalid amount';

  @override
  String get draftVolumeRequired => 'Enter the volume in ml';

  @override
  String get draftVolumeTooHigh => 'Volume too high';

  @override
  String get draftShareRequired => 'Enter your share in ml';

  @override
  String draftShareOver(String volume) {
    return 'Your share + leftover exceed the volume ($volume)';
  }

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
  String get draftPaidRequired => 'Enter the amount or choose another option';

  @override
  String get formSaveRecipeFailed => 'Could not save the recipe.';

  @override
  String get formSaveFailed => 'Could not save. Nothing was lost, try again.';

  @override
  String get formDeleteFailed => 'Could not delete. Try again.';

  @override
  String get detailNotGiven => 'Not given';

  @override
  String get detailAbv => 'Alcohol content';

  @override
  String detailAbvFrom(String source) {
    return 'ABV: $source. Not manufacturer data.';
  }

  @override
  String get detailIngredients => 'Declared ingredients (original wording)';

  @override
  String get detailIngredientsNone => 'Not given';

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
  String get detailMakeMine => 'Make my own version';

  @override
  String get detailSourceTitle => 'Data source';

  @override
  String detailSourceLine(String date, String source) {
    return '$source · consulted on $date';
  }

  @override
  String get detailCopyAddress => 'Copy address';

  @override
  String get detailAddressCopied => 'Address copied';

  @override
  String get detailMayVary =>
      'Data may vary by version and market. Always check the package label.';

  @override
  String detailAbvVaries(String lines) {
    return 'Varies by source, with no single value:\n$lines';
  }

  @override
  String get detailRecipeReference =>
      'Reference recipe: shows how the recipe is published, not what a bar served.';

  @override
  String get detailRecipeMine =>
      'Your saved recipe. When logging, you adjust what was actually served.';

  @override
  String get detailNoIngredientsYet =>
      'No ingredients yet: you build it when logging.';

  @override
  String get detailAlcoholLegend =>
      'Ingredients with a glass icon contain alcohol. Each one\'s ABV is entered when logging; without it the total alcohol is incomplete. Ice is not counted.';

  @override
  String get detailMethod => 'Method';

  @override
  String detailGarnish(String text) {
    return 'Garnish: $text';
  }

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
  String get customBrand => 'Brand (optional)';

  @override
  String get customStyle => 'Style (optional)';

  @override
  String get customSizeAndAbv => 'Size and ABV';

  @override
  String get customSize => 'Size (ml)';

  @override
  String get customSizeRequired => 'Enter the size in ml';

  @override
  String get customAbvHelper => 'Blank = unknown, not counted as zero.';

  @override
  String get customIngredients => 'Ingredients (optional)';

  @override
  String get customIngredientsHelper =>
      'Separate with commas. Only what you know.';

  @override
  String get customSaveUse => 'Save and use';

  @override
  String get recipeUnitLabel => 'Unit';

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
  String myDrinksRecipeSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recipe · $count ingredients',
      one: 'Recipe · 1 ingredient',
    );
    return '$_temp0';
  }

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
  String get myDrinksNewRecipe => 'New recipe';

  @override
  String recipeEditorNameCopy(String name) {
    return '$name (my version)';
  }

  @override
  String get recipeEditorNeedName => 'Give the recipe a name.';

  @override
  String get recipeEditorNeedIngredient => 'Add at least one ingredient.';

  @override
  String get recipeEditorIngredientName => 'Every ingredient needs a name.';

  @override
  String recipeEditorAbvRange(String name) {
    return 'The ABV of \"$name\" must be between 0 and 100%.';
  }

  @override
  String recipeEditorAmountInvalid(String name) {
    return 'The amount of \"$name\" is invalid.';
  }

  @override
  String recipeEditorNumberProblem(String name, String problem) {
    return '\"$name\": $problem';
  }

  @override
  String get recipeEditorEditTitle => 'Edit recipe';

  @override
  String get recipeEditorNewTitle => 'New recipe';

  @override
  String get recipeEditorIntro =>
      'Enter only what you know. A blank amount or ABV stays unknown and the total alcohol is shown as incomplete.';

  @override
  String get recipeEditorNameSection => 'Name';

  @override
  String get recipeEditorNameRequired => 'Give the recipe a name';

  @override
  String get recipeEditorIngredients => 'Ingredients';

  @override
  String get recipeEditorNoneYet => 'No ingredients yet.';

  @override
  String get recipeEditorAlcoholSection => 'Alcohol in the composition';

  @override
  String get recipeEditorDeclaredAlcohol => 'Declared pure alcohol';

  @override
  String get recipeEditorSaveRecipe => 'Save recipe';

  @override
  String get recipeEditorMoveUp => 'Move up';

  @override
  String get recipeEditorMoveDown => 'Move down';

  @override
  String recipeEditorOriginal(String text) {
    return 'In the original recipe: $text';
  }

  @override
  String get recipeEditorRole => 'Type (to pick the brand when logging)';

  @override
  String get recipeEditorNoRole => 'No type';

  @override
  String get recipeEditorRemove => 'Remove';
}
