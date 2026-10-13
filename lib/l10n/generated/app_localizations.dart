import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @accountAllConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Tudo confirmado na nuvem'**
  String get accountAllConfirmed;

  /// No description provided for @accountAllSentNow.
  ///
  /// In pt, this message translates to:
  /// **'Tudo enviado. Agora você pode sair.'**
  String get accountAllSentNow;

  /// No description provided for @accountChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha'**
  String get accountChangePassword;

  /// No description provided for @accountCloud.
  ///
  /// In pt, this message translates to:
  /// **'Nuvem'**
  String get accountCloud;

  /// No description provided for @accountCodeField.
  ///
  /// In pt, this message translates to:
  /// **'Código recebido por e-mail'**
  String get accountCodeField;

  /// No description provided for @accountCodeSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código para o seu e-mail.'**
  String get accountCodeSent;

  /// No description provided for @accountConflicts.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 alteração para resolver} other{{count} alterações para resolver}}'**
  String accountConflicts(int count);

  /// No description provided for @accountDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get accountDelete;

  /// No description provided for @accountEditName.
  ///
  /// In pt, this message translates to:
  /// **'Editar nome'**
  String get accountEditName;

  /// No description provided for @accountEmailConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'E-mail confirmado'**
  String get accountEmailConfirmed;

  /// No description provided for @accountEmailNotConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'E-mail não confirmado'**
  String get accountEmailNotConfirmed;

  /// No description provided for @accountHistoryNotDone.
  ///
  /// In pt, this message translates to:
  /// **'O histórico da nuvem ainda não terminou de chegar neste aparelho.'**
  String get accountHistoryNotDone;

  /// No description provided for @accountLastSync.
  ///
  /// In pt, this message translates to:
  /// **'Última sincronização concluída: {when}'**
  String accountLastSync(String when);

  /// No description provided for @accountLastSyncNever.
  ///
  /// In pt, this message translates to:
  /// **'Última sincronização concluída: ainda não houve.'**
  String get accountLastSyncNever;

  /// No description provided for @accountLegacy.
  ///
  /// In pt, this message translates to:
  /// **'Registros antigos deste aparelho'**
  String get accountLegacy;

  /// No description provided for @accountLegacyDecide.
  ///
  /// In pt, this message translates to:
  /// **'Registros antigos deste aparelho: importar ou exportar'**
  String get accountLegacyDecide;

  /// No description provided for @accountName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get accountName;

  /// No description provided for @accountNameUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Nome atualizado'**
  String get accountNameUpdated;

  /// No description provided for @accountNoName.
  ///
  /// In pt, this message translates to:
  /// **'Sem nome'**
  String get accountNoName;

  /// No description provided for @accountNothingWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Nada aguardando envio.'**
  String get accountNothingWaiting;

  /// No description provided for @accountOnlyHerePhotos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Também 1 foto aguardando envio.} other{Também {count} fotos aguardando envio.}}'**
  String accountOnlyHerePhotos(int count);

  /// No description provided for @accountOnlyHereRecords.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Salvo só neste aparelho por enquanto: 1 registro.} other{Salvo só neste aparelho por enquanto: {count} registros.}}'**
  String accountOnlyHereRecords(int count);

  /// No description provided for @accountPasswordChanged.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada'**
  String get accountPasswordChanged;

  /// No description provided for @accountResendCode.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código de novo'**
  String get accountResendCode;

  /// No description provided for @accountRestoring.
  ///
  /// In pt, this message translates to:
  /// **'Recuperando…'**
  String get accountRestoring;

  /// No description provided for @accountSaveNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nova senha'**
  String get accountSaveNewPassword;

  /// No description provided for @accountSession.
  ///
  /// In pt, this message translates to:
  /// **'Sessão'**
  String get accountSession;

  /// No description provided for @accountSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get accountSignOut;

  /// No description provided for @accountSignOutClean.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados estão na nuvem e voltam quando você entrar de novo. Neste aparelho eles ficam guardados só para esta conta.'**
  String get accountSignOutClean;

  /// No description provided for @accountSignOutConflicts.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Também há 1 alteração para resolver.} other{Também há {count} alterações para resolver.}}'**
  String accountSignOutConflicts(int count);

  /// No description provided for @accountSignOutPending.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Há 1 alteração ainda não enviada.} other{Há {count} alterações ainda não enviadas.}} Elas continuam guardadas neste aparelho, presas a esta conta, e só reaparecem quando você entrar nela de novo.'**
  String accountSignOutPending(int count);

  /// No description provided for @accountSignOutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get accountSignOutTitle;

  /// No description provided for @accountStillPending.
  ///
  /// In pt, this message translates to:
  /// **'Ainda há pendências: elas ficam guardadas neste aparelho.'**
  String get accountStillPending;

  /// No description provided for @accountSyncFirst.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar antes'**
  String get accountSyncFirst;

  /// No description provided for @accountYourData.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados'**
  String get accountYourData;

  /// No description provided for @accountYourName.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get accountYourName;

  /// No description provided for @alcoholAtLeast.
  ///
  /// In pt, this message translates to:
  /// **'pelo menos {amount}'**
  String alcoholAtLeast(String amount);

  /// No description provided for @alcoholDeclared.
  ///
  /// In pt, this message translates to:
  /// **'Álcool puro declarado'**
  String get alcoholDeclared;

  /// No description provided for @alcoholExplain.
  ///
  /// In pt, this message translates to:
  /// **'Calculado só com o que foi informado: volume × teor nas bebidas simples e quantidade × teor de cada componente nos drinks. Em drinks vale a receita declarada, não o que o bar serviu. Não é a concentração de álcool no sangue e não indica se você pode dirigir.'**
  String get alcoholExplain;

  /// No description provided for @alcoholIncompletePill.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro com teor ou quantidade desconhecidos: o total é um mínimo} other{{count} registros com teor ou quantidade desconhecidos: o total é um mínimo}}'**
  String alcoholIncompletePill(int count);

  /// No description provided for @alcoholNoVolumePill.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro sem volume informado (não entra no volume)} other{{count} registros sem volume informado (não entram no volume)}}'**
  String alcoholNoVolumePill(int count);

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Bebômetro'**
  String get appName;

  /// No description provided for @authAlreadyConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Já confirmei: entrar'**
  String get authAlreadyConfirmed;

  /// No description provided for @authCancelAndLeave.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar e sair'**
  String get authCancelAndLeave;

  /// No description provided for @authCheckEmail.
  ///
  /// In pt, this message translates to:
  /// **'Confira o e-mail digitado.'**
  String get authCheckEmail;

  /// No description provided for @authCheckInboxBody.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link para {email}. Abra o link neste aparelho para concluir.'**
  String authCheckInboxBody(String email);

  /// No description provided for @authCheckInboxTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confira seu e-mail'**
  String get authCheckInboxTitle;

  /// No description provided for @authChoosePassword.
  ///
  /// In pt, this message translates to:
  /// **'Escolha sua senha'**
  String get authChoosePassword;

  /// No description provided for @authChoosePasswordBody.
  ///
  /// In pt, this message translates to:
  /// **'E-mail confirmado. Agora escolha a senha para entrar em outros aparelhos.'**
  String get authChoosePasswordBody;

  /// No description provided for @authCloudDown.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível falar com o servidor agora. Confira a internet e tente de novo em instantes.'**
  String get authCloudDown;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get authConfirmNewPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get authConfirmPassword;

  /// No description provided for @authConvertBody.
  ///
  /// In pt, this message translates to:
  /// **'Seus registros deste aparelho continuam com você. Depois de confirmar o e-mail, você escolhe a senha.'**
  String get authConvertBody;

  /// No description provided for @authCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authCreateAccount;

  /// No description provided for @authCreateWithRecords.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta com seus registros'**
  String get authCreateWithRecords;

  /// No description provided for @authDifferentAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta diferente da sessão atual.'**
  String get authDifferentAccount;

  /// No description provided for @authEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get authEmail;

  /// No description provided for @authEmailExists.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma conta com esse e-mail. Entre com ela ou recupere a senha.'**
  String get authEmailExists;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirme seu e-mail antes de entrar. Procure o link na sua caixa de entrada (e no spam).'**
  String get authEmailNotConfirmed;

  /// No description provided for @authEnterEmail.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail.'**
  String get authEnterEmail;

  /// No description provided for @authEnterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha.'**
  String get authEnterPassword;

  /// No description provided for @authForgot.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get authForgot;

  /// No description provided for @authGenericError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir agora. Tente de novo.'**
  String get authGenericError;

  /// No description provided for @authHidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get authHidePassword;

  /// No description provided for @authLinkInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Esse link expirou ou já foi usado. Peça outro e abra-o neste aparelho. Se você confirmou o e-mail em outro aparelho, é só entrar com e-mail e senha.'**
  String get authLinkInvalid;

  /// No description provided for @authLinkingDisabled.
  ///
  /// In pt, this message translates to:
  /// **'A conversão da conta antiga não está liberada no servidor ainda. Você pode criar uma conta nova e importar os registros depois.'**
  String get authLinkingDisabled;

  /// No description provided for @authNameMissing.
  ///
  /// In pt, this message translates to:
  /// **'Como podemos te chamar?'**
  String get authNameMissing;

  /// No description provided for @authNeedsCode.
  ///
  /// In pt, this message translates to:
  /// **'Por segurança, confirme com o código enviado ao seu e-mail.'**
  String get authNeedsCode;

  /// No description provided for @authNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get authNewPassword;

  /// No description provided for @authNewPasswordFor.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma nova senha para {email}.'**
  String authNewPasswordFor(String email);

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get authNewPasswordTitle;

  /// No description provided for @authNoConnection.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Confira a internet e tente de novo.'**
  String get authNoConnection;

  /// No description provided for @authNoOldSession.
  ///
  /// In pt, this message translates to:
  /// **'Não há uma sessão antiga para converter.'**
  String get authNoOldSession;

  /// No description provided for @authNotArrived.
  ///
  /// In pt, this message translates to:
  /// **'Não chegou? Confira o spam e se o endereço está certo. O link vale por tempo limitado.'**
  String get authNotArrived;

  /// No description provided for @authPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get authPassword;

  /// No description provided for @authPasswordHelper.
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 8 caracteres, com letras e números.'**
  String get authPasswordHelper;

  /// No description provided for @authPasswordMin.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 8 caracteres.'**
  String get authPasswordMin;

  /// No description provided for @authPasswordMix.
  ///
  /// In pt, this message translates to:
  /// **'Misture letras e números.'**
  String get authPasswordMix;

  /// No description provided for @authPasswordsDiffer.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não são iguais.'**
  String get authPasswordsDiffer;

  /// No description provided for @authRecoverBody.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link para criar uma nova senha. Abra-o neste aparelho.'**
  String get authRecoverBody;

  /// No description provided for @authRecoverSent.
  ///
  /// In pt, this message translates to:
  /// **'Se houver uma conta com esse e-mail, o link chega em instantes. Confira também o spam.'**
  String get authRecoverSent;

  /// No description provided for @authRecoverTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get authRecoverTitle;

  /// No description provided for @authResend.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar e-mail'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar em {seconds} s'**
  String authResendIn(int seconds);

  /// No description provided for @authResendWait.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde {seconds} s para pedir outro e-mail.'**
  String authResendWait(int seconds);

  /// No description provided for @authResent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos outro e-mail. Confira também o spam.'**
  String get authResent;

  /// No description provided for @authSamePassword.
  ///
  /// In pt, this message translates to:
  /// **'A nova senha precisa ser diferente da atual.'**
  String get authSamePassword;

  /// No description provided for @authSavePassword.
  ///
  /// In pt, this message translates to:
  /// **'Salvar senha'**
  String get authSavePassword;

  /// No description provided for @authSendAgain.
  ///
  /// In pt, this message translates to:
  /// **'Enviar de novo'**
  String get authSendAgain;

  /// No description provided for @authSendConfirmation.
  ///
  /// In pt, this message translates to:
  /// **'Enviar confirmação'**
  String get authSendConfirmation;

  /// No description provided for @authSendLink.
  ///
  /// In pt, this message translates to:
  /// **'Enviar link'**
  String get authSendLink;

  /// No description provided for @authServerUnreachable.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor agora. Tente de novo em instantes.'**
  String get authServerUnreachable;

  /// No description provided for @authSessionEnded.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou. Entre novamente.'**
  String get authSessionEnded;

  /// No description provided for @authShowPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get authShowPassword;

  /// No description provided for @authSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authSignIn;

  /// No description provided for @authSignInAgainBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou no servidor. Seus registros continuam neste aparelho e voltam quando você entrar na mesma conta.'**
  String get authSignInAgainBody;

  /// No description provided for @authSignInAgainTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre novamente'**
  String get authSignInAgainTitle;

  /// No description provided for @authSignInAgainToContinue.
  ///
  /// In pt, this message translates to:
  /// **'Entre novamente para continuar.'**
  String get authSignInAgainToContinue;

  /// No description provided for @authSignInBody.
  ///
  /// In pt, this message translates to:
  /// **'Seus rolês ficam salvos na sua conta e voltam em qualquer aparelho.'**
  String get authSignInBody;

  /// No description provided for @authSignUpNote.
  ///
  /// In pt, this message translates to:
  /// **'Vamos enviar um link para confirmar o e-mail. Seu nome e e-mail só servem para a sua conta.'**
  String get authSignUpNote;

  /// No description provided for @authSignupDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro desativado no servidor no momento.'**
  String get authSignupDisabled;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Espere alguns minutos e tente de novo.'**
  String get authTooManyAttempts;

  /// No description provided for @authTooManyShort.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Espere alguns minutos.'**
  String get authTooManyShort;

  /// No description provided for @authUseOtherEmail.
  ///
  /// In pt, this message translates to:
  /// **'Usar outro e-mail'**
  String get authUseOtherEmail;

  /// No description provided for @authUseOtherEmailBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar e usar outro e-mail'**
  String get authUseOtherEmailBack;

  /// No description provided for @authWeakPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha fraca. Use pelo menos 8 caracteres, misturando letras e números.'**
  String get authWeakPassword;

  /// No description provided for @authWrongCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get authWrongCredentials;

  /// No description provided for @authYourAccount.
  ///
  /// In pt, this message translates to:
  /// **'sua conta'**
  String get authYourAccount;

  /// No description provided for @authYourEmail.
  ///
  /// In pt, this message translates to:
  /// **'o seu e-mail'**
  String get authYourEmail;

  /// No description provided for @budgetDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento para bebidas'**
  String get budgetDialogTitle;

  /// No description provided for @budgetEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar orçamento'**
  String get budgetEdit;

  /// No description provided for @budgetLeft.
  ///
  /// In pt, this message translates to:
  /// **'Sobram {amount} do orçamento.'**
  String budgetLeft(String amount);

  /// No description provided for @budgetLeftIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Dos gastos informados, sobram {amount} do orçamento (parcial: falta o preço de 1 bebida).} other{Dos gastos informados, sobram {amount} do orçamento (parcial: faltam preços de {count} bebidas).}}'**
  String budgetLeftIncomplete(String amount, int count);

  /// No description provided for @budgetLine.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento {budget} · gasto informado {spent}'**
  String budgetLine(String budget, String spent);

  /// No description provided for @budgetMustBePositive.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero'**
  String get budgetMustBePositive;

  /// No description provided for @budgetOptionalNote.
  ///
  /// In pt, this message translates to:
  /// **'Opcional. Compara só com os gastos que você informou.'**
  String get budgetOptionalNote;

  /// No description provided for @budgetOver.
  ///
  /// In pt, this message translates to:
  /// **'Passou {amount} do orçamento.'**
  String budgetOver(String amount);

  /// No description provided for @budgetOverIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Os gastos informados já passaram {amount} do orçamento e ainda faltam preços.'**
  String budgetOverIncomplete(String amount);

  /// No description provided for @budgetReached.
  ///
  /// In pt, this message translates to:
  /// **'Os gastos informados chegaram a {percent}% do orçamento ({spent} de {budget}).'**
  String budgetReached(String budget, int percent, String spent);

  /// No description provided for @budgetReachedIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Há bebidas sem preço: o total real pode ser maior.'**
  String get budgetReachedIncomplete;

  /// No description provided for @budgetSet.
  ///
  /// In pt, this message translates to:
  /// **'Definir orçamento'**
  String get budgetSet;

  /// No description provided for @budgetValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get budgetValue;

  /// No description provided for @commonAdjust.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar'**
  String get commonAdjust;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonCopied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado'**
  String get commonCopied;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado'**
  String get commonError;

  /// No description provided for @commonLater.
  ///
  /// In pt, this message translates to:
  /// **'Depois'**
  String get commonLater;

  /// No description provided for @commonMoreOptions.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get commonMoreOptions;

  /// No description provided for @commonNotNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get commonNotNow;

  /// No description provided for @commonOptional.
  ///
  /// In pt, this message translates to:
  /// **'(opcional)'**
  String get commonOptional;

  /// No description provided for @commonOptions.
  ///
  /// In pt, this message translates to:
  /// **'Opções'**
  String get commonOptions;

  /// No description provided for @commonRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get commonRemove;

  /// No description provided for @commonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonUndo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get commonUndo;

  /// No description provided for @conflictAcceptDeletion.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar a exclusão'**
  String get conflictAcceptDeletion;

  /// No description provided for @conflictApplyFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aplicar. Nada foi perdido.'**
  String get conflictApplyFailed;

  /// No description provided for @conflictCloud.
  ///
  /// In pt, this message translates to:
  /// **'Na nuvem'**
  String get conflictCloud;

  /// No description provided for @conflictCloudDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Na nuvem (excluído)'**
  String get conflictCloudDeleted;

  /// No description provided for @conflictCustomDrink.
  ///
  /// In pt, this message translates to:
  /// **'Bebida pessoal alterada em dois aparelhos'**
  String get conflictCustomDrink;

  /// No description provided for @conflictDeletionAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Exclusão aceita'**
  String get conflictDeletionAccepted;

  /// No description provided for @conflictDrink.
  ///
  /// In pt, this message translates to:
  /// **'Bebida editada em dois aparelhos'**
  String get conflictDrink;

  /// No description provided for @conflictEditedAt.
  ///
  /// In pt, this message translates to:
  /// **'Editado em {when}'**
  String conflictEditedAt(String when);

  /// No description provided for @conflictEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim: {when}'**
  String conflictEnd(String when);

  /// No description provided for @conflictEndHere.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o deste aparelho'**
  String get conflictEndHere;

  /// No description provided for @conflictEndOther.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o do outro aparelho'**
  String get conflictEndOther;

  /// No description provided for @conflictFromHere.
  ///
  /// In pt, this message translates to:
  /// **'Deste aparelho'**
  String get conflictFromHere;

  /// No description provided for @conflictFromOther.
  ///
  /// In pt, this message translates to:
  /// **'Do outro aparelho'**
  String get conflictFromOther;

  /// No description provided for @conflictHere.
  ///
  /// In pt, this message translates to:
  /// **'Neste aparelho'**
  String get conflictHere;

  /// No description provided for @conflictIntro.
  ///
  /// In pt, this message translates to:
  /// **'Estas alterações foram feitas em mais de um aparelho ao mesmo tempo. Escolha qual versão vale. A outra é descartada só quando você escolher.'**
  String get conflictIntro;

  /// No description provided for @conflictItem.
  ///
  /// In pt, this message translates to:
  /// **'Item alterado em dois aparelhos'**
  String get conflictItem;

  /// No description provided for @conflictKeepLocal.
  ///
  /// In pt, this message translates to:
  /// **'Manter a deste aparelho'**
  String get conflictKeepLocal;

  /// No description provided for @conflictKeptLocal.
  ///
  /// In pt, this message translates to:
  /// **'Mantida a versão deste aparelho'**
  String get conflictKeptLocal;

  /// No description provided for @conflictNone.
  ///
  /// In pt, this message translates to:
  /// **'Nada para resolver. Tudo certo.'**
  String get conflictNone;

  /// No description provided for @conflictOuting.
  ///
  /// In pt, this message translates to:
  /// **'Rolê alterado em dois aparelhos'**
  String get conflictOuting;

  /// No description provided for @conflictOutingEnded.
  ///
  /// In pt, this message translates to:
  /// **'Rolê encerrado'**
  String get conflictOutingEnded;

  /// No description provided for @conflictOutingLine.
  ///
  /// In pt, this message translates to:
  /// **'{label}: {name}'**
  String conflictOutingLine(String label, String name);

  /// No description provided for @conflictPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pago: {amount}'**
  String conflictPaid(String amount);

  /// No description provided for @conflictPlace.
  ///
  /// In pt, this message translates to:
  /// **'Local alterado em dois aparelhos'**
  String get conflictPlace;

  /// No description provided for @conflictRemoteUnreadable.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para ler a versão da nuvem agora. Você pode manter a deste aparelho ou tentar mais tarde.'**
  String get conflictRemoteUnreadable;

  /// No description provided for @conflictRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar com a versão deste aparelho'**
  String get conflictRestore;

  /// No description provided for @conflictRestored.
  ///
  /// In pt, this message translates to:
  /// **'Restaurado com a sua versão'**
  String get conflictRestored;

  /// No description provided for @conflictSince.
  ///
  /// In pt, this message translates to:
  /// **'desde {when}'**
  String conflictSince(String when);

  /// No description provided for @conflictStart.
  ///
  /// In pt, this message translates to:
  /// **'Início: {when}'**
  String conflictStart(String when);

  /// No description provided for @conflictTab.
  ///
  /// In pt, this message translates to:
  /// **'Comanda alterada em dois aparelhos'**
  String get conflictTab;

  /// No description provided for @conflictTabPayments.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum pagamento registrado} =1{1 pagamento registrado: {amount}} other{{count} pagamentos registrados: {amount}}}'**
  String conflictTabPayments(String amount, int count);

  /// No description provided for @conflictTabPeople.
  ///
  /// In pt, this message translates to:
  /// **'{people, plural, =1{1 participante} other{{people} participantes}} · {extras, plural, =0{nenhum item extra} =1{1 item extra} other{{extras} itens extras}}'**
  String conflictTabPeople(int extras, int people);

  /// No description provided for @conflictTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterações para resolver'**
  String get conflictTitle;

  /// No description provided for @conflictTwoActiveBody.
  ///
  /// In pt, this message translates to:
  /// **'Um foi começado neste aparelho e outro em outro aparelho, sem internet. Os dois foram guardados com as suas bebidas. Escolha qual encerrar agora.'**
  String get conflictTwoActiveBody;

  /// No description provided for @conflictUseRemote.
  ///
  /// In pt, this message translates to:
  /// **'Usar a da nuvem'**
  String get conflictUseRemote;

  /// No description provided for @conflictUsedRemote.
  ///
  /// In pt, this message translates to:
  /// **'Usada a versão da nuvem'**
  String get conflictUsedRemote;

  /// No description provided for @dateAtTime.
  ///
  /// In pt, this message translates to:
  /// **'{date} às {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @deleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso apaga de vez a sua conta, todos os rolês, bebidas, locais, comandas e fotos guardados na nuvem, e os dados desta conta neste aparelho. Não dá para desfazer.'**
  String get deleteBody;

  /// No description provided for @deleteConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua senha.'**
  String get deleteConfirmPassword;

  /// No description provided for @deleteConfirmPasswordAgain.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua senha de novo.'**
  String get deleteConfirmPasswordAgain;

  /// No description provided for @deleteExportFirst.
  ///
  /// In pt, this message translates to:
  /// **'Se quiser guardar uma cópia, exporte seus dados antes (Configurações > Exportar meus dados).'**
  String get deleteExportFirst;

  /// No description provided for @deleteOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Nada foi apagado.'**
  String get deleteOffline;

  /// No description provided for @deletePartial.
  ///
  /// In pt, this message translates to:
  /// **'A exclusão começou mas não terminou. Nada local foi apagado. Toque em \"Excluir conta\" de novo para continuar.'**
  String get deletePartial;

  /// No description provided for @deleteTickFirst.
  ///
  /// In pt, this message translates to:
  /// **'Marque a confirmação para continuar.'**
  String get deleteTickFirst;

  /// No description provided for @deleteUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A exclusão ainda não está disponível no servidor. Nada foi apagado. Tente mais tarde.'**
  String get deleteUnavailable;

  /// No description provided for @deleteUnderstand.
  ///
  /// In pt, this message translates to:
  /// **'Entendo que a exclusão é permanente.'**
  String get deleteUnderstand;

  /// No description provided for @deleteYourPassword.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha'**
  String get deleteYourPassword;

  /// No description provided for @drinkCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 bebida} other{{count} bebidas}}'**
  String drinkCount(int count);

  /// No description provided for @drinkFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Bebida'**
  String get drinkFallbackName;

  /// No description provided for @drinkShared.
  ///
  /// In pt, this message translates to:
  /// **'compartilhada'**
  String get drinkShared;

  /// No description provided for @drinkWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get drinkWater;

  /// No description provided for @durationHours.
  ///
  /// In pt, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @entryAlcoholIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'álcool incompleto'**
  String get entryAlcoholIncomplete;

  /// No description provided for @entryCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Corrigir'**
  String get entryCorrect;

  /// No description provided for @entryOptions.
  ///
  /// In pt, this message translates to:
  /// **'Opções do registro'**
  String get entryOptions;

  /// No description provided for @entrySharedPart.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{sua parte {mine} de {total} (1 pessoa)} other{sua parte {mine} de {total} ({count} pessoas)}}'**
  String entrySharedPart(int count, String mine, String total);

  /// No description provided for @feedbackDontAsk.
  ///
  /// In pt, this message translates to:
  /// **'Não perguntar'**
  String get feedbackDontAsk;

  /// No description provided for @feedbackFreeNote.
  ///
  /// In pt, this message translates to:
  /// **'Nota livre'**
  String get feedbackFreeNote;

  /// No description provided for @feedbackFreeNoteHint.
  ///
  /// In pt, this message translates to:
  /// **'Algo que você queira lembrar desse rolê'**
  String get feedbackFreeNoteHint;

  /// No description provided for @feedbackHangover.
  ///
  /// In pt, this message translates to:
  /// **'Ressaca'**
  String get feedbackHangover;

  /// No description provided for @feedbackHowItWent.
  ///
  /// In pt, this message translates to:
  /// **'Como foi'**
  String get feedbackHowItWent;

  /// No description provided for @feedbackNote.
  ///
  /// In pt, this message translates to:
  /// **'É só o seu relato de como foi a noite. Não mede nada e não indica quanto é seguro beber.'**
  String get feedbackNote;

  /// No description provided for @feedbackOptional.
  ///
  /// In pt, this message translates to:
  /// **'Tudo opcional. É só um registro pessoal, sem nota e sem comparação.'**
  String get feedbackOptional;

  /// No description provided for @feedbackReviewForgotten.
  ///
  /// In pt, this message translates to:
  /// **'Revisar bebidas esquecidas'**
  String get feedbackReviewForgotten;

  /// No description provided for @feedbackSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar relato'**
  String get feedbackSave;

  /// No description provided for @feedbackTellMore.
  ///
  /// In pt, this message translates to:
  /// **'Quer contar mais?'**
  String get feedbackTellMore;

  /// No description provided for @feedbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como foi o último rolê?'**
  String get feedbackTitle;

  /// No description provided for @feedbackWake.
  ///
  /// In pt, this message translates to:
  /// **'Como acordou'**
  String get feedbackWake;

  /// No description provided for @feedbackYourAccount.
  ///
  /// In pt, this message translates to:
  /// **'Seu relato'**
  String get feedbackYourAccount;

  /// No description provided for @fileGenerationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o arquivo.'**
  String get fileGenerationFailed;

  /// No description provided for @financeInformed.
  ///
  /// In pt, this message translates to:
  /// **'{amount} informados'**
  String financeInformed(String amount);

  /// No description provided for @financeNoRecords.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros ainda'**
  String get financeNoRecords;

  /// No description provided for @financeNoValue.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum valor informado'**
  String get financeNoValue;

  /// No description provided for @financeUnpriced.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 bebida sem preço} other{{count} bebidas sem preço}}'**
  String financeUnpriced(int count);

  /// No description provided for @finishAndSummary.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar e ver resumo'**
  String get finishAndSummary;

  /// No description provided for @finishBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum registro.} =1{1 registro.} other{{count} registros.}} Você ainda poderá corrigir registros depois, pelo histórico.'**
  String finishBody(int count);

  /// No description provided for @finishEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim: {when}'**
  String finishEnd(String when);

  /// No description provided for @finishKeepGoing.
  ///
  /// In pt, this message translates to:
  /// **'Continuar o rolê'**
  String get finishKeepGoing;

  /// No description provided for @finishTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar rolê?'**
  String get finishTitle;

  /// No description provided for @glassBigSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O volume informado, somado, num copo.'**
  String get glassBigSubtitle;

  /// No description provided for @glassBigTitle.
  ///
  /// In pt, this message translates to:
  /// **'Copão (opcional)'**
  String get glassBigTitle;

  /// No description provided for @glassTipPlay.
  ///
  /// In pt, this message translates to:
  /// **'Brincar de virar o copo'**
  String get glassTipPlay;

  /// No description provided for @groupRecipeAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'receita ajustada'**
  String get groupRecipeAdjusted;

  /// No description provided for @groupSharedPart.
  ///
  /// In pt, this message translates to:
  /// **'{mine} seus de {total}'**
  String groupSharedPart(String mine, String total);

  /// No description provided for @groupTimes.
  ///
  /// In pt, this message translates to:
  /// **'{count}×'**
  String groupTimes(int count);

  /// No description provided for @groupVolumeUnknown.
  ///
  /// In pt, this message translates to:
  /// **'volume desconhecido'**
  String get groupVolumeUnknown;

  /// No description provided for @groupVolumeUnknownShort.
  ///
  /// In pt, this message translates to:
  /// **'volume ?'**
  String get groupVolumeUnknownShort;

  /// No description provided for @hangoverMild.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get hangoverMild;

  /// No description provided for @hangoverModerate.
  ///
  /// In pt, this message translates to:
  /// **'Moderada'**
  String get hangoverModerate;

  /// No description provided for @hangoverNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get hangoverNone;

  /// No description provided for @hangoverStrong.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get hangoverStrong;

  /// No description provided for @homeContinueOuting.
  ///
  /// In pt, this message translates to:
  /// **'Continuar rolê'**
  String get homeContinueOuting;

  /// No description provided for @homeDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas'**
  String get homeDrinks;

  /// No description provided for @homeFirstBody.
  ///
  /// In pt, this message translates to:
  /// **'Quando você encerrar um rolê, o resumo do mês aparece aqui, só com o que você registrou.'**
  String get homeFirstBody;

  /// No description provided for @homeFirstTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu primeiro rolê começa aqui'**
  String get homeFirstTitle;

  /// No description provided for @homeIdleBody.
  ///
  /// In pt, this message translates to:
  /// **'Anote o que bebeu e quanto gastou, sem complicação.'**
  String get homeIdleBody;

  /// No description provided for @homeIdleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bora de rolê?'**
  String get homeIdleTitle;

  /// No description provided for @homeInformedSpent.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado'**
  String get homeInformedSpent;

  /// No description provided for @homeLastOuting.
  ///
  /// In pt, this message translates to:
  /// **'Último rolê'**
  String get homeLastOuting;

  /// No description provided for @homeNoneThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum rolê encerrado neste mês ainda.'**
  String get homeNoneThisMonth;

  /// No description provided for @homeOutingRunning.
  ///
  /// In pt, this message translates to:
  /// **'Rolê em andamento'**
  String get homeOutingRunning;

  /// No description provided for @homeOutings.
  ///
  /// In pt, this message translates to:
  /// **'Rolês'**
  String get homeOutings;

  /// No description provided for @homeSpent.
  ///
  /// In pt, this message translates to:
  /// **'Gasto'**
  String get homeSpent;

  /// No description provided for @homeStartOuting.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar rolê'**
  String get homeStartOuting;

  /// No description provided for @homeThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get homeThisMonth;

  /// No description provided for @homeTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get homeTime;

  /// No description provided for @homeUnpriced.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 sem preço} other{{count} sem preço}}'**
  String homeUnpriced(int count);

  /// No description provided for @itemFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Item'**
  String get itemFallbackName;

  /// No description provided for @languageEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languageMoneyNote.
  ///
  /// In pt, this message translates to:
  /// **'Valores continuam em reais (R\$) em qualquer idioma.'**
  String get languageMoneyNote;

  /// No description provided for @languagePt.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePt;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Idioma do sistema'**
  String get languageSystem;

  /// No description provided for @languageSystemHint.
  ///
  /// In pt, this message translates to:
  /// **'Português, inglês ou espanhol conforme o aparelho; outros idiomas usam português.'**
  String get languageSystemHint;

  /// No description provided for @legacyAnonBody.
  ///
  /// In pt, this message translates to:
  /// **'Se você já usava o app neste aparelho, seus registros foram guardados. Crie sua conta para continuar com eles e recuperá-los em outro aparelho.'**
  String get legacyAnonBody;

  /// No description provided for @legacyAnonCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta com meus registros'**
  String get legacyAnonCreate;

  /// No description provided for @legacyAnonHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get legacyAnonHaveAccount;

  /// No description provided for @legacyAnonHaveAccountHint.
  ///
  /// In pt, this message translates to:
  /// **'Os registros antigos ficam separados neste aparelho; você decide depois se importa para a conta.'**
  String get legacyAnonHaveAccountHint;

  /// No description provided for @legacyAnonTitle.
  ///
  /// In pt, this message translates to:
  /// **'Agora o Bebômetro usa conta'**
  String get legacyAnonTitle;

  /// No description provided for @legacyAnonView.
  ///
  /// In pt, this message translates to:
  /// **'Ver ou exportar os registros antigos'**
  String get legacyAnonView;

  /// No description provided for @legacyDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas'**
  String get legacyDrinks;

  /// No description provided for @legacyExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar registros antigos (JSON)'**
  String get legacyExport;

  /// No description provided for @legacyImport.
  ///
  /// In pt, this message translates to:
  /// **'Importar para minha conta'**
  String get legacyImport;

  /// No description provided for @legacyImportAsEnded.
  ///
  /// In pt, this message translates to:
  /// **'Importar como encerrado'**
  String get legacyImportAsEnded;

  /// No description provided for @legacyImportExplain.
  ///
  /// In pt, this message translates to:
  /// **'Importar copia os registros para a conta atual com novos identificadores (as fotos são reenviadas). Uma conta anônima antiga não pode ser recuperada sem a sessão dela: o que importa é o que está neste aparelho.'**
  String get legacyImportExplain;

  /// No description provided for @legacyImportFailed.
  ///
  /// In pt, this message translates to:
  /// **'A importação não terminou. Nada foi apagado; tente de novo.'**
  String get legacyImportFailed;

  /// No description provided for @legacyImported.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Importação concluída: 1 registro copiado para a sua conta. A cópia antiga continua guardada neste aparelho.} other{Importação concluída: {count} registros copiados para a sua conta. A cópia antiga continua guardada neste aparelho.}}'**
  String legacyImported(int count);

  /// No description provided for @legacyKeep.
  ///
  /// In pt, this message translates to:
  /// **'Manter separados por enquanto'**
  String get legacyKeep;

  /// No description provided for @legacyKept.
  ///
  /// In pt, this message translates to:
  /// **'Os registros antigos continuam separados neste aparelho. Você pode importar quando quiser, por \"Minha conta\".'**
  String get legacyKept;

  /// No description provided for @legacyNeverSent.
  ///
  /// In pt, this message translates to:
  /// **'Nunca enviados'**
  String get legacyNeverSent;

  /// No description provided for @legacyNone.
  ///
  /// In pt, this message translates to:
  /// **'Não há registros antigos neste aparelho.'**
  String get legacyNone;

  /// No description provided for @legacyNotice.
  ///
  /// In pt, this message translates to:
  /// **'Há registros antigos neste aparelho. Eles estão guardados: depois de entrar, você pode importá-los. Toque para ver ou exportar.'**
  String get legacyNotice;

  /// No description provided for @legacyOfferBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Há 1 rolê de antes de o Bebômetro usar contas. Ele está guardado e não entra na sua conta sem você escolher.} other{Há {count} rolês de antes de o Bebômetro usar contas. Eles estão guardados e não entram na sua conta sem você escolher.}}'**
  String legacyOfferBody(int count);

  /// No description provided for @legacyOfferOpen.
  ///
  /// In pt, this message translates to:
  /// **'Ver e decidir'**
  String get legacyOfferOpen;

  /// No description provided for @legacyOfferTitle.
  ///
  /// In pt, this message translates to:
  /// **'Registros antigos neste aparelho'**
  String get legacyOfferTitle;

  /// No description provided for @legacyOutings.
  ///
  /// In pt, this message translates to:
  /// **'Rolês'**
  String get legacyOutings;

  /// No description provided for @legacyStatusAdopted.
  ///
  /// In pt, this message translates to:
  /// **'Estes registros já são da sua conta (criada a partir deles).'**
  String get legacyStatusAdopted;

  /// No description provided for @legacyStatusImported.
  ///
  /// In pt, this message translates to:
  /// **'Estes registros já foram importados para uma conta. A cópia antiga fica guardada aqui por segurança.'**
  String get legacyStatusImported;

  /// No description provided for @legacyStatusKept.
  ///
  /// In pt, this message translates to:
  /// **'Você escolheu manter estes registros separados.'**
  String get legacyStatusKept;

  /// No description provided for @legacyStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Registros feitos antes de o Bebômetro usar contas. Eles não foram apagados.'**
  String get legacyStatusPending;

  /// No description provided for @legacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Registros antigos'**
  String get legacyTitle;

  /// No description provided for @legacyTwoActiveBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta já tem um rolê em andamento e os registros antigos também. Para importar, o rolê antigo entra como encerrado agora. As bebidas dele continuam nele, sem se misturar.'**
  String get legacyTwoActiveBody;

  /// No description provided for @legacyTwoActiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dois rolês em andamento'**
  String get legacyTwoActiveTitle;

  /// No description provided for @moneyFieldHelper.
  ///
  /// In pt, this message translates to:
  /// **'Valores em reais (R\$). Ex.: 15 ou 15,50.'**
  String get moneyFieldHelper;

  /// No description provided for @moodCheerful.
  ///
  /// In pt, this message translates to:
  /// **'Alegre'**
  String get moodCheerful;

  /// No description provided for @moodDrunk.
  ///
  /// In pt, this message translates to:
  /// **'Bêbado'**
  String get moodDrunk;

  /// No description provided for @moodSmooth.
  ///
  /// In pt, this message translates to:
  /// **'Suave'**
  String get moodSmooth;

  /// No description provided for @moodWasted.
  ///
  /// In pt, this message translates to:
  /// **'Bebaço'**
  String get moodWasted;

  /// No description provided for @navCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo'**
  String get navCatalog;

  /// No description provided for @navGames.
  ///
  /// In pt, this message translates to:
  /// **'Resenha'**
  String get navGames;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @noticeAnotherOne.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma: {name}'**
  String noticeAnotherOne(String name);

  /// No description provided for @noticeEntryDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Registro excluído'**
  String get noticeEntryDeleted;

  /// No description provided for @noticeWater.
  ///
  /// In pt, this message translates to:
  /// **'Água registrada'**
  String get noticeWater;

  /// No description provided for @numberAmbiguous.
  ///
  /// In pt, this message translates to:
  /// **'Formato ambíguo. Use vírgula ou ponto só para os centavos (ex.: 1500 ou 15,50).'**
  String get numberAmbiguous;

  /// No description provided for @numberInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Número inválido.'**
  String get numberInvalid;

  /// No description provided for @outingAddDrink.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar bebida'**
  String get outingAddDrink;

  /// No description provided for @outingAlcoholIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 com álcool incompleto} other{{count} com álcool incompleto}}'**
  String outingAlcoholIncomplete(int count);

  /// No description provided for @outingAlreadyEnded.
  ///
  /// In pt, this message translates to:
  /// **'Esse rolê já foi encerrado.'**
  String get outingAlreadyEnded;

  /// No description provided for @outingConfirmAnother.
  ///
  /// In pt, this message translates to:
  /// **'Registrar mais uma: {drink}?'**
  String outingConfirmAnother(String drink);

  /// No description provided for @outingConfirmWater.
  ///
  /// In pt, this message translates to:
  /// **'Registrar um copo de água?'**
  String get outingConfirmWater;

  /// No description provided for @outingDrinkLogged.
  ///
  /// In pt, this message translates to:
  /// **'Bebida registrada'**
  String get outingDrinkLogged;

  /// No description provided for @outingEntryUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Registro atualizado'**
  String get outingEntryUpdated;

  /// No description provided for @outingFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Rolê'**
  String get outingFallbackName;

  /// No description provided for @outingFinish.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar rolê'**
  String get outingFinish;

  /// No description provided for @outingFirstDrinkHint.
  ///
  /// In pt, this message translates to:
  /// **'Registre a primeira bebida e o botão \"Mais uma\" aparece aqui embaixo.'**
  String get outingFirstDrinkHint;

  /// No description provided for @outingHideHere.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar neste rolê'**
  String get outingHideHere;

  /// No description provided for @outingInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get outingInProgress;

  /// No description provided for @outingLockScreenRequest.
  ///
  /// In pt, this message translates to:
  /// **'Pedido da tela bloqueada'**
  String get outingLockScreenRequest;

  /// No description provided for @outingLog.
  ///
  /// In pt, this message translates to:
  /// **'Registrar'**
  String get outingLog;

  /// No description provided for @outingNoDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma bebida ainda'**
  String get outingNoDrinks;

  /// No description provided for @outingNoDrinksBody.
  ///
  /// In pt, this message translates to:
  /// **'Registre a primeira e o botão \"Mais uma\" aparece aqui embaixo.'**
  String get outingNoDrinksBody;

  /// No description provided for @outingNoVolume.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 sem volume} other{{count} sem volume}}'**
  String outingNoVolume(int count);

  /// No description provided for @outingNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Esse rolê não foi encontrado.'**
  String get outingNotFound;

  /// No description provided for @outingNothingToRepeat.
  ///
  /// In pt, this message translates to:
  /// **'Não há bebida para repetir neste rolê.'**
  String get outingNothingToRepeat;

  /// No description provided for @outingOpenScan.
  ///
  /// In pt, this message translates to:
  /// **'Há uma leitura de rótulo ou cardápio em aberto. Ela continua ligada a este rolê e aparece no resumo dele.'**
  String get outingOpenScan;

  /// No description provided for @outingRecords.
  ///
  /// In pt, this message translates to:
  /// **'Registros ({count})'**
  String outingRecords(int count);

  /// No description provided for @outingRunningFor.
  ///
  /// In pt, this message translates to:
  /// **'Rolando há'**
  String get outingRunningFor;

  /// No description provided for @outingShowOnLock.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar na tela bloqueada'**
  String get outingShowOnLock;

  /// No description provided for @outingTrackingBack.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhamento na tela bloqueada de volta.'**
  String get outingTrackingBack;

  /// No description provided for @outingTrackingHidden.
  ///
  /// In pt, this message translates to:
  /// **'Oculto da tela bloqueada neste rolê.'**
  String get outingTrackingHidden;

  /// No description provided for @outingTypeBar.
  ///
  /// In pt, this message translates to:
  /// **'Bar'**
  String get outingTypeBar;

  /// No description provided for @outingTypeBarbecue.
  ///
  /// In pt, this message translates to:
  /// **'Churrasco'**
  String get outingTypeBarbecue;

  /// No description provided for @outingTypeBeach.
  ///
  /// In pt, this message translates to:
  /// **'Praia'**
  String get outingTypeBeach;

  /// No description provided for @outingTypeClub.
  ///
  /// In pt, this message translates to:
  /// **'Balada'**
  String get outingTypeClub;

  /// No description provided for @outingTypeHome.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get outingTypeHome;

  /// No description provided for @outingTypeOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get outingTypeOther;

  /// No description provided for @outingTypeRestaurant.
  ///
  /// In pt, this message translates to:
  /// **'Restaurante'**
  String get outingTypeRestaurant;

  /// No description provided for @outingTypeSince.
  ///
  /// In pt, this message translates to:
  /// **'{type} · desde {time}'**
  String outingTypeSince(String time, String type);

  /// No description provided for @outingYourVolume.
  ///
  /// In pt, this message translates to:
  /// **'Seu volume'**
  String get outingYourVolume;

  /// No description provided for @placeCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Corrigir local'**
  String get placeCorrect;

  /// No description provided for @placeOpenInMaps.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no mapa'**
  String get placeOpenInMaps;

  /// No description provided for @priceComplimentary.
  ///
  /// In pt, this message translates to:
  /// **'Cortesia'**
  String get priceComplimentary;

  /// No description provided for @priceNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço'**
  String get priceNone;

  /// No description provided for @priceUnknown.
  ///
  /// In pt, this message translates to:
  /// **'sem preço'**
  String get priceUnknown;

  /// No description provided for @repeatAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'{name} (ajustada)'**
  String repeatAdjusted(String name);

  /// No description provided for @repeatButton.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma'**
  String get repeatButton;

  /// No description provided for @repeatSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma: {drink}'**
  String repeatSemantics(String drink);

  /// No description provided for @repeatYourPart.
  ///
  /// In pt, this message translates to:
  /// **'sua parte {amount}'**
  String repeatYourPart(String amount);

  /// No description provided for @repoAbvRange.
  ///
  /// In pt, this message translates to:
  /// **'O teor vai de 0 a 100%.'**
  String get repoAbvRange;

  /// No description provided for @repoActiveExists.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um rolê em andamento.'**
  String get repoActiveExists;

  /// No description provided for @repoCopyName.
  ///
  /// In pt, this message translates to:
  /// **'{name} (cópia)'**
  String repoCopyName(String name);

  /// No description provided for @repoDrinkName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a bebida.'**
  String get repoDrinkName;

  /// No description provided for @repoDrinkVolume.
  ///
  /// In pt, this message translates to:
  /// **'Informe o volume em ml.'**
  String get repoDrinkVolume;

  /// No description provided for @repoEndBeforeStart.
  ///
  /// In pt, this message translates to:
  /// **'O fim não pode ser antes do início.'**
  String get repoEndBeforeStart;

  /// No description provided for @repoEndFuture.
  ///
  /// In pt, this message translates to:
  /// **'O fim não pode estar no futuro.'**
  String get repoEndFuture;

  /// No description provided for @repoNicknameOrAddress.
  ///
  /// In pt, this message translates to:
  /// **'Informe um apelido ou um endereço.'**
  String get repoNicknameOrAddress;

  /// No description provided for @repoPlaceMissing.
  ///
  /// In pt, this message translates to:
  /// **'Informe um apelido ou um endereço para o local.'**
  String get repoPlaceMissing;

  /// No description provided for @repoPointNeedsName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um apelido para salvar este ponto.'**
  String get repoPointNeedsName;

  /// No description provided for @repoRecipeIngredient.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos um ingrediente.'**
  String get repoRecipeIngredient;

  /// No description provided for @repoRecipeName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a receita.'**
  String get repoRecipeName;

  /// No description provided for @repoStateFormat.
  ///
  /// In pt, this message translates to:
  /// **'A UF tem 2 letras (ex.: SP).'**
  String get repoStateFormat;

  /// No description provided for @restoreBody.
  ///
  /// In pt, this message translates to:
  /// **'Trazendo seus rolês, bebidas, locais e comandas da nuvem.'**
  String get restoreBody;

  /// No description provided for @restoreConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando…'**
  String get restoreConnecting;

  /// No description provided for @restoreFailedBody.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a nuvem. Nada foi perdido: tente de novo quando estiver com internet.'**
  String get restoreFailedBody;

  /// No description provided for @restoreFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para recuperar agora'**
  String get restoreFailedTitle;

  /// No description provided for @restoreReceived.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro recebido até agora} other{{count} registros recebidos até agora}}'**
  String restoreReceived(int count);

  /// No description provided for @restoreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperando seu histórico'**
  String get restoreTitle;

  /// No description provided for @restoreUseApp.
  ///
  /// In pt, this message translates to:
  /// **'Usar o app enquanto isso'**
  String get restoreUseApp;

  /// No description provided for @restoreUseAppHint.
  ///
  /// In pt, this message translates to:
  /// **'Se continuar agora, o histórico aparece conforme chegar. Os registros novos ficam salvos neste aparelho e são enviados depois.'**
  String get restoreUseAppHint;

  /// No description provided for @settingsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Minha conta'**
  String get settingsAccount;

  /// No description provided for @settingsBudget.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento'**
  String get settingsBudget;

  /// No description provided for @settingsBudgetAlerts.
  ///
  /// In pt, this message translates to:
  /// **'Avisos de orçamento'**
  String get settingsBudgetAlerts;

  /// No description provided for @settingsBudgetAlertsHint.
  ///
  /// In pt, this message translates to:
  /// **'Um aviso ao chegar a 80% e a 100% do orçamento do rolê, uma vez por patamar.'**
  String get settingsBudgetAlertsHint;

  /// No description provided for @settingsDrinkRecords.
  ///
  /// In pt, this message translates to:
  /// **'Registros de bebida'**
  String get settingsDrinkRecords;

  /// No description provided for @settingsExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar meus dados'**
  String get settingsExport;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLastSync.
  ///
  /// In pt, this message translates to:
  /// **'Última sincronização: {when}'**
  String settingsLastSync(String when);

  /// No description provided for @settingsLastSyncNever.
  ///
  /// In pt, this message translates to:
  /// **'Última sincronização: ainda não houve.'**
  String get settingsLastSyncNever;

  /// No description provided for @settingsLocalRisk.
  ///
  /// In pt, this message translates to:
  /// **'Enquanto isso, se você desinstalar o app ou limpar os dados do navegador, o que está só neste aparelho será perdido.'**
  String get settingsLocalRisk;

  /// No description provided for @settingsLockScreen.
  ///
  /// In pt, this message translates to:
  /// **'Rolê na tela bloqueada'**
  String get settingsLockScreen;

  /// No description provided for @settingsMyDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Minhas bebidas'**
  String get settingsMyDrinks;

  /// No description provided for @settingsMyDrinksAndRecipes.
  ///
  /// In pt, this message translates to:
  /// **'Minhas bebidas e receitas'**
  String get settingsMyDrinksAndRecipes;

  /// No description provided for @settingsNotYetInCloud.
  ///
  /// In pt, this message translates to:
  /// **'Alguns dados ainda não chegaram à nuvem.'**
  String get settingsNotYetInCloud;

  /// No description provided for @settingsOutingsHere.
  ///
  /// In pt, this message translates to:
  /// **'Rolês neste aparelho'**
  String get settingsOutingsHere;

  /// No description provided for @settingsPendingChanges.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 alteração aguardando envio.} other{{count} alterações aguardando envio.}}'**
  String settingsPendingChanges(int count);

  /// No description provided for @settingsSavedPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Locais salvos'**
  String get settingsSavedPlaces;

  /// No description provided for @settingsStorage.
  ///
  /// In pt, this message translates to:
  /// **'ARMAZENAMENTO'**
  String get settingsStorage;

  /// No description provided for @settingsSync.
  ///
  /// In pt, this message translates to:
  /// **'SINCRONIZAÇÃO'**
  String get settingsSync;

  /// No description provided for @settingsSyncDone.
  ///
  /// In pt, this message translates to:
  /// **'Tudo sincronizado.'**
  String get settingsSyncDone;

  /// No description provided for @settingsSyncDoneConflicts.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Enviado, mas há 1 alteração para resolver em Minha conta.} other{Enviado, mas há {count} alterações para resolver em Minha conta.}}'**
  String settingsSyncDoneConflicts(int count);

  /// No description provided for @settingsSyncFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sincronizar agora.'**
  String get settingsSyncFailed;

  /// No description provided for @settingsSyncNow.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar agora'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncState.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get settingsSyncState;

  /// No description provided for @settingsSyncStillPending.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Ainda há 1 alteração para enviar.} other{Ainda há {count} alterações para enviar.}}'**
  String settingsSyncStillPending(int count);

  /// No description provided for @settingsTable.
  ///
  /// In pt, this message translates to:
  /// **'Mesa do rolê'**
  String get settingsTable;

  /// No description provided for @settingsTableAnimations.
  ///
  /// In pt, this message translates to:
  /// **'Animações da mesa'**
  String get settingsTableAnimations;

  /// No description provided for @settingsTableAnimationsHint.
  ///
  /// In pt, this message translates to:
  /// **'Os recipientes esvaziam como ilustração. Desligado, a mesa fica estática.'**
  String get settingsTableAnimationsHint;

  /// No description provided for @settingsTableDefault.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar mesa como padrão'**
  String get settingsTableDefault;

  /// No description provided for @settingsTableDefaultHint.
  ///
  /// In pt, this message translates to:
  /// **'Na tela do rolê, a mesa ilustrada abre antes da lista.'**
  String get settingsTableDefaultHint;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @shareUnavailableCopied.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar não está disponível aqui. O conteúdo foi copiado: cole em um arquivo para guardar.'**
  String get shareUnavailableCopied;

  /// No description provided for @shellBackToOuting.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao rolê'**
  String get shellBackToOuting;

  /// No description provided for @shellOutingRunning.
  ///
  /// In pt, this message translates to:
  /// **'Rolê em andamento · {name}'**
  String shellOutingRunning(String name);

  /// No description provided for @staleBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} começou em {start} e está aberto há {duration}.'**
  String staleBody(String duration, String name, String start);

  /// No description provided for @staleEndOtherTime.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar com outro horário'**
  String get staleEndOtherTime;

  /// No description provided for @staleNote.
  ///
  /// In pt, this message translates to:
  /// **'Ao encerrar você escolhe o horário final. Nada é encerrado automaticamente.'**
  String get staleNote;

  /// No description provided for @staleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esse rolê ainda está acontecendo?'**
  String get staleTitle;

  /// No description provided for @startFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar o rolê. Tente de novo.'**
  String get startFailed;

  /// No description provided for @startFuture.
  ///
  /// In pt, this message translates to:
  /// **'O início não pode estar no futuro.'**
  String get startFuture;

  /// No description provided for @startPlaceError.
  ///
  /// In pt, this message translates to:
  /// **'Informe um apelido (ex.: Casa da Samara) ou um endereço'**
  String get startPlaceError;

  /// No description provided for @stateTwoLetters.
  ///
  /// In pt, this message translates to:
  /// **'A UF tem 2 letras'**
  String get stateTwoLetters;

  /// No description provided for @summaryAccountNote.
  ///
  /// In pt, this message translates to:
  /// **'Relato pessoal: não mede nada e não indica um limite de consumo.'**
  String get summaryAccountNote;

  /// No description provided for @summaryAddAccount.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar relato'**
  String get summaryAddAccount;

  /// No description provided for @summaryAddForgotten.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar bebida esquecida'**
  String get summaryAddForgotten;

  /// No description provided for @summaryConsumption.
  ///
  /// In pt, this message translates to:
  /// **'Consumo'**
  String get summaryConsumption;

  /// No description provided for @summaryDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get summaryDone;

  /// No description provided for @summaryDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get summaryDuration;

  /// No description provided for @summaryEditAccount.
  ///
  /// In pt, this message translates to:
  /// **'Editar relato'**
  String get summaryEditAccount;

  /// No description provided for @summaryEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim'**
  String get summaryEnd;

  /// No description provided for @summaryFillPrices.
  ///
  /// In pt, this message translates to:
  /// **'Preencher preços ausentes'**
  String get summaryFillPrices;

  /// No description provided for @summaryHangover.
  ///
  /// In pt, this message translates to:
  /// **'Ressaca: {level}'**
  String summaryHangover(String level);

  /// No description provided for @summaryNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Sem relato ainda.'**
  String get summaryNoAccount;

  /// No description provided for @summaryNoRecords.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro neste rolê'**
  String get summaryNoRecords;

  /// No description provided for @summaryRetro.
  ///
  /// In pt, this message translates to:
  /// **'Retrospectiva ilustrativa dos registros. Os números reais estão abaixo.'**
  String get summaryRetro;

  /// No description provided for @summaryShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar resumo'**
  String get summaryShare;

  /// No description provided for @summarySpending.
  ///
  /// In pt, this message translates to:
  /// **'Gastos'**
  String get summarySpending;

  /// No description provided for @summarySpentOnDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Gastos registrados em bebidas'**
  String get summarySpentOnDrinks;

  /// No description provided for @summaryStart.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get summaryStart;

  /// No description provided for @summaryTab.
  ///
  /// In pt, this message translates to:
  /// **'Comanda'**
  String get summaryTab;

  /// No description provided for @summaryTapToCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Toque em um registro para corrigir; o resumo se recalcula.'**
  String get summaryTapToCorrect;

  /// No description provided for @summaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo do rolê'**
  String get summaryTitle;

  /// No description provided for @summaryUnpricedPill.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 bebida sem preço: o total pode estar maior} other{{count} bebidas sem preço: o total pode estar maior}}'**
  String summaryUnpricedPill(int count);

  /// No description provided for @summaryUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Registro atualizado, resumo recalculado'**
  String get summaryUpdated;

  /// No description provided for @summaryWoke.
  ///
  /// In pt, this message translates to:
  /// **'Acordou: {feeling}'**
  String summaryWoke(String feeling);

  /// No description provided for @summaryYourAccount.
  ///
  /// In pt, this message translates to:
  /// **'Seu relato'**
  String get summaryYourAccount;

  /// No description provided for @summaryYourAccountTag.
  ///
  /// In pt, this message translates to:
  /// **'seu relato'**
  String get summaryYourAccountTag;

  /// No description provided for @syncLabelConflicts.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 para resolver} other{{count} para resolver}}'**
  String syncLabelConflicts(int count);

  /// No description provided for @syncLabelFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao sincronizar'**
  String get syncLabelFailed;

  /// No description provided for @syncLabelLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só neste aparelho'**
  String get syncLabelLocalOnly;

  /// No description provided for @syncLabelPending.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 aguardando envio} other{{count} aguardando envio}}'**
  String syncLabelPending(int count);

  /// No description provided for @syncLabelSynced.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizado'**
  String get syncLabelSynced;

  /// No description provided for @syncLabelSyncing.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizando…'**
  String get syncLabelSyncing;

  /// No description provided for @syncNoticeActiveConflict.
  ///
  /// In pt, this message translates to:
  /// **'O servidor já tem outro rolê em andamento. Nada foi apagado: os dados continuam salvos no aparelho.'**
  String get syncNoticeActiveConflict;

  /// No description provided for @syncNoticeLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'A nuvem ainda não está disponível. Seus registros estão salvos só neste aparelho e serão enviados quando for possível.'**
  String get syncNoticeLocalOnly;

  /// No description provided for @syncNoticeOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Vamos tentar de novo.'**
  String get syncNoticeOffline;

  /// No description provided for @syncNoticePhotos.
  ///
  /// In pt, this message translates to:
  /// **'Algumas fotos ainda não foram enviadas. Elas continuam salvas no aparelho e o envio será tentado de novo.'**
  String get syncNoticePhotos;

  /// No description provided for @syncNoticePlaceLink.
  ///
  /// In pt, this message translates to:
  /// **'O servidor não aceitou o vínculo de um rolê com o local salvo. Nada foi alterado: os dados continuam salvos no aparelho.'**
  String get syncNoticePlaceLink;

  /// No description provided for @syncNoticeRejected.
  ///
  /// In pt, this message translates to:
  /// **'O servidor recusou algumas alterações. Seus dados continuam salvos no aparelho.'**
  String get syncNoticeRejected;

  /// No description provided for @syncNoticeSchemaGap.
  ///
  /// In pt, this message translates to:
  /// **'Parte dos dados novos aguarda uma atualização do servidor. O restante já foi enviado e nada foi perdido.'**
  String get syncNoticeSchemaGap;

  /// No description provided for @syncNoticeSignInAgain.
  ///
  /// In pt, this message translates to:
  /// **'Entre novamente na sua conta para enviar e receber os dados. Tudo continua salvo neste aparelho.'**
  String get syncNoticeSignInAgain;

  /// No description provided for @syncNoticeWaitingPlace.
  ///
  /// In pt, this message translates to:
  /// **'Alguns rolês aguardam o envio do local salvo. Nada foi perdido.'**
  String get syncNoticeWaitingPlace;

  /// No description provided for @tableAboutMenu.
  ///
  /// In pt, this message translates to:
  /// **'Animação ilustrativa das bebidas registradas'**
  String get tableAboutMenu;

  /// No description provided for @tableChangeScene.
  ///
  /// In pt, this message translates to:
  /// **'Trocar cenário'**
  String get tableChangeScene;

  /// No description provided for @tableOptions.
  ///
  /// In pt, this message translates to:
  /// **'Opções da mesa'**
  String get tableOptions;

  /// No description provided for @tableViewList.
  ///
  /// In pt, this message translates to:
  /// **'Lista'**
  String get tableViewList;

  /// No description provided for @tableViewTable.
  ///
  /// In pt, this message translates to:
  /// **'Mesa'**
  String get tableViewTable;

  /// No description provided for @unitGrams.
  ///
  /// In pt, this message translates to:
  /// **'{value} g'**
  String unitGrams(String value);

  /// No description provided for @unitMl.
  ///
  /// In pt, this message translates to:
  /// **'{value} ml'**
  String unitMl(String value);

  /// No description provided for @volumeKnownPlusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'{known} (+{count} sem volume)'**
  String volumeKnownPlusUnknown(int count, String known);

  /// No description provided for @volumeUnknown.
  ///
  /// In pt, this message translates to:
  /// **'desconhecido'**
  String get volumeUnknown;

  /// No description provided for @wakeBad.
  ///
  /// In pt, this message translates to:
  /// **'Mal'**
  String get wakeBad;

  /// No description provided for @wakeGreat.
  ///
  /// In pt, this message translates to:
  /// **'Bem'**
  String get wakeGreat;

  /// No description provided for @wakeOk.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get wakeOk;

  /// No description provided for @wakeTired.
  ///
  /// In pt, this message translates to:
  /// **'Cansado'**
  String get wakeTired;

  /// No description provided for @startTitle.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar rolê'**
  String get startTitle;

  /// No description provided for @startWhatKind.
  ///
  /// In pt, this message translates to:
  /// **'Que tipo de rolê?'**
  String get startWhatKind;

  /// No description provided for @startWhere.
  ///
  /// In pt, this message translates to:
  /// **'Onde?'**
  String get startWhere;

  /// No description provided for @startSearchPlace.
  ///
  /// In pt, this message translates to:
  /// **'Buscar bar ou endereço'**
  String get startSearchPlace;

  /// No description provided for @startSearchPlaceHint.
  ///
  /// In pt, this message translates to:
  /// **'Ou usar sua localização e conferir no mapa'**
  String get startSearchPlaceHint;

  /// No description provided for @startSavedPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Locais salvos'**
  String get startSavedPlaces;

  /// No description provided for @startOrNickname.
  ///
  /// In pt, this message translates to:
  /// **'Ou só um apelido'**
  String get startOrNickname;

  /// No description provided for @startNicknameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Apelido do local'**
  String get startNicknameLabel;

  /// No description provided for @startNicknameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Bar MELT, Casa da Samara'**
  String get startNicknameHint;

  /// No description provided for @startAddAddress.
  ///
  /// In pt, this message translates to:
  /// **'Digitar endereço (opcional)'**
  String get startAddAddress;

  /// No description provided for @startAddressLabel.
  ///
  /// In pt, this message translates to:
  /// **'Endereço (opcional)'**
  String get startAddressLabel;

  /// No description provided for @startAddressHint.
  ///
  /// In pt, this message translates to:
  /// **'Rua, número, bairro'**
  String get startAddressHint;

  /// No description provided for @startAddressHelper.
  ///
  /// In pt, this message translates to:
  /// **'Apelido ou endereço já bastam.'**
  String get startAddressHelper;

  /// No description provided for @startCityLabel.
  ///
  /// In pt, this message translates to:
  /// **'Cidade (opcional)'**
  String get startCityLabel;

  /// No description provided for @startStateLabel.
  ///
  /// In pt, this message translates to:
  /// **'UF'**
  String get startStateLabel;

  /// No description provided for @startSavePlace.
  ///
  /// In pt, this message translates to:
  /// **'Salvar este local'**
  String get startSavePlace;

  /// No description provided for @startSavePlaceHint.
  ///
  /// In pt, this message translates to:
  /// **'Para escolher de novo nos próximos rolês. Fica privado no seu perfil.'**
  String get startSavePlaceHint;

  /// No description provided for @startWhen.
  ///
  /// In pt, this message translates to:
  /// **'Quando começou?'**
  String get startWhen;

  /// No description provided for @startBudgetSection.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento (opcional)'**
  String get startBudgetSection;

  /// No description provided for @startBudgetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento para bebidas'**
  String get startBudgetLabel;

  /// No description provided for @startBudgetHelper.
  ///
  /// In pt, this message translates to:
  /// **'Você pode definir ou mudar depois, durante o rolê. Valores em reais (R\$).'**
  String get startBudgetHelper;

  /// No description provided for @startBegin.
  ///
  /// In pt, this message translates to:
  /// **'Começar o rolê'**
  String get startBegin;

  /// No description provided for @startWillSavePlace.
  ///
  /// In pt, this message translates to:
  /// **'Será salvo nos seus locais'**
  String get startWillSavePlace;

  /// No description provided for @startChangePlace.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get startChangePlace;

  /// No description provided for @priceFixApplyTitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Aplicar a 1 registro?} other{Aplicar a {count} registros?}}'**
  String priceFixApplyTitle(int count);

  /// No description provided for @priceFixReplaced.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 já tinha preço e será substituído.} other{{count} já tinham preço e serão substituídos.}}'**
  String priceFixReplaced(int count);

  /// No description provided for @priceFixYourShare.
  ///
  /// In pt, this message translates to:
  /// **'sua parcela'**
  String get priceFixYourShare;

  /// No description provided for @priceFixUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Preços atualizados'**
  String get priceFixUpdated;

  /// No description provided for @priceFixPaidLabel.
  ///
  /// In pt, this message translates to:
  /// **'Preço pago'**
  String get priceFixPaidLabel;

  /// No description provided for @priceFixPaidShared.
  ///
  /// In pt, this message translates to:
  /// **'Quanto você pagou'**
  String get priceFixPaidShared;

  /// No description provided for @priceFixSharedNote.
  ///
  /// In pt, this message translates to:
  /// **'Bebida compartilhada: informe a sua parcela, não o preço da garrafa. O consumo não muda.'**
  String get priceFixSharedNote;

  /// No description provided for @priceFixEnterValue.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor'**
  String get priceFixEnterValue;

  /// No description provided for @priceFixTitle.
  ///
  /// In pt, this message translates to:
  /// **'Preços ausentes'**
  String get priceFixTitle;

  /// No description provided for @priceFixNoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum preço ausente'**
  String get priceFixNoneTitle;

  /// No description provided for @priceFixNoneBody.
  ///
  /// In pt, this message translates to:
  /// **'Todos os registros deste rolê têm preço ou cortesia informados.'**
  String get priceFixNoneBody;

  /// No description provided for @priceFixIntro.
  ///
  /// In pt, this message translates to:
  /// **'Preencha um por um, ou escolha vários registros iguais e aplique o mesmo preço depois de ver a prévia. Preços já informados não mudam, a menos que você os inclua e selecione de propósito.'**
  String get priceFixIntro;

  /// No description provided for @priceFixIncludePriced.
  ///
  /// In pt, this message translates to:
  /// **'Incluir também registros que já têm preço'**
  String get priceFixIncludePriced;

  /// No description provided for @priceFixForSelected.
  ///
  /// In pt, this message translates to:
  /// **'Preço para os selecionados'**
  String get priceFixForSelected;

  /// No description provided for @priceFixSharedHint.
  ///
  /// In pt, this message translates to:
  /// **'Em bebida compartilhada vale o que você pagou (sua parcela), nunca o preço da garrafa.'**
  String get priceFixSharedHint;

  /// No description provided for @priceFixSelectAll.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar os {count}'**
  String priceFixSelectAll(String count);

  /// No description provided for @priceFixClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get priceFixClear;

  /// No description provided for @priceFixCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Preço atual: {price}'**
  String priceFixCurrent(String price);

  /// No description provided for @priceFixOnlyThis.
  ///
  /// In pt, this message translates to:
  /// **'Informar só este preço'**
  String get priceFixOnlyThis;

  /// No description provided for @priceFixSelectRecords.
  ///
  /// In pt, this message translates to:
  /// **'Selecione registros'**
  String get priceFixSelectRecords;

  /// No description provided for @priceFixPreview.
  ///
  /// In pt, this message translates to:
  /// **'Ver prévia ({count})'**
  String priceFixPreview(String count);
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
