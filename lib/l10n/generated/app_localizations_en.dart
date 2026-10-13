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
  String outingTypeSince(String type, String time) {
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
  String volumeKnownPlusUnknown(String known, int count) {
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
  String entrySharedLine(String total, String count) {
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
  String entryHistoryShare(String price, String scope, String date) {
    return 'Your share was $price $scope on $date.';
  }

  @override
  String entryHistoryPaid(String price, String scope, String date) {
    return 'You paid $price $scope on $date.';
  }

  @override
  String get entryUseAsShare => 'Use as my share';

  @override
  String get entryUseValue => 'Use this amount';

  @override
  String entryHistoryTotal(String price, String date) {
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
  String detailSourceLine(String source, String date) {
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
  String scanMenuSize(String size) {
    return 'Size on the menu: $size';
  }

  @override
  String scanMenuIngredientsCited(String list) {
    return 'Ingredients mentioned: $list';
  }

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
  String get scanMenuSizeOptional => 'Size (optional)';

  @override
  String get scanMenuPriceOptional => 'Price (optional)';

  @override
  String get scanMenuCitedOptional => 'Ingredients mentioned (optional)';

  @override
  String get scanMenuCitedHelper => 'Separate with commas. No amounts.';

  @override
  String get scanMenuNeedName => 'Give the item a name.';

  @override
  String get scanMenuInvalidSize => 'Invalid size.';

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
  String get outingReviewVolumePositive =>
      'The volume must be greater than zero.';

  @override
  String get outingReviewAbvRange => 'ABV must be between 0 and 100%.';

  @override
  String get outingReviewOtherLines => 'Other lines read (tap to use):';

  @override
  String get outingReviewPickType => 'Choose the drink type';

  @override
  String get outingReviewTypeUnknown => 'Type not identified: choose one.';

  @override
  String get outingReviewDescription => 'Menu description (optional)';

  @override
  String get outingReviewPackageVolume => 'Package volume (optional)';

  @override
  String get outingReviewVolumeHelper =>
      'It is the product size, not how much you drank. Blank = unknown.';

  @override
  String outingReviewAbvSource(String source) {
    return 'Source: $source';
  }

  @override
  String get outingReviewIngredientsIntro =>
      'Only what the menu or you stated. Amounts stay unknown until you complete them when logging; alcohol is only calculated with a known volume and ABV.';

  @override
  String get outingReviewAlcoholChip => 'Alcohol';

  @override
  String get outingReviewDeclaredOptional => 'Declared ingredients (optional)';

  @override
  String get outingReviewDeclaredHelper =>
      'Separate with commas. Only what is written.';

  @override
  String get outingReviewAdvertisedSection => 'Advertised price';

  @override
  String get outingReviewMenuPriceOptional => 'Menu price (optional)';

  @override
  String get outingReviewMenuPriceHelper =>
      'Only a suggestion: when logging you confirm what you paid. Amounts in Brazilian reais (R\$).';

  @override
  String get outingReviewSimilar => 'Similar in the catalog';

  @override
  String get outingReviewSearch => 'Search';

  @override
  String get outingReviewSimilarNote =>
      'Optional. Choosing one is only a reference: the catalog product is never changed and nothing is linked automatically.';

  @override
  String get outingReviewNothingSimilar =>
      'Nothing similar found. This item stays only in the outing.';

  @override
  String get outingReviewReferenceChosen => 'Reference chosen';

  @override
  String get outingReviewUseReference => 'Use as reference';

  @override
  String get outingReviewFillEmpty => 'Fill empty fields';

  @override
  String get outingReviewCopyIngredients =>
      'Copy ingredients (without amounts)';

  @override
  String get outingReviewOriginSection => 'Data source';

  @override
  String get outingReviewOriginManual => 'Filled in by you.';

  @override
  String get outingReviewOriginPhoto =>
      'Read from the photo and checked by you. Automatic reading can be wrong: check every field.';

  @override
  String get outingReviewReferenceNote =>
      'With a catalog reference (it is not the same record).';

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
  String get placeStatDrinks => 'Drinks';

  @override
  String get placeStatSpent => 'Reported spend';

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
  String get splitPaidAmount => 'Amount paid to the venue';

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
}
