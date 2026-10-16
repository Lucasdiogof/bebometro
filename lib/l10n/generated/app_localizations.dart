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

  /// No description provided for @authCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authCreateAccount;

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

  /// No description provided for @authPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get authPassword;

  /// No description provided for @authPasswordHelper.
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 8 caracteres.'**
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

  /// No description provided for @authCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código'**
  String get authCodeTitle;

  /// No description provided for @authCodeBody.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código de 6 dígitos para {email}. Digite-o abaixo; ele vale por pouco tempo.'**
  String authCodeBody(String email);

  /// No description provided for @authCodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código de 6 dígitos'**
  String get authCodeLabel;

  /// No description provided for @authCodeVerify.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar código'**
  String get authCodeVerify;

  /// No description provided for @authCodeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou expirado. Confira os 6 dígitos ou peça um novo código.'**
  String get authCodeInvalid;

  /// No description provided for @authCodeIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Digite os 6 dígitos do código.'**
  String get authCodeIncomplete;

  /// No description provided for @authHaveCode.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho um código'**
  String get authHaveCode;

  /// No description provided for @authRecoverBody.
  ///
  /// In pt, this message translates to:
  /// **'Enviaremos um código de 6 dígitos para o seu e-mail. Você o digita aqui no app, em qualquer aparelho.'**
  String get authRecoverBody;

  /// No description provided for @authRecoverSent.
  ///
  /// In pt, this message translates to:
  /// **'Se houver uma conta com esse e-mail, o código chega em instantes. Confira também o spam.'**
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

  /// No description provided for @authSendLink.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código'**
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

  /// No description provided for @authWeakPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha fraca. Use pelo menos 8 caracteres.'**
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
  String budgetLeftIncomplete(int count, String amount);

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
  String budgetReached(int percent, String spent, String budget);

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
  String conflictTabPayments(int count, String amount);

  /// No description provided for @conflictTabPeople.
  ///
  /// In pt, this message translates to:
  /// **'{people, plural, =1{1 participante} other{{people} participantes}} · {extras, plural, =0{nenhum item extra} =1{1 item extra} other{{extras} itens extras}}'**
  String conflictTabPeople(int people, int extras);

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

  /// No description provided for @entryRepeat.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get entryRepeat;

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
  String outingTypeSince(String type, String time);

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
  String staleBody(String name, String start, String duration);

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
  String volumeKnownPlusUnknown(String known, int count);

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

  /// No description provided for @originGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Genérico'**
  String get originGeneric;

  /// No description provided for @originUser.
  ///
  /// In pt, this message translates to:
  /// **'Criada por você'**
  String get originUser;

  /// No description provided for @originVerified.
  ///
  /// In pt, this message translates to:
  /// **'Dados do fabricante'**
  String get originVerified;

  /// No description provided for @originMixed.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante + rótulo (fonte secundária)'**
  String get originMixed;

  /// No description provided for @originSecondary.
  ///
  /// In pt, this message translates to:
  /// **'Rótulo em fonte secundária'**
  String get originSecondary;

  /// No description provided for @originRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Receita de referência'**
  String get originRecipe;

  /// No description provided for @kindCan.
  ///
  /// In pt, this message translates to:
  /// **'Lata'**
  String get kindCan;

  /// No description provided for @kindLongNeck.
  ///
  /// In pt, this message translates to:
  /// **'Long neck'**
  String get kindLongNeck;

  /// No description provided for @kindBottle.
  ///
  /// In pt, this message translates to:
  /// **'Garrafa'**
  String get kindBottle;

  /// No description provided for @kindGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo/taça'**
  String get kindGlass;

  /// No description provided for @kindShot.
  ///
  /// In pt, this message translates to:
  /// **'Dose'**
  String get kindShot;

  /// No description provided for @presCan.
  ///
  /// In pt, this message translates to:
  /// **'Lata'**
  String get presCan;

  /// No description provided for @presBottle.
  ///
  /// In pt, this message translates to:
  /// **'Garrafa'**
  String get presBottle;

  /// No description provided for @presGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo'**
  String get presGlass;

  /// No description provided for @presMug.
  ///
  /// In pt, this message translates to:
  /// **'Caneca'**
  String get presMug;

  /// No description provided for @presTulip.
  ///
  /// In pt, this message translates to:
  /// **'Tulipa'**
  String get presTulip;

  /// No description provided for @presWineGlass.
  ///
  /// In pt, this message translates to:
  /// **'Taça'**
  String get presWineGlass;

  /// No description provided for @presShot.
  ///
  /// In pt, this message translates to:
  /// **'Dose'**
  String get presShot;

  /// No description provided for @presDoubleShot.
  ///
  /// In pt, this message translates to:
  /// **'Dose dupla'**
  String get presDoubleShot;

  /// No description provided for @unitLiters.
  ///
  /// In pt, this message translates to:
  /// **'{value} L'**
  String unitLiters(String value);

  /// No description provided for @abvVaries.
  ///
  /// In pt, this message translates to:
  /// **'teor varia'**
  String get abvVaries;

  /// No description provided for @categoryBeer.
  ///
  /// In pt, this message translates to:
  /// **'Cerveja'**
  String get categoryBeer;

  /// No description provided for @categoryDraft.
  ///
  /// In pt, this message translates to:
  /// **'Chopp'**
  String get categoryDraft;

  /// No description provided for @categoryCocktail.
  ///
  /// In pt, this message translates to:
  /// **'Drink'**
  String get categoryCocktail;

  /// No description provided for @categorySpirit.
  ///
  /// In pt, this message translates to:
  /// **'Destilado/dose'**
  String get categorySpirit;

  /// No description provided for @categoryReadyToDrink.
  ///
  /// In pt, this message translates to:
  /// **'Bebida pronta'**
  String get categoryReadyToDrink;

  /// No description provided for @categoryWine.
  ///
  /// In pt, this message translates to:
  /// **'Vinho'**
  String get categoryWine;

  /// No description provided for @categoryNonAlcoholic.
  ///
  /// In pt, this message translates to:
  /// **'Sem álcool'**
  String get categoryNonAlcoholic;

  /// No description provided for @categoryWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get categoryWater;

  /// No description provided for @abvSourceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rótulo (foto), conferido por você'**
  String get abvSourceLabel;

  /// No description provided for @abvSourceMenu.
  ///
  /// In pt, this message translates to:
  /// **'Cardápio (foto), conferido por você'**
  String get abvSourceMenu;

  /// No description provided for @abvSourceTyped.
  ///
  /// In pt, this message translates to:
  /// **'Informado por você'**
  String get abvSourceTyped;

  /// No description provided for @abvSourceCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Copiado do catálogo'**
  String get abvSourceCatalog;

  /// No description provided for @styleLagerPilsen.
  ///
  /// In pt, this message translates to:
  /// **'Lager/Pilsen'**
  String get styleLagerPilsen;

  /// No description provided for @styleDark.
  ///
  /// In pt, this message translates to:
  /// **'Escura'**
  String get styleDark;

  /// No description provided for @styleWhiteRum.
  ///
  /// In pt, this message translates to:
  /// **'Rum branco'**
  String get styleWhiteRum;

  /// No description provided for @styleAperitif.
  ///
  /// In pt, this message translates to:
  /// **'Aperitivo'**
  String get styleAperitif;

  /// No description provided for @styleBitterAperitif.
  ///
  /// In pt, this message translates to:
  /// **'Aperitivo bitter'**
  String get styleBitterAperitif;

  /// No description provided for @styleSweetVermouth.
  ///
  /// In pt, this message translates to:
  /// **'Vermute doce'**
  String get styleSweetVermouth;

  /// No description provided for @styleDryVermouth.
  ///
  /// In pt, this message translates to:
  /// **'Vermute seco'**
  String get styleDryVermouth;

  /// No description provided for @styleAgaveTequila.
  ///
  /// In pt, this message translates to:
  /// **'Tequila 100% agave'**
  String get styleAgaveTequila;

  /// No description provided for @roleCachaca.
  ///
  /// In pt, this message translates to:
  /// **'Cachaça'**
  String get roleCachaca;

  /// No description provided for @roleVodka.
  ///
  /// In pt, this message translates to:
  /// **'Vodka'**
  String get roleVodka;

  /// No description provided for @roleGin.
  ///
  /// In pt, this message translates to:
  /// **'Gin'**
  String get roleGin;

  /// No description provided for @roleRum.
  ///
  /// In pt, this message translates to:
  /// **'Rum'**
  String get roleRum;

  /// No description provided for @roleTequila.
  ///
  /// In pt, this message translates to:
  /// **'Tequila'**
  String get roleTequila;

  /// No description provided for @roleWhisky.
  ///
  /// In pt, this message translates to:
  /// **'Whisky'**
  String get roleWhisky;

  /// No description provided for @roleOrangeLiqueur.
  ///
  /// In pt, this message translates to:
  /// **'Licor de laranja'**
  String get roleOrangeLiqueur;

  /// No description provided for @roleCampari.
  ///
  /// In pt, this message translates to:
  /// **'Campari'**
  String get roleCampari;

  /// No description provided for @roleAperol.
  ///
  /// In pt, this message translates to:
  /// **'Aperol'**
  String get roleAperol;

  /// No description provided for @roleSweetVermouth.
  ///
  /// In pt, this message translates to:
  /// **'Vermute doce'**
  String get roleSweetVermouth;

  /// No description provided for @roleDryVermouth.
  ///
  /// In pt, this message translates to:
  /// **'Vermute seco'**
  String get roleDryVermouth;

  /// No description provided for @roleSparklingWine.
  ///
  /// In pt, this message translates to:
  /// **'Espumante'**
  String get roleSparklingWine;

  /// No description provided for @roleBitters.
  ///
  /// In pt, this message translates to:
  /// **'Bitter'**
  String get roleBitters;

  /// No description provided for @recipeUnitMl.
  ///
  /// In pt, this message translates to:
  /// **'ml (mililitros)'**
  String get recipeUnitMl;

  /// No description provided for @recipeUnitG.
  ///
  /// In pt, this message translates to:
  /// **'g (gramas)'**
  String get recipeUnitG;

  /// No description provided for @recipeUnitUnit.
  ///
  /// In pt, this message translates to:
  /// **'unidade'**
  String get recipeUnitUnit;

  /// No description provided for @recipeUnitTsp.
  ///
  /// In pt, this message translates to:
  /// **'colher de chá'**
  String get recipeUnitTsp;

  /// No description provided for @recipeUnitTbsp.
  ///
  /// In pt, this message translates to:
  /// **'colher de sopa'**
  String get recipeUnitTbsp;

  /// No description provided for @recipeUnitLeaf.
  ///
  /// In pt, this message translates to:
  /// **'folha'**
  String get recipeUnitLeaf;

  /// No description provided for @recipeUnitDrop.
  ///
  /// In pt, this message translates to:
  /// **'gota'**
  String get recipeUnitDrop;

  /// No description provided for @recipeUnitToTaste.
  ///
  /// In pt, this message translates to:
  /// **'a gosto'**
  String get recipeUnitToTaste;

  /// No description provided for @recipeUnitOther.
  ///
  /// In pt, this message translates to:
  /// **'texto da receita'**
  String get recipeUnitOther;

  /// No description provided for @recipeShortUnit.
  ///
  /// In pt, this message translates to:
  /// **'un.'**
  String get recipeShortUnit;

  /// No description provided for @recipeShortTsp.
  ///
  /// In pt, this message translates to:
  /// **'c. chá'**
  String get recipeShortTsp;

  /// No description provided for @recipeShortTbsp.
  ///
  /// In pt, this message translates to:
  /// **'c. sopa'**
  String get recipeShortTbsp;

  /// No description provided for @recipeShortLeaf.
  ///
  /// In pt, this message translates to:
  /// **'folha(s)'**
  String get recipeShortLeaf;

  /// No description provided for @recipeShortDrop.
  ///
  /// In pt, this message translates to:
  /// **'gota(s)'**
  String get recipeShortDrop;

  /// No description provided for @recipeAmountUnknown.
  ///
  /// In pt, this message translates to:
  /// **'quantidade não informada'**
  String get recipeAmountUnknown;

  /// No description provided for @recipeGapAbv.
  ///
  /// In pt, this message translates to:
  /// **'teor desconhecido'**
  String get recipeGapAbv;

  /// No description provided for @recipeGapNotMl.
  ///
  /// In pt, this message translates to:
  /// **'quantidade não está em ml'**
  String get recipeGapNotMl;

  /// No description provided for @recipeGapAmount.
  ///
  /// In pt, this message translates to:
  /// **'quantidade desconhecida'**
  String get recipeGapAmount;

  /// No description provided for @addDrinkTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar bebida'**
  String get addDrinkTitle;

  /// No description provided for @catalogMyDrinksTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Minhas bebidas e receitas'**
  String get catalogMyDrinksTooltip;

  /// No description provided for @catalogSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar marca, produto ou estilo'**
  String get catalogSearchHint;

  /// No description provided for @catalogMoreFilters.
  ///
  /// In pt, this message translates to:
  /// **'Mais filtros'**
  String get catalogMoreFilters;

  /// No description provided for @catalogAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get catalogAll;

  /// No description provided for @catalogScanLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ler rótulo'**
  String get catalogScanLabel;

  /// No description provided for @catalogScanMenu.
  ///
  /// In pt, this message translates to:
  /// **'Ler cardápio'**
  String get catalogScanMenu;

  /// No description provided for @catalogCreate.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar bebida'**
  String get catalogCreate;

  /// No description provided for @catalogCreateOuting.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar bebida deste rolê'**
  String get catalogCreateOuting;

  /// No description provided for @catalogNeedOutingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Precisa de um rolê em andamento'**
  String get catalogNeedOutingTitle;

  /// No description provided for @catalogNeedOutingBody.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas lidas de rótulo ou cardápio ficam guardadas no rolê em que foram cadastradas. Quer iniciar um agora?'**
  String get catalogNeedOutingBody;

  /// No description provided for @catalogSavedToOuting.
  ///
  /// In pt, this message translates to:
  /// **'Salva em \"Bebidas deste rolê\"'**
  String get catalogSavedToOuting;

  /// No description provided for @catalogMenuSaved.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item em \"Bebidas deste rolê\". Escolha um para registrar.} other{{count} itens em \"Bebidas deste rolê\". Escolha um para registrar.}}'**
  String catalogMenuSaved(int count);

  /// No description provided for @catalogDrinkSaved.
  ///
  /// In pt, this message translates to:
  /// **'Bebida salva em Minhas bebidas'**
  String get catalogDrinkSaved;

  /// No description provided for @catalogRecipeSaved.
  ///
  /// In pt, this message translates to:
  /// **'Receita salva em Minhas bebidas'**
  String get catalogRecipeSaved;

  /// No description provided for @catalogDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir esta bebida?'**
  String get catalogDeleteTitle;

  /// No description provided for @catalogDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Ela sai do catálogo. Os registros que você já fez com ela continuam como estão.'**
  String get catalogDeleteBody;

  /// No description provided for @catalogClearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get catalogClearFilters;

  /// No description provided for @catalogRemoveFilter.
  ///
  /// In pt, this message translates to:
  /// **'Remover filtro'**
  String get catalogRemoveFilter;

  /// No description provided for @catalogFilters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get catalogFilters;

  /// No description provided for @catalogOnlyNoAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Só sem álcool'**
  String get catalogOnlyNoAlcohol;

  /// No description provided for @catalogStyle.
  ///
  /// In pt, this message translates to:
  /// **'Estilo'**
  String get catalogStyle;

  /// No description provided for @catalogPresentation.
  ///
  /// In pt, this message translates to:
  /// **'Apresentação'**
  String get catalogPresentation;

  /// No description provided for @catalogBrand.
  ///
  /// In pt, this message translates to:
  /// **'Marca'**
  String get catalogBrand;

  /// No description provided for @catalogSeeCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Ver 1 bebida} other{Ver {count} bebidas}}'**
  String catalogSeeCount(int count);

  /// No description provided for @catalogRecents.
  ///
  /// In pt, this message translates to:
  /// **'Recentes'**
  String get catalogRecents;

  /// No description provided for @catalogFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritas'**
  String get catalogFavorites;

  /// No description provided for @catalogAllDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Todas as bebidas'**
  String get catalogAllDrinks;

  /// No description provided for @catalogResults.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 resultado} other{{count} resultados}}'**
  String catalogResults(int count);

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma bebida encontrada'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyOuting.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre uma bebida só deste rolê, ou leia um rótulo ou cardápio.'**
  String get catalogEmptyOuting;

  /// No description provided for @catalogEmptyNoFilter.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre a sua e ela fica salva para os próximos rolês.'**
  String get catalogEmptyNoFilter;

  /// No description provided for @catalogEmptyFilter.
  ///
  /// In pt, this message translates to:
  /// **'Tente tirar algum filtro ou cadastre a sua.'**
  String get catalogEmptyFilter;

  /// No description provided for @catalogSizes.
  ///
  /// In pt, this message translates to:
  /// **'{count} tamanhos'**
  String catalogSizes(String count);

  /// No description provided for @catalogDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get catalogDetails;

  /// No description provided for @catalogUnfavorite.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get catalogUnfavorite;

  /// No description provided for @catalogFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Favoritar'**
  String get catalogFavorite;

  /// No description provided for @entryDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir registro?'**
  String get entryDeleteTitle;

  /// No description provided for @entryDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Ele sai do rolê e do resumo.'**
  String get entryDeleteBody;

  /// No description provided for @entryDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações?'**
  String get entryDiscardTitle;

  /// No description provided for @entryDiscardBody.
  ///
  /// In pt, this message translates to:
  /// **'O que você preencheu aqui será perdido.'**
  String get entryDiscardBody;

  /// No description provided for @entryKeepEditing.
  ///
  /// In pt, this message translates to:
  /// **'Continuar editando'**
  String get entryKeepEditing;

  /// No description provided for @entryDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get entryDiscard;

  /// No description provided for @entryFix.
  ///
  /// In pt, this message translates to:
  /// **'Corrigir registro'**
  String get entryFix;

  /// No description provided for @entryLogCocktail.
  ///
  /// In pt, this message translates to:
  /// **'Registrar drink'**
  String get entryLogCocktail;

  /// No description provided for @entryLogDrink.
  ///
  /// In pt, this message translates to:
  /// **'Registrar bebida'**
  String get entryLogDrink;

  /// No description provided for @entryDrinkAndSize.
  ///
  /// In pt, this message translates to:
  /// **'Bebida e tamanho'**
  String get entryDrinkAndSize;

  /// No description provided for @entryGenericSpirit.
  ///
  /// In pt, this message translates to:
  /// **'Doses sugeridas, editáveis: não são medidas oficiais de nenhum estabelecimento. A garrafa é a embalagem, não a sua dose.'**
  String get entryGenericSpirit;

  /// No description provided for @entryGenericSizes.
  ///
  /// In pt, this message translates to:
  /// **'Tamanhos sugeridos: este produto não tem embalagens verificadas no catálogo. Confira na embalagem.'**
  String get entryGenericSizes;

  /// No description provided for @entryVolume.
  ///
  /// In pt, this message translates to:
  /// **'Volume (ml)'**
  String get entryVolume;

  /// No description provided for @entryOtherSize.
  ///
  /// In pt, this message translates to:
  /// **'Outro tamanho (ml)'**
  String get entryOtherSize;

  /// No description provided for @entryAbvOptional.
  ///
  /// In pt, this message translates to:
  /// **'Teor alcoólico (opcional)'**
  String get entryAbvOptional;

  /// No description provided for @entryAbvBlank.
  ///
  /// In pt, this message translates to:
  /// **'Em branco = desconhecido (não conta como zero).'**
  String get entryAbvBlank;

  /// No description provided for @entryAbvCheck.
  ///
  /// In pt, this message translates to:
  /// **'Confira no rótulo se puder.'**
  String get entryAbvCheck;

  /// No description provided for @entryAbvVariantsIntro.
  ///
  /// In pt, this message translates to:
  /// **'As fontes divergem. Escolha o que estiver no seu rótulo ou digite:'**
  String get entryAbvVariantsIntro;

  /// No description provided for @entryBottleShared.
  ///
  /// In pt, this message translates to:
  /// **'Garrafa que está sendo dividida (preenche o volume da garrafa):'**
  String get entryBottleShared;

  /// No description provided for @entryBottlesInfo.
  ///
  /// In pt, this message translates to:
  /// **'Embalagens do produto: {list}. Para dividir uma garrafa, marque \"Compartilhada\" abaixo.'**
  String entryBottlesInfo(String list);

  /// No description provided for @entryIndividualOrShared.
  ///
  /// In pt, this message translates to:
  /// **'Individual ou compartilhada'**
  String get entryIndividualOrShared;

  /// No description provided for @entryOnlyMine.
  ///
  /// In pt, this message translates to:
  /// **'Só minha'**
  String get entryOnlyMine;

  /// No description provided for @entryShared.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhada'**
  String get entryShared;

  /// No description provided for @entryPriceSection.
  ///
  /// In pt, this message translates to:
  /// **'Preço (opcional)'**
  String get entryPriceSection;

  /// No description provided for @entryTimeSection.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get entryTimeSection;

  /// No description provided for @entryYourShare.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte: {amount}'**
  String entryYourShare(String amount);

  /// No description provided for @entryYourShareUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte: —'**
  String get entryYourShareUnknown;

  /// No description provided for @entrySaveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get entrySaveChanges;

  /// No description provided for @entryIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes: {list}'**
  String entryIngredients(String list);

  /// No description provided for @entrySharedLine.
  ///
  /// In pt, this message translates to:
  /// **'de {total} · {count} pessoas, com você'**
  String entrySharedLine(String total, String count);

  /// No description provided for @entryPeople.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas (incluindo você)'**
  String get entryPeople;

  /// No description provided for @entryFewerPeople.
  ///
  /// In pt, this message translates to:
  /// **'Menos uma pessoa'**
  String get entryFewerPeople;

  /// No description provided for @entryMorePeople.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma pessoa'**
  String get entryMorePeople;

  /// No description provided for @entryAdjustShare.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar parcela e sobra'**
  String get entryAdjustShare;

  /// No description provided for @entryYourShareMl.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte (ml)'**
  String get entryYourShareMl;

  /// No description provided for @entryEqualSplit.
  ///
  /// In pt, this message translates to:
  /// **'Divisão igual por padrão.'**
  String get entryEqualSplit;

  /// No description provided for @entryLeftover.
  ///
  /// In pt, this message translates to:
  /// **'Sobra na garrafa (ml)'**
  String get entryLeftover;

  /// No description provided for @entryOptionalDot.
  ///
  /// In pt, this message translates to:
  /// **'Opcional.'**
  String get entryOptionalDot;

  /// No description provided for @entryOthersEach.
  ///
  /// In pt, this message translates to:
  /// **'Sobram {amount} {count, plural, =1{para a outra pessoa} other{para cada uma das outras {count} pessoas}}.'**
  String entryOthersEach(String amount, int count);

  /// No description provided for @entryPriceValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get entryPriceValue;

  /// No description provided for @entryPriceDontKnow.
  ///
  /// In pt, this message translates to:
  /// **'Não sei'**
  String get entryPriceDontKnow;

  /// No description provided for @entryBillTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total da conta/garrafa (opcional)'**
  String get entryBillTotal;

  /// No description provided for @entryPaidHelper.
  ///
  /// In pt, this message translates to:
  /// **'O que você pagou, não o que bebeu.'**
  String get entryPaidHelper;

  /// No description provided for @entrySplitEqually.
  ///
  /// In pt, this message translates to:
  /// **'Dividir igualmente ({count} pessoas)'**
  String entrySplitEqually(String count);

  /// No description provided for @entryComplimentaryNote.
  ///
  /// In pt, this message translates to:
  /// **'Cortesia conta como {amount} informado.'**
  String entryComplimentaryNote(String amount);

  /// No description provided for @entryNoPriceNote.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço: aparece como \"sem preço\" no resumo.'**
  String get entryNoPriceNote;

  /// No description provided for @commonAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get commonAdd;

  /// No description provided for @entryAddIngredient.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ingrediente'**
  String get entryAddIngredient;

  /// No description provided for @entryIngredientField.
  ///
  /// In pt, this message translates to:
  /// **'Ingrediente'**
  String get entryIngredientField;

  /// No description provided for @entryHasAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Tem álcool'**
  String get entryHasAlcohol;

  /// No description provided for @entrySaveRecipeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Salvar como minha receita'**
  String get entrySaveRecipeTitle;

  /// No description provided for @entryMineSuffix.
  ///
  /// In pt, this message translates to:
  /// **'{name} (minha)'**
  String entryMineSuffix(String name);

  /// No description provided for @entryRecipeName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da receita'**
  String get entryRecipeName;

  /// No description provided for @entrySaveRecipeBody.
  ///
  /// In pt, this message translates to:
  /// **'Guarda ingredientes, quantidades e teores para reutilizar. Registros antigos não mudam.'**
  String get entrySaveRecipeBody;

  /// No description provided for @entryRecipeSaved.
  ///
  /// In pt, this message translates to:
  /// **'Receita salva no seu catálogo'**
  String get entryRecipeSaved;

  /// No description provided for @entryCompositionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Composição'**
  String get entryCompositionTitle;

  /// No description provided for @entryCompositionSimple.
  ///
  /// In pt, this message translates to:
  /// **'Informe só o que você sabe.'**
  String get entryCompositionSimple;

  /// No description provided for @entryCompositionReference.
  ///
  /// In pt, this message translates to:
  /// **'Receita de referência ({source}). Ajuste para o que foi realmente servido.'**
  String entryCompositionReference(String source);

  /// No description provided for @entryCompositionAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'Composição ajustada'**
  String get entryCompositionAdjusted;

  /// No description provided for @entryCompositionView.
  ///
  /// In pt, this message translates to:
  /// **'Ver e ajustar composição'**
  String get entryCompositionView;

  /// No description provided for @entryNoIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ingrediente ainda'**
  String get entryNoIngredients;

  /// No description provided for @entryDrinkVolumeSection.
  ///
  /// In pt, this message translates to:
  /// **'Volume do drink (opcional)'**
  String get entryDrinkVolumeSection;

  /// No description provided for @entryServedVolume.
  ///
  /// In pt, this message translates to:
  /// **'Volume servido (ml)'**
  String get entryServedVolume;

  /// No description provided for @entryServedVolumeHelper.
  ///
  /// In pt, this message translates to:
  /// **'Se não souber, deixe em branco: o resumo mostra como desconhecido. O tamanho do copo e o gelo não contam como volume bebido.'**
  String get entryServedVolumeHelper;

  /// No description provided for @entryPureAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Álcool puro da composição acima'**
  String get entryPureAlcohol;

  /// No description provided for @entryAtLeast.
  ///
  /// In pt, this message translates to:
  /// **'pelo menos {amount}'**
  String entryAtLeast(String amount);

  /// No description provided for @entryMissingParts.
  ///
  /// In pt, this message translates to:
  /// **'Faltam teor ou quantidade de: {list}'**
  String entryMissingParts(String list);

  /// No description provided for @entryDeclaredNote.
  ///
  /// In pt, this message translates to:
  /// **'Vale a composição declarada, assumindo a porção inteira. Não é concentração no sangue.'**
  String get entryDeclaredNote;

  /// No description provided for @entryOptionalMark.
  ///
  /// In pt, this message translates to:
  /// **'{name} (opcional)'**
  String entryOptionalMark(String name);

  /// No description provided for @entryRemoveIngredient.
  ///
  /// In pt, this message translates to:
  /// **'Remover ingrediente'**
  String get entryRemoveIngredient;

  /// No description provided for @entryInRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Na receita: {text}'**
  String entryInRecipe(String text);

  /// No description provided for @entryAmount.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get entryAmount;

  /// No description provided for @entryAmountUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Em branco = desconhecida.'**
  String get entryAmountUnknown;

  /// No description provided for @entryChooseProduct.
  ///
  /// In pt, this message translates to:
  /// **'Escolher marca/produto'**
  String get entryChooseProduct;

  /// No description provided for @entryComponentAbv.
  ///
  /// In pt, this message translates to:
  /// **'Teor alcoólico (% vol.)'**
  String get entryComponentAbv;

  /// No description provided for @entryComponentAbvUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido: sem ele o álcool total fica incompleto.'**
  String get entryComponentAbvUnknown;

  /// No description provided for @entryComponentAlcoholNone.
  ///
  /// In pt, this message translates to:
  /// **'Álcool deste ingrediente: não calculado ({reason}).'**
  String entryComponentAlcoholNone(String reason);

  /// No description provided for @entryComponentAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Álcool deste ingrediente: {amount}'**
  String entryComponentAlcohol(String amount);

  /// No description provided for @entryIncompleteData.
  ///
  /// In pt, this message translates to:
  /// **'dados incompletos'**
  String get entryIncompleteData;

  /// No description provided for @entryWhichProduct.
  ///
  /// In pt, this message translates to:
  /// **'Qual {name}?'**
  String entryWhichProduct(String name);

  /// No description provided for @entryNoBrand.
  ///
  /// In pt, this message translates to:
  /// **'Sem marca: informar o teor'**
  String get entryNoBrand;

  /// No description provided for @entryProductAbv.
  ///
  /// In pt, this message translates to:
  /// **'Teor {abv}'**
  String entryProductAbv(String abv);

  /// No description provided for @entryProductAbvVaries.
  ///
  /// In pt, this message translates to:
  /// **'Teor varia conforme a fonte'**
  String get entryProductAbvVaries;

  /// No description provided for @entryProductAbvUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Teor não informado'**
  String get entryProductAbvUnknown;

  /// No description provided for @entryMenuPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço do cardápio'**
  String get entryMenuPrice;

  /// No description provided for @entryMenuPriceBody.
  ///
  /// In pt, this message translates to:
  /// **'O cardápio anunciava {price}. É só uma sugestão: confirme o que foi pago de fato, pois pode ter promoção ou outro pedido. Se for garrafa ou jarra dividida, marque \"Compartilhada\": o valor vira o total da conta, não a sua parte.'**
  String entryMenuPriceBody(String price);

  /// No description provided for @entryUseAsBillTotal.
  ///
  /// In pt, this message translates to:
  /// **'Usar como total da conta'**
  String get entryUseAsBillTotal;

  /// No description provided for @entryUseAsPaid.
  ///
  /// In pt, this message translates to:
  /// **'Usar como o que paguei'**
  String get entryUseAsPaid;

  /// No description provided for @entryHistory.
  ///
  /// In pt, this message translates to:
  /// **'Seu histórico'**
  String get entryHistory;

  /// No description provided for @entryHistoryShare.
  ///
  /// In pt, this message translates to:
  /// **'Sua parcela foi {price} {scope} em {date}.'**
  String entryHistoryShare(String price, String scope, String date);

  /// No description provided for @entryHistoryPaid.
  ///
  /// In pt, this message translates to:
  /// **'Você pagou {price} {scope} em {date}.'**
  String entryHistoryPaid(String price, String scope, String date);

  /// No description provided for @entryUseAsShare.
  ///
  /// In pt, this message translates to:
  /// **'Usar como minha parcela'**
  String get entryUseAsShare;

  /// No description provided for @entryUseValue.
  ///
  /// In pt, this message translates to:
  /// **'Usar este valor'**
  String get entryUseValue;

  /// No description provided for @entryHistoryTotal.
  ///
  /// In pt, this message translates to:
  /// **'O total da garrafa/porção foi {price} em {date}.'**
  String entryHistoryTotal(String price, String date);

  /// No description provided for @entryUseAsTotal.
  ///
  /// In pt, this message translates to:
  /// **'Usar como total'**
  String get entryUseAsTotal;

  /// No description provided for @entryScopeAtPlace.
  ///
  /// In pt, this message translates to:
  /// **'neste local'**
  String get entryScopeAtPlace;

  /// No description provided for @entryScopeAtOuting.
  ///
  /// In pt, this message translates to:
  /// **'neste rolê'**
  String get entryScopeAtOuting;

  /// No description provided for @draftVolumeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Volume inválido'**
  String get draftVolumeInvalid;

  /// No description provided for @draftAbvRange.
  ///
  /// In pt, this message translates to:
  /// **'O teor vai de 0 a 100%'**
  String get draftAbvRange;

  /// No description provided for @draftAmountInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade inválida'**
  String get draftAmountInvalid;

  /// No description provided for @draftVolumeRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o volume em ml'**
  String get draftVolumeRequired;

  /// No description provided for @draftVolumeTooHigh.
  ///
  /// In pt, this message translates to:
  /// **'Volume alto demais'**
  String get draftVolumeTooHigh;

  /// No description provided for @draftShareRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a sua parte em ml'**
  String get draftShareRequired;

  /// No description provided for @draftShareOver.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte + sobra passam do volume ({volume})'**
  String draftShareOver(String volume);

  /// No description provided for @draftBeforeStart.
  ///
  /// In pt, this message translates to:
  /// **'Antes do início do rolê ({time})'**
  String draftBeforeStart(String time);

  /// No description provided for @draftNotFuture.
  ///
  /// In pt, this message translates to:
  /// **'O horário não pode estar no futuro'**
  String get draftNotFuture;

  /// No description provided for @draftAfterEnd.
  ///
  /// In pt, this message translates to:
  /// **'Depois do fim do rolê ({time})'**
  String draftAfterEnd(String time);

  /// No description provided for @draftPaidRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o valor ou escolha outra opção'**
  String get draftPaidRequired;

  /// No description provided for @formSaveRecipeFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a receita.'**
  String get formSaveRecipeFailed;

  /// No description provided for @formSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Nada foi perdido, tente de novo.'**
  String get formSaveFailed;

  /// No description provided for @priceBulkTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar este preço às bebidas iguais?'**
  String get priceBulkTitle;

  /// No description provided for @priceBulkBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} por {price}. Neste rolê há {total} registros iguais: {unpriced} sem preço e {differing} com outro preço. Nada muda sem a sua escolha.'**
  String priceBulkBody(
    String name,
    String price,
    int total,
    int unpriced,
    int differing,
  );

  /// No description provided for @priceBulkUnpriced.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar aos {count} sem preço'**
  String priceBulkUnpriced(int count);

  /// No description provided for @priceBulkAll.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar a todos os {count} iguais'**
  String priceBulkAll(int count);

  /// No description provided for @priceBulkOnlyThis.
  ///
  /// In pt, this message translates to:
  /// **'Só este registro'**
  String get priceBulkOnlyThis;

  /// No description provided for @priceBulkConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Substituir preços?'**
  String get priceBulkConfirmTitle;

  /// No description provided for @priceBulkConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso troca o preço de {count} registros que já tinham outro valor. Os demais rolês não mudam.'**
  String priceBulkConfirmBody(int count);

  /// No description provided for @priceBulkReplace.
  ///
  /// In pt, this message translates to:
  /// **'Substituir'**
  String get priceBulkReplace;

  /// No description provided for @priceBulkApplied.
  ///
  /// In pt, this message translates to:
  /// **'Preço aplicado a {count} registros.'**
  String priceBulkApplied(int count);

  /// No description provided for @formDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir. Tente de novo.'**
  String get formDeleteFailed;

  /// No description provided for @detailNotGiven.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get detailNotGiven;

  /// No description provided for @detailAbv.
  ///
  /// In pt, this message translates to:
  /// **'Teor alcoólico'**
  String get detailAbv;

  /// No description provided for @detailAbvFrom.
  ///
  /// In pt, this message translates to:
  /// **'Teor: {source}. Não é dado do fabricante.'**
  String detailAbvFrom(String source);

  /// No description provided for @detailIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes declarados'**
  String get detailIngredients;

  /// No description provided for @detailIngredientsNone.
  ///
  /// In pt, this message translates to:
  /// **'Não informados'**
  String get detailIngredientsNone;

  /// No description provided for @detailPresentations.
  ///
  /// In pt, this message translates to:
  /// **'Apresentações'**
  String get detailPresentations;

  /// No description provided for @detailBottleNotDose.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da garrafa não é tamanho da dose. Ao registrar, você escolhe uma dose sugerida (editável) ou compartilha a garrafa.'**
  String get detailBottleNotDose;

  /// No description provided for @detailUnverifiedPackages.
  ///
  /// In pt, this message translates to:
  /// **'Embalagens não verificadas para este produto. Ao registrar, você pode escolher um tamanho sugerido ou digitar o volume.'**
  String get detailUnverifiedPackages;

  /// No description provided for @detailPackagesNote.
  ///
  /// In pt, this message translates to:
  /// **'Embalagens citadas pelo fabricante. O tamanho da embalagem não é o que você bebeu: isso você define ao registrar.'**
  String get detailPackagesNote;

  /// No description provided for @detailMakeMine.
  ///
  /// In pt, this message translates to:
  /// **'Criar minha versão'**
  String get detailMakeMine;

  /// No description provided for @detailSourceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fonte dos dados'**
  String get detailSourceTitle;

  /// No description provided for @detailSourceLine.
  ///
  /// In pt, this message translates to:
  /// **'{source} · consultado em {date}'**
  String detailSourceLine(String source, String date);

  /// No description provided for @detailCopyAddress.
  ///
  /// In pt, this message translates to:
  /// **'Copiar endereço'**
  String get detailCopyAddress;

  /// No description provided for @detailAddressCopied.
  ///
  /// In pt, this message translates to:
  /// **'Endereço copiado'**
  String get detailAddressCopied;

  /// No description provided for @detailMayVary.
  ///
  /// In pt, this message translates to:
  /// **'Os dados podem variar por versão e mercado. Confira sempre o rótulo da embalagem.'**
  String get detailMayVary;

  /// No description provided for @detailAbvVaries.
  ///
  /// In pt, this message translates to:
  /// **'Varia conforme a fonte, sem um valor único:\n{lines}'**
  String detailAbvVaries(String lines);

  /// No description provided for @detailRecipeReference.
  ///
  /// In pt, this message translates to:
  /// **'Receita de referência: mostra como a receita é publicada, não o que um bar serviu.'**
  String get detailRecipeReference;

  /// No description provided for @detailRecipeMine.
  ///
  /// In pt, this message translates to:
  /// **'Sua receita salva. Ao registrar, você ajusta o que realmente foi servido.'**
  String get detailRecipeMine;

  /// No description provided for @detailNoIngredientsYet.
  ///
  /// In pt, this message translates to:
  /// **'Sem ingredientes ainda: você monta ao registrar.'**
  String get detailNoIngredientsYet;

  /// No description provided for @detailAlcoholLegend.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes com copo ao lado têm álcool. O teor de cada um é informado ao registrar; sem ele o álcool total fica incompleto. Gelo não entra na conta.'**
  String get detailAlcoholLegend;

  /// No description provided for @detailMethod.
  ///
  /// In pt, this message translates to:
  /// **'Preparo'**
  String get detailMethod;

  /// No description provided for @detailGarnish.
  ///
  /// In pt, this message translates to:
  /// **'Decoração: {text}'**
  String detailGarnish(String text);

  /// No description provided for @customEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar bebida'**
  String get customEditTitle;

  /// No description provided for @customSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Seus dados continuam aqui.'**
  String get customSaveFailed;

  /// No description provided for @customEditNote.
  ///
  /// In pt, this message translates to:
  /// **'As mudanças valem para os próximos registros. O que você já registrou continua como estava.'**
  String get customEditNote;

  /// No description provided for @customNewNote.
  ///
  /// In pt, this message translates to:
  /// **'Fica salva para você usar de novo nos próximos rolês.'**
  String get customNewNote;

  /// No description provided for @customType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get customType;

  /// No description provided for @customIdentification.
  ///
  /// In pt, this message translates to:
  /// **'Identificação'**
  String get customIdentification;

  /// No description provided for @customName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da bebida'**
  String get customName;

  /// No description provided for @customNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a bebida'**
  String get customNameRequired;

  /// No description provided for @customBrand.
  ///
  /// In pt, this message translates to:
  /// **'Marca (opcional)'**
  String get customBrand;

  /// No description provided for @customStyle.
  ///
  /// In pt, this message translates to:
  /// **'Estilo (opcional)'**
  String get customStyle;

  /// No description provided for @customSizeAndAbv.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho e teor'**
  String get customSizeAndAbv;

  /// No description provided for @customSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho (ml)'**
  String get customSize;

  /// No description provided for @customSizeRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o tamanho em ml'**
  String get customSizeRequired;

  /// No description provided for @customAbvHelper.
  ///
  /// In pt, this message translates to:
  /// **'Em branco = desconhecido, não conta como zero.'**
  String get customAbvHelper;

  /// No description provided for @customIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes (opcional)'**
  String get customIngredients;

  /// No description provided for @customIngredientsHelper.
  ///
  /// In pt, this message translates to:
  /// **'Separe por vírgula. Só o que você sabe.'**
  String get customIngredientsHelper;

  /// No description provided for @customSaveUse.
  ///
  /// In pt, this message translates to:
  /// **'Salvar e usar'**
  String get customSaveUse;

  /// No description provided for @recipeUnitLabel.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get recipeUnitLabel;

  /// No description provided for @myDrinksNeedOuting.
  ///
  /// In pt, this message translates to:
  /// **'Inicie um rolê para registrar uma bebida.'**
  String get myDrinksNeedOuting;

  /// No description provided for @myDrinksLogged.
  ///
  /// In pt, this message translates to:
  /// **'Bebida registrada'**
  String get myDrinksLogged;

  /// No description provided for @myDrinksCopied.
  ///
  /// In pt, this message translates to:
  /// **'Cópia criada'**
  String get myDrinksCopied;

  /// No description provided for @myDrinksDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{name}\"?'**
  String myDrinksDeleteTitle(String name);

  /// No description provided for @myDrinksDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Sai do seu catálogo. Os registros que você já fez continuam como estão.'**
  String get myDrinksDeleteBody;

  /// No description provided for @myDrinksDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Excluída'**
  String get myDrinksDeleted;

  /// No description provided for @myDrinksRecipeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Receita · 1 ingrediente} other{Receita · {count} ingredientes}}'**
  String myDrinksRecipeSubtitle(int count);

  /// No description provided for @myDrinksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minhas bebidas e receitas'**
  String get myDrinksTitle;

  /// No description provided for @myDrinksEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda'**
  String get myDrinksEmptyTitle;

  /// No description provided for @myDrinksEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas e receitas que você cadastrar ficam aqui para reutilizar nos próximos rolês.'**
  String get myDrinksEmptyBody;

  /// No description provided for @myDrinksStartFirst.
  ///
  /// In pt, this message translates to:
  /// **'Para registrar, inicie um rolê primeiro.'**
  String get myDrinksStartFirst;

  /// No description provided for @myDrinksActionLog.
  ///
  /// In pt, this message translates to:
  /// **'Registrar'**
  String get myDrinksActionLog;

  /// No description provided for @myDrinksActionDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Duplicar'**
  String get myDrinksActionDuplicate;

  /// No description provided for @myDrinksNewDrink.
  ///
  /// In pt, this message translates to:
  /// **'Nova bebida'**
  String get myDrinksNewDrink;

  /// No description provided for @myDrinksNewRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Nova receita'**
  String get myDrinksNewRecipe;

  /// No description provided for @recipeEditorNameCopy.
  ///
  /// In pt, this message translates to:
  /// **'{name} (minha versão)'**
  String recipeEditorNameCopy(String name);

  /// No description provided for @recipeEditorNeedName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a receita.'**
  String get recipeEditorNeedName;

  /// No description provided for @recipeEditorNeedIngredient.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos um ingrediente.'**
  String get recipeEditorNeedIngredient;

  /// No description provided for @recipeEditorIngredientName.
  ///
  /// In pt, this message translates to:
  /// **'Todo ingrediente precisa de um nome.'**
  String get recipeEditorIngredientName;

  /// No description provided for @recipeEditorAbvRange.
  ///
  /// In pt, this message translates to:
  /// **'O teor de \"{name}\" vai de 0 a 100%.'**
  String recipeEditorAbvRange(String name);

  /// No description provided for @recipeEditorAmountInvalid.
  ///
  /// In pt, this message translates to:
  /// **'A quantidade de \"{name}\" é inválida.'**
  String recipeEditorAmountInvalid(String name);

  /// No description provided for @recipeEditorNumberProblem.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\": {problem}'**
  String recipeEditorNumberProblem(String name, String problem);

  /// No description provided for @recipeEditorEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar receita'**
  String get recipeEditorEditTitle;

  /// No description provided for @recipeEditorNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova receita'**
  String get recipeEditorNewTitle;

  /// No description provided for @recipeEditorIntro.
  ///
  /// In pt, this message translates to:
  /// **'Registre só o que você sabe. Quantidade ou teor em branco ficam como desconhecidos e o álcool total aparece como incompleto.'**
  String get recipeEditorIntro;

  /// No description provided for @recipeEditorNameSection.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get recipeEditorNameSection;

  /// No description provided for @recipeEditorNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a receita'**
  String get recipeEditorNameRequired;

  /// No description provided for @recipeEditorIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes'**
  String get recipeEditorIngredients;

  /// No description provided for @recipeEditorNoneYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ingrediente ainda.'**
  String get recipeEditorNoneYet;

  /// No description provided for @recipeEditorAlcoholSection.
  ///
  /// In pt, this message translates to:
  /// **'Álcool da composição'**
  String get recipeEditorAlcoholSection;

  /// No description provided for @recipeEditorDeclaredAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Álcool puro declarado'**
  String get recipeEditorDeclaredAlcohol;

  /// No description provided for @recipeEditorSaveRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Salvar receita'**
  String get recipeEditorSaveRecipe;

  /// No description provided for @recipeEditorMoveUp.
  ///
  /// In pt, this message translates to:
  /// **'Mover para cima'**
  String get recipeEditorMoveUp;

  /// No description provided for @recipeEditorMoveDown.
  ///
  /// In pt, this message translates to:
  /// **'Mover para baixo'**
  String get recipeEditorMoveDown;

  /// No description provided for @recipeEditorOriginal.
  ///
  /// In pt, this message translates to:
  /// **'Na receita original: {text}'**
  String recipeEditorOriginal(String text);

  /// No description provided for @recipeEditorRole.
  ///
  /// In pt, this message translates to:
  /// **'Tipo (para escolher a marca ao registrar)'**
  String get recipeEditorRole;

  /// No description provided for @recipeEditorNoRole.
  ///
  /// In pt, this message translates to:
  /// **'Sem tipo'**
  String get recipeEditorNoRole;

  /// No description provided for @recipeEditorRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get recipeEditorRemove;

  /// No description provided for @scanLabelPhotoGone.
  ///
  /// In pt, this message translates to:
  /// **'A foto desta leitura não está mais disponível neste aparelho. O texto foi mantido: tire outra foto ou continue sem ela.'**
  String get scanLabelPhotoGone;

  /// No description provided for @scanPhotoSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível guardar a foto no aparelho.'**
  String get scanPhotoSaveFailed;

  /// No description provided for @scanRotateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível girar a imagem.'**
  String get scanRotateFailed;

  /// No description provided for @scanPhotoUnavailableToRead.
  ///
  /// In pt, this message translates to:
  /// **'A foto não está disponível para leitura. Tire outra.'**
  String get scanPhotoUnavailableToRead;

  /// No description provided for @scanNoTextFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum texto foi encontrado. Tente outra foto mais de perto, com boa luz, ou digite o texto.'**
  String get scanNoTextFound;

  /// No description provided for @scanLabelTip.
  ///
  /// In pt, this message translates to:
  /// **'Enquadre o rótulo inteiro, de frente, com boa luz e sem reflexo. Volume e teor costumam ficar em outro lado da embalagem: fotografe esse lado ou complete na revisão. Você confere tudo antes de salvar.'**
  String get scanLabelTip;

  /// No description provided for @scanLabelEnded.
  ///
  /// In pt, this message translates to:
  /// **'Este rolê já foi encerrado. O que você ler fica salvo nele.'**
  String get scanLabelEnded;

  /// No description provided for @scanWebPhotoSession.
  ///
  /// In pt, this message translates to:
  /// **'No navegador a foto só fica guardada durante esta sessão.'**
  String get scanWebPhotoSession;

  /// No description provided for @scanPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get scanPhoto;

  /// No description provided for @scanTakePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get scanTakePhoto;

  /// No description provided for @scanChooseGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get scanChooseGallery;

  /// No description provided for @scanRotateLeft.
  ///
  /// In pt, this message translates to:
  /// **'Girar para a esquerda'**
  String get scanRotateLeft;

  /// No description provided for @scanRotateRight.
  ///
  /// In pt, this message translates to:
  /// **'Girar para a direita'**
  String get scanRotateRight;

  /// No description provided for @scanNewPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Nova foto'**
  String get scanNewPhoto;

  /// No description provided for @scanReplacePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get scanReplacePhoto;

  /// No description provided for @scanDiscardReading.
  ///
  /// In pt, this message translates to:
  /// **'Descartar leitura'**
  String get scanDiscardReading;

  /// No description provided for @scanReadingOnDevice.
  ///
  /// In pt, this message translates to:
  /// **'Lendo o texto da foto neste aparelho…'**
  String get scanReadingOnDevice;

  /// No description provided for @scanCancelReading.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar leitura'**
  String get scanCancelReading;

  /// No description provided for @scanReadAgain.
  ///
  /// In pt, this message translates to:
  /// **'Ler de novo'**
  String get scanReadAgain;

  /// No description provided for @scanOcrUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A leitura automática não está disponível aqui (só no app para Android e iOS). Veja a foto e digite ou cole o texto do rótulo, ou preencha direto.'**
  String get scanOcrUnavailable;

  /// No description provided for @scanLabelText.
  ///
  /// In pt, this message translates to:
  /// **'Texto do rótulo'**
  String get scanLabelText;

  /// No description provided for @scanTextHintCanRead.
  ///
  /// In pt, this message translates to:
  /// **'O texto lido aparece aqui. Você pode corrigir.'**
  String get scanTextHintCanRead;

  /// No description provided for @scanTextHintManual.
  ///
  /// In pt, this message translates to:
  /// **'Digite ou cole o texto do rótulo (opcional)'**
  String get scanTextHintManual;

  /// No description provided for @scanInterpret.
  ///
  /// In pt, this message translates to:
  /// **'Interpretar texto'**
  String get scanInterpret;

  /// No description provided for @scanFillManually.
  ///
  /// In pt, this message translates to:
  /// **'Preencher manualmente'**
  String get scanFillManually;

  /// No description provided for @photoUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Foto indisponível agora: ainda não enviada pelo outro aparelho, ou sem conexão. O registro continua salvo.'**
  String get photoUnavailable;

  /// No description provided for @photoDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir foto'**
  String get photoDelete;

  /// No description provided for @photoDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir esta foto?'**
  String get photoDeleteTitle;

  /// No description provided for @photoDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Só a foto sai. As bebidas e os dados que você confirmou continuam no rolê.'**
  String get photoDeleteBody;

  /// No description provided for @captureCameraUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A câmera não está disponível aqui. Escolha uma foto da galeria.'**
  String get captureCameraUnavailable;

  /// No description provided for @captureGalleryUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A galeria não está disponível aqui.'**
  String get captureGalleryUnavailable;

  /// No description provided for @capturePermissionCamera.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão para usar a câmera. Libere nas configurações do aparelho ou escolha outra opção.'**
  String get capturePermissionCamera;

  /// No description provided for @capturePermissionGallery.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão para usar a galeria. Libere nas configurações do aparelho ou escolha outra opção.'**
  String get capturePermissionGallery;

  /// No description provided for @captureOpenCameraFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a câmera.'**
  String get captureOpenCameraFailed;

  /// No description provided for @captureOpenGalleryFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a galeria.'**
  String get captureOpenGalleryFailed;

  /// No description provided for @captureFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a captura de imagem.'**
  String get captureFailed;

  /// No description provided for @captureUnreadable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler essa imagem.'**
  String get captureUnreadable;

  /// No description provided for @captureTooBig.
  ///
  /// In pt, this message translates to:
  /// **'A imagem é muito grande. Tente uma foto menor.'**
  String get captureTooBig;

  /// No description provided for @captureNotImage.
  ///
  /// In pt, this message translates to:
  /// **'Esse arquivo não parece ser uma imagem válida.'**
  String get captureNotImage;

  /// No description provided for @ocrUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A leitura automática não está disponível neste dispositivo.'**
  String get ocrUnavailable;

  /// No description provided for @ocrReadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o texto desta foto.'**
  String get ocrReadFailed;

  /// No description provided for @matchOtherCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria diferente (catálogo: {category})'**
  String matchOtherCategory(String category);

  /// No description provided for @matchSameSize.
  ///
  /// In pt, this message translates to:
  /// **'Mesmo tamanho ({size})'**
  String matchSameSize(String size);

  /// No description provided for @matchOtherSize.
  ///
  /// In pt, this message translates to:
  /// **'Outro tamanho (catálogo: {sizes})'**
  String matchOtherSize(String sizes);

  /// No description provided for @matchSameAbv.
  ///
  /// In pt, this message translates to:
  /// **'Mesmo teor ({abv})'**
  String matchSameAbv(String abv);

  /// No description provided for @matchOtherAbv.
  ///
  /// In pt, this message translates to:
  /// **'Teor diferente (catálogo: {catalog}, seu: {yours})'**
  String matchOtherAbv(String catalog, String yours);

  /// No description provided for @matchAbvVaries.
  ///
  /// In pt, this message translates to:
  /// **'O teor do catálogo varia por fonte'**
  String get matchAbvVaries;

  /// No description provided for @matchNoAbv.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo sem teor para comparar'**
  String get matchNoAbv;

  /// No description provided for @matchOtherBrand.
  ///
  /// In pt, this message translates to:
  /// **'Outra marca ({brand})'**
  String matchOtherBrand(String brand);

  /// No description provided for @matchRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Receita de referência: o drink servido pode ser diferente'**
  String get matchRecipe;

  /// No description provided for @matchSimilar.
  ///
  /// In pt, this message translates to:
  /// **'Parecida pelo nome: confirme se é o mesmo produto'**
  String get matchSimilar;

  /// No description provided for @parseManyVolumes.
  ///
  /// In pt, this message translates to:
  /// **'Mais de um volume no texto ({list}). Escolha o da embalagem.'**
  String parseManyVolumes(String list);

  /// No description provided for @parseManyAbvs.
  ///
  /// In pt, this message translates to:
  /// **'Mais de um teor no texto ({list}). Confira no rótulo.'**
  String parseManyAbvs(String list);

  /// No description provided for @parseCheckName.
  ///
  /// In pt, this message translates to:
  /// **'Confira o nome e a marca. Toque nas sugestões para trocar.'**
  String get parseCheckName;

  /// No description provided for @menuNoteColumns.
  ///
  /// In pt, this message translates to:
  /// **'O cardápio parece ter {count} colunas. Confira se cada preço ficou no item certo.'**
  String menuNoteColumns(String count);

  /// No description provided for @menuNoteOrphans.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 preço sem item claro foi ignorado. Adicione o item manualmente se precisar.} other{{count} preços sem item claro foram ignorados. Adicione o item manualmente se precisar.}}'**
  String menuNoteOrphans(int count);

  /// No description provided for @menuNoteNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item foi identificado. Cole ou digite o texto, ou adicione os itens manualmente.'**
  String get menuNoteNone;

  /// No description provided for @scanMenuReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Itens do cardápio'**
  String get scanMenuReviewTitle;

  /// No description provided for @scanMenuLostPhotos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Uma foto desta leitura não está mais disponível. Os itens dela foram mantidos para você conferir.} other{{count} fotos desta leitura não estão mais disponíveis. Os itens delas foram mantidos para você conferir.}}'**
  String scanMenuLostPhotos(int count);

  /// No description provided for @scanMenuNoItemsRead.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item foi identificado. Gire a foto, tente de perto ou cole o texto do cardápio.'**
  String get scanMenuNoItemsRead;

  /// No description provided for @scanMenuNoItems.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item foi identificado.'**
  String get scanMenuNoItems;

  /// No description provided for @scanMenuNoneSelected.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item selecionado.'**
  String get scanMenuNoneSelected;

  /// No description provided for @scanMenuUnnamed.
  ///
  /// In pt, this message translates to:
  /// **'Há item sem nome. Corrija ou descarte.'**
  String get scanMenuUnnamed;

  /// No description provided for @scanMenuNeedType.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o tipo dos itens marcados com \"Tipo?\".'**
  String get scanMenuNeedType;

  /// No description provided for @scanMenuSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Seus itens continuam aqui.'**
  String get scanMenuSaveFailed;

  /// No description provided for @scanMenuDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar esta leitura?'**
  String get scanMenuDiscardTitle;

  /// No description provided for @scanMenuDiscardBody.
  ///
  /// In pt, this message translates to:
  /// **'As fotos e os itens ainda não confirmados serão apagados.'**
  String get scanMenuDiscardBody;

  /// No description provided for @scanMenuTip.
  ///
  /// In pt, this message translates to:
  /// **'Fotografe uma página por vez, de frente e com boa luz, sem cortar os preços. Pode adicionar várias fotos. Você confere e corrige cada item antes de salvar.'**
  String get scanMenuTip;

  /// No description provided for @scanMenuEnded.
  ///
  /// In pt, this message translates to:
  /// **'Este rolê já foi encerrado. Os itens ficam salvos nele.'**
  String get scanMenuEnded;

  /// No description provided for @scanMenuWebPhotos.
  ///
  /// In pt, this message translates to:
  /// **'No navegador as fotos só ficam guardadas durante esta sessão.'**
  String get scanMenuWebPhotos;

  /// No description provided for @scanMenuPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Fotos ({count})'**
  String scanMenuPhotos(String count);

  /// No description provided for @scanMenuPhotoN.
  ///
  /// In pt, this message translates to:
  /// **'Foto {number}'**
  String scanMenuPhotoN(String number);

  /// No description provided for @scanMenuRead.
  ///
  /// In pt, this message translates to:
  /// **'Lida'**
  String get scanMenuRead;

  /// No description provided for @scanMenuUnread.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não lida'**
  String get scanMenuUnread;

  /// No description provided for @scanRemovePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Remover foto'**
  String get scanRemovePhoto;

  /// No description provided for @scanAnotherPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma foto'**
  String get scanAnotherPhoto;

  /// No description provided for @scanMenuReadingMany.
  ///
  /// In pt, this message translates to:
  /// **'Lendo o texto das fotos neste aparelho…'**
  String get scanMenuReadingMany;

  /// No description provided for @scanMenuSeeRead.
  ///
  /// In pt, this message translates to:
  /// **'Ver itens lidos'**
  String get scanMenuSeeRead;

  /// No description provided for @scanMenuOcrUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A leitura automática não está disponível aqui (só no app para Android e iOS). Veja as fotos e digite ou cole o texto do cardápio, ou adicione os itens à mão.'**
  String get scanMenuOcrUnavailable;

  /// No description provided for @scanMenuPastedSection.
  ///
  /// In pt, this message translates to:
  /// **'Texto do cardápio (opcional)'**
  String get scanMenuPastedSection;

  /// No description provided for @scanMenuPastedHint.
  ///
  /// In pt, this message translates to:
  /// **'Um item por linha, com o preço na mesma linha ou na seguinte. Ex.: Caipirinha R\$ 18,00'**
  String get scanMenuPastedHint;

  /// No description provided for @scanMenuAddManual.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item à mão'**
  String get scanMenuAddManual;

  /// No description provided for @scanMenuSeeCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Ver 1 item} other{Ver {count} itens}}'**
  String scanMenuSeeCount(int count);

  /// No description provided for @scanMenuReviewIntro.
  ///
  /// In pt, this message translates to:
  /// **'Marque os itens que quer deixar disponíveis neste rolê. Nada é registrado como consumo agora: você escolhe a bebida e confirma o preço quando for pedir.'**
  String get scanMenuReviewIntro;

  /// No description provided for @scanMenuPhotosAndReading.
  ///
  /// In pt, this message translates to:
  /// **'Fotos e leitura'**
  String get scanMenuPhotosAndReading;

  /// No description provided for @scanMenuAddItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get scanMenuAddItem;

  /// No description provided for @scanMenuSave.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Salvar 1 item neste rolê} other{Salvar {count} itens neste rolê}}'**
  String scanMenuSave(int count);

  /// No description provided for @scanMenuNoName.
  ///
  /// In pt, this message translates to:
  /// **'(sem nome)'**
  String get scanMenuNoName;

  /// No description provided for @scanMenuSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho no cardápio: {size}'**
  String scanMenuSize(String size);

  /// No description provided for @scanMenuIngredientsCited.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes citados: {list}'**
  String scanMenuIngredientsCited(String list);

  /// No description provided for @scanMenuEditItem.
  ///
  /// In pt, this message translates to:
  /// **'Editar item'**
  String get scanMenuEditItem;

  /// No description provided for @scanMenuTypeHint.
  ///
  /// In pt, this message translates to:
  /// **'Tipo?'**
  String get scanMenuTypeHint;

  /// No description provided for @scanMenuDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Repetido em outra foto'**
  String get scanMenuDuplicate;

  /// No description provided for @scanMenuPromo.
  ///
  /// In pt, this message translates to:
  /// **'Possível promoção: confirme o valor'**
  String get scanMenuPromo;

  /// No description provided for @scanMenuPriceOnMenu.
  ///
  /// In pt, this message translates to:
  /// **'{price} no cardápio'**
  String scanMenuPriceOnMenu(String price);

  /// No description provided for @scanMenuNoPriceRead.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço lido'**
  String get scanMenuNoPriceRead;

  /// No description provided for @scanMenuPriceUnsure.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para ter certeza do preço. Escolha o certo ou deixe sem preço:'**
  String get scanMenuPriceUnsure;

  /// No description provided for @scanMenuChangePrice.
  ///
  /// In pt, this message translates to:
  /// **'Trocar preço'**
  String get scanMenuChangePrice;

  /// No description provided for @scanMenuNewItem.
  ///
  /// In pt, this message translates to:
  /// **'Novo item'**
  String get scanMenuNewItem;

  /// No description provided for @scanMenuName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get scanMenuName;

  /// No description provided for @scanMenuDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição (opcional)'**
  String get scanMenuDescription;

  /// No description provided for @scanMenuSizeOptional.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho (opcional)'**
  String get scanMenuSizeOptional;

  /// No description provided for @scanMenuPriceOptional.
  ///
  /// In pt, this message translates to:
  /// **'Preço (opcional)'**
  String get scanMenuPriceOptional;

  /// No description provided for @scanMenuCitedOptional.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes citados (opcional)'**
  String get scanMenuCitedOptional;

  /// No description provided for @scanMenuCitedHelper.
  ///
  /// In pt, this message translates to:
  /// **'Separe por vírgula. Sem quantidades.'**
  String get scanMenuCitedHelper;

  /// No description provided for @scanMenuNeedName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome ao item.'**
  String get scanMenuNeedName;

  /// No description provided for @scanMenuInvalidSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho inválido.'**
  String get scanMenuInvalidSize;

  /// No description provided for @scanMenuInvalidPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço inválido.'**
  String get scanMenuInvalidPrice;

  /// No description provided for @commonApply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get commonApply;

  /// No description provided for @originManual.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro neste rolê'**
  String get originManual;

  /// No description provided for @originPhotoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Foto do rótulo'**
  String get originPhotoLabel;

  /// No description provided for @originMenu.
  ///
  /// In pt, this message translates to:
  /// **'Foto do cardápio'**
  String get originMenu;

  /// No description provided for @outingReviewEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar bebida do rolê'**
  String get outingReviewEditTitle;

  /// No description provided for @outingReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bebida deste rolê'**
  String get outingReviewTitle;

  /// No description provided for @outingReviewIsolation.
  ///
  /// In pt, this message translates to:
  /// **'Esta bebida existe só neste rolê. Ela não entra no catálogo, nem em Minhas bebidas, nem em outros rolês.'**
  String get outingReviewIsolation;

  /// No description provided for @outingReviewEnded.
  ///
  /// In pt, this message translates to:
  /// **'Este rolê já foi encerrado. O item fica salvo nele.'**
  String get outingReviewEnded;

  /// No description provided for @outingReviewDrinkSection.
  ///
  /// In pt, this message translates to:
  /// **'Bebida'**
  String get outingReviewDrinkSection;

  /// No description provided for @outingReviewNeedName.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome para a bebida.'**
  String get outingReviewNeedName;

  /// No description provided for @outingReviewNeedType.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o tipo da bebida.'**
  String get outingReviewNeedType;

  /// No description provided for @outingReviewVolumePositive.
  ///
  /// In pt, this message translates to:
  /// **'O volume precisa ser maior que zero.'**
  String get outingReviewVolumePositive;

  /// No description provided for @outingReviewAbvRange.
  ///
  /// In pt, this message translates to:
  /// **'O teor vai de 0 a 100%.'**
  String get outingReviewAbvRange;

  /// No description provided for @outingReviewOtherLines.
  ///
  /// In pt, this message translates to:
  /// **'Outras linhas lidas (toque para usar):'**
  String get outingReviewOtherLines;

  /// No description provided for @outingReviewPickType.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o tipo da bebida'**
  String get outingReviewPickType;

  /// No description provided for @outingReviewTypeUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Tipo não identificado: escolha um.'**
  String get outingReviewTypeUnknown;

  /// No description provided for @outingReviewDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição do cardápio (opcional)'**
  String get outingReviewDescription;

  /// No description provided for @outingReviewPackageVolume.
  ///
  /// In pt, this message translates to:
  /// **'Volume da embalagem (opcional)'**
  String get outingReviewPackageVolume;

  /// No description provided for @outingReviewVolumeHelper.
  ///
  /// In pt, this message translates to:
  /// **'É o tamanho do produto, não o quanto você bebeu. Em branco = desconhecido.'**
  String get outingReviewVolumeHelper;

  /// No description provided for @outingReviewAbvSource.
  ///
  /// In pt, this message translates to:
  /// **'Origem: {source}'**
  String outingReviewAbvSource(String source);

  /// No description provided for @outingReviewIngredientsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Só o que o cardápio ou você informaram. As quantidades ficam desconhecidas até você completar ao registrar; o álcool só é calculado com volume e teor conhecidos.'**
  String get outingReviewIngredientsIntro;

  /// No description provided for @outingReviewAlcoholChip.
  ///
  /// In pt, this message translates to:
  /// **'Álcool'**
  String get outingReviewAlcoholChip;

  /// No description provided for @outingReviewDeclaredOptional.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes declarados (opcional)'**
  String get outingReviewDeclaredOptional;

  /// No description provided for @outingReviewDeclaredHelper.
  ///
  /// In pt, this message translates to:
  /// **'Separe por vírgula. Só o que está escrito.'**
  String get outingReviewDeclaredHelper;

  /// No description provided for @outingReviewAdvertisedSection.
  ///
  /// In pt, this message translates to:
  /// **'Preço anunciado'**
  String get outingReviewAdvertisedSection;

  /// No description provided for @outingReviewMenuPriceOptional.
  ///
  /// In pt, this message translates to:
  /// **'Preço do cardápio (opcional)'**
  String get outingReviewMenuPriceOptional;

  /// No description provided for @outingReviewMenuPriceHelper.
  ///
  /// In pt, this message translates to:
  /// **'Só uma sugestão: ao registrar você confirma o que pagou. Valores em reais (R\$).'**
  String get outingReviewMenuPriceHelper;

  /// No description provided for @outingReviewSimilar.
  ///
  /// In pt, this message translates to:
  /// **'Parecidas no catálogo'**
  String get outingReviewSimilar;

  /// No description provided for @outingReviewSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get outingReviewSearch;

  /// No description provided for @outingReviewSimilarNote.
  ///
  /// In pt, this message translates to:
  /// **'Opcional. Escolher uma é só uma referência: o produto do catálogo nunca é alterado e nada é ligado sozinho.'**
  String get outingReviewSimilarNote;

  /// No description provided for @outingReviewNothingSimilar.
  ///
  /// In pt, this message translates to:
  /// **'Nada parecido encontrado. Este item fica só no rolê.'**
  String get outingReviewNothingSimilar;

  /// No description provided for @outingReviewReferenceChosen.
  ///
  /// In pt, this message translates to:
  /// **'Referência escolhida'**
  String get outingReviewReferenceChosen;

  /// No description provided for @outingReviewUseReference.
  ///
  /// In pt, this message translates to:
  /// **'Usar como referência'**
  String get outingReviewUseReference;

  /// No description provided for @outingReviewFillEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Preencher campos vazios'**
  String get outingReviewFillEmpty;

  /// No description provided for @outingReviewCopyIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Copiar ingredientes (sem quantidades)'**
  String get outingReviewCopyIngredients;

  /// No description provided for @outingReviewOriginSection.
  ///
  /// In pt, this message translates to:
  /// **'Origem dos dados'**
  String get outingReviewOriginSection;

  /// No description provided for @outingReviewOriginManual.
  ///
  /// In pt, this message translates to:
  /// **'Preenchido por você.'**
  String get outingReviewOriginManual;

  /// No description provided for @outingReviewOriginPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Lido da foto e conferido por você. Leitura automática pode errar: confira cada campo.'**
  String get outingReviewOriginPhoto;

  /// No description provided for @outingReviewReferenceNote.
  ///
  /// In pt, this message translates to:
  /// **'Com referência do catálogo (não é o mesmo registro).'**
  String get outingReviewReferenceNote;

  /// No description provided for @outingReviewSourceText.
  ///
  /// In pt, this message translates to:
  /// **'Texto lido na foto'**
  String get outingReviewSourceText;

  /// No description provided for @outingReviewConfirmContinue.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar e continuar'**
  String get outingReviewConfirmContinue;

  /// No description provided for @outingReviewSaveOnly.
  ///
  /// In pt, this message translates to:
  /// **'Salvar só neste rolê'**
  String get outingReviewSaveOnly;

  /// No description provided for @outingDrinksSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas deste rolê'**
  String get outingDrinksSectionTitle;

  /// No description provided for @outingDrinksTapToLog.
  ///
  /// In pt, this message translates to:
  /// **'Só existem neste rolê. Toque para registrar uma.'**
  String get outingDrinksTapToLog;

  /// No description provided for @outingDrinksRemoveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tirar da lista do rolê?'**
  String get outingDrinksRemoveTitle;

  /// No description provided for @outingDrinksRemoveBody.
  ///
  /// In pt, this message translates to:
  /// **'Ela sai de \"Bebidas deste rolê\". Os registros que você já fez continuam no histórico.'**
  String get outingDrinksRemoveBody;

  /// No description provided for @outingDrinksRemove.
  ///
  /// In pt, this message translates to:
  /// **'Tirar'**
  String get outingDrinksRemove;

  /// No description provided for @outingDrinksMoreActions.
  ///
  /// In pt, this message translates to:
  /// **'Mais ações'**
  String get outingDrinksMoreActions;

  /// No description provided for @outingDrinksRemoveFromList.
  ///
  /// In pt, this message translates to:
  /// **'Tirar da lista'**
  String get outingDrinksRemoveFromList;

  /// No description provided for @outingDrinksMenuPrice.
  ///
  /// In pt, this message translates to:
  /// **'cardápio {price}'**
  String outingDrinksMenuPrice(String price);

  /// No description provided for @outingScanUnfinishedMenu.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de cardápio não concluída'**
  String get outingScanUnfinishedMenu;

  /// No description provided for @outingScanUnfinishedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de rótulo não concluída'**
  String get outingScanUnfinishedLabel;

  /// No description provided for @outingScanUnfinishedNote.
  ///
  /// In pt, this message translates to:
  /// **'Ela continua ligada a este rolê. Se você concluir agora, o resultado fica salvo nele, não em outro.'**
  String get outingScanUnfinishedNote;

  /// No description provided for @outingScanOnlyHere.
  ///
  /// In pt, this message translates to:
  /// **'Existem só neste rolê.'**
  String get outingScanOnlyHere;

  /// No description provided for @outingScanPhotosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fotos do rolê'**
  String get outingScanPhotosTitle;

  /// No description provided for @outingScanAllUploaded.
  ///
  /// In pt, this message translates to:
  /// **'Fotos guardadas também na nuvem, em arquivo privado.'**
  String get outingScanAllUploaded;

  /// No description provided for @outingScanPending.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 foto ainda só neste aparelho; o envio é tentado de novo sozinho.} other{{count} fotos ainda só neste aparelho; o envio é tentado de novo sozinho.}}'**
  String outingScanPending(int count);

  /// No description provided for @outingScanLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 foto só neste aparelho.} other{{count} fotos só neste aparelho.}}'**
  String outingScanLocalOnly(int count);

  /// No description provided for @photoKindLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rótulo'**
  String get photoKindLabel;

  /// No description provided for @photoKindMenu.
  ///
  /// In pt, this message translates to:
  /// **'Cardápio'**
  String get photoKindMenu;

  /// No description provided for @pickerStartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Onde é o rolê?'**
  String get pickerStartTitle;

  /// No description provided for @pickerChangeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Corrigir local'**
  String get pickerChangeTitle;

  /// No description provided for @pickerLocateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Localização do local'**
  String get pickerLocateTitle;

  /// No description provided for @pickerAlreadySavedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lugar já salvo'**
  String get pickerAlreadySavedTitle;

  /// No description provided for @pickerAlreadySavedBody.
  ///
  /// In pt, this message translates to:
  /// **'Este lugar já está nos seus locais como \"{name}\". Usar aqui também?'**
  String pickerAlreadySavedBody(String name);

  /// No description provided for @pickerUseAnyway.
  ///
  /// In pt, this message translates to:
  /// **'Usar mesmo assim'**
  String get pickerUseAnyway;

  /// No description provided for @pickerSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar bar, restaurante ou endereço'**
  String get pickerSearchHint;

  /// No description provided for @pickerClearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar busca'**
  String get pickerClearSearch;

  /// No description provided for @pickerUseLocation.
  ///
  /// In pt, this message translates to:
  /// **'Usar minha localização'**
  String get pickerUseLocation;

  /// No description provided for @pickerApproximate.
  ///
  /// In pt, this message translates to:
  /// **'Localização aproximada: confira o lugar na lista ou no mapa.'**
  String get pickerApproximate;

  /// No description provided for @pickerLocationHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostra lugares por perto. Você sempre confirma onde está.'**
  String get pickerLocationHint;

  /// No description provided for @pickerNicknameOnly.
  ///
  /// In pt, this message translates to:
  /// **'Informar apenas um apelido'**
  String get pickerNicknameOnly;

  /// No description provided for @pickerNicknameOnlyExample.
  ///
  /// In pt, this message translates to:
  /// **'Sem mapa nem endereço. Ex.: Casa da Samara'**
  String get pickerNicknameOnlyExample;

  /// No description provided for @pickerNicknameOnlyShort.
  ///
  /// In pt, this message translates to:
  /// **'Sem mapa nem endereço.'**
  String get pickerNicknameOnlyShort;

  /// No description provided for @pickerYourPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Seus locais'**
  String get pickerYourPlaces;

  /// No description provided for @pickerNotConfiguredFull.
  ///
  /// In pt, this message translates to:
  /// **'A busca de lugares e o mapa não estão configurados nesta versão. Apelido, endereço digitado e locais salvos funcionam normalmente.'**
  String get pickerNotConfiguredFull;

  /// No description provided for @pickerNearYou.
  ///
  /// In pt, this message translates to:
  /// **'Perto de você'**
  String get pickerNearYou;

  /// No description provided for @pickerNothingNearby.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum bar ou restaurante encontrado bem perto. Você pode buscar pelo nome ou marcar só o ponto.'**
  String get pickerNothingNearby;

  /// No description provided for @pickerPinOnly.
  ///
  /// In pt, this message translates to:
  /// **'Marcar só este ponto no mapa'**
  String get pickerPinOnly;

  /// No description provided for @pickerPinOnlyHint.
  ///
  /// In pt, this message translates to:
  /// **'Você pode dar um apelido em seguida.'**
  String get pickerPinOnlyHint;

  /// No description provided for @pickerNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'A busca de lugares não está configurada nesta versão.'**
  String get pickerNotConfigured;

  /// No description provided for @pickerMinChars.
  ///
  /// In pt, this message translates to:
  /// **'Digite pelo menos 3 letras para buscar.'**
  String get pickerMinChars;

  /// No description provided for @pickerNothingFound.
  ///
  /// In pt, this message translates to:
  /// **'Nada encontrado. Tente o nome com o bairro ou a cidade, ou informe só um apelido.'**
  String get pickerNothingFound;

  /// No description provided for @pickerResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados'**
  String get pickerResults;

  /// No description provided for @pickerErrorOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem internet agora. Você ainda pode usar um local salvo ou informar um apelido.'**
  String get pickerErrorOffline;

  /// No description provided for @pickerErrorUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A busca está indisponível no momento. Você ainda pode usar um local salvo ou informar um apelido.'**
  String get pickerErrorUnavailable;

  /// No description provided for @pickerLocServiceOff.
  ///
  /// In pt, this message translates to:
  /// **'A localização do aparelho está desligada.'**
  String get pickerLocServiceOff;

  /// No description provided for @pickerOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir ajustes'**
  String get pickerOpenSettings;

  /// No description provided for @pickerLocDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão de localização. Você pode buscar pelo nome ou endereço normalmente.'**
  String get pickerLocDenied;

  /// No description provided for @pickerLocDeniedForever.
  ///
  /// In pt, this message translates to:
  /// **'A localização foi negada para o Bebômetro. Se quiser usá-la, libere nos ajustes do aparelho. A busca funciona sem ela.'**
  String get pickerLocDeniedForever;

  /// No description provided for @pickerLocTimeout.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter a localização a tempo.'**
  String get pickerLocTimeout;

  /// No description provided for @pickerLocUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A localização não está disponível aqui. Busque pelo nome ou endereço.'**
  String get pickerLocUnavailable;

  /// No description provided for @pickerSavedAs.
  ///
  /// In pt, this message translates to:
  /// **'Salvo como \"{name}\"'**
  String pickerSavedAs(String name);

  /// No description provided for @pickerManualNickname.
  ///
  /// In pt, this message translates to:
  /// **'Apelido'**
  String get pickerManualNickname;

  /// No description provided for @pickerManualHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Casa da Samara'**
  String get pickerManualHint;

  /// No description provided for @pickerManualHelper.
  ///
  /// In pt, this message translates to:
  /// **'O apelido sozinho já basta.'**
  String get pickerManualHelper;

  /// No description provided for @pickerAddAddress.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar endereço (opcional)'**
  String get pickerAddAddress;

  /// No description provided for @pickerNeedNicknameOrAddress.
  ///
  /// In pt, this message translates to:
  /// **'Informe um apelido (ex.: Casa da Samara) ou um endereço'**
  String get pickerNeedNicknameOrAddress;

  /// No description provided for @pickerStateTwoLetters.
  ///
  /// In pt, this message translates to:
  /// **'A UF tem 2 letras'**
  String get pickerStateTwoLetters;

  /// No description provided for @placeSaveToMine.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nos meus locais'**
  String get placeSaveToMine;

  /// No description provided for @placeSaveToMineHint.
  ///
  /// In pt, this message translates to:
  /// **'Para escolher de novo nos próximos rolês. Fica privado.'**
  String get placeSaveToMineHint;

  /// No description provided for @pickerUseThisPlace.
  ///
  /// In pt, this message translates to:
  /// **'Usar este local'**
  String get pickerUseThisPlace;

  /// No description provided for @distanceMeters.
  ///
  /// In pt, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(String meters);

  /// No description provided for @distanceKm.
  ///
  /// In pt, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @confirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conferir local'**
  String get confirmTitle;

  /// No description provided for @confirmTapMap.
  ///
  /// In pt, this message translates to:
  /// **'Toque no mapa para ajustar o ponto, se precisar.'**
  String get confirmTapMap;

  /// No description provided for @confirmMapFailed.
  ///
  /// In pt, this message translates to:
  /// **'O mapa não carregou. Você pode confirmar pelos dados abaixo.'**
  String get confirmMapFailed;

  /// No description provided for @confirmNoAddress.
  ///
  /// In pt, this message translates to:
  /// **'Sem endereço confirmado para este ponto.'**
  String get confirmNoAddress;

  /// No description provided for @confirmAdjustedWas.
  ///
  /// In pt, this message translates to:
  /// **'Ponto ajustado: \"{name}\" e o endereço dele não valem mais para este ponto.'**
  String confirmAdjustedWas(String name);

  /// No description provided for @confirmAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'Ponto ajustado por você.'**
  String get confirmAdjusted;

  /// No description provided for @confirmLookUp.
  ///
  /// In pt, this message translates to:
  /// **'Buscar endereço deste ponto'**
  String get confirmLookUp;

  /// No description provided for @confirmNoAddressFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum endereço encontrado para este ponto.'**
  String get confirmNoAddressFound;

  /// No description provided for @confirmOfflinePointKept.
  ///
  /// In pt, this message translates to:
  /// **'Sem internet. O ponto continua marcado.'**
  String get confirmOfflinePointKept;

  /// No description provided for @confirmLookUpFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível buscar o endereço agora.'**
  String get confirmLookUpFailed;

  /// No description provided for @confirmAlreadySaved.
  ///
  /// In pt, this message translates to:
  /// **'Você já salvou este lugar como \"{name}\". Ele será reaproveitado.'**
  String confirmAlreadySaved(String name);

  /// No description provided for @confirmAlreadySavedNick.
  ///
  /// In pt, this message translates to:
  /// **'Você já salvou este lugar como \"{name}\". Ele será reaproveitado e o apelido continua.'**
  String confirmAlreadySavedNick(String name);

  /// No description provided for @confirmNicknameSection.
  ///
  /// In pt, this message translates to:
  /// **'Apelido (opcional)'**
  String get confirmNicknameSection;

  /// No description provided for @confirmNicknameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Aparece no lugar do nome. O endereço fica nos detalhes.'**
  String get confirmNicknameHelper;

  /// No description provided for @confirmUseAsNickname.
  ///
  /// In pt, this message translates to:
  /// **'Usar \"{name}\" como apelido'**
  String confirmUseAsNickname(String name);

  /// No description provided for @confirmNeedNickname.
  ///
  /// In pt, this message translates to:
  /// **'Dê um apelido para salvar este ponto.'**
  String get confirmNeedNickname;

  /// No description provided for @placeFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get placeFallbackName;

  /// No description provided for @placePointOnMap.
  ///
  /// In pt, this message translates to:
  /// **'Ponto no mapa'**
  String get placePointOnMap;

  /// No description provided for @changePlaceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trocar o local deste rolê?'**
  String get changePlaceTitle;

  /// No description provided for @changePlaceBody.
  ///
  /// In pt, this message translates to:
  /// **'O rolê passa a ser \"{name}\". Só este rolê muda: as bebidas, fotos e a comanda continuam nele, e os outros rolês não são alterados.'**
  String changePlaceBody(String name);

  /// No description provided for @changePlaceConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Trocar local'**
  String get changePlaceConfirm;

  /// No description provided for @changePlaceDone.
  ///
  /// In pt, this message translates to:
  /// **'Local do rolê atualizado'**
  String get changePlaceDone;

  /// No description provided for @changePlaceFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível trocar o local. Nada foi alterado.'**
  String get changePlaceFailed;

  /// No description provided for @openMapsFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir um aplicativo de mapas.'**
  String get openMapsFailed;

  /// No description provided for @mapSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Mapa com o ponto do local'**
  String get mapSemantics;

  /// No description provided for @mapZoomIn.
  ///
  /// In pt, this message translates to:
  /// **'Aproximar'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In pt, this message translates to:
  /// **'Afastar'**
  String get mapZoomOut;

  /// No description provided for @mapCenter.
  ///
  /// In pt, this message translates to:
  /// **'Centralizar no ponto'**
  String get mapCenter;

  /// No description provided for @placeNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Esse local não foi encontrado.'**
  String get placeNotFound;

  /// No description provided for @placeScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get placeScreenTitle;

  /// No description provided for @placeReactivated.
  ///
  /// In pt, this message translates to:
  /// **'Local reativado'**
  String get placeReactivated;

  /// No description provided for @placeArchivedToast.
  ///
  /// In pt, this message translates to:
  /// **'Local arquivado'**
  String get placeArchivedToast;

  /// No description provided for @placeReactivate.
  ///
  /// In pt, this message translates to:
  /// **'Reativar'**
  String get placeReactivate;

  /// No description provided for @placeArchive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get placeArchive;

  /// No description provided for @placeArchivedPill.
  ///
  /// In pt, this message translates to:
  /// **'Arquivado'**
  String get placeArchivedPill;

  /// No description provided for @placeStatOutings.
  ///
  /// In pt, this message translates to:
  /// **'Rolês'**
  String get placeStatOutings;

  /// No description provided for @placeStatDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas'**
  String get placeStatDrinks;

  /// No description provided for @placeStatSpent.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado'**
  String get placeStatSpent;

  /// No description provided for @placeLastVisit.
  ///
  /// In pt, this message translates to:
  /// **'Última visita: {date}'**
  String placeLastVisit(String date);

  /// No description provided for @placeStartHere.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar rolê aqui'**
  String get placeStartHere;

  /// No description provided for @placeOpenMap.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no mapa'**
  String get placeOpenMap;

  /// No description provided for @placeSpendNote.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado: o que você registrou nas suas bebidas aqui. O total da mesa e os pagamentos da comanda ficam no resumo de cada rolê e não entram nesta soma.'**
  String get placeSpendNote;

  /// No description provided for @placePriceHistory.
  ///
  /// In pt, this message translates to:
  /// **'Seu histórico de preços'**
  String get placePriceHistory;

  /// No description provided for @placePriceHistoryNone.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há preços informados por você aqui. Quando houver, o último preço e a faixa observada aparecem neste lugar.'**
  String get placePriceHistoryNone;

  /// No description provided for @placePriceHistoryNote.
  ///
  /// In pt, this message translates to:
  /// **'Seu histórico: só o que você mesmo informou neste local, por bebida e tamanho. Não é média de mercado, da cidade nem do estado.'**
  String get placePriceHistoryNote;

  /// No description provided for @placeVisits.
  ///
  /// In pt, this message translates to:
  /// **'Rolês neste local ({count})'**
  String placeVisits(String count);

  /// No description provided for @placeNoVisits.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum rolê registrado aqui ainda.'**
  String get placeNoVisits;

  /// No description provided for @placeVisitInProgress.
  ///
  /// In pt, this message translates to:
  /// **'em andamento'**
  String get placeVisitInProgress;

  /// No description provided for @placeNoValues.
  ///
  /// In pt, this message translates to:
  /// **'sem valores'**
  String get placeNoValues;

  /// No description provided for @rangeTo.
  ///
  /// In pt, this message translates to:
  /// **'{from} a {to}'**
  String rangeTo(String from, String to);

  /// No description provided for @placePriceLast.
  ///
  /// In pt, this message translates to:
  /// **'Último: {price} em {date}'**
  String placePriceLast(String price, String date);

  /// No description provided for @placePriceLastShared.
  ///
  /// In pt, this message translates to:
  /// **'Último: {price} em {date} (total da garrafa/porção)'**
  String placePriceLastShared(String price, String date);

  /// No description provided for @placePriceRangeLine.
  ///
  /// In pt, this message translates to:
  /// **'Faixa observada: {range} · {count, plural, =1{1 registro} other{{count} registros}} · {period}'**
  String placePriceRangeLine(String range, int count, String period);

  /// No description provided for @placeAlreadyActive.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um rolê em andamento. Encerre-o antes.'**
  String get placeAlreadyActive;

  /// No description provided for @placeFieldMapName.
  ///
  /// In pt, this message translates to:
  /// **'Nome no mapa'**
  String get placeFieldMapName;

  /// No description provided for @placeFieldAddress.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get placeFieldAddress;

  /// No description provided for @placeFieldCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get placeFieldCity;

  /// No description provided for @placeFieldOrigin.
  ///
  /// In pt, this message translates to:
  /// **'Origem'**
  String get placeFieldOrigin;

  /// No description provided for @placeSourceSearch.
  ///
  /// In pt, this message translates to:
  /// **'Escolhido na busca (OpenStreetMap)'**
  String get placeSourceSearch;

  /// No description provided for @placeSourceLocation.
  ///
  /// In pt, this message translates to:
  /// **'Sua localização, conferida no mapa'**
  String get placeSourceLocation;

  /// No description provided for @placeSourceAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'Ponto ajustado por você'**
  String get placeSourceAdjusted;

  /// No description provided for @placeSourceManual.
  ///
  /// In pt, this message translates to:
  /// **'Informado por você'**
  String get placeSourceManual;

  /// No description provided for @placeDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get placeDetailsTitle;

  /// No description provided for @placeNoPointNoAddress.
  ///
  /// In pt, this message translates to:
  /// **'Sem endereço nem ponto no mapa. Dá para buscar em \"Editar\".'**
  String get placeNoPointNoAddress;

  /// No description provided for @placesEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum local salvo'**
  String get placesEmptyTitle;

  /// No description provided for @placesEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Salve os lugares onde você costuma ir para escolher rápido ao iniciar um rolê. Eles ficam privados no seu perfil.'**
  String get placesEmptyBody;

  /// No description provided for @placesArchivedSection.
  ///
  /// In pt, this message translates to:
  /// **'Arquivados'**
  String get placesArchivedSection;

  /// No description provided for @placesNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo local'**
  String get placesNew;

  /// No description provided for @placesVisits.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 rolê} other{{count} rolês}}'**
  String placesVisits(int count);

  /// No description provided for @placeEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar local'**
  String get placeEditTitle;

  /// No description provided for @placeEditorNote.
  ///
  /// In pt, this message translates to:
  /// **'As mudanças valem para os próximos rolês. Os rolês que já aconteceram mantêm o nome e o endereço de quando foram feitos.'**
  String get placeEditorNote;

  /// No description provided for @placeEditorLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get placeEditorLocation;

  /// No description provided for @placeEditorSourceSearch.
  ///
  /// In pt, this message translates to:
  /// **'Escolhido na busca (dados do OpenStreetMap)'**
  String get placeEditorSourceSearch;

  /// No description provided for @placeEditorSourceAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'Ponto ajustado por você no mapa'**
  String get placeEditorSourceAdjusted;

  /// No description provided for @placeEditorNoPointHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional. Apelido ou endereço já bastam.'**
  String get placeEditorNoPointHint;

  /// No description provided for @placeEditorPointSaved.
  ///
  /// In pt, this message translates to:
  /// **'Ponto salvo'**
  String get placeEditorPointSaved;

  /// No description provided for @placeEditorNoPoint.
  ///
  /// In pt, this message translates to:
  /// **'Sem ponto no mapa'**
  String get placeEditorNoPoint;

  /// No description provided for @placeEditorSearchMap.
  ///
  /// In pt, this message translates to:
  /// **'Buscar no mapa'**
  String get placeEditorSearchMap;

  /// No description provided for @placeEditorSearchAdjust.
  ///
  /// In pt, this message translates to:
  /// **'Buscar ou ajustar'**
  String get placeEditorSearchAdjust;

  /// No description provided for @placeEditorRemoveFromMap.
  ///
  /// In pt, this message translates to:
  /// **'Remover do mapa'**
  String get placeEditorRemoveFromMap;

  /// No description provided for @placeEditorAddressHelper.
  ///
  /// In pt, this message translates to:
  /// **'Apelido, nome do lugar ou endereço já bastam.'**
  String get placeEditorAddressHelper;

  /// No description provided for @placeEditorPrivate.
  ///
  /// In pt, this message translates to:
  /// **'Seus locais e endereços são privados: só aparecem para você.'**
  String get placeEditorPrivate;

  /// No description provided for @placeEditorSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar local'**
  String get placeEditorSave;

  /// No description provided for @tabMe.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get tabMe;

  /// No description provided for @tabCatFood.
  ///
  /// In pt, this message translates to:
  /// **'Petisco / comida'**
  String get tabCatFood;

  /// No description provided for @tabCatSoft.
  ///
  /// In pt, this message translates to:
  /// **'Água / refrigerante'**
  String get tabCatSoft;

  /// No description provided for @tabCatCover.
  ///
  /// In pt, this message translates to:
  /// **'Couvert'**
  String get tabCatCover;

  /// No description provided for @tabCatStarter.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get tabCatStarter;

  /// No description provided for @tabCatTransport.
  ///
  /// In pt, this message translates to:
  /// **'Transporte'**
  String get tabCatTransport;

  /// No description provided for @tabCatOther.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get tabCatOther;

  /// No description provided for @tabCatDrink.
  ///
  /// In pt, this message translates to:
  /// **'Bebida só da comanda'**
  String get tabCatDrink;

  /// No description provided for @tabSplitEqual.
  ///
  /// In pt, this message translates to:
  /// **'Igualmente'**
  String get tabSplitEqual;

  /// No description provided for @tabSplitItem.
  ///
  /// In pt, this message translates to:
  /// **'Por item'**
  String get tabSplitItem;

  /// No description provided for @tabSplitCustom.
  ///
  /// In pt, this message translates to:
  /// **'Valores personalizados'**
  String get tabSplitCustom;

  /// No description provided for @tabShared.
  ///
  /// In pt, this message translates to:
  /// **'compartilhada'**
  String get tabShared;

  /// No description provided for @tabShareHeader.
  ///
  /// In pt, this message translates to:
  /// **'Comanda · {title}'**
  String tabShareHeader(String title);

  /// No description provided for @tabShareNoItems.
  ///
  /// In pt, this message translates to:
  /// **'Sem itens na comanda.'**
  String get tabShareNoItems;

  /// No description provided for @tabShareItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get tabShareItems;

  /// No description provided for @tabShareLineGroup.
  ///
  /// In pt, this message translates to:
  /// **'• {title} · {count} × {unit} = {sum}'**
  String tabShareLineGroup(String title, String count, String unit, String sum);

  /// No description provided for @tabShareLineQty.
  ///
  /// In pt, this message translates to:
  /// **'• {title} · {qty}× = {total}'**
  String tabShareLineQty(String title, String qty, String total);

  /// No description provided for @tabShareLineGroupNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'• {title} · {count} × sem preço'**
  String tabShareLineGroupNoPrice(String title, String count);

  /// No description provided for @tabShareLine.
  ///
  /// In pt, this message translates to:
  /// **'• {title} · {price}'**
  String tabShareLine(String title, String price);

  /// No description provided for @tabShareLineNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'• {title} · sem preço'**
  String tabShareLineNoPrice(String title);

  /// No description provided for @tabShareSubtotalKnown.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal conhecido: {amount}'**
  String tabShareSubtotalKnown(String amount);

  /// No description provided for @tabShareSubtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal: {amount}'**
  String tabShareSubtotal(String amount);

  /// No description provided for @tabShareDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto: -{amount}'**
  String tabShareDiscount(String amount);

  /// No description provided for @tabShareService.
  ///
  /// In pt, this message translates to:
  /// **'Serviço ({pct} sobre {base}): {amount}'**
  String tabShareService(String pct, String base, String amount);

  /// No description provided for @tabShareTotalKnown.
  ///
  /// In pt, this message translates to:
  /// **'Total conhecido: {amount}'**
  String tabShareTotalKnown(String amount);

  /// No description provided for @tabShareTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total: {amount}'**
  String tabShareTotal(String amount);

  /// No description provided for @tabSharePartial.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Conta parcial: 1 item sem preço.} other{Conta parcial: {count} itens sem preço.}}'**
  String tabSharePartial(int count);

  /// No description provided for @tabShareSplitHeader.
  ///
  /// In pt, this message translates to:
  /// **'Divisão ({mode})'**
  String tabShareSplitHeader(String mode);

  /// No description provided for @tabShareSplitLine.
  ///
  /// In pt, this message translates to:
  /// **'• {name}: {amount}'**
  String tabShareSplitLine(String name, String amount);

  /// No description provided for @tabSharePaid.
  ///
  /// In pt, this message translates to:
  /// **' · pagou {amount}'**
  String tabSharePaid(String amount);

  /// No description provided for @tabShareMissing.
  ///
  /// In pt, this message translates to:
  /// **' · falta {amount}'**
  String tabShareMissing(String amount);

  /// No description provided for @tabShareOver.
  ///
  /// In pt, this message translates to:
  /// **' · a mais {amount}'**
  String tabShareOver(String amount);

  /// No description provided for @tabShareUnassigned.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem dividir: {amount}'**
  String tabShareUnassigned(String amount);

  /// No description provided for @tabShareOverTotal.
  ///
  /// In pt, this message translates to:
  /// **'Acima do total: {amount}'**
  String tabShareOverTotal(String amount);

  /// No description provided for @tabShareSplitPartial.
  ///
  /// In pt, this message translates to:
  /// **'Divisão parcial: os valores podem mudar.'**
  String get tabShareSplitPartial;

  /// No description provided for @tabTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comanda'**
  String get tabTitle;

  /// No description provided for @tabShareSplitTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar divisão'**
  String get tabShareSplitTooltip;

  /// No description provided for @tabIntro.
  ///
  /// In pt, this message translates to:
  /// **'Opcional. A comanda não registra consumo: o que você bebeu continua nos seus registros.'**
  String get tabIntro;

  /// No description provided for @tabEnded.
  ///
  /// In pt, this message translates to:
  /// **'Rolê encerrado. A comanda segue editável; encerrar não marca a conta como paga.'**
  String get tabEnded;

  /// No description provided for @tabItemsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Itens ({count})'**
  String tabItemsTitle(String count);

  /// No description provided for @tabEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comanda vazia'**
  String get tabEmptyTitle;

  /// No description provided for @tabEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Adicione petiscos e outros gastos, ou inclua as bebidas que você já registrou.'**
  String get tabEmptyBody;

  /// No description provided for @tabNoDrinksToLink.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma bebida registrada para incluir'**
  String get tabNoDrinksToLink;

  /// No description provided for @tabLinkDrinks.
  ///
  /// In pt, this message translates to:
  /// **'Incluir bebidas registradas ({count})'**
  String tabLinkDrinks(String count);

  /// No description provided for @tabSplitBill.
  ///
  /// In pt, this message translates to:
  /// **'Dividir conta'**
  String get tabSplitBill;

  /// No description provided for @tabSubtotalKnown.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal conhecido'**
  String get tabSubtotalKnown;

  /// No description provided for @tabSubtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get tabSubtotal;

  /// No description provided for @tabDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get tabDiscount;

  /// No description provided for @tabServiceLine.
  ///
  /// In pt, this message translates to:
  /// **'Serviço {pct} sobre {base}'**
  String tabServiceLine(String pct, String base);

  /// No description provided for @tabTotalKnown.
  ///
  /// In pt, this message translates to:
  /// **'Total conhecido'**
  String get tabTotalKnown;

  /// No description provided for @tabTotalTab.
  ///
  /// In pt, this message translates to:
  /// **'Total da comanda'**
  String get tabTotalTab;

  /// No description provided for @tabPartialPill.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item sem preço: a conta e a divisão são parciais.} other{{count} itens sem preço: a conta e a divisão são parciais.}}'**
  String tabPartialPill(int count);

  /// No description provided for @tabYourShareProvisional.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte (provisória)'**
  String get tabYourShareProvisional;

  /// No description provided for @tabYourShare.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte'**
  String get tabYourShare;

  /// No description provided for @tabOrderNote.
  ///
  /// In pt, this message translates to:
  /// **'Ordem: subtotal → desconto → serviço sobre os itens com serviço, já com desconto → total.'**
  String get tabOrderNote;

  /// No description provided for @tabServiceAndDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Serviço e desconto'**
  String get tabServiceAndDiscount;

  /// No description provided for @tabServiceSummary.
  ///
  /// In pt, this message translates to:
  /// **'serviço {pct}'**
  String tabServiceSummary(String pct);

  /// No description provided for @tabNoService.
  ///
  /// In pt, this message translates to:
  /// **'sem serviço'**
  String get tabNoService;

  /// No description provided for @tabDiscountSummary.
  ///
  /// In pt, this message translates to:
  /// **'desconto {amount}'**
  String tabDiscountSummary(String amount);

  /// No description provided for @tabChargeService.
  ///
  /// In pt, this message translates to:
  /// **'Cobrar serviço'**
  String get tabChargeService;

  /// No description provided for @tabChargeServiceHint.
  ///
  /// In pt, this message translates to:
  /// **'Só nos itens marcados com serviço. Transporte e entrada começam sem.'**
  String get tabChargeServiceHint;

  /// No description provided for @tabPercent.
  ///
  /// In pt, this message translates to:
  /// **'Percentual'**
  String get tabPercent;

  /// No description provided for @tabServiceBase.
  ///
  /// In pt, this message translates to:
  /// **'Base {base} → {service}'**
  String tabServiceBase(String base, String service);

  /// No description provided for @tabDiscountNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum'**
  String get tabDiscountNone;

  /// No description provided for @tabDiscountAmountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Valor do desconto'**
  String get tabDiscountAmountLabel;

  /// No description provided for @tabDiscountPercentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Percentual do desconto'**
  String get tabDiscountPercentLabel;

  /// No description provided for @tabDiscountCapped.
  ///
  /// In pt, this message translates to:
  /// **'Limitado ao subtotal: {amount}'**
  String tabDiscountCapped(String amount);

  /// No description provided for @tabDiscountHelper.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o subtotal dos itens, distribuído entre eles.'**
  String get tabDiscountHelper;

  /// No description provided for @tabGroupHeaderMulti.
  ///
  /// In pt, this message translates to:
  /// **'{title} · {count} × {unit} = {sum}'**
  String tabGroupHeaderMulti(
    String title,
    String count,
    String unit,
    String sum,
  );

  /// No description provided for @tabGroupHeaderNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'{title} · {count} × sem preço'**
  String tabGroupHeaderNoPrice(String title, String count);

  /// No description provided for @tabGroupQtyNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'{title} · {qty}× sem preço'**
  String tabGroupQtyNoPrice(String title, String qty);

  /// No description provided for @tabGroupQtyTotal.
  ///
  /// In pt, this message translates to:
  /// **'{title} · {qty}× = {total}'**
  String tabGroupQtyTotal(String title, String qty, String total);

  /// No description provided for @tabComplimentary.
  ///
  /// In pt, this message translates to:
  /// **'cortesia'**
  String get tabComplimentary;

  /// No description provided for @tabNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'sem preço'**
  String get tabNoPrice;

  /// No description provided for @tabPersonalOnly.
  ///
  /// In pt, this message translates to:
  /// **'só a sua parte ({amount}) é conhecida · total da garrafa desconhecido'**
  String tabPersonalOnly(String amount);

  /// No description provided for @tabPersonalOnlyShort.
  ///
  /// In pt, this message translates to:
  /// **'só a parte pessoal é conhecida; total desconhecido'**
  String get tabPersonalOnlyShort;

  /// No description provided for @tabLineOnlyYourShare.
  ///
  /// In pt, this message translates to:
  /// **'só sua parte {amount}'**
  String tabLineOnlyYourShare(String amount);

  /// No description provided for @tabLineDiscount.
  ///
  /// In pt, this message translates to:
  /// **'desc. −{amount}'**
  String tabLineDiscount(String amount);

  /// No description provided for @tabLineService.
  ///
  /// In pt, this message translates to:
  /// **'serviço +{amount}'**
  String tabLineService(String amount);

  /// No description provided for @tabLineRegisteredDrink.
  ///
  /// In pt, this message translates to:
  /// **'Bebida registrada'**
  String get tabLineRegisteredDrink;

  /// No description provided for @tabLineItem.
  ///
  /// In pt, this message translates to:
  /// **'Item da comanda'**
  String get tabLineItem;

  /// No description provided for @tabActions.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get tabActions;

  /// No description provided for @tabFillTotalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Total da garrafa/jarra'**
  String get tabFillTotalTitle;

  /// No description provided for @tabFillPriceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Preço'**
  String get tabFillPriceTitle;

  /// No description provided for @tabFillTotalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Total da conta deste item'**
  String get tabFillTotalLabel;

  /// No description provided for @tabFillTotal.
  ///
  /// In pt, this message translates to:
  /// **'Informar total'**
  String get tabFillTotal;

  /// No description provided for @tabFillPrice.
  ///
  /// In pt, this message translates to:
  /// **'Informar preço'**
  String get tabFillPrice;

  /// No description provided for @tabNoServiceItem.
  ///
  /// In pt, this message translates to:
  /// **'Sem serviço neste item'**
  String get tabNoServiceItem;

  /// No description provided for @tabRemoveFromTab.
  ///
  /// In pt, this message translates to:
  /// **'Tirar da comanda'**
  String get tabRemoveFromTab;

  /// No description provided for @tabDeleteItem.
  ///
  /// In pt, this message translates to:
  /// **'Excluir item'**
  String get tabDeleteItem;

  /// No description provided for @splitTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dividir conta'**
  String get splitTitle;

  /// No description provided for @splitRename.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get splitRename;

  /// No description provided for @splitRemoveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover {name}?'**
  String splitRemoveTitle(String name);

  /// No description provided for @splitRemoveBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} tem {share} atribuídos. Escolha o que acontece com eles:'**
  String splitRemoveBody(String name, String share);

  /// No description provided for @splitRemoveBodyPay.
  ///
  /// In pt, this message translates to:
  /// **'{name} tem {share} atribuídos e {count, plural, =1{1 pagamento} other{{count} pagamentos}} ({paid}). Escolha o que acontece com eles:'**
  String splitRemoveBodyPay(String name, String share, int count, String paid);

  /// No description provided for @splitPassTo.
  ///
  /// In pt, this message translates to:
  /// **'Passar para'**
  String get splitPassTo;

  /// No description provided for @splitNobody.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém (redistribuir)'**
  String get splitNobody;

  /// No description provided for @splitRedistributeNote.
  ///
  /// In pt, this message translates to:
  /// **'Os itens só dessa pessoa voltam a ser divididos entre todos e os pagamentos dela são apagados.'**
  String get splitRedistributeNote;

  /// No description provided for @splitTransferNote.
  ///
  /// In pt, this message translates to:
  /// **'Itens, valores e pagamentos passam para essa pessoa.'**
  String get splitTransferNote;

  /// No description provided for @splitRegisterPayment.
  ///
  /// In pt, this message translates to:
  /// **'Registrar pagamento'**
  String get splitRegisterPayment;

  /// No description provided for @splitEditPayment.
  ///
  /// In pt, this message translates to:
  /// **'Editar pagamento'**
  String get splitEditPayment;

  /// No description provided for @splitWhoPaid.
  ///
  /// In pt, this message translates to:
  /// **'Quem pagou'**
  String get splitWhoPaid;

  /// No description provided for @splitPaidAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor pago ao estabelecimento'**
  String get splitPaidAmount;

  /// No description provided for @splitNoteOptional.
  ///
  /// In pt, this message translates to:
  /// **'Observação (opcional)'**
  String get splitNoteOptional;

  /// No description provided for @splitPaymentPositive.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero.'**
  String get splitPaymentPositive;

  /// No description provided for @splitTotalKnown.
  ///
  /// In pt, this message translates to:
  /// **'Total conhecido {amount}'**
  String splitTotalKnown(String amount);

  /// No description provided for @splitTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total {amount}'**
  String splitTotal(String amount);

  /// No description provided for @splitPendingPill.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item sem preço: a divisão e os saldos são provisórios.} other{{count} itens sem preço: a divisão e os saldos são provisórios.}}'**
  String splitPendingPill(int count);

  /// No description provided for @splitComplete.
  ///
  /// In pt, this message translates to:
  /// **'Divisão completa: as parcelas somam o total.'**
  String get splitComplete;

  /// No description provided for @splitMissing.
  ///
  /// In pt, this message translates to:
  /// **'Falta distribuir {amount}.'**
  String splitMissing(String amount);

  /// No description provided for @splitOver.
  ///
  /// In pt, this message translates to:
  /// **'Distribuído {amount} a mais que o total.'**
  String splitOver(String amount);

  /// No description provided for @splitPeople.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas'**
  String get splitPeople;

  /// No description provided for @splitAddPerson.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar pessoa (apelido)'**
  String get splitAddPerson;

  /// No description provided for @splitNicknamesOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só apelidos, sem login nem convite. Ficam apenas nesta comanda.'**
  String get splitNicknamesOnly;

  /// No description provided for @splitHow.
  ///
  /// In pt, this message translates to:
  /// **'Como dividir'**
  String get splitHow;

  /// No description provided for @splitModeEqualShort.
  ///
  /// In pt, this message translates to:
  /// **'Igual'**
  String get splitModeEqualShort;

  /// No description provided for @splitModeItemShort.
  ///
  /// In pt, this message translates to:
  /// **'Por item'**
  String get splitModeItemShort;

  /// No description provided for @splitModeValuesShort.
  ///
  /// In pt, this message translates to:
  /// **'Valores'**
  String get splitModeValuesShort;

  /// No description provided for @splitModeEqualNote.
  ///
  /// In pt, this message translates to:
  /// **'Modo ativo: igualmente. O total é dividido entre as pessoas marcadas.'**
  String get splitModeEqualNote;

  /// No description provided for @splitModeItemNote.
  ///
  /// In pt, this message translates to:
  /// **'Modo ativo: por item. Cada pedido é dividido entre quem participa dele, com serviço e desconto do próprio item.'**
  String get splitModeItemNote;

  /// No description provided for @splitModeCustomNote.
  ///
  /// In pt, this message translates to:
  /// **'Modo ativo: valores personalizados. Você digita a parcela de cada um; só fecha quando a soma bate com o total.'**
  String get splitModeCustomNote;

  /// No description provided for @splitAddItemsHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione itens à comanda para dividir por item.'**
  String get splitAddItemsHint;

  /// No description provided for @splitFillEqually.
  ///
  /// In pt, this message translates to:
  /// **'Preencher igualmente'**
  String get splitFillEqually;

  /// No description provided for @splitAllDistributed.
  ///
  /// In pt, this message translates to:
  /// **'Tudo distribuído.'**
  String get splitAllDistributed;

  /// No description provided for @splitNotDistributed.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não distribuído: {amount}'**
  String splitNotDistributed(String amount);

  /// No description provided for @splitPassedTotal.
  ///
  /// In pt, this message translates to:
  /// **'Passou do total em {amount}'**
  String splitPassedTotal(String amount);

  /// No description provided for @splitResult.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get splitResult;

  /// No description provided for @splitProvisionalNote.
  ///
  /// In pt, this message translates to:
  /// **'Provisório: os valores mudam se a conta mudar.'**
  String get splitProvisionalNote;

  /// No description provided for @splitAttributedNote.
  ///
  /// In pt, this message translates to:
  /// **'Atribuído é o que cabe a cada um; pago é o que a pessoa disse ter pago ao estabelecimento.'**
  String get splitAttributedNote;

  /// No description provided for @splitPaidLine.
  ///
  /// In pt, this message translates to:
  /// **'Pagou {paid} · {balance}'**
  String splitPaidLine(String paid, String balance);

  /// No description provided for @splitBalanceMissing.
  ///
  /// In pt, this message translates to:
  /// **'falta pagar {amount}{provisional, select, true{ (provisório)} other{}}'**
  String splitBalanceMissing(String amount, String provisional);

  /// No description provided for @splitBalanceOver.
  ///
  /// In pt, this message translates to:
  /// **'pagou {amount} a mais{provisional, select, true{ (provisório)} other{}}'**
  String splitBalanceOver(String amount, String provisional);

  /// No description provided for @splitBalanceEven.
  ///
  /// In pt, this message translates to:
  /// **'em dia{provisional, select, true{ (provisório)} other{}}'**
  String splitBalanceEven(String provisional);

  /// No description provided for @splitPayments.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos'**
  String get splitPayments;

  /// No description provided for @splitNoPayments.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pagamento registrado.'**
  String get splitNoPayments;

  /// No description provided for @splitRemovedPerson.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa removida'**
  String get splitRemovedPerson;

  /// No description provided for @splitDeletePayment.
  ///
  /// In pt, this message translates to:
  /// **'Excluir pagamento'**
  String get splitDeletePayment;

  /// No description provided for @splitPaymentNote.
  ///
  /// In pt, this message translates to:
  /// **'Registrar um pagamento não muda o total, o consumo nem o orçamento: só o saldo. O app não faz cobrança, Pix nem transferência, e não diz quem deve pagar a quem. O preço de um consumo não conta como pagamento.'**
  String get splitPaymentNote;

  /// No description provided for @splitAssignEveryone.
  ///
  /// In pt, this message translates to:
  /// **'Todos dividem'**
  String get splitAssignEveryone;

  /// No description provided for @splitAssignNobody.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém'**
  String get splitAssignNobody;

  /// No description provided for @splitAssignIntro.
  ///
  /// In pt, this message translates to:
  /// **'Quem participa e com que peso. Quem não participa não recebe parcela deste item.'**
  String get splitAssignIntro;

  /// No description provided for @splitWeight.
  ///
  /// In pt, this message translates to:
  /// **'peso {number}'**
  String splitWeight(String number);

  /// No description provided for @tabExtraNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo item da comanda'**
  String get tabExtraNew;

  /// No description provided for @tabExtraNote.
  ///
  /// In pt, this message translates to:
  /// **'Só na comanda deste rolê. Não vira consumo nem entra no catálogo.'**
  String get tabExtraNote;

  /// No description provided for @tabExtraDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get tabExtraDescription;

  /// No description provided for @tabExtraHintTransport.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Uber de volta (opcional)'**
  String get tabExtraHintTransport;

  /// No description provided for @tabExtraHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Porção de fritas'**
  String get tabExtraHint;

  /// No description provided for @tabBasisUnit.
  ///
  /// In pt, this message translates to:
  /// **'Preço de cada um'**
  String get tabBasisUnit;

  /// No description provided for @tabBasisTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total dos {qty}'**
  String tabBasisTotal(String qty);

  /// No description provided for @tabValueEach.
  ///
  /// In pt, this message translates to:
  /// **'Valor de cada unidade'**
  String get tabValueEach;

  /// No description provided for @tabValueTotalQty.
  ///
  /// In pt, this message translates to:
  /// **'Valor total dos {qty}'**
  String tabValueTotalQty(String qty);

  /// No description provided for @tabExtraServiceItem.
  ///
  /// In pt, this message translates to:
  /// **'Cobrar serviço neste item'**
  String get tabExtraServiceItem;

  /// No description provided for @tabExtraServiceHint.
  ///
  /// In pt, this message translates to:
  /// **'Só vale se o serviço estiver ligado.'**
  String get tabExtraServiceHint;

  /// No description provided for @tabExtraWho.
  ///
  /// In pt, this message translates to:
  /// **'Quem divide este item'**
  String get tabExtraWho;

  /// No description provided for @tabExtraAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get tabExtraAll;

  /// No description provided for @tabExtraSome.
  ///
  /// In pt, this message translates to:
  /// **'{count} de {total}'**
  String tabExtraSome(String count, String total);

  /// No description provided for @tabExtraWhoNote.
  ///
  /// In pt, this message translates to:
  /// **'Vale no modo \"Por item\" da divisão.'**
  String get tabExtraWhoNote;

  /// No description provided for @tabExtraSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar item'**
  String get tabExtraSave;

  /// No description provided for @tabExtraNeedValue.
  ///
  /// In pt, this message translates to:
  /// **'Informe o valor, ou escolha Cortesia / Não sei.'**
  String get tabExtraNeedValue;

  /// No description provided for @tabExtraHelperUnit.
  ///
  /// In pt, this message translates to:
  /// **'{qty} × {unit} = {total}'**
  String tabExtraHelperUnit(String qty, String unit, String total);

  /// No description provided for @tabExtraHelperLine.
  ///
  /// In pt, this message translates to:
  /// **'Total da linha: {amount}'**
  String tabExtraHelperLine(String amount);

  /// No description provided for @tabExtraNoPrice.
  ///
  /// In pt, this message translates to:
  /// **'Sem preço: a conta fica parcial até você preencher.'**
  String get tabExtraNoPrice;

  /// No description provided for @tabLinkSharedTotal.
  ///
  /// In pt, this message translates to:
  /// **'compartilhada · total {amount}'**
  String tabLinkSharedTotal(String amount);

  /// No description provided for @tabLinkSharedPersonal.
  ///
  /// In pt, this message translates to:
  /// **'compartilhada · só a sua parte ({amount}) é conhecida'**
  String tabLinkSharedPersonal(String amount);

  /// No description provided for @tabLinkSameBottleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mesma garrafa ou outra?'**
  String get tabLinkSameBottleTitle;

  /// No description provided for @tabLinkSameBottleBody.
  ///
  /// In pt, this message translates to:
  /// **'{count} registros compartilhados de \"{name}\" têm o mesmo total ({total}). Foi a mesma garrafa/jarra ou {count} separadas?\n\nO total entra na comanda uma vez por garrafa; o app não adivinha.'**
  String tabLinkSameBottleBody(String count, String name, String total);

  /// No description provided for @tabLinkSeparate.
  ///
  /// In pt, this message translates to:
  /// **'{count} separadas'**
  String tabLinkSeparate(String count);

  /// No description provided for @tabLinkSame.
  ///
  /// In pt, this message translates to:
  /// **'Mesma garrafa'**
  String get tabLinkSame;

  /// No description provided for @tabLinkTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas já registradas'**
  String get tabLinkTitle;

  /// No description provided for @tabLinkNote.
  ///
  /// In pt, this message translates to:
  /// **'Elas só são ligadas à comanda: o preço continua no registro e uma correção lá vale aqui. Seus registros não mostram tudo o que a mesa pediu.'**
  String get tabLinkNote;

  /// No description provided for @tabLinkAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get tabLinkAll;

  /// No description provided for @tabLinkNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get tabLinkNone;

  /// No description provided for @tabLinkInclude.
  ///
  /// In pt, this message translates to:
  /// **'Incluir {count} na comanda'**
  String tabLinkInclude(String count);

  /// No description provided for @tabSharePreview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia do texto. Nada é enviado até você tocar em Compartilhar.'**
  String get tabSharePreview;

  /// No description provided for @tabShareIncludePayments.
  ///
  /// In pt, this message translates to:
  /// **'Incluir pagamentos e saldos'**
  String get tabShareIncludePayments;

  /// No description provided for @tabShareOffDefault.
  ///
  /// In pt, this message translates to:
  /// **'Desligado por padrão.'**
  String get tabShareOffDefault;

  /// No description provided for @tabShareExcludes.
  ///
  /// In pt, this message translates to:
  /// **'Não inclui endereço, fotos, anotações pessoais nem relato de embriaguez.'**
  String get tabShareExcludes;

  /// No description provided for @tabShareButton.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get tabShareButton;

  /// No description provided for @tabCopyText.
  ///
  /// In pt, this message translates to:
  /// **'Copiar texto'**
  String get tabCopyText;

  /// No description provided for @tabTextCopied.
  ///
  /// In pt, this message translates to:
  /// **'Texto copiado'**
  String get tabTextCopied;

  /// No description provided for @tabShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Divisão da conta'**
  String get tabShareSubject;

  /// No description provided for @tabShareFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o compartilhamento. Copie o texto.'**
  String get tabShareFailed;

  /// No description provided for @tabCardHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional: petiscos, serviço e divisão da conta.'**
  String get tabCardHint;

  /// No description provided for @tabCardTotalPartial.
  ///
  /// In pt, this message translates to:
  /// **'Total da comanda (parcial): {amount}'**
  String tabCardTotalPartial(String amount);

  /// No description provided for @tabCardTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total da comanda: {amount}'**
  String tabCardTotal(String amount);

  /// No description provided for @tabCardShareProv.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte da comanda (provisória): {amount}'**
  String tabCardShareProv(String amount);

  /// No description provided for @tabCardShare.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte da comanda: {amount}'**
  String tabCardShare(String amount);

  /// No description provided for @tabCardLineTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total {amount}'**
  String tabCardLineTotal(String amount);

  /// No description provided for @tabCardLineKnown.
  ///
  /// In pt, this message translates to:
  /// **'Total conhecido {amount}'**
  String tabCardLineKnown(String amount);

  /// No description provided for @tabCardLineTotalShare.
  ///
  /// In pt, this message translates to:
  /// **'Total {amount} · sua parte {mine}'**
  String tabCardLineTotalShare(String amount, String mine);

  /// No description provided for @tabCardLineKnownShare.
  ///
  /// In pt, this message translates to:
  /// **'Total conhecido {amount} · sua parte {mine}'**
  String tabCardLineKnownShare(String amount, String mine);

  /// No description provided for @statsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas'**
  String get statsTitle;

  /// No description provided for @statsPresetDays.
  ///
  /// In pt, this message translates to:
  /// **'{days} dias'**
  String statsPresetDays(String days);

  /// No description provided for @statsPresetCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado'**
  String get statsPresetCustom;

  /// No description provided for @statsRangeLine.
  ///
  /// In pt, this message translates to:
  /// **'{from} a {to} · {days, plural, =1{1 dia} other{{days} dias}}'**
  String statsRangeLine(String from, String to, int days);

  /// No description provided for @statsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada registrado neste período'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso só quer dizer que não há registros aqui, não que não houve rolê.'**
  String get statsEmptyBody;

  /// No description provided for @statsSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo'**
  String get statsSummary;

  /// No description provided for @statsOutingsOfPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Rolês do período'**
  String get statsOutingsOfPeriod;

  /// No description provided for @statsDrinksLogged.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas registradas'**
  String get statsDrinksLogged;

  /// No description provided for @statsDrinksOfPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas do período'**
  String get statsDrinksOfPeriod;

  /// No description provided for @statsPricedRecords.
  ///
  /// In pt, this message translates to:
  /// **'Registros com preço'**
  String get statsPricedRecords;

  /// No description provided for @statsVolumeSection.
  ///
  /// In pt, this message translates to:
  /// **'Volume pessoal informado'**
  String get statsVolumeSection;

  /// No description provided for @statsAlcoholicVolume.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas com álcool'**
  String get statsAlcoholicVolume;

  /// No description provided for @statsNonAlcoholicVolume.
  ///
  /// In pt, this message translates to:
  /// **'Água e sem álcool'**
  String get statsNonAlcoholicVolume;

  /// No description provided for @statsUnknownVolume.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro sem volume: não entra nas somas} other{{count} registros sem volume: não entram nas somas}}'**
  String statsUnknownVolume(int count);

  /// No description provided for @statsAlcoholSection.
  ///
  /// In pt, this message translates to:
  /// **'Álcool calculado'**
  String get statsAlcoholSection;

  /// No description provided for @statsPureAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'Álcool puro dos dados conhecidos'**
  String get statsPureAlcohol;

  /// No description provided for @statsIncompleteAlcohol.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro com teor ou quantidade desconhecidos} other{{count} registros com teor ou quantidade desconhecidos}}'**
  String statsIncompleteAlcohol(int count);

  /// No description provided for @statsAlcoholNote.
  ///
  /// In pt, this message translates to:
  /// **'Volume × teor (ou quantidade × teor dos componentes dos drinks). Não é concentração no sangue.'**
  String get statsAlcoholNote;

  /// No description provided for @statsAlcoholByCategory.
  ///
  /// In pt, this message translates to:
  /// **'Com álcool, por categoria'**
  String get statsAlcoholByCategory;

  /// No description provided for @statsNoVolumeNote.
  ///
  /// In pt, this message translates to:
  /// **'{count} sem volume'**
  String statsNoVolumeNote(String count);

  /// No description provided for @statsNonAlcoholicSection.
  ///
  /// In pt, this message translates to:
  /// **'Água e sem álcool, à parte'**
  String get statsNonAlcoholicSection;

  /// No description provided for @statsTopPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Locais mais visitados'**
  String get statsTopPlaces;

  /// No description provided for @statsPlacesNote.
  ///
  /// In pt, this message translates to:
  /// **'Locais só são agrupados quando são o mesmo local salvo; nomes parecidos não são unidos.'**
  String get statsPlacesNote;

  /// No description provided for @statsMoods.
  ///
  /// In pt, this message translates to:
  /// **'Relatos pós-rolê'**
  String get statsMoods;

  /// No description provided for @statsNoMoods.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum relato neste período.'**
  String get statsNoMoods;

  /// No description provided for @statsWithoutMood.
  ///
  /// In pt, this message translates to:
  /// **'{count} sem relato.'**
  String statsWithoutMood(String count);

  /// No description provided for @statsMoodsNote.
  ///
  /// In pt, this message translates to:
  /// **'Relatos são pessoais: não medem tolerância e não indicam um limite seguro.'**
  String get statsMoodsNote;

  /// No description provided for @statsPrevious.
  ///
  /// In pt, this message translates to:
  /// **'Período anterior'**
  String get statsPrevious;

  /// No description provided for @statsFootnote.
  ///
  /// In pt, this message translates to:
  /// **'Dia sem registro não significa dia sem beber: os números refletem só o que foi registrado.'**
  String get statsFootnote;

  /// No description provided for @statsNoBaseline.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{Sem base de comparação: não há rolês registrados no dia anterior a este período.} other{Sem base de comparação: não há rolês registrados nos {days} dias anteriores a este período.}}'**
  String statsNoBaseline(int days);

  /// No description provided for @statsComparedTo.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{Comparado ao dia imediatamente antes ({from} a {to}).} other{Comparado aos {days} dias imediatamente antes ({from} a {to}).}}'**
  String statsComparedTo(int days, String from, String to);

  /// No description provided for @statsIncompleteCompare.
  ///
  /// In pt, this message translates to:
  /// **'Há bebidas sem preço em um dos períodos: o gasto real pode ser maior que o informado.'**
  String get statsIncompleteCompare;

  /// No description provided for @statsLineBefore.
  ///
  /// In pt, this message translates to:
  /// **'{now}  (antes: {before})'**
  String statsLineBefore(String now, String before);

  /// No description provided for @statsNoSavedPlace.
  ///
  /// In pt, this message translates to:
  /// **'Sem local salvo'**
  String get statsNoSavedPlace;

  /// No description provided for @statsSavedPlaceFallback.
  ///
  /// In pt, this message translates to:
  /// **'Local salvo'**
  String get statsSavedPlaceFallback;

  /// No description provided for @recordsUnknownVolume.
  ///
  /// In pt, this message translates to:
  /// **'volume desconhecido'**
  String get recordsUnknownVolume;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum rolê encerrado'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Quando você encerrar um rolê, ele aparece aqui.'**
  String get historyEmptyBody;

  /// No description provided for @historySearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar pelo nome do local'**
  String get historySearchHint;

  /// No description provided for @historyNoMatchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum rolê com esses filtros'**
  String get historyNoMatchTitle;

  /// No description provided for @historyNoMatchBody.
  ///
  /// In pt, this message translates to:
  /// **'Tente outro nome, período ou tipo.'**
  String get historyNoMatchBody;

  /// No description provided for @historyPeriodAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get historyPeriodAll;

  /// No description provided for @historyPeriodMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get historyPeriodMonth;

  /// No description provided for @historyAllTypes.
  ///
  /// In pt, this message translates to:
  /// **'Todos os tipos'**
  String get historyAllTypes;

  /// No description provided for @historyNoValues.
  ///
  /// In pt, this message translates to:
  /// **'Sem valores'**
  String get historyNoValues;

  /// No description provided for @exportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar meus dados'**
  String get exportTitle;

  /// No description provided for @exportIntro.
  ///
  /// In pt, this message translates to:
  /// **'Seus registros, do jeito que estão no aparelho. Nada é enviado a ninguém: você escolhe onde guardar. Nenhum dado de acesso ou sessão entra nos arquivos.'**
  String get exportIntro;

  /// No description provided for @exportJsonTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em JSON'**
  String get exportJsonTitle;

  /// No description provided for @exportJsonBody.
  ///
  /// In pt, this message translates to:
  /// **'Locais, rolês, bebidas, composições, comandas e suas bebidas próprias, com todos os detalhes. Chaves e códigos fixos, independentes do idioma do app.'**
  String get exportJsonBody;

  /// No description provided for @exportOutingsCsvTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rolês em CSV'**
  String get exportOutingsCsvTitle;

  /// No description provided for @exportOutingsCsvBody.
  ///
  /// In pt, this message translates to:
  /// **'Um resumo por rolê. Separador \";\", decimal com vírgula, UTF-8. Colunas e códigos fixos, independentes do idioma do app.'**
  String get exportOutingsCsvBody;

  /// No description provided for @exportDrinksCsvTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas em CSV'**
  String get exportDrinksCsvTitle;

  /// No description provided for @exportDrinksCsvBody.
  ///
  /// In pt, this message translates to:
  /// **'Uma linha por registro. Campo vazio = desconhecido, nunca zero. Colunas e códigos fixos, independentes do idioma do app.'**
  String get exportDrinksCsvBody;

  /// No description provided for @exportButton.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get exportButton;

  /// No description provided for @exportCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get exportCopy;

  /// No description provided for @exportCopied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado'**
  String get exportCopied;

  /// No description provided for @exportShareUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar não está disponível aqui. Use \"Copiar texto\" para guardar o conteúdo.'**
  String get exportShareUnavailable;

  /// No description provided for @exportFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o arquivo.'**
  String get exportFailed;

  /// No description provided for @exportJsonNote.
  ///
  /// In pt, this message translates to:
  /// **'Dados pessoais exportados pela própria pessoa. Valores em centavos, volumes em ml, horários em UTC. Campos nulos são desconhecidos, não zero.'**
  String get exportJsonNote;

  /// No description provided for @shareCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar resumo'**
  String get shareCardTitle;

  /// No description provided for @shareCardIntro.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o que aparece. O endereço e o seu relato nunca entram, e nada é publicado sozinho.'**
  String get shareCardIntro;

  /// No description provided for @shareCardWhat.
  ///
  /// In pt, this message translates to:
  /// **'O que mostrar'**
  String get shareCardWhat;

  /// No description provided for @shareCardPlaceName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do local'**
  String get shareCardPlaceName;

  /// No description provided for @shareCardPlaceNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Só o nome, nunca o endereço.'**
  String get shareCardPlaceNameHint;

  /// No description provided for @shareCardSpendHint.
  ///
  /// In pt, this message translates to:
  /// **'Há bebidas sem preço: o total é parcial.'**
  String get shareCardSpendHint;

  /// No description provided for @shareCardFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o compartilhamento. Você pode copiar o texto do resumo.'**
  String get shareCardFailed;

  /// No description provided for @shareCardCaptureFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar a imagem. Você pode copiar o texto do resumo.'**
  String get shareCardCaptureFailed;

  /// No description provided for @shareCardMyOuting.
  ///
  /// In pt, this message translates to:
  /// **'Meu rolê'**
  String get shareCardMyOuting;

  /// No description provided for @shareCardOthers.
  ///
  /// In pt, this message translates to:
  /// **'+ {count} outros'**
  String shareCardOthers(String count);

  /// No description provided for @shareCardSpendText.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado: {amount}'**
  String shareCardSpendText(String amount);

  /// No description provided for @shareCardSpendTextPartial.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado: {amount} (há bebidas sem preço)'**
  String shareCardSpendTextPartial(String amount);

  /// No description provided for @shareCardSpendCard.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado {amount}'**
  String shareCardSpendCard(String amount);

  /// No description provided for @shareCardSpendCardPartial.
  ///
  /// In pt, this message translates to:
  /// **'Gasto informado {amount} (parcial)'**
  String shareCardSpendCardPartial(String amount);

  /// No description provided for @trackingWeb.
  ///
  /// In pt, this message translates to:
  /// **'Não disponível no navegador: o acompanhamento fica só dentro do app.'**
  String get trackingWeb;

  /// No description provided for @trackingIosOld.
  ///
  /// In pt, this message translates to:
  /// **'Não disponível nesta versão do iOS (precisa do iOS 16.2 ou mais novo).'**
  String get trackingIosOld;

  /// No description provided for @trackingUnsupported.
  ///
  /// In pt, this message translates to:
  /// **'Não disponível neste aparelho.'**
  String get trackingUnsupported;

  /// No description provided for @trackingDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Desativado por você.'**
  String get trackingDisabled;

  /// No description provided for @trackingPermission.
  ///
  /// In pt, this message translates to:
  /// **'Permissão do sistema indisponível. Libere as notificações do Bebômetro nas configurações do aparelho.'**
  String get trackingPermission;

  /// No description provided for @trackingSystemOffIos.
  ///
  /// In pt, this message translates to:
  /// **'Desligado nos ajustes do iPhone (Atividades ao Vivo).'**
  String get trackingSystemOffIos;

  /// No description provided for @trackingSystemOffAndroid.
  ///
  /// In pt, this message translates to:
  /// **'Notificações desligadas nas configurações do aparelho.'**
  String get trackingSystemOffAndroid;

  /// No description provided for @trackingNoOuting.
  ///
  /// In pt, this message translates to:
  /// **'Disponível durante um rolê.'**
  String get trackingNoOuting;

  /// No description provided for @trackingHidden.
  ///
  /// In pt, this message translates to:
  /// **'Oculto neste rolê. Use \"{action}\" na tela do rolê.'**
  String trackingHidden(String action);

  /// No description provided for @trackingDismissed.
  ///
  /// In pt, this message translates to:
  /// **'Você removeu da tela bloqueada neste rolê. Use \"{action}\" na tela do rolê.'**
  String trackingDismissed(String action);

  /// No description provided for @trackingActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo agora.'**
  String get trackingActive;

  /// No description provided for @trackingPending.
  ///
  /// In pt, this message translates to:
  /// **'Ligado, mas ainda não apareceu. No iPhone ele só começa com o app aberto; abra o rolê.'**
  String get trackingPending;

  /// No description provided for @trackingAwaitingSave.
  ///
  /// In pt, this message translates to:
  /// **'aguardando registro'**
  String get trackingAwaitingSave;

  /// No description provided for @trackingNoPermissionToast.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão de notificações. Dá para liberar nas configurações do aparelho.'**
  String get trackingNoPermissionToast;

  /// No description provided for @trackingEnable.
  ///
  /// In pt, this message translates to:
  /// **'Ativar acompanhamento'**
  String get trackingEnable;

  /// No description provided for @trackingEnableHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostra o tempo e a contagem do rolê em andamento na tela bloqueada. Sem som nem vibração.'**
  String get trackingEnableHint;

  /// No description provided for @trackingShowSpend.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar gastos'**
  String get trackingShowSpend;

  /// No description provided for @trackingShowSpendHint.
  ///
  /// In pt, this message translates to:
  /// **'Quanto você informou ter gasto em bebidas, não o total da mesa.'**
  String get trackingShowSpendHint;

  /// No description provided for @trackingShowPlace.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar nome do local'**
  String get trackingShowPlace;

  /// No description provided for @trackingShowPlaceHint.
  ///
  /// In pt, this message translates to:
  /// **'Desligado, aparece só \"Rolê em andamento\". O endereço nunca aparece.'**
  String get trackingShowPlaceHint;

  /// No description provided for @trackingCountNote.
  ///
  /// In pt, this message translates to:
  /// **'O contador mostra quantos registros de bebida alcoólica você fez (água não conta; uma garrafa dividida é um registro). Não são doses nem medem alcoolemia. O sistema pode encerrar a exibição sozinho depois de algumas horas, sem encerrar o rolê.'**
  String get trackingCountNote;

  /// No description provided for @trackingOfferBody.
  ///
  /// In pt, this message translates to:
  /// **'Veja o tempo e a contagem de bebidas do rolê sem abrir o app. Por padrão não mostra gastos nem o nome do local. Sem som nem vibração, e dá para ocultar em cada rolê ou desligar quando quiser em Configurações.'**
  String get trackingOfferBody;

  /// No description provided for @trackingOfferActivate.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get trackingOfferActivate;

  /// No description provided for @trackingTitleFallback.
  ///
  /// In pt, this message translates to:
  /// **'Rolê em andamento'**
  String get trackingTitleFallback;

  /// No description provided for @trackingCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum registro de bebida alcoólica} =1{1 registro de bebida alcoólica} other{{count} registros de bebida alcoólica}}'**
  String trackingCount(int count);

  /// No description provided for @trackingSpend.
  ///
  /// In pt, this message translates to:
  /// **'{amount} informados'**
  String trackingSpend(String amount);

  /// No description provided for @trackingSpendUnpriced.
  ///
  /// In pt, this message translates to:
  /// **'{amount} informados · {count} sem preço'**
  String trackingSpendUnpriced(String amount, String count);

  /// No description provided for @trackingOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get trackingOpen;

  /// No description provided for @trackingAnother.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma'**
  String get trackingAnother;

  /// No description provided for @trackingAnotherWith.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma · {next}'**
  String trackingAnotherWith(String next);

  /// No description provided for @trackingAnotherA11y.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma, {next}'**
  String trackingAnotherA11y(String next);

  /// No description provided for @trackingWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get trackingWater;

  /// No description provided for @trackingChannelDescription.
  ///
  /// In pt, this message translates to:
  /// **'Tempo e contagem do rolê na tela bloqueada. Sem som nem vibração.'**
  String get trackingChannelDescription;

  /// No description provided for @vesselCan.
  ///
  /// In pt, this message translates to:
  /// **'Lata'**
  String get vesselCan;

  /// No description provided for @vesselLongNeck.
  ///
  /// In pt, this message translates to:
  /// **'Long neck'**
  String get vesselLongNeck;

  /// No description provided for @vesselBottle.
  ///
  /// In pt, this message translates to:
  /// **'Garrafa'**
  String get vesselBottle;

  /// No description provided for @vesselBeerGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo de cerveja'**
  String get vesselBeerGlass;

  /// No description provided for @vesselDraftMug.
  ///
  /// In pt, this message translates to:
  /// **'Copo de chopp'**
  String get vesselDraftMug;

  /// No description provided for @vesselShot.
  ///
  /// In pt, this message translates to:
  /// **'Dose'**
  String get vesselShot;

  /// No description provided for @vesselWineGlass.
  ///
  /// In pt, this message translates to:
  /// **'Taça de vinho'**
  String get vesselWineGlass;

  /// No description provided for @vesselCocktailGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo de drink'**
  String get vesselCocktailGlass;

  /// No description provided for @vesselWaterGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo de água'**
  String get vesselWaterGlass;

  /// No description provided for @vesselGlass.
  ///
  /// In pt, this message translates to:
  /// **'Copo'**
  String get vesselGlass;

  /// No description provided for @scenarioBar.
  ///
  /// In pt, this message translates to:
  /// **'Bar/boteco'**
  String get scenarioBar;

  /// No description provided for @scenarioClub.
  ///
  /// In pt, this message translates to:
  /// **'Balada'**
  String get scenarioClub;

  /// No description provided for @scenarioBarbecue.
  ///
  /// In pt, this message translates to:
  /// **'Churrasco'**
  String get scenarioBarbecue;

  /// No description provided for @scenarioHome.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get scenarioHome;

  /// No description provided for @scenarioBeach.
  ///
  /// In pt, this message translates to:
  /// **'Praia'**
  String get scenarioBeach;

  /// No description provided for @scenarioRestaurant.
  ///
  /// In pt, this message translates to:
  /// **'Restaurante'**
  String get scenarioRestaurant;

  /// No description provided for @tableSemanticsMany.
  ///
  /// In pt, this message translates to:
  /// **'{count} registros de {name}'**
  String tableSemanticsMany(String count, String name);

  /// No description provided for @tableSemanticsSharedPart.
  ///
  /// In pt, this message translates to:
  /// **'sua parte de bebida compartilhada'**
  String get tableSemanticsSharedPart;

  /// No description provided for @tableSemanticsTap.
  ///
  /// In pt, this message translates to:
  /// **'Toque para ver os detalhes.'**
  String get tableSemanticsTap;

  /// No description provided for @tableOthersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Outros registros ({count})'**
  String tableOthersTitle(String count);

  /// No description provided for @tableGroupTitle.
  ///
  /// In pt, this message translates to:
  /// **'{count} × {name}'**
  String tableGroupTitle(String count, String name);

  /// No description provided for @tableSemanticsOuting.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Mesa do rolê com 1 registro} other{Mesa do rolê com {count} registros}}'**
  String tableSemanticsOuting(int count);

  /// No description provided for @tableSemanticsTable.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Mesa com 1 registro} other{Mesa com {count} registros}}'**
  String tableSemanticsTable(int count);

  /// No description provided for @tableEmpty.
  ///
  /// In pt, this message translates to:
  /// **'A mesa está vazia'**
  String get tableEmpty;

  /// No description provided for @tableOverflowSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Mais {count} registros. Toque para ver a lista.'**
  String tableOverflowSemantics(String count);

  /// No description provided for @tableYours.
  ///
  /// In pt, this message translates to:
  /// **'{amount} seus'**
  String tableYours(String amount);

  /// No description provided for @tableYourVolume.
  ///
  /// In pt, this message translates to:
  /// **'Seu volume'**
  String get tableYourVolume;

  /// No description provided for @tableSharedLine.
  ///
  /// In pt, this message translates to:
  /// **'Sua parte: {mine} de {total} ({count} pessoas)'**
  String tableSharedLine(String mine, String total, String count);

  /// No description provided for @tableRecipeAdjusted.
  ///
  /// In pt, this message translates to:
  /// **'Receita ajustada'**
  String get tableRecipeAdjusted;

  /// No description provided for @tableScenarioTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cenário da mesa'**
  String get tableScenarioTitle;

  /// No description provided for @tableScenarioNote.
  ///
  /// In pt, this message translates to:
  /// **'Só muda a ilustração. O local, o tipo e os registros do rolê continuam iguais.'**
  String get tableScenarioNote;

  /// No description provided for @tableAboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre a mesa'**
  String get tableAboutTitle;

  /// No description provided for @tableAboutBody.
  ///
  /// In pt, this message translates to:
  /// **'Animação ilustrativa das bebidas registradas.\n\nOs recipientes esvaziam só como efeito visual, com base no horário do registro. Isso não mede quanto você bebeu, não indica álcool no corpo e não muda nenhum registro: os totais vêm apenas do que você informou.'**
  String get tableAboutBody;

  /// No description provided for @tableUnderstood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get tableUnderstood;

  /// No description provided for @glassSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Copão: {total} de volume informado, em uma escala de até {scale}{unknown, plural, =0{} =1{, mais 1 registro sem volume} other{, mais {unknown} registros sem volume}}.'**
  String glassSemantics(String total, String scale, int unknown);

  /// No description provided for @glassVolumeReported.
  ///
  /// In pt, this message translates to:
  /// **'Volume informado'**
  String get glassVolumeReported;

  /// No description provided for @glassScale.
  ///
  /// In pt, this message translates to:
  /// **'Escala: até {scale}'**
  String glassScale(String scale);

  /// No description provided for @glassAlcoholic.
  ///
  /// In pt, this message translates to:
  /// **'Com álcool: {amount}'**
  String glassAlcoholic(String amount);

  /// No description provided for @glassOther.
  ///
  /// In pt, this message translates to:
  /// **'Água e sem álcool: {amount}'**
  String glassOther(String amount);

  /// No description provided for @glassNoVolume.
  ///
  /// In pt, this message translates to:
  /// **'+ {count} sem volume (não entram)'**
  String glassNoVolume(String count);

  /// No description provided for @glassNote.
  ///
  /// In pt, this message translates to:
  /// **'Só uma forma de ver a soma dos volumes registrados. Não representa álcool no corpo, capacidade nem meta.'**
  String get glassNote;

  /// No description provided for @tipNoSensor.
  ///
  /// In pt, this message translates to:
  /// **'Sem sensor de movimento. Arraste para inclinar.'**
  String get tipNoSensor;

  /// No description provided for @tipHintTilt.
  ///
  /// In pt, this message translates to:
  /// **'Incline o celular para mexer a cerveja.'**
  String get tipHintTilt;

  /// No description provided for @tipHintDrag.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para inclinar.'**
  String get tipHintDrag;

  /// No description provided for @tipNoReading.
  ///
  /// In pt, this message translates to:
  /// **'Sem leitura de movimento. Arraste para inclinar.'**
  String get tipNoReading;

  /// No description provided for @tipReactMotion.
  ///
  /// In pt, this message translates to:
  /// **'Reagir ao movimento'**
  String get tipReactMotion;

  /// No description provided for @tipWebNote.
  ///
  /// In pt, this message translates to:
  /// **'Não disponível no navegador: arraste para inclinar.'**
  String get tipWebNote;

  /// No description provided for @tipOffNote.
  ///
  /// In pt, this message translates to:
  /// **'Desligado, você arrasta o dedo para inclinar.'**
  String get tipOffNote;

  /// No description provided for @tipBubbles.
  ///
  /// In pt, this message translates to:
  /// **'Bolhas e ondas'**
  String get tipBubbles;

  /// No description provided for @tipBubblesNote.
  ///
  /// In pt, this message translates to:
  /// **'Desligue para uma cerveja mais calma.'**
  String get tipBubblesNote;

  /// No description provided for @tipLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nivelar'**
  String get tipLevel;

  /// No description provided for @tipVisualNote.
  ///
  /// In pt, this message translates to:
  /// **'Só visual: o copo não mede nem registra consumo, e encher não é meta.'**
  String get tipVisualNote;

  /// No description provided for @tipSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Cerveja que ocupa a tela. Incline o celular para mexer o líquido. Só visual, não registra consumo.'**
  String get tipSemantics;

  /// No description provided for @tipRefill.
  ///
  /// In pt, this message translates to:
  /// **'Reencher'**
  String get tipRefill;

  /// No description provided for @tipRefillAgain.
  ///
  /// In pt, this message translates to:
  /// **'Encher novamente'**
  String get tipRefillAgain;

  /// No description provided for @gameNeverTitle.
  ///
  /// In pt, this message translates to:
  /// **'Eu nunca'**
  String get gameNeverTitle;

  /// No description provided for @gameNeverDesc.
  ///
  /// In pt, this message translates to:
  /// **'Quem já fez, conta. Sem pressão.'**
  String get gameNeverDesc;

  /// No description provided for @gameMostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem é mais provável'**
  String get gameMostTitle;

  /// No description provided for @gameMostDesc.
  ///
  /// In pt, this message translates to:
  /// **'A turma aponta quem combina mais com a frase.'**
  String get gameMostDesc;

  /// No description provided for @gameTruthTitle.
  ///
  /// In pt, this message translates to:
  /// **'Verdade ou desafio'**
  String get gameTruthTitle;

  /// No description provided for @gameTruthDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cada um na sua vez, com opção de pular.'**
  String get gameTruthDesc;

  /// No description provided for @gameModeLight.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get gameModeLight;

  /// No description provided for @gameModeAdult.
  ///
  /// In pt, this message translates to:
  /// **'+18'**
  String get gameModeAdult;

  /// No description provided for @gameKindCard.
  ///
  /// In pt, this message translates to:
  /// **'Carta'**
  String get gameKindCard;

  /// No description provided for @gameKindTruth.
  ///
  /// In pt, this message translates to:
  /// **'Verdade'**
  String get gameKindTruth;

  /// No description provided for @gameKindDare.
  ///
  /// In pt, this message translates to:
  /// **'Desafio'**
  String get gameKindDare;

  /// No description provided for @resenhaIntro.
  ///
  /// In pt, this message translates to:
  /// **'Jogos para a mesa, sem internet e sem conta. As cartas não pedem para beber e não registram nenhuma bebida.'**
  String get resenhaIntro;

  /// No description provided for @resenhaInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Partida em andamento'**
  String get resenhaInProgress;

  /// No description provided for @resenhaSession.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 participante · modo {mode}} other{{count} participantes · modo {mode}}}'**
  String resenhaSession(int count, String mode);

  /// No description provided for @resenhaResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get resenhaResume;

  /// No description provided for @resenhaGames.
  ///
  /// In pt, this message translates to:
  /// **'Jogos'**
  String get resenhaGames;

  /// No description provided for @resenhaPlay.
  ///
  /// In pt, this message translates to:
  /// **'Brincadeira'**
  String get resenhaPlay;

  /// No description provided for @resenhaTipTitle.
  ///
  /// In pt, this message translates to:
  /// **'Virar o copo'**
  String get resenhaTipTitle;

  /// No description provided for @resenhaTipBody.
  ///
  /// In pt, this message translates to:
  /// **'A tela vira um copo: incline o celular. Só visual.'**
  String get resenhaTipBody;

  /// No description provided for @resenhaCards.
  ///
  /// In pt, this message translates to:
  /// **'Cartas'**
  String get resenhaCards;

  /// No description provided for @resenhaMyCards.
  ///
  /// In pt, this message translates to:
  /// **'Minhas cartas'**
  String get resenhaMyCards;

  /// No description provided for @resenhaMyCardsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma criada por você} =1{1 criada por você} other{{count} criadas por você}}'**
  String resenhaMyCardsCount(int count);

  /// No description provided for @gameAlreadyPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Já existe alguém com esse apelido.'**
  String get gameAlreadyPlayer;

  /// No description provided for @gameMaxPlayers.
  ///
  /// In pt, this message translates to:
  /// **'No máximo 20 participantes.'**
  String get gameMaxPlayers;

  /// No description provided for @gameWhoPlays.
  ///
  /// In pt, this message translates to:
  /// **'Quem vai jogar?'**
  String get gameWhoPlays;

  /// No description provided for @gameAddPlayerTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar participante'**
  String get gameAddPlayerTooltip;

  /// No description provided for @gameNeedPlayers.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Adicione pelo menos 1 participante.} other{Adicione pelo menos {count} participantes.}}'**
  String gameNeedPlayers(int count);

  /// No description provided for @gameRemovePlayer.
  ///
  /// In pt, this message translates to:
  /// **'Remover {name}'**
  String gameRemovePlayer(String name);

  /// No description provided for @gameMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo'**
  String get gameMode;

  /// No description provided for @gameLightNote.
  ///
  /// In pt, this message translates to:
  /// **'Sem conteúdo sexual. Para qualquer turma.'**
  String get gameLightNote;

  /// No description provided for @gameAdultNote.
  ///
  /// In pt, this message translates to:
  /// **'Mistura as cartas leves com flerte e humor para adultos. Nada explícito, e tudo pode ser pulado sem punição.'**
  String get gameAdultNote;

  /// No description provided for @gameAdultConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmo que todas as pessoas que vão jogar são adultas (18+) e toparam o modo +18.'**
  String get gameAdultConfirm;

  /// No description provided for @gamePoints.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get gamePoints;

  /// No description provided for @gameCountPoints.
  ///
  /// In pt, this message translates to:
  /// **'Contar pontos (opcional)'**
  String get gameCountPoints;

  /// No description provided for @gameCountPointsHint.
  ///
  /// In pt, this message translates to:
  /// **'Dá para jogar só na conversa, sem placar.'**
  String get gameCountPointsHint;

  /// No description provided for @gameNoDrinkNote.
  ///
  /// In pt, this message translates to:
  /// **'As cartas nunca pedem para beber, virar doses ou acumular bebidas, e nada aqui registra bebidas no seu rolê.'**
  String get gameNoDrinkNote;

  /// No description provided for @gameStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get gameStart;

  /// No description provided for @gameFinishTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar a partida?'**
  String get gameFinishTitle;

  /// No description provided for @gameFinishBody.
  ///
  /// In pt, this message translates to:
  /// **'Ela não ficará salva. Para só dar uma pausa, volte e retome depois.'**
  String get gameFinishBody;

  /// No description provided for @gameKeepPlaying.
  ///
  /// In pt, this message translates to:
  /// **'Continuar jogando'**
  String get gameKeepPlaying;

  /// No description provided for @gameFinish.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get gameFinish;

  /// No description provided for @gameModePill.
  ///
  /// In pt, this message translates to:
  /// **'Modo {mode}'**
  String gameModePill(String mode);

  /// No description provided for @gameCardsLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 carta restante} other{{count} cartas restantes}}'**
  String gameCardsLeft(int count);

  /// No description provided for @gameOutOfCards.
  ///
  /// In pt, this message translates to:
  /// **'Acabaram as cartas'**
  String get gameOutOfCards;

  /// No description provided for @gameOutOfCardsHint.
  ///
  /// In pt, this message translates to:
  /// **'Dá para embaralhar tudo de novo ou encerrar a partida.'**
  String get gameOutOfCardsHint;

  /// No description provided for @gameReshuffle.
  ///
  /// In pt, this message translates to:
  /// **'Embaralhar de novo'**
  String get gameReshuffle;

  /// No description provided for @gameTurnOf.
  ///
  /// In pt, this message translates to:
  /// **'Vez de {name}'**
  String gameTurnOf(String name);

  /// No description provided for @gameTruthOrDareQ.
  ///
  /// In pt, this message translates to:
  /// **'Verdade ou desafio?'**
  String get gameTruthOrDareQ;

  /// No description provided for @gameNoTruthLeft.
  ///
  /// In pt, this message translates to:
  /// **'Acabaram as cartas de verdade. Escolha outra.'**
  String get gameNoTruthLeft;

  /// No description provided for @gameNoDareLeft.
  ///
  /// In pt, this message translates to:
  /// **'Acabaram as cartas de desafio. Escolha outra.'**
  String get gameNoDareLeft;

  /// No description provided for @gameWhoReads.
  ///
  /// In pt, this message translates to:
  /// **'Quem lê: {name}'**
  String gameWhoReads(String name);

  /// No description provided for @gameOptional.
  ///
  /// In pt, this message translates to:
  /// **'Opcional: pode pular sem punição.'**
  String get gameOptional;

  /// No description provided for @gameTapToScore.
  ///
  /// In pt, this message translates to:
  /// **'Toque no nome para somar 1 ponto'**
  String get gameTapToScore;

  /// No description provided for @gamePlusOne.
  ///
  /// In pt, this message translates to:
  /// **'+1 para {name}'**
  String gamePlusOne(String name);

  /// No description provided for @gameSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get gameSkip;

  /// No description provided for @gameNext.
  ///
  /// In pt, this message translates to:
  /// **'Próxima'**
  String get gameNext;

  /// No description provided for @gameSavedNote.
  ///
  /// In pt, this message translates to:
  /// **'A partida fica salva: você pode sair e retomar em {hub}.'**
  String gameSavedNote(String hub);

  /// No description provided for @gameNewCard.
  ///
  /// In pt, this message translates to:
  /// **'Nova carta'**
  String get gameNewCard;

  /// No description provided for @gameCardHintNever.
  ///
  /// In pt, this message translates to:
  /// **'Eu nunca…'**
  String get gameCardHintNever;

  /// No description provided for @gameCardHintMost.
  ///
  /// In pt, this message translates to:
  /// **'Quem é mais provável de…'**
  String get gameCardHintMost;

  /// No description provided for @gameCardText.
  ///
  /// In pt, this message translates to:
  /// **'Texto da carta'**
  String get gameCardText;

  /// No description provided for @gameCardRules.
  ///
  /// In pt, this message translates to:
  /// **'Sem exposição, gravação, coerção, direção, violência, atividades perigosas ou beber como penalidade.'**
  String get gameCardRules;

  /// No description provided for @gameCardCreated.
  ///
  /// In pt, this message translates to:
  /// **'Carta criada'**
  String get gameCardCreated;

  /// No description provided for @gameCardDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir esta carta?'**
  String get gameCardDeleteTitle;

  /// No description provided for @gameCardsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma carta sua ainda'**
  String get gameCardsEmptyTitle;

  /// No description provided for @gameCardsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Crie cartas para os seus jogos. Elas entram no sorteio das próximas partidas.'**
  String get gameCardsEmptyBody;

  /// No description provided for @gameCardDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir carta'**
  String get gameCardDelete;

  /// No description provided for @gameCardLine.
  ///
  /// In pt, this message translates to:
  /// **'{game} · {mode}'**
  String gameCardLine(String game, String mode);

  /// No description provided for @gameCardLineKind.
  ///
  /// In pt, this message translates to:
  /// **'{game} · {mode} · {kind}'**
  String gameCardLineKind(String game, String mode, String kind);

  /// No description provided for @gameCardNeedText.
  ///
  /// In pt, this message translates to:
  /// **'Escreva o texto da carta.'**
  String get gameCardNeedText;

  /// No description provided for @gameCardTooLong.
  ///
  /// In pt, this message translates to:
  /// **'Texto longo demais.'**
  String get gameCardTooLong;

  /// No description provided for @provenanceOfficial.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante / ficha oficial'**
  String get provenanceOfficial;

  /// No description provided for @provenanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rótulo em fonte secundária'**
  String get provenanceLabel;

  /// No description provided for @provenancePackagingRegistry.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro público de embalagem'**
  String get provenancePackagingRegistry;

  /// No description provided for @provenanceSecondary.
  ///
  /// In pt, this message translates to:
  /// **'Fonte secundária'**
  String get provenanceSecondary;

  /// No description provided for @provenanceRecipe.
  ///
  /// In pt, this message translates to:
  /// **'Receita de referência'**
  String get provenanceRecipe;

  /// No description provided for @provenanceUser.
  ///
  /// In pt, this message translates to:
  /// **'Informação sua'**
  String get provenanceUser;

  /// No description provided for @provenanceSuggestion.
  ///
  /// In pt, this message translates to:
  /// **'Volume sugerido'**
  String get provenanceSuggestion;

  /// No description provided for @provenanceGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Referência genérica'**
  String get provenanceGeneric;

  /// No description provided for @provenanceGeneral.
  ///
  /// In pt, this message translates to:
  /// **'Fonte geral do produto'**
  String get provenanceGeneral;

  /// No description provided for @provenanceSuggestionLine.
  ///
  /// In pt, this message translates to:
  /// **'Tamanhos comuns para facilitar o registro, não embalagens documentadas deste produto.'**
  String get provenanceSuggestionLine;

  /// No description provided for @aboutDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre estes dados'**
  String get aboutDataTitle;

  /// No description provided for @aboutDataFallback.
  ///
  /// In pt, this message translates to:
  /// **'Sem fonte específica para este campo; vale a fonte geral do produto.'**
  String get aboutDataFallback;

  /// No description provided for @aboutDataGeneralTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fonte geral do produto'**
  String get aboutDataGeneralTitle;

  /// No description provided for @aboutDataVariantsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Teores documentados (sem média)'**
  String get aboutDataVariantsTitle;

  /// No description provided for @aboutDataDivergence.
  ///
  /// In pt, this message translates to:
  /// **'As fontes divergem sobre o teor'**
  String get aboutDataDivergence;

  /// No description provided for @aboutDataRegistryNote.
  ///
  /// In pt, this message translates to:
  /// **'O cadastro mostra que a embalagem existiu no mercado; não indica que esteja à venda hoje.'**
  String get aboutDataRegistryNote;

  /// No description provided for @aboutDataOpenFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o endereço. Copie e abra no navegador.'**
  String get aboutDataOpenFailed;

  /// No description provided for @aboutDataMarket.
  ///
  /// In pt, this message translates to:
  /// **'Mercado: {market}'**
  String aboutDataMarket(String market);

  /// No description provided for @aboutDataConsulted.
  ///
  /// In pt, this message translates to:
  /// **'Consultado em {date}'**
  String aboutDataConsulted(String date);

  /// No description provided for @pendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Registros pendentes'**
  String get pendingTitle;

  /// No description provided for @pendingIntro.
  ///
  /// In pt, this message translates to:
  /// **'Toques em \"Mais uma\" na tela bloqueada que não puderam ser registrados sozinhos. Nada entra no seu histórico sem você confirmar aqui.'**
  String get pendingIntro;

  /// No description provided for @pendingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro pendente.'**
  String get pendingEmpty;

  /// No description provided for @pendingReasonEnded.
  ///
  /// In pt, this message translates to:
  /// **'O rolê foi encerrado antes do registro. Revise para adicionar a ele.'**
  String get pendingReasonEnded;

  /// No description provided for @pendingReasonOutside.
  ///
  /// In pt, this message translates to:
  /// **'O horário do toque está fora do período do rolê. Ajuste o horário na revisão.'**
  String get pendingReasonOutside;

  /// No description provided for @pendingReasonNoDrink.
  ///
  /// In pt, this message translates to:
  /// **'Não dá para saber qual bebida repetir. Escolha a bebida e revise.'**
  String get pendingReasonNoDrink;

  /// No description provided for @pendingReasonFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Você pode tentar novamente.'**
  String get pendingReasonFailed;

  /// No description provided for @pendingReasonUnsupported.
  ///
  /// In pt, this message translates to:
  /// **'Esta versão do app não reconhece este pedido. Você pode descartá-lo.'**
  String get pendingReasonUnsupported;

  /// No description provided for @pendingReasonInReview.
  ///
  /// In pt, this message translates to:
  /// **'Em revisão.'**
  String get pendingReasonInReview;

  /// No description provided for @pendingDrinkUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Bebida não identificada'**
  String get pendingDrinkUnknown;

  /// No description provided for @pendingRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get pendingRetry;

  /// No description provided for @pendingRetryFailed.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não foi possível registrar.'**
  String get pendingRetryFailed;

  /// No description provided for @pendingSaved.
  ///
  /// In pt, this message translates to:
  /// **'Registrado.'**
  String get pendingSaved;

  /// No description provided for @pendingDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get pendingDiscard;

  /// No description provided for @pendingDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar este toque?'**
  String get pendingDiscardTitle;

  /// No description provided for @pendingDiscardBody.
  ///
  /// In pt, this message translates to:
  /// **'O pedido some desta lista. Nenhum registro já salvo é apagado.'**
  String get pendingDiscardBody;

  /// No description provided for @pendingDiscarded.
  ///
  /// In pt, this message translates to:
  /// **'Descartado.'**
  String get pendingDiscarded;

  /// No description provided for @pendingNoDrinkToChoose.
  ///
  /// In pt, this message translates to:
  /// **'Este rolê não tem bebida alcoólica registrada para repetir.'**
  String get pendingNoDrinkToChoose;

  /// No description provided for @pendingChooseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual bebida era?'**
  String get pendingChooseTitle;

  /// No description provided for @pendingChooseDrink.
  ///
  /// In pt, this message translates to:
  /// **'Escolher bebida'**
  String get pendingChooseDrink;

  /// No description provided for @pendingReviewAdd.
  ///
  /// In pt, this message translates to:
  /// **'Revisar e adicionar'**
  String get pendingReviewAdd;

  /// No description provided for @pendingNotice.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 toque da tela bloqueada aguarda você} other{{count} toques da tela bloqueada aguardam você}}'**
  String pendingNotice(int count);

  /// No description provided for @pendingOutingOn.
  ///
  /// In pt, this message translates to:
  /// **'Rolê de {date}'**
  String pendingOutingOn(String date);

  /// No description provided for @pendingTappedAt.
  ///
  /// In pt, this message translates to:
  /// **'Toque em {time}'**
  String pendingTappedAt(String time);

  /// No description provided for @pendingReviewNote.
  ///
  /// In pt, this message translates to:
  /// **'Toque original na tela bloqueada: {time}'**
  String pendingReviewNote(String time);

  /// No description provided for @entryFromLockScreen.
  ///
  /// In pt, this message translates to:
  /// **'Adicionado pela tela bloqueada'**
  String get entryFromLockScreen;

  /// No description provided for @entryOriginalTap.
  ///
  /// In pt, this message translates to:
  /// **'Toque original: {time}'**
  String entryOriginalTap(String time);

  /// No description provided for @entryOriginalTapCorrected.
  ///
  /// In pt, this message translates to:
  /// **'Horário corrigido. Toque original: {time}'**
  String entryOriginalTapCorrected(String time);
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
