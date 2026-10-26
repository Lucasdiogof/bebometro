// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get accountAllConfirmed => 'Tudo confirmado na nuvem';

  @override
  String get accountAllSentNow => 'Tudo enviado. Agora você pode sair.';

  @override
  String get accountChangePassword => 'Alterar senha';

  @override
  String get accountCloud => 'Nuvem';

  @override
  String get accountCodeField => 'Código recebido por e-mail';

  @override
  String get accountCodeSent => 'Enviamos um código para o seu e-mail.';

  @override
  String accountConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações para resolver',
      one: '1 alteração para resolver',
    );
    return '$_temp0';
  }

  @override
  String get accountDelete => 'Excluir conta';

  @override
  String get accountEditName => 'Editar nome';

  @override
  String get accountEmailConfirmed => 'E-mail confirmado';

  @override
  String get accountEmailNotConfirmed => 'E-mail não confirmado';

  @override
  String get accountHistoryNotDone =>
      'O histórico da nuvem ainda não terminou de chegar neste aparelho.';

  @override
  String accountLastSync(String when) {
    return 'Última sincronização concluída: $when';
  }

  @override
  String get accountLastSyncNever =>
      'Última sincronização concluída: ainda não houve.';

  @override
  String get accountName => 'Nome';

  @override
  String get accountNameUpdated => 'Nome atualizado';

  @override
  String get accountNoName => 'Sem nome';

  @override
  String get accountNothingWaiting => 'Nada aguardando envio.';

  @override
  String accountOnlyHerePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Também $count fotos aguardando envio.',
      one: 'Também 1 foto aguardando envio.',
    );
    return '$_temp0';
  }

  @override
  String accountOnlyHereRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvo só neste aparelho por enquanto: $count registros.',
      one: 'Salvo só neste aparelho por enquanto: 1 registro.',
    );
    return '$_temp0';
  }

  @override
  String get accountPasswordChanged => 'Senha alterada';

  @override
  String get accountResendCode => 'Enviar código de novo';

  @override
  String get accountRestoring => 'Recuperando…';

  @override
  String get accountSaveNewPassword => 'Salvar nova senha';

  @override
  String get accountSession => 'Sessão';

  @override
  String get accountSignOut => 'Sair';

  @override
  String get accountSignOutClean =>
      'Seus dados estão na nuvem e voltam quando você entrar de novo. Neste aparelho eles ficam guardados só para esta conta.';

  @override
  String accountSignOutConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Também há $count alterações para resolver.',
      one: 'Também há 1 alteração para resolver.',
    );
    return '$_temp0';
  }

  @override
  String accountSignOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count alterações ainda não enviadas.',
      one: 'Há 1 alteração ainda não enviada.',
    );
    return '$_temp0 Elas continuam guardadas neste aparelho, presas a esta conta, e só reaparecem quando você entrar nela de novo.';
  }

  @override
  String get accountSignOutTitle => 'Sair da conta?';

  @override
  String get accountStillPending =>
      'Ainda há pendências: elas ficam guardadas neste aparelho.';

  @override
  String get accountSyncFirst => 'Sincronizar antes';

  @override
  String get accountYourData => 'Seus dados';

  @override
  String get accountYourName => 'Seu nome';

  @override
  String alcoholAtLeast(String amount) {
    return 'pelo menos $amount';
  }

  @override
  String get alcoholDeclared => 'Álcool puro declarado';

  @override
  String get alcoholExplain =>
      'Calculado só com o que foi informado: volume × teor nas bebidas simples e quantidade × teor de cada componente nos drinks. Em drinks vale a receita declarada, não o que o bar serviu. Não é a concentração de álcool no sangue e não indica se você pode dirigir.';

  @override
  String alcoholIncompletePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count registros com teor ou quantidade desconhecidos: o total é um mínimo',
      one: '1 registro com teor ou quantidade desconhecidos: o total é um mínimo',
    );
    return '$_temp0';
  }

  @override
  String alcoholNoVolumePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros sem volume informado (não entram no volume)',
      one: '1 registro sem volume informado (não entra no volume)',
    );
    return '$_temp0';
  }

  @override
  String get appName => 'Bebômetro';

  @override
  String get authCancelAndLeave => 'Cancelar e sair';

  @override
  String get authCheckEmail => 'Confira o e-mail digitado.';

  @override
  String get authCloudDown =>
      'Não foi possível falar com o servidor agora. Confira a internet e tente de novo em instantes.';

  @override
  String get authConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authDifferentAccount => 'Conta diferente da sessão atual.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authEmailExists =>
      'Já existe uma conta com esse e-mail. Entre com ela ou recupere a senha.';

  @override
  String get authEmailNotConfirmed =>
      'Confirme seu e-mail antes de entrar. Procure o link na sua caixa de entrada (e no spam).';

  @override
  String get authEnterEmail => 'Informe seu e-mail.';

  @override
  String get authEnterPassword => 'Informe sua senha.';

  @override
  String get authForgot => 'Esqueci minha senha';

  @override
  String get authGenericError =>
      'Não foi possível concluir agora. Tente de novo.';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authLinkInvalid =>
      'Esse link expirou ou já foi usado. Peça outro e abra-o neste aparelho. Se você confirmou o e-mail em outro aparelho, é só entrar com e-mail e senha.';

  @override
  String get authNameMissing => 'Como podemos te chamar?';

  @override
  String get authNeedsCode =>
      'Por segurança, confirme com o código enviado ao seu e-mail.';

  @override
  String get authNewPassword => 'Nova senha';

  @override
  String authNewPasswordFor(String email) {
    return 'Crie uma nova senha para $email.';
  }

  @override
  String get authNewPasswordTitle => 'Nova senha';

  @override
  String get authNoConnection =>
      'Sem conexão. Confira a internet e tente de novo.';

  @override
  String get authPassword => 'Senha';

  @override
  String get authPasswordHelper => 'Pelo menos 8 caracteres.';

  @override
  String get authPasswordMin => 'Use pelo menos 8 caracteres.';

  @override
  String get authPasswordMix => 'Misture letras e números.';

  @override
  String get authPasswordsDiffer => 'As senhas não são iguais.';

  @override
  String get authCodeTitle => 'Digite o código';

  @override
  String authCodeBody(String email) {
    return 'Enviamos um código de 6 dígitos para $email. Digite-o abaixo; ele vale por pouco tempo.';
  }

  @override
  String get authCodeLabel => 'Código de 6 dígitos';

  @override
  String get authCodeVerify => 'Confirmar código';

  @override
  String get authCodeInvalid =>
      'Código inválido ou expirado. Confira os 6 dígitos ou peça um novo código.';

  @override
  String get authCodeIncomplete => 'Digite os 6 dígitos do código.';

  @override
  String get authHaveCode => 'Já tenho um código';

  @override
  String get authRecoverBody =>
      'Enviaremos um código de 6 dígitos para o seu e-mail. Você o digita aqui no app, em qualquer aparelho.';

  @override
  String get authRecoverSent =>
      'Se houver uma conta com esse e-mail, o código chega em instantes. Confira também o spam.';

  @override
  String get authRecoverTitle => 'Recuperar senha';

  @override
  String get authResend => 'Reenviar e-mail';

  @override
  String authResendIn(int seconds) {
    return 'Reenviar em $seconds s';
  }

  @override
  String authResendWait(int seconds) {
    return 'Aguarde $seconds s para pedir outro e-mail.';
  }

  @override
  String get authSamePassword => 'A nova senha precisa ser diferente da atual.';

  @override
  String get authSavePassword => 'Salvar senha';

  @override
  String get authSendLink => 'Enviar código';

  @override
  String get authServerUnreachable =>
      'Sem conexão com o servidor agora. Tente de novo em instantes.';

  @override
  String get authSessionEnded => 'Sua sessão terminou. Entre novamente.';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authSignInAgainBody =>
      'Sua sessão terminou no servidor. Seus registros continuam neste aparelho e voltam quando você entrar na mesma conta.';

  @override
  String get authSignInAgainTitle => 'Entre novamente';

  @override
  String get authSignInAgainToContinue => 'Entre novamente para continuar.';

  @override
  String get authSignInBody =>
      'Seus rolês ficam salvos na sua conta e voltam em qualquer aparelho.';

  @override
  String get authSignUpNote =>
      'Seu nome e e-mail só servem para a sua conta. Você entra direto, sem precisar confirmar o e-mail.';

  @override
  String get authSignupDisabled =>
      'Cadastro desativado no servidor no momento.';

  @override
  String get authTooManyAttempts =>
      'Muitas tentativas. Espere alguns minutos e tente de novo.';

  @override
  String get authTooManyShort => 'Muitas tentativas. Espere alguns minutos.';

  @override
  String get authWeakPassword => 'Senha fraca. Use pelo menos 8 caracteres.';

  @override
  String get authWrongCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authYourAccount => 'sua conta';

  @override
  String get budgetDialogTitle => 'Orçamento para bebidas';

  @override
  String get budgetEdit => 'Editar orçamento';

  @override
  String budgetLeft(String amount) {
    return 'Sobram $amount do orçamento.';
  }

  @override
  String budgetLeftIncomplete(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Dos gastos informados, sobram $amount do orçamento (parcial: faltam preços de $count bebidas).',
      one:
          'Dos gastos informados, sobram $amount do orçamento (parcial: falta o preço de 1 bebida).',
    );
    return '$_temp0';
  }

  @override
  String budgetLine(String budget, String spent) {
    return 'Orçamento $budget · gasto informado $spent';
  }

  @override
  String get budgetMustBePositive => 'Informe um valor maior que zero';

  @override
  String get budgetOptionalNote =>
      'Opcional. Compara só com os gastos informados nas suas bebidas; o que a mesa gasta fica na comanda.';

  @override
  String budgetOver(String amount) {
    return 'Passou $amount do orçamento.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'Os gastos informados já passaram $amount do orçamento e ainda faltam preços.';
  }

  @override
  String budgetReached(int percent, String spent, String budget) {
    return 'Os gastos informados chegaram a $percent% do orçamento ($spent de $budget).';
  }

  @override
  String get budgetReachedIncomplete =>
      'Há bebidas sem preço: o total real pode ser maior.';

  @override
  String get budgetSet => 'Definir orçamento';

  @override
  String get budgetValue => 'Valor';

  @override
  String get commonAdjust => 'Ajustar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonError => 'Algo deu errado';

  @override
  String get commonLater => 'Depois';

  @override
  String get commonMoreOptions => 'Mais opções';

  @override
  String get commonNotNow => 'Agora não';

  @override
  String get commonOptional => '(opcional)';

  @override
  String get commonOptions => 'Opções';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonUndo => 'Desfazer';

  @override
  String get conflictAcceptDeletion => 'Aceitar a exclusão';

  @override
  String get conflictApplyFailed =>
      'Não foi possível aplicar. Nada foi perdido.';

  @override
  String get conflictCloud => 'Na nuvem';

  @override
  String get conflictCloudDeleted => 'Na nuvem (excluído)';

  @override
  String get conflictCustomDrink => 'Bebida pessoal alterada em dois aparelhos';

  @override
  String get conflictDeletionAccepted => 'Exclusão aceita';

  @override
  String get conflictDrink => 'Bebida editada em dois aparelhos';

  @override
  String conflictEditedAt(String when) {
    return 'Editado em $when';
  }

  @override
  String conflictEnd(String when) {
    return 'Fim: $when';
  }

  @override
  String get conflictEndHere => 'Encerrar o deste aparelho';

  @override
  String get conflictEndOther => 'Encerrar o do outro aparelho';

  @override
  String get conflictFromHere => 'Deste aparelho';

  @override
  String get conflictFromOther => 'Do outro aparelho';

  @override
  String get conflictHere => 'Neste aparelho';

  @override
  String get conflictIntro =>
      'Estas alterações foram feitas em mais de um aparelho ao mesmo tempo. Escolha qual versão vale. A outra é descartada só quando você escolher.';

  @override
  String get conflictItem => 'Item alterado em dois aparelhos';

  @override
  String get conflictKeepLocal => 'Manter a deste aparelho';

  @override
  String get conflictKeptLocal => 'Mantida a versão deste aparelho';

  @override
  String get conflictNone => 'Nada para resolver. Tudo certo.';

  @override
  String get conflictOuting => 'Rolê alterado em dois aparelhos';

  @override
  String get conflictOutingEnded => 'Rolê encerrado';

  @override
  String conflictOutingLine(String label, String name) {
    return '$label: $name';
  }

  @override
  String conflictPaid(String amount) {
    return 'Pago: $amount';
  }

  @override
  String get conflictPlace => 'Local alterado em dois aparelhos';

  @override
  String get conflictRemoteUnreadable =>
      'Não deu para ler a versão da nuvem agora. Você pode manter a deste aparelho ou tentar mais tarde.';

  @override
  String get conflictRestore => 'Restaurar com a versão deste aparelho';

  @override
  String get conflictRestored => 'Restaurado com a sua versão';

  @override
  String conflictSince(String when) {
    return 'desde $when';
  }

  @override
  String conflictStart(String when) {
    return 'Início: $when';
  }

  @override
  String get conflictTab => 'Comanda alterada em dois aparelhos';

  @override
  String conflictTabPayments(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamentos registrados: $amount',
      one: '1 pagamento registrado: $amount',
      zero: 'Nenhum pagamento registrado',
    );
    return '$_temp0';
  }

  @override
  String conflictTabPeople(int people, int extras) {
    String _temp0 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people participantes',
      one: '1 participante',
    );
    String _temp1 = intl.Intl.pluralLogic(
      extras,
      locale: localeName,
      other: '$extras itens extras',
      one: '1 item extra',
      zero: 'nenhum item extra',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get conflictTitle => 'Alterações para resolver';

  @override
  String get conflictTwoActiveBody =>
      'Um foi começado neste aparelho e outro em outro aparelho, sem internet. Os dois foram guardados com as suas bebidas. Escolha qual encerrar agora.';

  @override
  String get conflictUseRemote => 'Usar a da nuvem';

  @override
  String get conflictUsedRemote => 'Usada a versão da nuvem';

  @override
  String dateAtTime(String date, String time) {
    return '$date às $time';
  }

  @override
  String get deleteBody =>
      'Isso apaga de vez a sua conta, todos os rolês, bebidas, locais, comandas e fotos guardados na nuvem, e os dados desta conta neste aparelho. Não dá para desfazer.';

  @override
  String get deleteConfirmPassword => 'Confirme sua senha.';

  @override
  String get deleteConfirmPasswordAgain => 'Confirme sua senha de novo.';

  @override
  String get deleteExportFirst =>
      'Se quiser guardar uma cópia, exporte seus dados antes (Configurações > Exportar meus dados).';

  @override
  String get deleteOffline => 'Sem conexão. Nada foi apagado.';

  @override
  String get deletePartial =>
      'A exclusão começou mas não terminou. Nada local foi apagado. Toque em \"Excluir conta\" de novo para continuar.';

  @override
  String get deleteTickFirst => 'Marque a confirmação para continuar.';

  @override
  String get deleteUnavailable =>
      'A exclusão ainda não está disponível no servidor. Nada foi apagado. Tente mais tarde.';

  @override
  String get deleteUnderstand => 'Entendo que a exclusão é permanente.';

  @override
  String get deleteYourPassword => 'Sua senha';

  @override
  String drinkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas',
      one: '1 bebida',
    );
    return '$_temp0';
  }

  @override
  String get drinkFallbackName => 'Bebida';

  @override
  String get drinkShared => 'compartilhada';

  @override
  String get drinkWater => 'Água';

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
  String get entryAlcoholIncomplete => 'álcool incompleto';

  @override
  String get entryCorrect => 'Corrigir';

  @override
  String get entryRepeat => 'Repetir';

  @override
  String get entryOptions => 'Opções do registro';

  @override
  String entrySharedPart(int count, String mine, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sua parte $mine de $total ($count pessoas)',
      one: 'sua parte $mine de $total (1 pessoa)',
    );
    return '$_temp0';
  }

  @override
  String get feedbackDontAsk => 'Não perguntar';

  @override
  String get feedbackFreeNote => 'Nota livre';

  @override
  String get feedbackFreeNoteHint => 'Algo que você queira lembrar desse rolê';

  @override
  String get feedbackHangover => 'Ressaca';

  @override
  String get feedbackHowItWent => 'Como foi';

  @override
  String get feedbackNote =>
      'É só o seu relato de como foi a noite. Não mede nada e não indica quanto é seguro beber.';

  @override
  String get feedbackOptional =>
      'Tudo opcional. É só um registro pessoal, sem nota e sem comparação.';

  @override
  String get feedbackReviewForgotten => 'Revisar bebidas esquecidas';

  @override
  String get feedbackSave => 'Salvar relato';

  @override
  String get feedbackTellMore => 'Quer contar mais?';

  @override
  String get feedbackTitle => 'Como foi o último rolê?';

  @override
  String get feedbackWake => 'Como acordou';

  @override
  String get feedbackYourAccount => 'Seu relato';

  @override
  String get fileGenerationFailed => 'Não foi possível gerar o arquivo.';

  @override
  String financeInformed(String amount) {
    return '$amount informados';
  }

  @override
  String get financeNoRecords => 'Sem registros ainda';

  @override
  String get financeNoValue => 'Nenhum valor informado';

  @override
  String financeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas sem preço',
      one: '1 bebida sem preço',
    );
    return '$_temp0';
  }

  @override
  String get finishAndSummary => 'Encerrar e ver resumo';

  @override
  String finishBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros.',
      one: '1 registro.',
      zero: 'Nenhum registro.',
    );
    return '$_temp0 Você ainda poderá corrigir registros depois, pelo histórico.';
  }

  @override
  String finishEnd(String when) {
    return 'Fim: $when';
  }

  @override
  String get finishKeepGoing => 'Continuar o rolê';

  @override
  String get finishTitle => 'Encerrar rolê?';

  @override
  String get glassBigSubtitle => 'O volume informado, somado, num copo.';

  @override
  String get glassBigTitle => 'Copão (opcional)';

  @override
  String get glassTipPlay => 'Brincar de virar o copo';

  @override
  String get groupRecipeAdjusted => 'receita ajustada';

  @override
  String groupSharedPart(String mine, String total) {
    return '$mine seus de $total';
  }

  @override
  String groupTimes(int count) {
    return '$count×';
  }

  @override
  String get groupVolumeUnknown => 'volume desconhecido';

  @override
  String get groupVolumeUnknownShort => 'volume ?';

  @override
  String get hangoverMild => 'Leve';

  @override
  String get hangoverModerate => 'Moderada';

  @override
  String get hangoverNone => 'Nenhuma';

  @override
  String get hangoverStrong => 'Forte';

  @override
  String get homeContinueOuting => 'Continuar rolê';

  @override
  String get homeDrinks => 'Bebidas';

  @override
  String get homeFirstBody =>
      'Quando você encerrar um rolê, o resumo do mês aparece aqui, só com o que você registrou.';

  @override
  String get homeFirstTitle => 'Seu primeiro rolê começa aqui';

  @override
  String get homeIdleBody =>
      'Anote o que bebeu e quanto gastou, sem complicação.';

  @override
  String get homeIdleTitle => 'Bora de rolê?';

  @override
  String get homeInformedSpent => 'Seu gasto informado';

  @override
  String get homeLastOuting => 'Último rolê';

  @override
  String get homeNoneThisMonth => 'Nenhum rolê encerrado neste mês ainda.';

  @override
  String get homeOutingRunning => 'Rolê em andamento';

  @override
  String get homeOutings => 'Rolês';

  @override
  String get homeSpent => 'Seu gasto';

  @override
  String get homeStartOuting => 'Iniciar rolê';

  @override
  String get homeThisMonth => 'Este mês';

  @override
  String get homeTime => 'Tempo';

  @override
  String homeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sem preço',
      one: '1 sem preço',
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
      'Valores continuam em reais (R\$) em qualquer idioma.';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageSystemHint =>
      'Português, inglês ou espanhol conforme o aparelho; outros idiomas usam português.';

  @override
  String get legacyTwoActiveTitle => 'Dois rolês em andamento';

  @override
  String get moneyFieldHelper => 'Valores em reais (R\$). Ex.: 15 ou 15,50.';

  @override
  String get moodCheerful => 'Alegre';

  @override
  String get moodDrunk => 'Bêbado';

  @override
  String get moodSmooth => 'Suave';

  @override
  String get moodWasted => 'Bebaço';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navGames => 'Resenha';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navHome => 'Início';

  @override
  String noticeAnotherOne(String name) {
    return 'Mais uma: $name';
  }

  @override
  String get noticeEntryDeleted => 'Registro excluído';

  @override
  String get noticeWater => 'Água registrada';

  @override
  String get numberAmbiguous =>
      'Formato ambíguo. Use vírgula ou ponto só para os centavos (ex.: 1500 ou 15,50).';

  @override
  String get numberInvalid => 'Número inválido.';

  @override
  String get outingAddDrink => 'Adicionar bebida';

  @override
  String outingAlcoholIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count com álcool incompleto',
      one: '1 com álcool incompleto',
    );
    return '$_temp0';
  }

  @override
  String get outingAlreadyEnded => 'Esse rolê já foi encerrado.';

  @override
  String outingConfirmAnother(String drink) {
    return 'Registrar mais uma: $drink?';
  }

  @override
  String get outingConfirmWater => 'Registrar um copo de água?';

  @override
  String get outingDrinkLogged => 'Bebida registrada';

  @override
  String get outingEntryUpdated => 'Registro atualizado';

  @override
  String get outingFallbackName => 'Rolê';

  @override
  String get outingFinish => 'Encerrar rolê';

  @override
  String get outingFirstDrinkHint =>
      'Registre a primeira bebida e o botão \"Mais uma\" aparece aqui embaixo.';

  @override
  String get outingHideHere => 'Ocultar neste rolê';

  @override
  String get outingInProgress => 'Em andamento';

  @override
  String get outingLockScreenRequest => 'Pedido da tela bloqueada';

  @override
  String get outingLog => 'Registrar';

  @override
  String get outingNoDrinks => 'Nenhuma bebida ainda';

  @override
  String get outingNoDrinksBody =>
      'Registre a primeira e o botão \"Mais uma\" aparece aqui embaixo.';

  @override
  String outingNoVolume(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sem volume',
      one: '1 sem volume',
    );
    return '$_temp0';
  }

  @override
  String get outingNotFound => 'Esse rolê não foi encontrado.';

  @override
  String get trackingOutingGone => 'Esse rolê não existe mais neste aparelho.';

  @override
  String get outingNothingToRepeat => 'Não há bebida para repetir neste rolê.';

  @override
  String get outingOpenScan =>
      'Há uma leitura de rótulo ou cardápio em aberto. Ela continua ligada a este rolê e aparece no resumo dele.';

  @override
  String outingRecords(int count) {
    return 'Registros ($count)';
  }

  @override
  String get outingRunningFor => 'Rolando há';

  @override
  String get outingShowOnLock => 'Mostrar na tela bloqueada';

  @override
  String get outingTrackingBack => 'Acompanhamento na tela bloqueada de volta.';

  @override
  String get outingTrackingHidden => 'Oculto da tela bloqueada neste rolê.';

  @override
  String get outingTypeBar => 'Bar';

  @override
  String get outingTypeBarbecue => 'Churrasco';

  @override
  String get outingTypeBeach => 'Praia';

  @override
  String get outingTypeClub => 'Balada';

  @override
  String get outingTypeHome => 'Casa';

  @override
  String get outingTypeOther => 'Outro';

  @override
  String get outingTypeRestaurant => 'Restaurante';

  @override
  String outingTypeSince(String type, String time) {
    return '$type · desde $time';
  }

  @override
  String get outingYourVolume => 'Seu volume';

  @override
  String get placeCorrect => 'Corrigir local';

  @override
  String get placeOpenInMaps => 'Abrir no mapa';

  @override
  String get priceComplimentary => 'Cortesia';

  @override
  String get priceNone => 'Sem preço';

  @override
  String get priceUnknown => 'sem preço';

  @override
  String repeatAdjusted(String name) {
    return '$name (ajustada)';
  }

  @override
  String get repeatButton => 'Mais uma';

  @override
  String repeatSemantics(String drink) {
    return 'Mais uma: $drink';
  }

  @override
  String repeatYourPart(String amount) {
    return 'sua parte $amount';
  }

  @override
  String get repoAbvRange => 'O teor vai de 0 a 100%.';

  @override
  String get repoActiveExists => 'Já existe um rolê em andamento.';

  @override
  String repoCopyName(String name) {
    return '$name (cópia)';
  }

  @override
  String get repoDrinkName => 'Dê um nome para a bebida.';

  @override
  String get repoDrinkVolume => 'Informe o volume em ml.';

  @override
  String get repoEndBeforeStart => 'O fim não pode ser antes do início.';

  @override
  String get repoEndFuture => 'O fim não pode estar no futuro.';

  @override
  String get repoNicknameOrAddress => 'Informe um apelido ou um endereço.';

  @override
  String get repoPlaceMissing =>
      'Informe um apelido ou um endereço para o local.';

  @override
  String get repoPointNeedsName => 'Dê um apelido para salvar este ponto.';

  @override
  String get repoRecipeIngredient => 'Adicione pelo menos um ingrediente.';

  @override
  String get repoRecipeName => 'Dê um nome para a receita.';

  @override
  String get repoStateFormat => 'A UF tem 2 letras (ex.: SP).';

  @override
  String get settingsAccount => 'Minha conta';

  @override
  String get settingsBudget => 'Orçamento';

  @override
  String get settingsBudgetAlerts => 'Avisos de orçamento';

  @override
  String get settingsBudgetAlertsHint =>
      'Um aviso ao chegar a 80% e a 100% do orçamento do rolê, uma vez por patamar.';

  @override
  String get settingsDrinkRecords => 'Registros de bebida';

  @override
  String get settingsExport => 'Exportar meus dados';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String settingsLastSync(String when) {
    return 'Última sincronização: $when';
  }

  @override
  String get settingsLastSyncNever => 'Última sincronização: ainda não houve.';

  @override
  String get settingsLocalRisk =>
      'Enquanto isso, se você desinstalar o app ou limpar os dados do navegador, o que está só neste aparelho será perdido.';

  @override
  String get settingsLockScreen => 'Rolê na tela bloqueada';

  @override
  String get settingsMyDrinks => 'Minhas bebidas';

  @override
  String get settingsMyDrinksAndRecipes => 'Minhas bebidas e receitas';

  @override
  String get settingsNotYetInCloud =>
      'Alguns dados ainda não chegaram à nuvem.';

  @override
  String get settingsOutingsHere => 'Rolês neste aparelho';

  @override
  String settingsPendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações aguardando envio.',
      one: '1 alteração aguardando envio.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavedPlaces => 'Locais salvos';

  @override
  String get settingsStorage => 'ARMAZENAMENTO';

  @override
  String get settingsSync => 'SINCRONIZAÇÃO';

  @override
  String get settingsSyncDone => 'Tudo sincronizado.';

  @override
  String settingsSyncDoneConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado, mas há $count alterações para resolver em Minha conta.',
      one: 'Enviado, mas há 1 alteração para resolver em Minha conta.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncFailed => 'Não foi possível sincronizar agora.';

  @override
  String get settingsSyncNow => 'Sincronizar agora';

  @override
  String get settingsSyncState => 'Estado';

  @override
  String settingsSyncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda há $count alterações para enviar.',
      one: 'Ainda há 1 alteração para enviar.',
    );
    return '$_temp0';
  }

  @override
  String get settingsTable => 'Mesa do rolê';

  @override
  String get settingsTableAnimations => 'Animações da mesa';

  @override
  String get settingsTableAnimationsHint =>
      'Os recipientes esvaziam como ilustração. Desligado, a mesa fica estática.';

  @override
  String get settingsTableDefault => 'Mostrar mesa como padrão';

  @override
  String get settingsTableDefaultHint =>
      'Na tela do rolê, a mesa ilustrada abre antes da lista.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get shareUnavailableCopied =>
      'Compartilhar não está disponível aqui. O conteúdo foi copiado: cole em um arquivo para guardar.';

  @override
  String get shellBackToOuting => 'Voltar ao rolê';

  @override
  String shellOutingRunning(String name) {
    return 'Rolê em andamento · $name';
  }

  @override
  String staleBody(String name, String start, String duration) {
    return '$name começou em $start e está aberto há $duration.';
  }

  @override
  String get staleEndOtherTime => 'Encerrar com outro horário';

  @override
  String get staleNote =>
      'Ao encerrar você escolhe o horário final. Nada é encerrado automaticamente.';

  @override
  String get staleTitle => 'Esse rolê ainda está acontecendo?';

  @override
  String get startFailed => 'Não foi possível iniciar o rolê. Tente de novo.';

  @override
  String get startFuture => 'O início não pode estar no futuro.';

  @override
  String get startPlaceError =>
      'Informe um apelido (ex.: Casa da Samara) ou um endereço';

  @override
  String get stateTwoLetters => 'A UF tem 2 letras';

  @override
  String get summaryAccountNote =>
      'Relato pessoal: não mede nada e não indica um limite de consumo.';

  @override
  String get summaryAddAccount => 'Adicionar relato';

  @override
  String get summaryAddForgotten => 'Adicionar bebida esquecida';

  @override
  String get summaryConsumption => 'Consumo';

  @override
  String get summaryDone => 'Concluir';

  @override
  String get summaryDuration => 'Duração';

  @override
  String get summaryEditAccount => 'Editar relato';

  @override
  String get summaryEnd => 'Fim';

  @override
  String get summaryFillPrices => 'Preencher preços ausentes';

  @override
  String summaryHangover(String level) {
    return 'Ressaca: $level';
  }

  @override
  String get summaryNoAccount => 'Sem relato ainda.';

  @override
  String get summaryNoRecords => 'Nenhum registro neste rolê';

  @override
  String get summaryRetro =>
      'Retrospectiva ilustrativa dos registros. Os números reais estão abaixo.';

  @override
  String get summaryShare => 'Compartilhar resumo';

  @override
  String get summarySpending => 'Gastos';

  @override
  String get summarySpentOnDrinks => 'Seus gastos registrados em bebidas';

  @override
  String get summaryStart => 'Início';

  @override
  String get summaryTab => 'Comanda';

  @override
  String get summaryTapToCorrect =>
      'Toque em um registro para corrigir; o resumo se recalcula.';

  @override
  String get summaryTitle => 'Resumo do rolê';

  @override
  String summaryUnpricedPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas sem preço: o total pode estar maior',
      one: '1 bebida sem preço: o total pode estar maior',
    );
    return '$_temp0';
  }

  @override
  String get summaryUpdated => 'Registro atualizado, resumo recalculado';

  @override
  String summaryWoke(String feeling) {
    return 'Acordou: $feeling';
  }

  @override
  String get summaryYourAccount => 'Seu relato';

  @override
  String get summaryYourAccountTag => 'seu relato';

  @override
  String syncLabelConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para resolver',
      one: '1 para resolver',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelFailed => 'Falha ao sincronizar';

  @override
  String get syncLabelLocalOnly => 'Só neste aparelho';

  @override
  String syncLabelPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aguardando envio',
      one: '1 aguardando envio',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelSynced => 'Sincronizado';

  @override
  String get syncLabelSyncing => 'Sincronizando…';

  @override
  String get syncNoticeActiveConflict =>
      'O servidor já tem outro rolê em andamento. Nada foi apagado: os dados continuam salvos no aparelho.';

  @override
  String get syncNoticeLocalOnly =>
      'A nuvem ainda não está disponível. Seus registros estão salvos só neste aparelho e serão enviados quando for possível.';

  @override
  String get syncNoticeOffline => 'Sem conexão. Vamos tentar de novo.';

  @override
  String get syncNoticePhotos =>
      'Algumas fotos ainda não foram enviadas. Elas continuam salvas no aparelho e o envio será tentado de novo.';

  @override
  String get syncNoticePlaceLink =>
      'O servidor não aceitou o vínculo de um rolê com o local salvo. Nada foi alterado: os dados continuam salvos no aparelho.';

  @override
  String get syncNoticeRejected =>
      'O servidor recusou algumas alterações. Seus dados continuam salvos no aparelho.';

  @override
  String get syncNoticeSchemaGap =>
      'Parte dos dados novos aguarda uma atualização do servidor. O restante já foi enviado e nada foi perdido.';

  @override
  String get syncNoticeSignInAgain =>
      'Entre novamente na sua conta para enviar e receber os dados. Tudo continua salvo neste aparelho.';

  @override
  String get syncNoticeWaitingPlace =>
      'Alguns rolês aguardam o envio do local salvo. Nada foi perdido.';

  @override
  String get tableAboutMenu => 'Animação ilustrativa das bebidas registradas';

  @override
  String get tableChangeScene => 'Trocar cenário';

  @override
  String get tableOptions => 'Opções da mesa';

  @override
  String get tableViewList => 'Lista';

  @override
  String get tableViewTable => 'Mesa';

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
    return '$known (+$count sem volume)';
  }

  @override
  String get volumeUnknown => 'desconhecido';

  @override
  String get wakeBad => 'Mal';

  @override
  String get wakeGreat => 'Bem';

  @override
  String get wakeOk => 'Normal';

  @override
  String get wakeTired => 'Cansado';

  @override
  String get startTitle => 'Iniciar rolê';

  @override
  String get startWhatKind => 'Que tipo de rolê?';

  @override
  String get startWhere => 'Onde?';

  @override
  String get startSearchPlace => 'Buscar bar ou endereço';

  @override
  String get startSearchPlaceHint =>
      'Ou usar sua localização e conferir no mapa';

  @override
  String get startSavedPlaces => 'Locais salvos';

  @override
  String get startOrNickname => 'Ou só um apelido';

  @override
  String get startNicknameLabel => 'Apelido do local';

  @override
  String get startNicknameHint => 'Ex.: Bar MELT, Casa da Samara';

  @override
  String get startAddAddress => 'Digitar endereço (opcional)';

  @override
  String get startAddressLabel => 'Endereço (opcional)';

  @override
  String get startAddressHint => 'Rua, número, bairro';

  @override
  String get startAddressHelper => 'Apelido ou endereço já bastam.';

  @override
  String get startCityLabel => 'Cidade (opcional)';

  @override
  String get startStateLabel => 'UF';

  @override
  String get startSavePlace => 'Salvar este local';

  @override
  String get startSavePlaceHint =>
      'Para escolher de novo nos próximos rolês. Fica privado no seu perfil.';

  @override
  String get startWhen => 'Quando começou?';

  @override
  String get startBudgetSection => 'Orçamento (opcional)';

  @override
  String get startBudgetLabel => 'Orçamento para bebidas';

  @override
  String get startBudgetHelper =>
      'Você pode definir ou mudar depois, durante o rolê. Valores em reais (R\$).';

  @override
  String get startBegin => 'Começar o rolê';

  @override
  String get startWillSavePlace => 'Será salvo nos seus locais';

  @override
  String get startChangePlace => 'Trocar';

  @override
  String priceFixApplyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aplicar a $count registros?',
      one: 'Aplicar a 1 registro?',
    );
    return '$_temp0';
  }

  @override
  String priceFixReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count já tinham preço e serão substituídos.',
      one: '1 já tinha preço e será substituído.',
    );
    return '$_temp0';
  }

  @override
  String get priceFixYourShare => 'sua parcela';

  @override
  String get priceFixUpdated => 'Preços atualizados';

  @override
  String get priceFixPaidLabel => 'Preço pago';

  @override
  String get priceFixPaidShared => 'Quanto você pagou';

  @override
  String get priceFixSharedNote =>
      'Bebida compartilhada: informe a sua parcela, não o preço da garrafa. O consumo não muda.';

  @override
  String get priceFixEnterValue => 'Informe um valor';

  @override
  String get priceFixTitle => 'Preços ausentes';

  @override
  String get priceFixNoneTitle => 'Nenhum preço ausente';

  @override
  String get priceFixNoneBody =>
      'Todos os registros deste rolê têm preço ou cortesia informados.';

  @override
  String get priceFixIntro =>
      'Preencha um por um, ou escolha vários registros iguais e aplique o mesmo preço depois de ver a prévia. Preços já informados não mudam, a menos que você os inclua e selecione de propósito.';

  @override
  String get priceFixIncludePriced =>
      'Incluir também registros que já têm preço';

  @override
  String get priceFixForSelected => 'Preço para os selecionados';

  @override
  String get priceFixSharedHint =>
      'Em bebida compartilhada vale o que você pagou (sua parcela), nunca o preço da garrafa.';

  @override
  String priceFixSelectAll(String count) {
    return 'Selecionar os $count';
  }

  @override
  String get priceFixClear => 'Limpar';

  @override
  String priceFixCurrent(String price) {
    return 'Preço atual: $price';
  }

  @override
  String get priceFixOnlyThis => 'Informar só este preço';

  @override
  String get priceFixSelectRecords => 'Selecione registros';

  @override
  String priceFixPreview(String count) {
    return 'Ver prévia ($count)';
  }

  @override
  String get originGeneric => 'Genérico';

  @override
  String get originUser => 'Criada por você';

  @override
  String get originVerified => 'Dados do fabricante';

  @override
  String get originMixed => 'Fabricante + rótulo (fonte secundária)';

  @override
  String get originSecondary => 'Rótulo em fonte secundária';

  @override
  String get originRecipe => 'Receita de referência';

  @override
  String get kindCan => 'Lata';

  @override
  String get kindLongNeck => 'Long neck';

  @override
  String get kindBottle => 'Garrafa';

  @override
  String get kindGlass => 'Copo/taça';

  @override
  String get kindShot => 'Dose';

  @override
  String get presCan => 'Lata';

  @override
  String get presBottle => 'Garrafa';

  @override
  String get presGlass => 'Copo';

  @override
  String get presMug => 'Caneca';

  @override
  String get presTulip => 'Tulipa';

  @override
  String get presWineGlass => 'Taça';

  @override
  String get presShot => 'Dose';

  @override
  String get presDoubleShot => 'Dose dupla';

  @override
  String unitLiters(String value) {
    return '$value L';
  }

  @override
  String get abvVaries => 'teor varia';

  @override
  String get categoryBeer => 'Cerveja';

  @override
  String get categoryDraft => 'Chopp';

  @override
  String get categoryCocktail => 'Drink';

  @override
  String get categorySpirit => 'Destilado/dose';

  @override
  String get categoryReadyToDrink => 'Bebida pronta';

  @override
  String get categoryWine => 'Vinho';

  @override
  String get categoryNonAlcoholic => 'Sem álcool';

  @override
  String get categoryWater => 'Água';

  @override
  String get abvSourceLabel => 'Rótulo (foto), conferido por você';

  @override
  String get abvSourceMenu => 'Cardápio (foto), conferido por você';

  @override
  String get abvSourceTyped => 'Informado por você';

  @override
  String get abvSourceCatalog => 'Copiado do catálogo';

  @override
  String get styleLagerPilsen => 'Lager/Pilsen';

  @override
  String get styleDark => 'Escura';

  @override
  String get styleWhiteRum => 'Rum branco';

  @override
  String get styleAperitif => 'Aperitivo';

  @override
  String get styleBitterAperitif => 'Aperitivo bitter';

  @override
  String get styleSweetVermouth => 'Vermute doce';

  @override
  String get styleDryVermouth => 'Vermute seco';

  @override
  String get styleAgaveTequila => 'Tequila 100% agave';

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
  String get roleOrangeLiqueur => 'Licor de laranja';

  @override
  String get roleCampari => 'Campari';

  @override
  String get roleAperol => 'Aperol';

  @override
  String get roleSweetVermouth => 'Vermute doce';

  @override
  String get roleDryVermouth => 'Vermute seco';

  @override
  String get roleSparklingWine => 'Espumante';

  @override
  String get roleBitters => 'Bitter';

  @override
  String get recipeUnitMl => 'ml (mililitros)';

  @override
  String get recipeUnitG => 'g (gramas)';

  @override
  String get recipeUnitUnit => 'unidade';

  @override
  String get recipeUnitTsp => 'colher de chá';

  @override
  String get recipeUnitTbsp => 'colher de sopa';

  @override
  String get recipeUnitLeaf => 'folha';

  @override
  String get recipeUnitDrop => 'gota';

  @override
  String get recipeUnitToTaste => 'a gosto';

  @override
  String get recipeUnitOther => 'texto da receita';

  @override
  String get recipeShortUnit => 'un.';

  @override
  String get recipeShortTsp => 'c. chá';

  @override
  String get recipeShortTbsp => 'c. sopa';

  @override
  String get recipeShortLeaf => 'folha(s)';

  @override
  String get recipeShortDrop => 'gota(s)';

  @override
  String get recipeAmountUnknown => 'quantidade não informada';

  @override
  String get recipeGapAbv => 'teor desconhecido';

  @override
  String get recipeGapNotMl => 'quantidade não está em ml';

  @override
  String get recipeGapAmount => 'quantidade desconhecida';

  @override
  String get addDrinkTitle => 'Adicionar bebida';

  @override
  String get catalogMyDrinksTooltip => 'Minhas bebidas e receitas';

  @override
  String get catalogSearchHint => 'Buscar marca, produto ou estilo';

  @override
  String get catalogMoreFilters => 'Mais filtros';

  @override
  String get catalogAll => 'Todas';

  @override
  String get catalogScanLabel => 'Ler rótulo';

  @override
  String get catalogScanMenu => 'Ler cardápio';

  @override
  String get catalogCreate => 'Cadastrar bebida';

  @override
  String get catalogCreateOuting => 'Cadastrar bebida deste rolê';

  @override
  String get catalogNeedOutingTitle => 'Precisa de um rolê em andamento';

  @override
  String get catalogNeedOutingBody =>
      'Bebidas lidas de rótulo ou cardápio ficam guardadas no rolê em que foram cadastradas. Quer iniciar um agora?';

  @override
  String get catalogSavedToOuting => 'Salva em \"Bebidas deste rolê\"';

  @override
  String catalogMenuSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count itens em \"Bebidas deste rolê\". Escolha um para registrar.',
      one: '1 item em \"Bebidas deste rolê\". Escolha um para registrar.',
    );
    return '$_temp0';
  }

  @override
  String get catalogDrinkSaved => 'Bebida salva em Minhas bebidas';

  @override
  String get catalogRecipeSaved => 'Receita salva em Minhas bebidas';

  @override
  String get catalogDeleteTitle => 'Excluir esta bebida?';

  @override
  String get catalogDeleteBody =>
      'Ela sai do catálogo. Os registros que você já fez com ela continuam como estão.';

  @override
  String get catalogClearFilters => 'Limpar filtros';

  @override
  String get catalogRemoveFilter => 'Remover filtro';

  @override
  String get catalogFilters => 'Filtros';

  @override
  String get catalogOnlyNoAlcohol => 'Só sem álcool';

  @override
  String get catalogStyle => 'Estilo';

  @override
  String get catalogPresentation => 'Apresentação';

  @override
  String get catalogBrand => 'Marca';

  @override
  String catalogSeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count bebidas',
      one: 'Ver 1 bebida',
    );
    return '$_temp0';
  }

  @override
  String get catalogRecents => 'Recentes';

  @override
  String get catalogFavorites => 'Favoritas';

  @override
  String get catalogAllDrinks => 'Todas as bebidas';

  @override
  String catalogResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get catalogEmptyTitle => 'Nenhuma bebida encontrada';

  @override
  String get catalogEmptyOuting =>
      'Cadastre uma bebida só deste rolê, ou leia um rótulo ou cardápio.';

  @override
  String get catalogEmptyNoFilter =>
      'Cadastre a sua e ela fica salva para os próximos rolês.';

  @override
  String get catalogEmptyFilter =>
      'Tente tirar algum filtro ou cadastre a sua.';

  @override
  String catalogSizes(String count) {
    return '$count tamanhos';
  }

  @override
  String get catalogDetails => 'Detalhes';

  @override
  String get catalogUnfavorite => 'Remover dos favoritos';

  @override
  String get catalogFavorite => 'Favoritar';

  @override
  String get entryDeleteTitle => 'Excluir registro?';

  @override
  String get entryDeleteBody => 'Ele sai do rolê e do resumo.';

  @override
  String get entryDiscardTitle => 'Descartar alterações?';

  @override
  String get entryDiscardBody => 'O que você preencheu aqui será perdido.';

  @override
  String get entryKeepEditing => 'Continuar editando';

  @override
  String get entryDiscard => 'Descartar';

  @override
  String get entryFix => 'Corrigir registro';

  @override
  String get entryLogCocktail => 'Registrar drink';

  @override
  String get entryLogDrink => 'Registrar bebida';

  @override
  String get entryDrinkAndSize => 'Bebida e tamanho';

  @override
  String get entryGenericSpirit =>
      'Doses sugeridas, editáveis: não são medidas oficiais de nenhum estabelecimento. A garrafa é a embalagem, não a sua dose.';

  @override
  String get entryGenericSizes =>
      'Tamanhos sugeridos: este produto não tem embalagens verificadas no catálogo. Confira na embalagem.';

  @override
  String get entryVolume => 'Volume (ml)';

  @override
  String get entryOtherSize => 'Outro tamanho (ml)';

  @override
  String get entryAbvOptional => 'Teor alcoólico (opcional)';

  @override
  String get entryAbvBlank => 'Em branco = desconhecido (não conta como zero).';

  @override
  String get entryAbvCheck => 'Confira no rótulo se puder.';

  @override
  String get entryAbvVariantsIntro =>
      'As fontes divergem. Escolha o que estiver no seu rótulo ou digite:';

  @override
  String get entryBottleShared =>
      'Garrafa que está sendo dividida (preenche o volume da garrafa):';

  @override
  String entryBottlesInfo(String list) {
    return 'Embalagens do produto: $list. Para dividir uma garrafa, marque \"Compartilhada\" abaixo.';
  }

  @override
  String get entryIndividualOrShared => 'Individual ou compartilhada';

  @override
  String get entryOnlyMine => 'Só minha';

  @override
  String get entryShared => 'Compartilhada';

  @override
  String get entryPriceSection => 'Preço (opcional)';

  @override
  String get entryTimeSection => 'Horário';

  @override
  String entryYourShare(String amount) {
    return 'Sua parte: $amount';
  }

  @override
  String get entryYourShareUnknown => 'Sua parte: —';

  @override
  String get entrySaveChanges => 'Salvar alterações';

  @override
  String entryIngredients(String list) {
    return 'Ingredientes: $list';
  }

  @override
  String entrySharedLine(String total, String count) {
    return 'de $total · $count pessoas, com você';
  }

  @override
  String get entryPeople => 'Pessoas (incluindo você)';

  @override
  String get entryFewerPeople => 'Menos uma pessoa';

  @override
  String get entryMorePeople => 'Mais uma pessoa';

  @override
  String get entryAdjustShare => 'Ajustar parcela e sobra';

  @override
  String get entryYourShareMl => 'Sua parte (ml)';

  @override
  String get entryEqualSplit => 'Divisão igual por padrão.';

  @override
  String get entryLeftover => 'Sobra na garrafa (ml)';

  @override
  String get entryOptionalDot => 'Opcional.';

  @override
  String entryOthersEach(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'para cada uma das outras $count pessoas',
      one: 'para a outra pessoa',
    );
    return 'Sobram $amount $_temp0.';
  }

  @override
  String get entryPriceValue => 'Valor';

  @override
  String get entryPriceDontKnow => 'Não sei';

  @override
  String get entryBillTotal => 'Total da conta/garrafa (opcional)';

  @override
  String get entryPaidHelper => 'O que você pagou, não o que bebeu.';

  @override
  String entrySplitEqually(String count) {
    return 'Dividir igualmente ($count pessoas)';
  }

  @override
  String entryComplimentaryNote(String amount) {
    return 'Cortesia conta como $amount informado.';
  }

  @override
  String get entryNoPriceNote =>
      'Sem preço: aparece como \"sem preço\" no resumo.';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String get entryAddIngredient => 'Adicionar ingrediente';

  @override
  String get entryIngredientField => 'Ingrediente';

  @override
  String get entryHasAlcohol => 'Tem álcool';

  @override
  String get entrySaveRecipeTitle => 'Salvar como minha receita';

  @override
  String entryMineSuffix(String name) {
    return '$name (minha)';
  }

  @override
  String get entryRecipeName => 'Nome da receita';

  @override
  String get entrySaveRecipeBody =>
      'Guarda ingredientes, quantidades e teores para reutilizar. Registros antigos não mudam.';

  @override
  String get entryRecipeSaved => 'Receita salva no seu catálogo';

  @override
  String get entryCompositionTitle => 'Composição';

  @override
  String get entryCompositionSimple => 'Informe só o que você sabe.';

  @override
  String entryCompositionReference(String source) {
    return 'Receita de referência ($source). Ajuste para o que foi realmente servido.';
  }

  @override
  String get entryCompositionAdjusted => 'Composição ajustada';

  @override
  String get entryCompositionView => 'Ver e ajustar composição';

  @override
  String get entryNoIngredients => 'Nenhum ingrediente ainda';

  @override
  String get entryDrinkVolumeSection => 'Volume do drink (opcional)';

  @override
  String get entryServedVolume => 'Volume servido (ml)';

  @override
  String get entryServedVolumeHelper =>
      'Se não souber, deixe em branco: o resumo mostra como desconhecido. O tamanho do copo e o gelo não contam como volume bebido.';

  @override
  String get entryPureAlcohol => 'Álcool puro da composição acima';

  @override
  String entryAtLeast(String amount) {
    return 'pelo menos $amount';
  }

  @override
  String entryMissingParts(String list) {
    return 'Faltam teor ou quantidade de: $list';
  }

  @override
  String get entryDeclaredNote =>
      'Vale a composição declarada, assumindo a porção inteira. Não é concentração no sangue.';

  @override
  String entryOptionalMark(String name) {
    return '$name (opcional)';
  }

  @override
  String get entryRemoveIngredient => 'Remover ingrediente';

  @override
  String entryInRecipe(String text) {
    return 'Na receita: $text';
  }

  @override
  String get entryAmount => 'Quantidade';

  @override
  String get entryAmountUnknown => 'Em branco = desconhecida.';

  @override
  String get entryChooseProduct => 'Escolher marca/produto';

  @override
  String get entryComponentAbv => 'Teor alcoólico (% vol.)';

  @override
  String get entryComponentAbvUnknown =>
      'Desconhecido: sem ele o álcool total fica incompleto.';

  @override
  String entryComponentAlcoholNone(String reason) {
    return 'Álcool deste ingrediente: não calculado ($reason).';
  }

  @override
  String entryComponentAlcohol(String amount) {
    return 'Álcool deste ingrediente: $amount';
  }

  @override
  String get entryIncompleteData => 'dados incompletos';

  @override
  String entryWhichProduct(String name) {
    return 'Qual $name?';
  }

  @override
  String get entryNoBrand => 'Sem marca: informar o teor';

  @override
  String entryProductAbv(String abv) {
    return 'Teor $abv';
  }

  @override
  String get entryProductAbvVaries => 'Teor varia conforme a fonte';

  @override
  String get entryProductAbvUnknown => 'Teor não informado';

  @override
  String get entryMenuPrice => 'Preço do cardápio';

  @override
  String entryMenuPriceBody(String price) {
    return 'O cardápio anunciava $price. É só uma sugestão: confirme o que foi pago de fato, pois pode ter promoção ou outro pedido. Se for garrafa ou jarra dividida, marque \"Compartilhada\": o valor vira o total da conta, não a sua parte.';
  }

  @override
  String get entryUseAsBillTotal => 'Usar como total da conta';

  @override
  String get entryUseAsPaid => 'Usar como o que paguei';

  @override
  String get entryHistory => 'Seu histórico';

  @override
  String entryHistoryShare(String price, String scope, String date) {
    return 'Sua parcela foi $price $scope em $date.';
  }

  @override
  String entryHistoryPaid(String price, String scope, String date) {
    return 'Você pagou $price $scope em $date.';
  }

  @override
  String get entryUseAsShare => 'Usar como minha parcela';

  @override
  String get entryUseValue => 'Usar este valor';

  @override
  String entryHistoryTotal(String price, String date) {
    return 'O total da garrafa/porção foi $price em $date.';
  }

  @override
  String get entryUseAsTotal => 'Usar como total';

  @override
  String get entryScopeAtPlace => 'neste local';

  @override
  String get entryScopeAtOuting => 'neste rolê';

  @override
  String get draftVolumeInvalid => 'Volume inválido';

  @override
  String get draftAbvRange => 'O teor vai de 0 a 100%';

  @override
  String get draftAmountInvalid => 'Quantidade inválida';

  @override
  String get draftVolumeRequired => 'Informe o volume em ml';

  @override
  String get draftVolumeTooHigh => 'Volume alto demais';

  @override
  String get draftShareRequired => 'Informe a sua parte em ml';

  @override
  String draftShareOver(String volume) {
    return 'Sua parte + sobra passam do volume ($volume)';
  }

  @override
  String draftBeforeStart(String time) {
    return 'Antes do início do rolê ($time)';
  }

  @override
  String get draftNotFuture => 'O horário não pode estar no futuro';

  @override
  String draftAfterEnd(String time) {
    return 'Depois do fim do rolê ($time)';
  }

  @override
  String get draftPaidRequired => 'Informe o valor ou escolha outra opção';

  @override
  String get formSaveRecipeFailed => 'Não foi possível salvar a receita.';

  @override
  String get formSaveFailed =>
      'Não foi possível salvar. Nada foi perdido, tente de novo.';

  @override
  String get priceBulkTitle => 'Aplicar este preço às bebidas iguais?';

  @override
  String priceBulkBody(
    String name,
    String price,
    int total,
    int unpriced,
    int differing,
  ) {
    return '$name por $price. Neste rolê há $total registros iguais: $unpriced sem preço e $differing com outro preço. Nada muda sem a sua escolha.';
  }

  @override
  String priceBulkUnpriced(int count) {
    return 'Aplicar aos $count sem preço';
  }

  @override
  String priceBulkAll(int count) {
    return 'Aplicar a todos os $count iguais';
  }

  @override
  String get priceBulkOnlyThis => 'Só este registro';

  @override
  String get priceBulkConfirmTitle => 'Substituir preços?';

  @override
  String priceBulkConfirmBody(int count) {
    return 'Isso troca o preço de $count registros que já tinham outro valor. Os demais rolês não mudam.';
  }

  @override
  String get priceBulkReplace => 'Substituir';

  @override
  String priceBulkApplied(int count) {
    return 'Preço aplicado a $count registros.';
  }

  @override
  String get formDeleteFailed => 'Não foi possível excluir. Tente de novo.';

  @override
  String get detailNotGiven => 'Não informado';

  @override
  String get detailAbv => 'Teor alcoólico';

  @override
  String detailAbvFrom(String source) {
    return 'Teor: $source. Não é dado do fabricante.';
  }

  @override
  String get detailIngredients => 'Ingredientes declarados';

  @override
  String get detailIngredientsNone => 'Não informados';

  @override
  String get detailPresentations => 'Apresentações';

  @override
  String get detailBottleNotDose =>
      'Tamanho da garrafa não é tamanho da dose. Ao registrar, você escolhe uma dose sugerida (editável) ou compartilha a garrafa.';

  @override
  String get detailUnverifiedPackages =>
      'Embalagens não verificadas para este produto. Ao registrar, você pode escolher um tamanho sugerido ou digitar o volume.';

  @override
  String get detailPackagesNote =>
      'Embalagens citadas pelo fabricante. O tamanho da embalagem não é o que você bebeu: isso você define ao registrar.';

  @override
  String get detailMakeMine => 'Criar minha versão';

  @override
  String get detailSourceTitle => 'Fonte dos dados';

  @override
  String detailSourceLine(String source, String date) {
    return '$source · consultado em $date';
  }

  @override
  String get detailCopyAddress => 'Copiar endereço';

  @override
  String get detailAddressCopied => 'Endereço copiado';

  @override
  String get detailMayVary =>
      'Os dados podem variar por versão e mercado. Confira sempre o rótulo da embalagem.';

  @override
  String detailAbvVaries(String lines) {
    return 'Varia conforme a fonte, sem um valor único:\n$lines';
  }

  @override
  String get detailRecipeReference =>
      'Receita de referência: mostra como a receita é publicada, não o que um bar serviu.';

  @override
  String get detailRecipeMine =>
      'Sua receita salva. Ao registrar, você ajusta o que realmente foi servido.';

  @override
  String get detailNoIngredientsYet =>
      'Sem ingredientes ainda: você monta ao registrar.';

  @override
  String get detailAlcoholLegend =>
      'Ingredientes com copo ao lado têm álcool. O teor de cada um é informado ao registrar; sem ele o álcool total fica incompleto. Gelo não entra na conta.';

  @override
  String get detailMethod => 'Preparo';

  @override
  String detailGarnish(String text) {
    return 'Decoração: $text';
  }

  @override
  String get customEditTitle => 'Editar bebida';

  @override
  String get customSaveFailed =>
      'Não foi possível salvar. Seus dados continuam aqui.';

  @override
  String get customEditNote =>
      'As mudanças valem para os próximos registros. O que você já registrou continua como estava.';

  @override
  String get customNewNote =>
      'Fica salva para você usar de novo nos próximos rolês.';

  @override
  String get customType => 'Tipo';

  @override
  String get customIdentification => 'Identificação';

  @override
  String get customName => 'Nome da bebida';

  @override
  String get customNameRequired => 'Dê um nome para a bebida';

  @override
  String get customBrand => 'Marca (opcional)';

  @override
  String get customStyle => 'Estilo (opcional)';

  @override
  String get customSizeAndAbv => 'Tamanho e teor';

  @override
  String get customSize => 'Tamanho (ml)';

  @override
  String get customSizeRequired => 'Informe o tamanho em ml';

  @override
  String get customAbvHelper =>
      'Em branco = desconhecido, não conta como zero.';

  @override
  String get customIngredients => 'Ingredientes (opcional)';

  @override
  String get customIngredientsHelper =>
      'Separe por vírgula. Só o que você sabe.';

  @override
  String get customSaveUse => 'Salvar e usar';

  @override
  String get recipeUnitLabel => 'Unidade';

  @override
  String get myDrinksNeedOuting => 'Inicie um rolê para registrar uma bebida.';

  @override
  String get myDrinksLogged => 'Bebida registrada';

  @override
  String get myDrinksCopied => 'Cópia criada';

  @override
  String myDrinksDeleteTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get myDrinksDeleteBody =>
      'Sai do seu catálogo. Os registros que você já fez continuam como estão.';

  @override
  String get myDrinksDeleted => 'Excluída';

  @override
  String myDrinksRecipeSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Receita · $count ingredientes',
      one: 'Receita · 1 ingrediente',
    );
    return '$_temp0';
  }

  @override
  String get myDrinksTitle => 'Minhas bebidas e receitas';

  @override
  String get myDrinksEmptyTitle => 'Nada por aqui ainda';

  @override
  String get myDrinksEmptyBody =>
      'Bebidas e receitas que você cadastrar ficam aqui para reutilizar nos próximos rolês.';

  @override
  String get myDrinksStartFirst => 'Para registrar, inicie um rolê primeiro.';

  @override
  String get myDrinksActionLog => 'Registrar';

  @override
  String get myDrinksActionDuplicate => 'Duplicar';

  @override
  String get myDrinksNewDrink => 'Nova bebida';

  @override
  String get myDrinksNewRecipe => 'Nova receita';

  @override
  String recipeEditorNameCopy(String name) {
    return '$name (minha versão)';
  }

  @override
  String get recipeEditorNeedName => 'Dê um nome para a receita.';

  @override
  String get recipeEditorNeedIngredient =>
      'Adicione pelo menos um ingrediente.';

  @override
  String get recipeEditorIngredientName =>
      'Todo ingrediente precisa de um nome.';

  @override
  String recipeEditorAbvRange(String name) {
    return 'O teor de \"$name\" vai de 0 a 100%.';
  }

  @override
  String recipeEditorAmountInvalid(String name) {
    return 'A quantidade de \"$name\" é inválida.';
  }

  @override
  String recipeEditorNumberProblem(String name, String problem) {
    return '\"$name\": $problem';
  }

  @override
  String get recipeEditorEditTitle => 'Editar receita';

  @override
  String get recipeEditorNewTitle => 'Nova receita';

  @override
  String get recipeEditorIntro =>
      'Registre só o que você sabe. Quantidade ou teor em branco ficam como desconhecidos e o álcool total aparece como incompleto.';

  @override
  String get recipeEditorNameSection => 'Nome';

  @override
  String get recipeEditorNameRequired => 'Dê um nome para a receita';

  @override
  String get recipeEditorIngredients => 'Ingredientes';

  @override
  String get recipeEditorNoneYet => 'Nenhum ingrediente ainda.';

  @override
  String get recipeEditorAlcoholSection => 'Álcool da composição';

  @override
  String get recipeEditorDeclaredAlcohol => 'Álcool puro declarado';

  @override
  String get recipeEditorSaveRecipe => 'Salvar receita';

  @override
  String get recipeEditorMoveUp => 'Mover para cima';

  @override
  String get recipeEditorMoveDown => 'Mover para baixo';

  @override
  String recipeEditorOriginal(String text) {
    return 'Na receita original: $text';
  }

  @override
  String get recipeEditorRole => 'Tipo (para escolher a marca ao registrar)';

  @override
  String get recipeEditorNoRole => 'Sem tipo';

  @override
  String get recipeEditorRemove => 'Remover';

  @override
  String get scanLabelPhotoGone =>
      'A foto desta leitura não está mais disponível neste aparelho. O texto foi mantido: tire outra foto ou continue sem ela.';

  @override
  String get scanPhotoSaveFailed =>
      'Não foi possível guardar a foto no aparelho.';

  @override
  String get scanRotateFailed => 'Não foi possível girar a imagem.';

  @override
  String get scanPhotoUnavailableToRead =>
      'A foto não está disponível para leitura. Tire outra.';

  @override
  String get scanNoTextFound =>
      'Nenhum texto foi encontrado. Tente outra foto mais de perto, com boa luz, ou digite o texto.';

  @override
  String get scanLabelTip =>
      'Enquadre o rótulo inteiro, de frente, com boa luz e sem reflexo. Volume e teor costumam ficar em outro lado da embalagem: fotografe esse lado ou complete na revisão. Você confere tudo antes de salvar.';

  @override
  String get scanLabelEnded =>
      'Este rolê já foi encerrado. O que você ler fica salvo nele.';

  @override
  String get scanWebPhotoSession =>
      'No navegador a foto só fica guardada durante esta sessão.';

  @override
  String get scanPhoto => 'Foto';

  @override
  String get scanTakePhoto => 'Tirar foto';

  @override
  String get scanChooseGallery => 'Escolher da galeria';

  @override
  String get scanRotateLeft => 'Girar para a esquerda';

  @override
  String get scanRotateRight => 'Girar para a direita';

  @override
  String get scanNewPhoto => 'Nova foto';

  @override
  String get scanReplacePhoto => 'Trocar';

  @override
  String get scanDiscardReading => 'Descartar leitura';

  @override
  String get scanReadingOnDevice => 'Lendo o texto da foto neste aparelho…';

  @override
  String get scanCancelReading => 'Cancelar leitura';

  @override
  String get scanReadAgain => 'Ler de novo';

  @override
  String get scanOcrUnavailable =>
      'A leitura automática não está disponível aqui (só no app para Android e iOS). Veja a foto e digite ou cole o texto do rótulo, ou preencha direto.';

  @override
  String get scanLabelText => 'Texto do rótulo';

  @override
  String get scanTextHintCanRead =>
      'O texto lido aparece aqui. Você pode corrigir.';

  @override
  String get scanTextHintManual =>
      'Digite ou cole o texto do rótulo (opcional)';

  @override
  String get scanInterpret => 'Interpretar texto';

  @override
  String get scanFillManually => 'Preencher manualmente';

  @override
  String get photoUnavailable =>
      'Foto indisponível agora: ainda não enviada pelo outro aparelho, ou sem conexão. O registro continua salvo.';

  @override
  String get photoDelete => 'Excluir foto';

  @override
  String get photoDeleteTitle => 'Excluir esta foto?';

  @override
  String get photoDeleteBody =>
      'Só a foto sai. As bebidas e os dados que você confirmou continuam no rolê.';

  @override
  String get captureCameraUnavailable =>
      'A câmera não está disponível aqui. Escolha uma foto da galeria.';

  @override
  String get captureGalleryUnavailable => 'A galeria não está disponível aqui.';

  @override
  String get capturePermissionCamera =>
      'Sem permissão para usar a câmera. Libere nas configurações do aparelho ou escolha outra opção.';

  @override
  String get capturePermissionGallery =>
      'Sem permissão para usar a galeria. Libere nas configurações do aparelho ou escolha outra opção.';

  @override
  String get captureOpenCameraFailed => 'Não foi possível abrir a câmera.';

  @override
  String get captureOpenGalleryFailed => 'Não foi possível abrir a galeria.';

  @override
  String get captureFailed => 'Não foi possível abrir a captura de imagem.';

  @override
  String get captureUnreadable => 'Não foi possível ler essa imagem.';

  @override
  String get captureTooBig => 'A imagem é muito grande. Tente uma foto menor.';

  @override
  String get captureNotImage =>
      'Esse arquivo não parece ser uma imagem válida.';

  @override
  String get ocrUnavailable =>
      'A leitura automática não está disponível neste dispositivo.';

  @override
  String get ocrReadFailed => 'Não foi possível ler o texto desta foto.';

  @override
  String matchOtherCategory(String category) {
    return 'Categoria diferente (catálogo: $category)';
  }

  @override
  String matchSameSize(String size) {
    return 'Mesmo tamanho ($size)';
  }

  @override
  String matchOtherSize(String sizes) {
    return 'Outro tamanho (catálogo: $sizes)';
  }

  @override
  String matchSameAbv(String abv) {
    return 'Mesmo teor ($abv)';
  }

  @override
  String matchOtherAbv(String catalog, String yours) {
    return 'Teor diferente (catálogo: $catalog, seu: $yours)';
  }

  @override
  String get matchAbvVaries => 'O teor do catálogo varia por fonte';

  @override
  String get matchNoAbv => 'Catálogo sem teor para comparar';

  @override
  String matchOtherBrand(String brand) {
    return 'Outra marca ($brand)';
  }

  @override
  String get matchRecipe =>
      'Receita de referência: o drink servido pode ser diferente';

  @override
  String get matchSimilar =>
      'Parecida pelo nome: confirme se é o mesmo produto';

  @override
  String parseManyVolumes(String list) {
    return 'Mais de um volume no texto ($list). Escolha o da embalagem.';
  }

  @override
  String parseManyAbvs(String list) {
    return 'Mais de um teor no texto ($list). Confira no rótulo.';
  }

  @override
  String get parseCheckName =>
      'Confira o nome e a marca. Toque nas sugestões para trocar.';

  @override
  String menuNoteColumns(String count) {
    return 'O cardápio parece ter $count colunas. Confira se cada preço ficou no item certo.';
  }

  @override
  String menuNoteOrphans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count preços sem item claro foram ignorados. Adicione o item manualmente se precisar.',
      one: '1 preço sem item claro foi ignorado. Adicione o item manualmente se precisar.',
    );
    return '$_temp0';
  }

  @override
  String get menuNoteNone =>
      'Nenhum item foi identificado. Cole ou digite o texto, ou adicione os itens manualmente.';

  @override
  String get scanMenuReviewTitle => 'Itens do cardápio';

  @override
  String scanMenuLostPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos desta leitura não estão mais disponíveis. Os itens delas foram mantidos para você conferir.',
      one: 'Uma foto desta leitura não está mais disponível. Os itens dela foram mantidos para você conferir.',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoItemsRead =>
      'Nenhum item foi identificado. Gire a foto, tente de perto ou cole o texto do cardápio.';

  @override
  String get scanMenuNoItems => 'Nenhum item foi identificado.';

  @override
  String get scanMenuNoneSelected => 'Nenhum item selecionado.';

  @override
  String get scanMenuUnnamed => 'Há item sem nome. Corrija ou descarte.';

  @override
  String get scanMenuNeedType =>
      'Escolha o tipo dos itens marcados com \"Tipo?\".';

  @override
  String get scanMenuSaveFailed =>
      'Não foi possível salvar. Seus itens continuam aqui.';

  @override
  String get scanMenuDiscardTitle => 'Descartar esta leitura?';

  @override
  String get scanMenuDiscardBody =>
      'As fotos e os itens ainda não confirmados serão apagados.';

  @override
  String get scanMenuTip =>
      'Fotografe uma página por vez, de frente e com boa luz, sem cortar os preços. Pode adicionar várias fotos. Você confere e corrige cada item antes de salvar.';

  @override
  String get scanMenuEnded =>
      'Este rolê já foi encerrado. Os itens ficam salvos nele.';

  @override
  String get scanMenuWebPhotos =>
      'No navegador as fotos só ficam guardadas durante esta sessão.';

  @override
  String scanMenuPhotos(String count) {
    return 'Fotos ($count)';
  }

  @override
  String scanMenuPhotoN(String number) {
    return 'Foto $number';
  }

  @override
  String get scanMenuRead => 'Lida';

  @override
  String get scanMenuUnread => 'Ainda não lida';

  @override
  String get scanRemovePhoto => 'Remover foto';

  @override
  String get scanAnotherPhoto => 'Mais uma foto';

  @override
  String get scanMenuReadingMany => 'Lendo o texto das fotos neste aparelho…';

  @override
  String get scanMenuSeeRead => 'Ver itens lidos';

  @override
  String get scanMenuOcrUnavailable =>
      'A leitura automática não está disponível aqui (só no app para Android e iOS). Veja as fotos e digite ou cole o texto do cardápio, ou adicione os itens à mão.';

  @override
  String get scanMenuPastedSection => 'Texto do cardápio (opcional)';

  @override
  String get scanMenuPastedHint =>
      'Um item por linha, com o preço na mesma linha ou na seguinte. Ex.: Caipirinha R\$ 18,00';

  @override
  String get scanMenuAddManual => 'Adicionar item à mão';

  @override
  String scanMenuSeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count itens',
      one: 'Ver 1 item',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuReviewIntro =>
      'Marque os itens que quer deixar disponíveis neste rolê. Nada é registrado como consumo agora: você escolhe a bebida e confirma o preço quando for pedir.';

  @override
  String get scanMenuPhotosAndReading => 'Fotos e leitura';

  @override
  String get scanMenuAddItem => 'Adicionar item';

  @override
  String scanMenuSave(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count itens neste rolê',
      one: 'Salvar 1 item neste rolê',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoName => '(sem nome)';

  @override
  String scanMenuSize(String size) {
    return 'Tamanho no cardápio: $size';
  }

  @override
  String scanMenuIngredientsCited(String list) {
    return 'Ingredientes citados: $list';
  }

  @override
  String get scanMenuEditItem => 'Editar item';

  @override
  String get scanMenuTypeHint => 'Tipo?';

  @override
  String get scanMenuDuplicate => 'Repetido em outra foto';

  @override
  String get scanMenuPromo => 'Possível promoção: confirme o valor';

  @override
  String scanMenuPriceOnMenu(String price) {
    return '$price no cardápio';
  }

  @override
  String get scanMenuNoPriceRead => 'Sem preço lido';

  @override
  String get scanMenuPriceUnsure =>
      'Não deu para ter certeza do preço. Escolha o certo ou deixe sem preço:';

  @override
  String get scanMenuChangePrice => 'Trocar preço';

  @override
  String get scanMenuNewItem => 'Novo item';

  @override
  String get scanMenuName => 'Nome';

  @override
  String get scanMenuDescription => 'Descrição (opcional)';

  @override
  String get scanMenuSizeOptional => 'Tamanho (opcional)';

  @override
  String get scanMenuPriceOptional => 'Preço (opcional)';

  @override
  String get scanMenuCitedOptional => 'Ingredientes citados (opcional)';

  @override
  String get scanMenuCitedHelper => 'Separe por vírgula. Sem quantidades.';

  @override
  String get scanMenuNeedName => 'Dê um nome ao item.';

  @override
  String get scanMenuInvalidSize => 'Tamanho inválido.';

  @override
  String get scanMenuInvalidPrice => 'Preço inválido.';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get originManual => 'Cadastro neste rolê';

  @override
  String get originPhotoLabel => 'Foto do rótulo';

  @override
  String get originMenu => 'Foto do cardápio';

  @override
  String get outingReviewEditTitle => 'Editar bebida do rolê';

  @override
  String get outingReviewTitle => 'Bebida deste rolê';

  @override
  String get outingReviewIsolation =>
      'Esta bebida existe só neste rolê. Ela não entra no catálogo, nem em Minhas bebidas, nem em outros rolês.';

  @override
  String get outingReviewEnded =>
      'Este rolê já foi encerrado. O item fica salvo nele.';

  @override
  String get outingReviewDrinkSection => 'Bebida';

  @override
  String get outingReviewNeedName => 'Dê um nome para a bebida.';

  @override
  String get outingReviewNeedType => 'Escolha o tipo da bebida.';

  @override
  String get outingReviewVolumePositive =>
      'O volume precisa ser maior que zero.';

  @override
  String get outingReviewAbvRange => 'O teor vai de 0 a 100%.';

  @override
  String get outingReviewOtherLines => 'Outras linhas lidas (toque para usar):';

  @override
  String get outingReviewPickType => 'Escolha o tipo da bebida';

  @override
  String get outingReviewTypeUnknown => 'Tipo não identificado: escolha um.';

  @override
  String get outingReviewDescription => 'Descrição do cardápio (opcional)';

  @override
  String get outingReviewPackageVolume => 'Volume da embalagem (opcional)';

  @override
  String get outingReviewVolumeHelper =>
      'É o tamanho do produto, não o quanto você bebeu. Em branco = desconhecido.';

  @override
  String outingReviewAbvSource(String source) {
    return 'Origem: $source';
  }

  @override
  String get outingReviewIngredientsIntro =>
      'Só o que o cardápio ou você informaram. As quantidades ficam desconhecidas até você completar ao registrar; o álcool só é calculado com volume e teor conhecidos.';

  @override
  String get outingReviewAlcoholChip => 'Álcool';

  @override
  String get outingReviewDeclaredOptional =>
      'Ingredientes declarados (opcional)';

  @override
  String get outingReviewDeclaredHelper =>
      'Separe por vírgula. Só o que está escrito.';

  @override
  String get outingReviewAdvertisedSection => 'Preço anunciado';

  @override
  String get outingReviewMenuPriceOptional => 'Preço do cardápio (opcional)';

  @override
  String get outingReviewMenuPriceHelper =>
      'Só uma sugestão: ao registrar você confirma o que pagou. Valores em reais (R\$).';

  @override
  String get outingReviewSimilar => 'Parecidas no catálogo';

  @override
  String get outingReviewSearch => 'Buscar';

  @override
  String get outingReviewSimilarNote =>
      'Opcional. Escolher uma é só uma referência: o produto do catálogo nunca é alterado e nada é ligado sozinho.';

  @override
  String get outingReviewNothingSimilar =>
      'Nada parecido encontrado. Este item fica só no rolê.';

  @override
  String get outingReviewReferenceChosen => 'Referência escolhida';

  @override
  String get outingReviewUseReference => 'Usar como referência';

  @override
  String get outingReviewFillEmpty => 'Preencher campos vazios';

  @override
  String get outingReviewCopyIngredients =>
      'Copiar ingredientes (sem quantidades)';

  @override
  String get outingReviewOriginSection => 'Origem dos dados';

  @override
  String get outingReviewOriginManual => 'Preenchido por você.';

  @override
  String get outingReviewOriginPhoto =>
      'Lido da foto e conferido por você. Leitura automática pode errar: confira cada campo.';

  @override
  String get outingReviewReferenceNote =>
      'Com referência do catálogo (não é o mesmo registro).';

  @override
  String get outingReviewSourceText => 'Texto lido na foto';

  @override
  String get outingReviewConfirmContinue => 'Confirmar e continuar';

  @override
  String get outingReviewSaveOnly => 'Salvar só neste rolê';

  @override
  String get outingDrinksSectionTitle => 'Bebidas deste rolê';

  @override
  String get outingDrinksTapToLog =>
      'Só existem neste rolê. Toque para registrar uma.';

  @override
  String get outingDrinksRemoveTitle => 'Tirar da lista do rolê?';

  @override
  String get outingDrinksRemoveBody =>
      'Ela sai de \"Bebidas deste rolê\". Os registros que você já fez continuam no histórico.';

  @override
  String get outingDrinksRemove => 'Tirar';

  @override
  String get outingDrinksMoreActions => 'Mais ações';

  @override
  String get outingDrinksRemoveFromList => 'Tirar da lista';

  @override
  String outingDrinksMenuPrice(String price) {
    return 'cardápio $price';
  }

  @override
  String get outingScanUnfinishedMenu => 'Leitura de cardápio não concluída';

  @override
  String get outingScanUnfinishedLabel => 'Leitura de rótulo não concluída';

  @override
  String get outingScanUnfinishedNote =>
      'Ela continua ligada a este rolê. Se você concluir agora, o resultado fica salvo nele, não em outro.';

  @override
  String get outingScanOnlyHere => 'Existem só neste rolê.';

  @override
  String get outingScanPhotosTitle => 'Fotos do rolê';

  @override
  String get outingScanAllUploaded =>
      'Fotos guardadas também na nuvem, em arquivo privado.';

  @override
  String outingScanPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos ainda só neste aparelho; o envio é tentado de novo sozinho.',
      one: '1 foto ainda só neste aparelho; o envio é tentado de novo sozinho.',
    );
    return '$_temp0';
  }

  @override
  String outingScanLocalOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos só neste aparelho.',
      one: '1 foto só neste aparelho.',
    );
    return '$_temp0';
  }

  @override
  String get photoKindLabel => 'Rótulo';

  @override
  String get photoKindMenu => 'Cardápio';

  @override
  String get pickerStartTitle => 'Onde é o rolê?';

  @override
  String get pickerChangeTitle => 'Corrigir local';

  @override
  String get pickerLocateTitle => 'Localização do local';

  @override
  String get pickerAlreadySavedTitle => 'Lugar já salvo';

  @override
  String pickerAlreadySavedBody(String name) {
    return 'Este lugar já está nos seus locais como \"$name\". Usar aqui também?';
  }

  @override
  String get pickerUseAnyway => 'Usar mesmo assim';

  @override
  String get pickerSearchHint => 'Buscar bar, restaurante ou endereço';

  @override
  String get pickerClearSearch => 'Limpar busca';

  @override
  String get pickerUseLocation => 'Usar minha localização';

  @override
  String get pickerApproximate =>
      'Localização aproximada: confira o lugar na lista ou no mapa.';

  @override
  String get pickerLocationHint =>
      'Mostra lugares por perto. Você sempre confirma onde está.';

  @override
  String get pickerNicknameOnly => 'Informar apenas um apelido';

  @override
  String get pickerNicknameOnlyExample =>
      'Sem mapa nem endereço. Ex.: Casa da Samara';

  @override
  String get pickerNicknameOnlyShort => 'Sem mapa nem endereço.';

  @override
  String get pickerYourPlaces => 'Seus locais';

  @override
  String get pickerNotConfiguredFull =>
      'A busca de lugares e o mapa não estão configurados nesta versão. Apelido, endereço digitado e locais salvos funcionam normalmente.';

  @override
  String get pickerNearYou => 'Perto de você';

  @override
  String get pickerNothingNearby =>
      'Nenhum bar ou restaurante encontrado bem perto. Você pode buscar pelo nome ou marcar só o ponto.';

  @override
  String get pickerPinOnly => 'Marcar só este ponto no mapa';

  @override
  String get pickerPinOnlyHint => 'Você pode dar um apelido em seguida.';

  @override
  String get pickerNotConfigured =>
      'A busca de lugares não está configurada nesta versão.';

  @override
  String get pickerMinChars => 'Digite pelo menos 3 letras para buscar.';

  @override
  String get pickerNothingFound =>
      'Nada encontrado. Tente o nome com o bairro ou a cidade, ou informe só um apelido.';

  @override
  String get pickerResults => 'Resultados';

  @override
  String get pickerErrorOffline =>
      'Sem internet agora. Você ainda pode usar um local salvo ou informar um apelido.';

  @override
  String get pickerErrorUnavailable =>
      'A busca está indisponível no momento. Você ainda pode usar um local salvo ou informar um apelido.';

  @override
  String get pickerLocServiceOff => 'A localização do aparelho está desligada.';

  @override
  String get pickerOpenSettings => 'Abrir ajustes';

  @override
  String get pickerLocDenied =>
      'Sem permissão de localização. Você pode buscar pelo nome ou endereço normalmente.';

  @override
  String get pickerLocDeniedForever =>
      'A localização foi negada para o Bebômetro. Se quiser usá-la, libere nos ajustes do aparelho. A busca funciona sem ela.';

  @override
  String get pickerLocTimeout =>
      'Não foi possível obter a localização a tempo.';

  @override
  String get pickerLocUnavailable =>
      'A localização não está disponível aqui. Busque pelo nome ou endereço.';

  @override
  String pickerSavedAs(String name) {
    return 'Salvo como \"$name\"';
  }

  @override
  String get pickerManualNickname => 'Apelido';

  @override
  String get pickerManualHint => 'Ex.: Casa da Samara';

  @override
  String get pickerManualHelper => 'O apelido sozinho já basta.';

  @override
  String get pickerAddAddress => 'Adicionar endereço (opcional)';

  @override
  String get pickerNeedNicknameOrAddress =>
      'Informe um apelido (ex.: Casa da Samara) ou um endereço';

  @override
  String get pickerStateTwoLetters => 'A UF tem 2 letras';

  @override
  String get placeSaveToMine => 'Salvar nos meus locais';

  @override
  String get placeSaveToMineHint =>
      'Para escolher de novo nos próximos rolês. Fica privado.';

  @override
  String get pickerUseThisPlace => 'Usar este local';

  @override
  String distanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get confirmTitle => 'Conferir local';

  @override
  String get confirmTapMap =>
      'Toque no mapa para ajustar o ponto, se precisar.';

  @override
  String get confirmMapFailed =>
      'O mapa não carregou. Você pode confirmar pelos dados abaixo.';

  @override
  String get confirmNoAddress => 'Sem endereço confirmado para este ponto.';

  @override
  String confirmAdjustedWas(String name) {
    return 'Ponto ajustado: \"$name\" e o endereço dele não valem mais para este ponto.';
  }

  @override
  String get confirmAdjusted => 'Ponto ajustado por você.';

  @override
  String get confirmLookUp => 'Buscar endereço deste ponto';

  @override
  String get confirmNoAddressFound =>
      'Nenhum endereço encontrado para este ponto.';

  @override
  String get confirmOfflinePointKept =>
      'Sem internet. O ponto continua marcado.';

  @override
  String get confirmLookUpFailed => 'Não foi possível buscar o endereço agora.';

  @override
  String confirmAlreadySaved(String name) {
    return 'Você já salvou este lugar como \"$name\". Ele será reaproveitado.';
  }

  @override
  String confirmAlreadySavedNick(String name) {
    return 'Você já salvou este lugar como \"$name\". Ele será reaproveitado e o apelido continua.';
  }

  @override
  String get confirmNicknameSection => 'Apelido (opcional)';

  @override
  String get confirmNicknameHelper =>
      'Aparece no lugar do nome. O endereço fica nos detalhes.';

  @override
  String confirmUseAsNickname(String name) {
    return 'Usar \"$name\" como apelido';
  }

  @override
  String get confirmNeedNickname => 'Dê um apelido para salvar este ponto.';

  @override
  String get placeFallbackName => 'Local';

  @override
  String get placePointOnMap => 'Ponto no mapa';

  @override
  String get changePlaceTitle => 'Trocar o local deste rolê?';

  @override
  String changePlaceBody(String name) {
    return 'O rolê passa a ser \"$name\". Só este rolê muda: as bebidas, fotos e a comanda continuam nele, e os outros rolês não são alterados.';
  }

  @override
  String get changePlaceConfirm => 'Trocar local';

  @override
  String get changePlaceDone => 'Local do rolê atualizado';

  @override
  String get changePlaceFailed =>
      'Não foi possível trocar o local. Nada foi alterado.';

  @override
  String get openMapsFailed => 'Não foi possível abrir um aplicativo de mapas.';

  @override
  String get mapSemantics => 'Mapa com o ponto do local';

  @override
  String get mapZoomIn => 'Aproximar';

  @override
  String get mapZoomOut => 'Afastar';

  @override
  String get mapCenter => 'Centralizar no ponto';

  @override
  String get placeNotFound => 'Esse local não foi encontrado.';

  @override
  String get placeScreenTitle => 'Local';

  @override
  String get placeReactivated => 'Local reativado';

  @override
  String get placeArchivedToast => 'Local arquivado';

  @override
  String get placeReactivate => 'Reativar';

  @override
  String get placeArchive => 'Arquivar';

  @override
  String get placeArchivedPill => 'Arquivado';

  @override
  String get placeStatOutings => 'Rolês';

  @override
  String get placeStatDrinks => 'Suas bebidas';

  @override
  String get placeStatSpent => 'Seu gasto informado';

  @override
  String placeLastVisit(String date) {
    return 'Última visita: $date';
  }

  @override
  String get placeStartHere => 'Iniciar rolê aqui';

  @override
  String get placeOpenMap => 'Abrir no mapa';

  @override
  String get placeSpendNote =>
      'Gasto informado: o que você registrou nas suas bebidas aqui. O total da mesa e os pagamentos da comanda ficam no resumo de cada rolê e não entram nesta soma.';

  @override
  String get placePriceHistory => 'Seu histórico de preços';

  @override
  String get placePriceHistoryNone =>
      'Ainda não há preços informados por você aqui. Quando houver, o último preço e a faixa observada aparecem neste lugar.';

  @override
  String get placePriceHistoryNote =>
      'Seu histórico: só o que você mesmo informou neste local, por bebida e tamanho. Não é média de mercado, da cidade nem do estado.';

  @override
  String placeVisits(String count) {
    return 'Rolês neste local ($count)';
  }

  @override
  String get placeNoVisits => 'Nenhum rolê registrado aqui ainda.';

  @override
  String get placeVisitInProgress => 'em andamento';

  @override
  String get placeNoValues => 'sem valores';

  @override
  String rangeTo(String from, String to) {
    return '$from a $to';
  }

  @override
  String placePriceLast(String price, String date) {
    return 'Último: $price em $date';
  }

  @override
  String placePriceLastShared(String price, String date) {
    return 'Último: $price em $date (total da garrafa/porção)';
  }

  @override
  String placePriceRangeLine(String range, int count, String period) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return 'Faixa observada: $range · $_temp0 · $period';
  }

  @override
  String get placeAlreadyActive =>
      'Já existe um rolê em andamento. Encerre-o antes.';

  @override
  String get placeFieldMapName => 'Nome no mapa';

  @override
  String get placeFieldAddress => 'Endereço';

  @override
  String get placeFieldCity => 'Cidade';

  @override
  String get placeFieldOrigin => 'Origem';

  @override
  String get placeSourceSearch => 'Escolhido na busca (OpenStreetMap)';

  @override
  String get placeSourceLocation => 'Sua localização, conferida no mapa';

  @override
  String get placeSourceAdjusted => 'Ponto ajustado por você';

  @override
  String get placeSourceManual => 'Informado por você';

  @override
  String get placeDetailsTitle => 'Detalhes';

  @override
  String get placeNoPointNoAddress =>
      'Sem endereço nem ponto no mapa. Dá para buscar em \"Editar\".';

  @override
  String get placesEmptyTitle => 'Nenhum local salvo';

  @override
  String get placesEmptyBody =>
      'Salve os lugares onde você costuma ir para escolher rápido ao iniciar um rolê. Eles ficam privados no seu perfil.';

  @override
  String get placesArchivedSection => 'Arquivados';

  @override
  String get placesNew => 'Novo local';

  @override
  String placesVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rolês',
      one: '1 rolê',
    );
    return '$_temp0';
  }

  @override
  String get placeEditTitle => 'Editar local';

  @override
  String get placeEditorNote =>
      'As mudanças valem para os próximos rolês. Os rolês que já aconteceram mantêm o nome e o endereço de quando foram feitos.';

  @override
  String get placeEditorLocation => 'Localização';

  @override
  String get placeEditorSourceSearch =>
      'Escolhido na busca (dados do OpenStreetMap)';

  @override
  String get placeEditorSourceAdjusted => 'Ponto ajustado por você no mapa';

  @override
  String get placeEditorNoPointHint =>
      'Opcional. Apelido ou endereço já bastam.';

  @override
  String get placeEditorPointSaved => 'Ponto salvo';

  @override
  String get placeEditorNoPoint => 'Sem ponto no mapa';

  @override
  String get placeEditorSearchMap => 'Buscar no mapa';

  @override
  String get placeEditorSearchAdjust => 'Buscar ou ajustar';

  @override
  String get placeEditorRemoveFromMap => 'Remover do mapa';

  @override
  String get placeEditorAddressHelper =>
      'Apelido, nome do lugar ou endereço já bastam.';

  @override
  String get placeEditorPrivate =>
      'Seus locais e endereços são privados: só aparecem para você.';

  @override
  String get placeEditorSave => 'Salvar local';

  @override
  String get tabMe => 'Você';

  @override
  String get tabCatFood => 'Petisco / comida';

  @override
  String get tabCatSoft => 'Água / refrigerante';

  @override
  String get tabCatCover => 'Couvert';

  @override
  String get tabCatStarter => 'Entrada';

  @override
  String get tabCatTransport => 'Transporte';

  @override
  String get tabCatOther => 'Outros';

  @override
  String get tabCatDrink => 'Bebida só da comanda';

  @override
  String get tabSplitEqual => 'Igualmente';

  @override
  String get tabSplitItem => 'Por item';

  @override
  String get tabSplitCustom => 'Valores personalizados';

  @override
  String get tabShared => 'compartilhada';

  @override
  String tabShareHeader(String title) {
    return 'Comanda · $title';
  }

  @override
  String get tabShareNoItems => 'Sem itens na comanda.';

  @override
  String get tabShareItems => 'Itens';

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
    return '• $title · $count × sem preço';
  }

  @override
  String tabShareLine(String title, String price) {
    return '• $title · $price';
  }

  @override
  String tabShareLineNoPrice(String title) {
    return '• $title · sem preço';
  }

  @override
  String tabShareSubtotalKnown(String amount) {
    return 'Subtotal conhecido: $amount';
  }

  @override
  String tabShareSubtotal(String amount) {
    return 'Subtotal: $amount';
  }

  @override
  String tabShareDiscount(String amount) {
    return 'Desconto: -$amount';
  }

  @override
  String tabShareService(String pct, String base, String amount) {
    return 'Serviço ($pct sobre $base): $amount';
  }

  @override
  String tabShareTotalKnown(String amount) {
    return 'Total conhecido: $amount';
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
      other: 'Conta parcial: $count itens sem preço.',
      one: 'Conta parcial: 1 item sem preço.',
    );
    return '$_temp0';
  }

  @override
  String tabShareSplitHeader(String mode) {
    return 'Divisão ($mode)';
  }

  @override
  String tabShareSplitLine(String name, String amount) {
    return '• $name: $amount';
  }

  @override
  String tabSharePaid(String amount) {
    return ' · pagou $amount';
  }

  @override
  String get tabShareCovered => ' · coberto por outro pagamento';

  @override
  String tabShareMissing(String amount) {
    return ' · falta $amount';
  }

  @override
  String tabShareOver(String amount) {
    return ' · a mais $amount';
  }

  @override
  String tabShareUnassigned(String amount) {
    return 'Ainda sem dividir: $amount';
  }

  @override
  String tabShareOverTotal(String amount) {
    return 'Acima do total: $amount';
  }

  @override
  String get tabShareSplitPartial => 'Divisão parcial: os valores podem mudar.';

  @override
  String get tabTitle => 'Comanda';

  @override
  String get tabShareSplitTooltip => 'Compartilhar divisão';

  @override
  String get tabIntro =>
      'Opcional. A comanda não registra consumo: o que você bebeu continua nos seus registros.';

  @override
  String get tabEnded =>
      'Rolê encerrado. A comanda segue editável; encerrar não marca a conta como paga.';

  @override
  String tabItemsTitle(String count) {
    return 'Itens ($count)';
  }

  @override
  String get tabEmptyTitle => 'Comanda vazia';

  @override
  String get tabEmptyBody =>
      'Adicione petiscos e outros gastos, ou inclua as bebidas que você já registrou.';

  @override
  String get tabNoDrinksToLink => 'Nenhuma bebida registrada para incluir';

  @override
  String tabLinkDrinks(String count) {
    return 'Incluir bebidas registradas ($count)';
  }

  @override
  String get tabSplitBill => 'Dividir conta';

  @override
  String get tabSubtotalKnown => 'Subtotal conhecido';

  @override
  String get tabSubtotal => 'Subtotal';

  @override
  String get tabDiscount => 'Desconto';

  @override
  String tabServiceLine(String pct, String base) {
    return 'Serviço $pct sobre $base';
  }

  @override
  String get tabTotalKnown => 'Total conhecido';

  @override
  String get tabTotalTab => 'Total da comanda';

  @override
  String tabPartialPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens sem preço: a conta e a divisão são parciais.',
      one: '1 item sem preço: a conta e a divisão são parciais.',
    );
    return '$_temp0';
  }

  @override
  String get tabYourShareProvisional => 'Sua parte (provisória)';

  @override
  String get tabYourShare => 'Sua parte';

  @override
  String get tabOrderNote =>
      'Ordem: subtotal → desconto → serviço sobre os itens com serviço, já com desconto → total.';

  @override
  String get tabServiceAndDiscount => 'Serviço e desconto';

  @override
  String tabServiceSummary(String pct) {
    return 'serviço $pct';
  }

  @override
  String get tabNoService => 'sem serviço';

  @override
  String tabDiscountSummary(String amount) {
    return 'desconto $amount';
  }

  @override
  String get tabChargeService => 'Cobrar serviço';

  @override
  String get tabChargeServiceHint =>
      'Só nos itens marcados com serviço. Transporte e entrada começam sem.';

  @override
  String get tabPercent => 'Percentual';

  @override
  String tabServiceBase(String base, String service) {
    return 'Base $base → $service';
  }

  @override
  String get tabDiscountNone => 'Nenhum';

  @override
  String get tabDiscountAmountLabel => 'Valor do desconto';

  @override
  String get tabDiscountPercentLabel => 'Percentual do desconto';

  @override
  String tabDiscountCapped(String amount) {
    return 'Limitado ao subtotal: $amount';
  }

  @override
  String get tabDiscountHelper =>
      'Sobre o subtotal dos itens, distribuído entre eles.';

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
    return '$title · $count × sem preço';
  }

  @override
  String tabGroupQtyNoPrice(String title, String qty) {
    return '$title · $qty× sem preço';
  }

  @override
  String tabGroupQtyTotal(String title, String qty, String total) {
    return '$title · $qty× = $total';
  }

  @override
  String get tabComplimentary => 'cortesia';

  @override
  String get tabNoPrice => 'sem preço';

  @override
  String tabPersonalOnly(String amount) {
    return 'só a sua parte ($amount) é conhecida · total da garrafa desconhecido';
  }

  @override
  String get tabPersonalOnlyShort =>
      'só a parte pessoal é conhecida; total desconhecido';

  @override
  String tabLineOnlyYourShare(String amount) {
    return 'só sua parte $amount';
  }

  @override
  String tabLineDiscount(String amount) {
    return 'desc. −$amount';
  }

  @override
  String tabLineService(String amount) {
    return 'serviço +$amount';
  }

  @override
  String get tabLineRegisteredDrink => 'Bebida registrada';

  @override
  String get tabLineItem => 'Item da comanda';

  @override
  String get tabActions => 'Ações';

  @override
  String get tabFillTotalTitle => 'Total da garrafa/jarra';

  @override
  String get tabFillPriceTitle => 'Preço';

  @override
  String get tabFillTotalLabel => 'Total da conta deste item';

  @override
  String get tabFillTotal => 'Informar total';

  @override
  String get tabFillPrice => 'Informar preço';

  @override
  String get tabNoServiceItem => 'Sem serviço neste item';

  @override
  String get tabRemoveFromTab => 'Tirar da comanda';

  @override
  String get tabDeleteItem => 'Excluir item';

  @override
  String get splitTitle => 'Dividir conta';

  @override
  String get splitRename => 'Renomear';

  @override
  String splitRemoveTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String splitRemoveBody(String name, String share) {
    return '$name tem $share atribuídos. Escolha o que acontece com eles:';
  }

  @override
  String splitRemoveBodyPay(String name, String share, int count, String paid) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamentos',
      one: '1 pagamento',
    );
    return '$name tem $share atribuídos e $_temp0 ($paid). Escolha o que acontece com eles:';
  }

  @override
  String get splitPassTo => 'Passar para';

  @override
  String get splitNobody => 'Ninguém (redistribuir)';

  @override
  String get splitRedistributeNote =>
      'Os itens só dessa pessoa voltam a ser divididos entre todos e os pagamentos dela são apagados.';

  @override
  String get splitTransferNote =>
      'Itens, valores e pagamentos passam para essa pessoa.';

  @override
  String get splitRegisterPayment => 'Registrar pagamento';

  @override
  String get splitEditPayment => 'Editar pagamento';

  @override
  String get splitWhoPaid => 'Quem pagou';

  @override
  String get splitPaidAmount => 'Valor pago ao bar';

  @override
  String get splitNoteOptional => 'Observação (opcional)';

  @override
  String get splitPaymentPositive => 'Informe um valor maior que zero.';

  @override
  String splitTotalKnown(String amount) {
    return 'Total conhecido $amount';
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
      other: '$count itens sem preço: a divisão e os saldos são provisórios.',
      one: '1 item sem preço: a divisão e os saldos são provisórios.',
    );
    return '$_temp0';
  }

  @override
  String get splitComplete => 'Divisão completa: as parcelas somam o total.';

  @override
  String splitMissing(String amount) {
    return 'Falta distribuir $amount.';
  }

  @override
  String splitOver(String amount) {
    return 'Distribuído $amount a mais que o total.';
  }

  @override
  String get splitPeople => 'Pessoas';

  @override
  String get splitAddPerson => 'Adicionar pessoa (apelido)';

  @override
  String get splitNicknamesOnly =>
      'Só apelidos, sem login nem convite. Ficam apenas nesta comanda.';

  @override
  String get splitHow => 'Como dividir';

  @override
  String get splitModeEqualShort => 'Igual';

  @override
  String get splitModeItemShort => 'Por item';

  @override
  String get splitModeValuesShort => 'Valores';

  @override
  String get splitModeEqualNote =>
      'Modo ativo: igualmente. O total é dividido entre as pessoas marcadas.';

  @override
  String get splitModeItemNote =>
      'Modo ativo: por item. Cada pedido é dividido entre quem participa dele, com serviço e desconto do próprio item.';

  @override
  String get splitModeCustomNote =>
      'Modo ativo: valores personalizados. Você digita a parcela de cada um; só fecha quando a soma bate com o total.';

  @override
  String get splitAddItemsHint =>
      'Adicione itens à comanda para dividir por item.';

  @override
  String get splitFillEqually => 'Preencher igualmente';

  @override
  String get splitAllDistributed => 'Tudo distribuído.';

  @override
  String splitNotDistributed(String amount) {
    return 'Ainda não distribuído: $amount';
  }

  @override
  String splitPassedTotal(String amount) {
    return 'Passou do total em $amount';
  }

  @override
  String get splitResult => 'Resultado';

  @override
  String get splitProvisionalNote =>
      'Provisório: os valores mudam se a conta mudar.';

  @override
  String get splitAttributedNote =>
      'Atribuído é o que cabe a cada um; pago é o que a pessoa disse ter pago ao estabelecimento.';

  @override
  String splitPaidLine(String paid, String balance) {
    return 'Pagou $paid · $balance';
  }

  @override
  String get splitBalanceCovered => 'coberto por outro pagamento (bar quitado)';

  @override
  String splitBalanceMissing(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisório)',
      'other': '',
    });
    return 'falta pagar $amount$_temp0';
  }

  @override
  String splitBalanceOver(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisório)',
      'other': '',
    });
    return 'pagou $amount a mais$_temp0';
  }

  @override
  String splitBalanceEven(String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisório)',
      'other': '',
    });
    return 'em dia$_temp0';
  }

  @override
  String get splitPayments => 'Pagamentos';

  @override
  String get splitNoPayments => 'Nenhum pagamento registrado.';

  @override
  String get splitRemovedPerson => 'Pessoa removida';

  @override
  String get splitDeletePayment => 'Excluir pagamento';

  @override
  String get splitPaymentNote =>
      'Registrar um pagamento não muda o total, o consumo nem o orçamento: só o saldo. O app não faz cobrança, Pix nem transferência, e não diz quem deve pagar a quem. O preço de um consumo não conta como pagamento.';

  @override
  String get splitAssignEveryone => 'Todos dividem';

  @override
  String get splitAssignNobody => 'Ninguém';

  @override
  String get splitAssignIntro =>
      'Quem participa e com que peso. Quem não participa não recebe parcela deste item.';

  @override
  String splitWeight(String number) {
    return 'peso $number';
  }

  @override
  String get tabExtraNew => 'Novo item da comanda';

  @override
  String get tabExtraNote =>
      'Só na comanda deste rolê. Não vira consumo nem entra no catálogo.';

  @override
  String get tabExtraDescription => 'Descrição';

  @override
  String get tabExtraHintTransport => 'Ex.: Uber de volta (opcional)';

  @override
  String get tabExtraHint => 'Ex.: Porção de fritas';

  @override
  String get tabBasisUnit => 'Preço de cada um';

  @override
  String tabBasisTotal(String qty) {
    return 'Total dos $qty';
  }

  @override
  String get tabValueEach => 'Valor de cada unidade';

  @override
  String tabValueTotalQty(String qty) {
    return 'Valor total dos $qty';
  }

  @override
  String get tabExtraServiceItem => 'Cobrar serviço neste item';

  @override
  String get tabExtraServiceHint => 'Só vale se o serviço estiver ligado.';

  @override
  String get tabExtraWho => 'Quem divide este item';

  @override
  String get tabExtraAll => 'Todos';

  @override
  String tabExtraSome(String count, String total) {
    return '$count de $total';
  }

  @override
  String get tabExtraWhoNote => 'Vale no modo \"Por item\" da divisão.';

  @override
  String get tabExtraSave => 'Salvar item';

  @override
  String get tabExtraNeedValue =>
      'Informe o valor, ou escolha Cortesia / Não sei.';

  @override
  String tabExtraHelperUnit(String qty, String unit, String total) {
    return '$qty × $unit = $total';
  }

  @override
  String tabExtraHelperLine(String amount) {
    return 'Total da linha: $amount';
  }

  @override
  String get tabExtraNoPrice =>
      'Sem preço: a conta fica parcial até você preencher.';

  @override
  String tabLinkSharedTotal(String amount) {
    return 'compartilhada · total $amount';
  }

  @override
  String tabLinkSharedPersonal(String amount) {
    return 'compartilhada · só a sua parte ($amount) é conhecida';
  }

  @override
  String get tabLinkSameBottleTitle => 'Mesma garrafa ou outra?';

  @override
  String tabLinkSameBottleBody(String count, String name, String total) {
    return '$count registros compartilhados de \"$name\" têm o mesmo total ($total). Foi a mesma garrafa/jarra ou $count separadas?\n\nO total entra na comanda uma vez por garrafa; o app não adivinha.';
  }

  @override
  String tabLinkSeparate(String count) {
    return '$count separadas';
  }

  @override
  String get tabLinkSame => 'Mesma garrafa';

  @override
  String get tabLinkTitle => 'Bebidas já registradas';

  @override
  String get tabLinkNote =>
      'Elas só são ligadas à comanda: o preço continua no registro e uma correção lá vale aqui. Seus registros não mostram tudo o que a mesa pediu.';

  @override
  String get tabLinkAll => 'Todas';

  @override
  String get tabLinkNone => 'Nenhuma';

  @override
  String tabLinkInclude(String count) {
    return 'Incluir $count na comanda';
  }

  @override
  String get tabSharePreview =>
      'Prévia do texto. Nada é enviado até você tocar em Compartilhar.';

  @override
  String get tabShareIncludePayments => 'Incluir pagamentos e saldos';

  @override
  String get tabShareOffDefault => 'Desligado por padrão.';

  @override
  String get tabShareExcludes =>
      'Não inclui endereço, fotos, anotações pessoais nem relato de embriaguez.';

  @override
  String get tabShareButton => 'Compartilhar';

  @override
  String get tabCopyText => 'Copiar texto';

  @override
  String get tabTextCopied => 'Texto copiado';

  @override
  String get tabShareSubject => 'Divisão da conta';

  @override
  String get tabShareFailed =>
      'Não foi possível abrir o compartilhamento. Copie o texto.';

  @override
  String get tabCardHint => 'Opcional: petiscos, serviço e divisão da conta.';

  @override
  String tabCardTotalPartial(String amount) {
    return 'Total da comanda (parcial): $amount';
  }

  @override
  String tabCardTotal(String amount) {
    return 'Total da comanda: $amount';
  }

  @override
  String tabCardShareProv(String amount) {
    return 'Sua parte da comanda (provisória): $amount';
  }

  @override
  String tabCardShare(String amount) {
    return 'Sua parte da comanda: $amount';
  }

  @override
  String tabCardLineTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String tabCardLineKnown(String amount) {
    return 'Total conhecido $amount';
  }

  @override
  String tabCardLineTotalShare(String amount, String mine) {
    return 'Total $amount · sua parte $mine';
  }

  @override
  String tabCardLineKnownShare(String amount, String mine) {
    return 'Total conhecido $amount · sua parte $mine';
  }

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String statsPresetDays(String days) {
    return '$days dias';
  }

  @override
  String get statsPresetCustom => 'Personalizado';

  @override
  String statsRangeLine(String from, String to, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$from a $to · $_temp0';
  }

  @override
  String get statsEmptyTitle => 'Nada registrado neste período';

  @override
  String get statsEmptyBody =>
      'Isso só quer dizer que não há registros aqui, não que não houve rolê.';

  @override
  String get statsSummary => 'Resumo';

  @override
  String get statsOutingsOfPeriod => 'Rolês do período';

  @override
  String get statsDrinksLogged => 'Suas bebidas registradas';

  @override
  String get statsDrinksOfPeriod => 'Suas bebidas do período';

  @override
  String get statsPricedRecords => 'Registros com preço';

  @override
  String get statsVolumeSection => 'Volume pessoal informado';

  @override
  String get statsAlcoholicVolume => 'Bebidas com álcool';

  @override
  String get statsNonAlcoholicVolume => 'Água e sem álcool';

  @override
  String statsUnknownVolume(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros sem volume: não entram nas somas',
      one: '1 registro sem volume: não entra nas somas',
    );
    return '$_temp0';
  }

  @override
  String get statsAlcoholSection => 'Álcool calculado';

  @override
  String get statsPureAlcohol => 'Álcool puro dos dados conhecidos';

  @override
  String statsIncompleteAlcohol(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros com teor ou quantidade desconhecidos',
      one: '1 registro com teor ou quantidade desconhecidos',
    );
    return '$_temp0';
  }

  @override
  String get statsAlcoholNote =>
      'Volume × teor (ou quantidade × teor dos componentes dos drinks). Não é concentração no sangue.';

  @override
  String get statsAlcoholByCategory => 'Com álcool, por categoria';

  @override
  String statsNoVolumeNote(String count) {
    return '$count sem volume';
  }

  @override
  String get statsNonAlcoholicSection => 'Água e sem álcool, à parte';

  @override
  String get statsTopPlaces => 'Locais mais visitados';

  @override
  String get statsPlacesNote =>
      'Locais só são agrupados quando são o mesmo local salvo; nomes parecidos não são unidos.';

  @override
  String get statsMoods => 'Relatos pós-rolê';

  @override
  String get statsNoMoods => 'Nenhum relato neste período.';

  @override
  String statsWithoutMood(String count) {
    return '$count sem relato.';
  }

  @override
  String get statsMoodsNote =>
      'Relatos são pessoais: não medem tolerância e não indicam um limite seguro.';

  @override
  String get statsPrevious => 'Período anterior';

  @override
  String get statsFootnote =>
      'Dia sem registro não significa dia sem beber: os números refletem só o que foi registrado.';

  @override
  String statsNoBaseline(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Sem base de comparação: não há rolês registrados nos $days dias anteriores a este período.',
      one: 'Sem base de comparação: não há rolês registrados no dia anterior a este período.',
    );
    return '$_temp0';
  }

  @override
  String statsComparedTo(int days, String from, String to) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Comparado aos $days dias imediatamente antes ($from a $to).',
      one: 'Comparado ao dia imediatamente antes ($from a $to).',
    );
    return '$_temp0';
  }

  @override
  String get statsIncompleteCompare =>
      'Há bebidas sem preço em um dos períodos: o gasto real pode ser maior que o informado.';

  @override
  String statsLineBefore(String now, String before) {
    return '$now  (antes: $before)';
  }

  @override
  String get statsNoSavedPlace => 'Sem local salvo';

  @override
  String get statsSavedPlaceFallback => 'Local salvo';

  @override
  String get recordsUnknownVolume => 'volume desconhecido';

  @override
  String get historyEmptyTitle => 'Nenhum rolê encerrado';

  @override
  String get historyEmptyBody =>
      'Quando você encerrar um rolê, ele aparece aqui.';

  @override
  String get historySearchHint => 'Buscar por local, bebida ou pessoa';

  @override
  String get historyNoMatchTitle => 'Nenhum rolê com esses filtros';

  @override
  String get historyNoMatchBody => 'Tente outro nome, período ou tipo.';

  @override
  String get historyPeriodAll => 'Tudo';

  @override
  String get historyPeriodMonth => 'Este mês';

  @override
  String get historyAllTypes => 'Todos os tipos';

  @override
  String get historyNoValues => 'Sem valores';

  @override
  String get exportTitle => 'Exportar meus dados';

  @override
  String get exportIntro =>
      'Seus registros, do jeito que estão no aparelho. Nada é enviado a ninguém: você escolhe onde guardar. Nenhum dado de acesso ou sessão entra nos arquivos.';

  @override
  String get exportJsonTitle => 'Tudo em JSON';

  @override
  String get exportJsonBody =>
      'Locais, rolês, bebidas, composições, comandas e suas bebidas próprias, com todos os detalhes. Chaves e códigos fixos, independentes do idioma do app.';

  @override
  String get exportOutingsCsvTitle => 'Rolês em CSV';

  @override
  String get exportOutingsCsvBody =>
      'Um resumo por rolê. Separador \";\", decimal com vírgula, UTF-8. Colunas e códigos fixos, independentes do idioma do app.';

  @override
  String get exportDrinksCsvTitle => 'Bebidas em CSV';

  @override
  String get exportDrinksCsvBody =>
      'Uma linha por registro. Campo vazio = desconhecido, nunca zero. Colunas e códigos fixos, independentes do idioma do app.';

  @override
  String get exportButton => 'Exportar';

  @override
  String get exportCopy => 'Copiar';

  @override
  String get exportCopied => 'Copiado';

  @override
  String get exportShareUnavailable =>
      'Compartilhar não está disponível aqui. Use \"Copiar texto\" para guardar o conteúdo.';

  @override
  String get exportFailed => 'Não foi possível gerar o arquivo.';

  @override
  String get exportJsonNote =>
      'Dados pessoais exportados pela própria pessoa. Valores em centavos, volumes em ml, horários em UTC. Campos nulos são desconhecidos, não zero.';

  @override
  String get shareCardTitle => 'Compartilhar resumo';

  @override
  String get shareCardIntro =>
      'Escolha o que aparece. O endereço e o seu relato nunca entram, e nada é publicado sozinho.';

  @override
  String get shareCardWhat => 'O que mostrar';

  @override
  String get shareCardPlaceName => 'Nome do local';

  @override
  String get shareCardPlaceNameHint => 'Só o nome, nunca o endereço.';

  @override
  String get shareCardSpendHint => 'Há bebidas sem preço: o total é parcial.';

  @override
  String get shareCardFailed =>
      'Não foi possível abrir o compartilhamento. Você pode copiar o texto do resumo.';

  @override
  String get shareCardCaptureFailed =>
      'Não foi possível gerar a imagem. Você pode copiar o texto do resumo.';

  @override
  String get shareCardMyOuting => 'Meu rolê';

  @override
  String shareCardOthers(String count) {
    return '+ $count outros';
  }

  @override
  String shareCardSpendText(String amount) {
    return 'Gasto informado: $amount';
  }

  @override
  String shareCardSpendTextPartial(String amount) {
    return 'Gasto informado: $amount (há bebidas sem preço)';
  }

  @override
  String shareCardSpendCard(String amount) {
    return 'Gasto informado $amount';
  }

  @override
  String shareCardSpendCardPartial(String amount) {
    return 'Gasto informado $amount (parcial)';
  }

  @override
  String get trackingWeb =>
      'Não disponível no navegador: o acompanhamento fica só dentro do app.';

  @override
  String get trackingIosOld =>
      'Não disponível nesta versão do iOS (precisa do iOS 16.2 ou mais novo).';

  @override
  String get trackingUnsupported => 'Não disponível neste aparelho.';

  @override
  String get trackingDisabled => 'Desativado por você.';

  @override
  String get trackingPermission =>
      'Permissão do sistema indisponível. Libere as notificações do Bebômetro nas configurações do aparelho.';

  @override
  String get trackingSystemOffIos =>
      'Desligado nos ajustes do iPhone (Atividades ao Vivo).';

  @override
  String get trackingSystemOffAndroid =>
      'Notificações desligadas nas configurações do aparelho.';

  @override
  String get trackingNoOuting => 'Disponível durante um rolê.';

  @override
  String trackingHidden(String action) {
    return 'Oculto neste rolê. Use \"$action\" na tela do rolê.';
  }

  @override
  String trackingDismissed(String action) {
    return 'Você removeu da tela bloqueada neste rolê. Use \"$action\" na tela do rolê.';
  }

  @override
  String get trackingActive => 'Ativo agora.';

  @override
  String get trackingPending =>
      'Ligado, mas ainda não apareceu. No iPhone ele só começa com o app aberto; abra o rolê.';

  @override
  String get trackingAwaitingSave => 'aguardando registro';

  @override
  String get trackingNoPermissionToast =>
      'Sem permissão de notificações. Dá para liberar nas configurações do aparelho.';

  @override
  String get trackingEnable => 'Ativar acompanhamento';

  @override
  String get trackingEnableHint =>
      'Mostra o tempo e a contagem do rolê em andamento na tela bloqueada. Sem som nem vibração.';

  @override
  String get trackingShowSpend => 'Mostrar gastos';

  @override
  String get trackingShowSpendHint =>
      'Quanto você informou ter gasto em bebidas, não o total da mesa.';

  @override
  String get trackingShowPlace => 'Mostrar nome do local';

  @override
  String get trackingShowPlaceHint =>
      'Desligado, aparece só \"Rolê em andamento\". O endereço nunca aparece.';

  @override
  String get trackingCountNote =>
      'O contador mostra quantos registros de bebida alcoólica você fez (água não conta; uma garrafa dividida é um registro). Não são doses nem medem alcoolemia. O sistema pode encerrar a exibição sozinho depois de algumas horas, sem encerrar o rolê.';

  @override
  String get trackingOfferBody =>
      'Veja o tempo e a contagem de bebidas do rolê sem abrir o app. Por padrão não mostra gastos nem o nome do local. Sem som nem vibração, e dá para ocultar em cada rolê ou desligar quando quiser em Configurações.';

  @override
  String get trackingOfferActivate => 'Ativar';

  @override
  String get trackingTitleFallback => 'Rolê em andamento';

  @override
  String trackingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros de bebida alcoólica',
      one: '1 registro de bebida alcoólica',
      zero: 'Nenhum registro de bebida alcoólica',
    );
    return '$_temp0';
  }

  @override
  String trackingSpend(String amount) {
    return '$amount informados';
  }

  @override
  String trackingSpendUnpriced(String amount, String count) {
    return '$amount informados · $count sem preço';
  }

  @override
  String get trackingOpen => 'Abrir';

  @override
  String get trackingAnother => 'Mais uma';

  @override
  String trackingAnotherWith(String next) {
    return 'Mais uma · $next';
  }

  @override
  String trackingAnotherA11y(String next) {
    return 'Mais uma, $next';
  }

  @override
  String get trackingWater => 'Água';

  @override
  String get trackingChannelDescription =>
      'Tempo e contagem do rolê na tela bloqueada. Sem som nem vibração.';

  @override
  String get vesselCan => 'Lata';

  @override
  String get vesselLongNeck => 'Long neck';

  @override
  String get vesselBottle => 'Garrafa';

  @override
  String get vesselBeerGlass => 'Copo de cerveja';

  @override
  String get vesselDraftMug => 'Copo de chopp';

  @override
  String get vesselShot => 'Dose';

  @override
  String get vesselWineGlass => 'Taça de vinho';

  @override
  String get vesselCocktailGlass => 'Copo de drink';

  @override
  String get vesselWaterGlass => 'Copo de água';

  @override
  String get vesselGlass => 'Copo';

  @override
  String get scenarioBar => 'Bar/boteco';

  @override
  String get scenarioClub => 'Balada';

  @override
  String get scenarioBarbecue => 'Churrasco';

  @override
  String get scenarioHome => 'Casa';

  @override
  String get scenarioBeach => 'Praia';

  @override
  String get scenarioRestaurant => 'Restaurante';

  @override
  String tableSemanticsMany(String count, String name) {
    return '$count registros de $name';
  }

  @override
  String get tableSemanticsSharedPart => 'sua parte de bebida compartilhada';

  @override
  String get tableSemanticsTap => 'Toque para ver os detalhes.';

  @override
  String tableOthersTitle(String count) {
    return 'Outros registros ($count)';
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
      other: 'Mesa do rolê com $count registros',
      one: 'Mesa do rolê com 1 registro',
    );
    return '$_temp0';
  }

  @override
  String tableSemanticsTable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mesa com $count registros',
      one: 'Mesa com 1 registro',
    );
    return '$_temp0';
  }

  @override
  String get tableEmpty => 'A mesa está vazia';

  @override
  String tableOverflowSemantics(String count) {
    return 'Mais $count registros. Toque para ver a lista.';
  }

  @override
  String tableYours(String amount) {
    return '$amount seus';
  }

  @override
  String get tableYourVolume => 'Seu volume';

  @override
  String tableSharedLine(String mine, String total, String count) {
    return 'Sua parte: $mine de $total ($count pessoas)';
  }

  @override
  String get tableRecipeAdjusted => 'Receita ajustada';

  @override
  String get tableScenarioTitle => 'Cenário da mesa';

  @override
  String get tableScenarioNote =>
      'Só muda a ilustração. O local, o tipo e os registros do rolê continuam iguais.';

  @override
  String get tableAboutTitle => 'Sobre a mesa';

  @override
  String get tableAboutBody =>
      'Animação ilustrativa das bebidas registradas.\n\nOs recipientes esvaziam só como efeito visual, com base no horário do registro. Isso não mede quanto você bebeu, não indica álcool no corpo e não muda nenhum registro: os totais vêm apenas do que você informou.';

  @override
  String get tableUnderstood => 'Entendi';

  @override
  String glassSemantics(String total, String scale, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', mais $unknown registros sem volume',
      one: ', mais 1 registro sem volume',
      zero: '',
    );
    return 'Copão: $total de volume informado, em uma escala de até $scale$_temp0.';
  }

  @override
  String get glassVolumeReported => 'Volume informado';

  @override
  String glassScale(String scale) {
    return 'Escala: até $scale';
  }

  @override
  String glassAlcoholic(String amount) {
    return 'Com álcool: $amount';
  }

  @override
  String glassOther(String amount) {
    return 'Água e sem álcool: $amount';
  }

  @override
  String glassNoVolume(String count) {
    return '+ $count sem volume (não entram)';
  }

  @override
  String get glassNote =>
      'Só uma forma de ver a soma dos volumes registrados. Não representa álcool no corpo, capacidade nem meta.';

  @override
  String get tipNoSensor => 'Sem sensor de movimento. Arraste para inclinar.';

  @override
  String get tipHintTilt => 'Incline o celular para mexer a cerveja.';

  @override
  String get tipHintDrag => 'Arraste para inclinar.';

  @override
  String get tipNoReading => 'Sem leitura de movimento. Arraste para inclinar.';

  @override
  String get tipReactMotion => 'Reagir ao movimento';

  @override
  String get tipWebNote =>
      'Não disponível no navegador: arraste para inclinar.';

  @override
  String get tipOffNote => 'Desligado, você arrasta o dedo para inclinar.';

  @override
  String get tipBubbles => 'Bolhas e ondas';

  @override
  String get tipBubblesNote => 'Desligue para uma cerveja mais calma.';

  @override
  String get tipLevel => 'Nivelar';

  @override
  String get tipVisualNote =>
      'Só visual: o copo não mede nem registra consumo, e encher não é meta.';

  @override
  String get tipSemantics =>
      'Cerveja que ocupa a tela. Incline o celular para mexer o líquido. Só visual, não registra consumo.';

  @override
  String get tipRefill => 'Reencher';

  @override
  String get tipRefillAgain => 'Encher novamente';

  @override
  String get gameNeverTitle => 'Eu nunca';

  @override
  String get gameNeverDesc => 'Quem já fez, conta. Sem pressão.';

  @override
  String get gameMostTitle => 'Quem é mais provável';

  @override
  String get gameMostDesc => 'A turma aponta quem combina mais com a frase.';

  @override
  String get gameTruthTitle => 'Verdade ou desafio';

  @override
  String get gameTruthDesc => 'Cada um na sua vez, com opção de pular.';

  @override
  String get gameModeLight => 'Leve';

  @override
  String get gameModeAdult => '+18';

  @override
  String get gameKindCard => 'Carta';

  @override
  String get gameKindTruth => 'Verdade';

  @override
  String get gameKindDare => 'Desafio';

  @override
  String get resenhaIntro =>
      'Jogos para a mesa, que funcionam sem internet. As cartas não pedem para beber e não registram nenhuma bebida.';

  @override
  String get resenhaInProgress => 'Partida em andamento';

  @override
  String resenhaSession(int count, String mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes · modo $mode',
      one: '1 participante · modo $mode',
    );
    return '$_temp0';
  }

  @override
  String get resenhaResume => 'Retomar';

  @override
  String get resenhaGames => 'Jogos';

  @override
  String get resenhaPlay => 'Brincadeira';

  @override
  String get resenhaTipTitle => 'Virar o copo';

  @override
  String get resenhaTipBody =>
      'A tela vira um copo: incline o celular. Só visual.';

  @override
  String get resenhaCards => 'Cartas';

  @override
  String get resenhaMyCards => 'Minhas cartas';

  @override
  String resenhaMyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count criadas por você',
      one: '1 criada por você',
      zero: 'Nenhuma criada por você',
    );
    return '$_temp0';
  }

  @override
  String get gameAlreadyPlayer => 'Já existe alguém com esse apelido.';

  @override
  String get gameMaxPlayers => 'No máximo 20 participantes.';

  @override
  String get gameWhoPlays => 'Quem vai jogar?';

  @override
  String get gameAddPlayerTooltip => 'Adicionar participante';

  @override
  String gameNeedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicione pelo menos $count participantes.',
      one: 'Adicione pelo menos 1 participante.',
    );
    return '$_temp0';
  }

  @override
  String gameRemovePlayer(String name) {
    return 'Remover $name';
  }

  @override
  String get gameMode => 'Modo';

  @override
  String get gameLightNote => 'Sem conteúdo sexual. Para qualquer turma.';

  @override
  String get gameAdultNote =>
      'Mistura as cartas leves com flerte e humor para adultos. Nada explícito, e tudo pode ser pulado sem punição.';

  @override
  String get gameAdultConfirm =>
      'Confirmo que todas as pessoas que vão jogar são adultas (18+) e toparam o modo +18.';

  @override
  String get gameNoDrinkNote =>
      'As cartas nunca pedem para beber, virar doses ou acumular bebidas, e nada aqui registra bebidas no seu rolê.';

  @override
  String get gameStart => 'Começar';

  @override
  String get gameFinishTitle => 'Encerrar a partida?';

  @override
  String get gameFinishBody =>
      'Ela não ficará salva. Para só dar uma pausa, volte e retome depois.';

  @override
  String get gameKeepPlaying => 'Continuar jogando';

  @override
  String get gameFinish => 'Encerrar';

  @override
  String gameModePill(String mode) {
    return 'Modo $mode';
  }

  @override
  String gameCardsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas restantes',
      one: '1 carta restante',
    );
    return '$_temp0';
  }

  @override
  String get gameOutOfCards => 'Acabaram as cartas';

  @override
  String get gameOutOfCardsHint =>
      'Dá para embaralhar tudo de novo ou encerrar a partida.';

  @override
  String get gameReshuffle => 'Embaralhar de novo';

  @override
  String gameReaderCall(String name) {
    return '$name, leia a pergunta';
  }

  @override
  String get gameReaderLabel => 'Sua vez de ler';

  @override
  String gameResponder(String name) {
    return 'Responde: $name';
  }

  @override
  String get gameEveryoneAnswers => 'Todo mundo responde';

  @override
  String get gamePassTurn => 'Passar a vez';

  @override
  String get gameChangeReader => 'Trocar leitor';

  @override
  String get gameChooseReader => 'Quem vai ler?';

  @override
  String get gameImportFromOuting => 'Pessoas do rolê';

  @override
  String get gameImportTitle => 'Quem do rolê vai jogar?';

  @override
  String get gameImportUse => 'Usar selecionados';

  @override
  String get bafoStart => 'Começar';

  @override
  String get bafoHoldOption => 'Prefiro segurar o botão (sem microfone)';

  @override
  String get bafoHoldButton => 'Segurar para brincar';

  @override
  String get bafoDenied =>
      'Sem acesso ao microfone. Dá para brincar segurando o botão.';

  @override
  String get bafoUnsupported =>
      'Este aparelho não consegue usar o microfone aqui. Dá para brincar segurando o botão.';

  @override
  String get bafoStop => 'Parar';

  @override
  String get bafoAgain => 'Tentar de novo';

  @override
  String get bafoDone => 'Concluir';

  @override
  String get homeYourDrinks => 'Suas bebidas';

  @override
  String outingRecordsTable(int count) {
    return 'Registros da mesa ($count)';
  }

  @override
  String get summaryPeopleTitle => 'Pessoas e conta';

  @override
  String summaryPersonLine(String name, String share, String paid) {
    return '$name · parcela $share · pagou $paid';
  }

  @override
  String summaryPersonDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas',
      one: '1 bebida',
      zero: 'Nenhuma bebida',
    );
    return '$_temp0';
  }

  @override
  String get entrySharedUseOrder =>
      'Para dividir uma garrafa ou jarra entre pessoas da mesa, use \"Novo pedido\" na tela do rolê e escolha \"Garrafa ou jarra compartilhada\": lá você diz quanto cada um tomou.';

  @override
  String get formPortionsTitle => 'Quanto cada pessoa tomou';

  @override
  String get formPortionsHint =>
      'Deixe em branco se não souber: fica desconhecido, nunca zero. A soma não pode passar do tamanho da garrafa.';

  @override
  String get formPortionMl => 'ml';

  @override
  String drinkCountYours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas suas',
      one: '1 bebida sua',
    );
    return '$_temp0';
  }

  @override
  String get outingEditTitle => 'Editar rolê';

  @override
  String get outingEditKind => 'Tipo de rolê';

  @override
  String get outingEditStart => 'Início';

  @override
  String get outingStartFuture => 'O início não pode estar no futuro.';

  @override
  String get outingStartAfterEnd =>
      'O início precisa ser antes do fim do rolê.';

  @override
  String get outingStartAfterRecords =>
      'Já há bebidas registradas antes desse horário. Escolha um início anterior ao primeiro registro.';

  @override
  String get outingDelete => 'Excluir rolê';

  @override
  String get outingDeleteTitle => 'Excluir este rolê?';

  @override
  String get outingDeleteBody =>
      'O rolê, os registros de bebida, a comanda e as pessoas somem das suas listas e dos seus outros aparelhos. Não dá para desfazer.';

  @override
  String get outingDeleted => 'Rolê excluído';

  @override
  String gameTurnOf(String name) {
    return 'Vez de $name';
  }

  @override
  String get gameTruthOrDareQ => 'Verdade ou desafio?';

  @override
  String get gameNoTruthLeft => 'Acabaram as cartas de verdade. Escolha outra.';

  @override
  String get gameNoDareLeft => 'Acabaram as cartas de desafio. Escolha outra.';

  @override
  String get gameOptional => 'Opcional: pode pular sem punição.';

  @override
  String get gameSkip => 'Pular';

  @override
  String get gameNext => 'Próxima';

  @override
  String gameSavedNote(String hub) {
    return 'A partida fica salva: você pode sair e retomar em $hub.';
  }

  @override
  String get gameNewCard => 'Nova carta';

  @override
  String get gameCardHintNever => 'Eu nunca…';

  @override
  String get gameCardHintMost => 'Quem é mais provável de…';

  @override
  String get gameCardText => 'Texto da carta';

  @override
  String get gameCardRules =>
      'Sem exposição, gravação, coerção, direção, violência, atividades perigosas ou beber como penalidade.';

  @override
  String get gameCardCreated => 'Carta criada';

  @override
  String get gameCardDeleteTitle => 'Excluir esta carta?';

  @override
  String get gameCardsEmptyTitle => 'Nenhuma carta sua ainda';

  @override
  String get gameCardsEmptyBody =>
      'Crie cartas para os seus jogos. Elas entram no sorteio das próximas partidas.';

  @override
  String get gameCardDelete => 'Excluir carta';

  @override
  String gameCardLine(String game, String mode) {
    return '$game · $mode';
  }

  @override
  String gameCardLineKind(String game, String mode, String kind) {
    return '$game · $mode · $kind';
  }

  @override
  String get gameCardNeedText => 'Escreva o texto da carta.';

  @override
  String get gameCardTooLong => 'Texto longo demais.';

  @override
  String get provenanceOfficial => 'Fabricante / ficha oficial';

  @override
  String get provenanceLabel => 'Rótulo em fonte secundária';

  @override
  String get provenancePackagingRegistry => 'Cadastro público de embalagem';

  @override
  String get provenanceSecondary => 'Fonte secundária';

  @override
  String get provenanceRecipe => 'Receita de referência';

  @override
  String get provenanceUser => 'Informação sua';

  @override
  String get provenanceSuggestion => 'Volume sugerido';

  @override
  String get provenanceGeneric => 'Referência genérica';

  @override
  String get provenanceGeneral => 'Fonte geral do produto';

  @override
  String get provenanceSuggestionLine =>
      'Tamanhos comuns para facilitar o registro, não embalagens documentadas deste produto.';

  @override
  String get aboutDataTitle => 'Sobre estes dados';

  @override
  String get aboutDataFallback =>
      'Sem fonte específica para este campo; vale a fonte geral do produto.';

  @override
  String get aboutDataGeneralTitle => 'Fonte geral do produto';

  @override
  String get aboutDataVariantsTitle => 'Teores documentados (sem média)';

  @override
  String get aboutDataDivergence => 'As fontes divergem sobre o teor';

  @override
  String get aboutDataRegistryNote =>
      'O cadastro mostra que a embalagem existiu no mercado; não indica que esteja à venda hoje.';

  @override
  String get aboutDataOpenFailed =>
      'Não foi possível abrir o endereço. Copie e abra no navegador.';

  @override
  String aboutDataMarket(String market) {
    return 'Mercado: $market';
  }

  @override
  String aboutDataConsulted(String date) {
    return 'Consultado em $date';
  }

  @override
  String get pendingTitle => 'Registros pendentes';

  @override
  String get pendingIntro =>
      'Toques em \"Mais uma\" na tela bloqueada que não puderam ser registrados sozinhos. Nada entra no seu histórico sem você confirmar aqui.';

  @override
  String get pendingEmpty => 'Nenhum registro pendente.';

  @override
  String get pendingReasonEnded =>
      'O rolê foi encerrado antes do registro. Revise para adicionar a ele.';

  @override
  String get pendingReasonOutside =>
      'O horário do toque está fora do período do rolê. Ajuste o horário na revisão.';

  @override
  String get pendingReasonNoDrink =>
      'Não dá para saber qual bebida repetir. Escolha a bebida e revise.';

  @override
  String get pendingReasonNotPersonal =>
      'O pedido que o botão mostrava foi para outra pessoa ou virou garrafa compartilhada. Escolha o que registrar para você e revise.';

  @override
  String get pendingReasonFailed =>
      'Não foi possível salvar. Você pode tentar novamente.';

  @override
  String get pendingReasonUnsupported =>
      'Esta versão do app não reconhece este pedido. Você pode descartá-lo.';

  @override
  String get pendingReasonInReview => 'Em revisão.';

  @override
  String get pendingDrinkUnknown => 'Bebida não identificada';

  @override
  String get pendingRetry => 'Tentar novamente';

  @override
  String get pendingRetryFailed => 'Ainda não foi possível registrar.';

  @override
  String get pendingSaved => 'Registrado.';

  @override
  String get pendingDiscard => 'Descartar';

  @override
  String get pendingDiscardTitle => 'Descartar este toque?';

  @override
  String get pendingDiscardBody =>
      'O pedido some desta lista. Nenhum registro já salvo é apagado.';

  @override
  String get pendingDiscarded => 'Descartado.';

  @override
  String get pendingNoDrinkToChoose =>
      'Este rolê não tem bebida alcoólica registrada para repetir.';

  @override
  String get pendingChooseTitle => 'Qual bebida era?';

  @override
  String get pendingChooseDrink => 'Escolher bebida';

  @override
  String get pendingReviewAdd => 'Revisar e adicionar';

  @override
  String pendingNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count toques da tela bloqueada aguardam você',
      one: '1 toque da tela bloqueada aguarda você',
    );
    return '$_temp0';
  }

  @override
  String pendingOutingOn(String date) {
    return 'Rolê de $date';
  }

  @override
  String pendingTappedAt(String time) {
    return 'Toque em $time';
  }

  @override
  String pendingReviewNote(String time) {
    return 'Toque original na tela bloqueada: $time';
  }

  @override
  String get entryFromLockScreen => 'Adicionado pela tela bloqueada';

  @override
  String entryOriginalTap(String time) {
    return 'Toque original: $time';
  }

  @override
  String entryOriginalTapCorrected(String time) {
    return 'Horário corrigido. Toque original: $time';
  }

  @override
  String get syncLabelOffline => 'Sem conexão';

  @override
  String get startWho => 'Quem está no rolê?';

  @override
  String get startWhoHint =>
      'Você já está. Adicione quem vai pedir ou dividir a conta; dá para mudar depois.';

  @override
  String get startWhoName => 'Nome da pessoa';

  @override
  String get startWhoAdd => 'Adicionar';

  @override
  String startWhoRemove(String name) {
    return 'Tirar $name';
  }

  @override
  String get orderTitle => 'Novo pedido';

  @override
  String get orderWhat => 'O que foi pedido?';

  @override
  String get orderNameLabel => 'Nome do pedido';

  @override
  String get orderNameHint => 'Escreva o nome ou procure no catálogo';

  @override
  String orderFromCatalog(String name) {
    return 'Do catálogo: $name';
  }

  @override
  String get orderUseTextOnly => 'Usar só o texto';

  @override
  String orderNotInCatalog(String text) {
    return 'Não achou no catálogo? Sem problema: fica registrado como “$text” só neste rolê.';
  }

  @override
  String get orderKind => 'Tipo';

  @override
  String get orderFor => 'Para quem?';

  @override
  String get orderForHint => 'Toque em quem vai beber e diga quantas.';

  @override
  String get orderEach => 'Cada um o seu';

  @override
  String get orderSharedBottle => 'Garrafa ou jarra compartilhada';

  @override
  String orderMore(String name) {
    return 'Mais um para $name';
  }

  @override
  String orderLess(String name) {
    return 'Menos um para $name';
  }

  @override
  String get orderSharers => 'Quem divide?';

  @override
  String orderPortionMl(String name) {
    return 'ml de $name';
  }

  @override
  String get orderPortionHint => 'Opcional. Em branco = não sei.';

  @override
  String get orderDivideVolume => 'Dividir volume igualmente';

  @override
  String get orderDivideNote =>
      'É uma estimativa: assume que cada um bebeu a mesma quantidade. Dividir só o preço não prova isso.';

  @override
  String get orderBottles => 'Garrafas';

  @override
  String get orderLeftover => 'Sobra (ml)';

  @override
  String get orderPrice => 'Preço';

  @override
  String get orderPriceEach => 'Por unidade';

  @override
  String get orderPriceTotal => 'Total do pedido';

  @override
  String get orderPriceEachLabel => 'Valor de cada';

  @override
  String get orderPriceTotalLabel => 'Valor total do pedido';

  @override
  String get orderPriceTotalHelper =>
      'Promoção? Informe o total: o app reparte em centavos exatos.';

  @override
  String get orderPriceBottleLabel => 'Preço da garrafa (total)';

  @override
  String orderLineSummary(int count, String price, String total) {
    return '$count × $price = $total';
  }

  @override
  String orderSplitEach(String each) {
    return 'Cada um paga $each se dividir igual.';
  }

  @override
  String get orderDetails => 'Detalhes (opcional)';

  @override
  String get orderVolume => 'Volume servido (ml)';

  @override
  String get orderVolumeNote =>
      'Sugestões editáveis; não são o tamanho oficial da marca nem do bar.';

  @override
  String get orderAbv => 'Teor alcoólico (%)';

  @override
  String get orderUseRecipe => 'Usar a receita de referência';

  @override
  String get orderUseRecipeNote =>
      'Só se foi assim que o bar preparou. Sem confirmar, o drink fica sem composição.';

  @override
  String orderSummaryFor(String who) {
    return 'Para: $who';
  }

  @override
  String get orderSave => 'Adicionar ao rolê';

  @override
  String get orderErrName => 'Diga o que foi pedido.';

  @override
  String get orderErrNobody => 'Escolha pelo menos uma pessoa.';

  @override
  String get orderErrSharers =>
      'Para dividir, escolha pelo menos duas pessoas.';

  @override
  String get orderErrPortions =>
      'As porções e a sobra passam do tamanho da garrafa.';

  @override
  String get orderErrPrice => 'Informe o valor ou escolha outra opção.';

  @override
  String get orderErrVolume => 'Volume inválido.';

  @override
  String get orderErrAbv => 'O teor vai de 0 a 100%.';

  @override
  String orderAdded(String summary) {
    return 'Adicionado: $summary';
  }

  @override
  String get actionDrink => 'Bebida';

  @override
  String get actionFood => 'Comida';

  @override
  String get actionOther => 'Outro item';

  @override
  String get tabOrders => 'Pedidos';

  @override
  String get tabPeople => 'Por pessoa';

  @override
  String get tabBill => 'Conta';

  @override
  String get tileItems => 'Itens';

  @override
  String get tileTableTotal => 'Total da mesa';

  @override
  String get tileYourShare => 'Sua parte';

  @override
  String get tileTheirShare => 'Parte';

  @override
  String get tileVolume => 'Volume';

  @override
  String billTotalKnownShort(String total) {
    return '$total+';
  }

  @override
  String ordersTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
      zero: 'Pedidos',
    );
    return '$_temp0';
  }

  @override
  String get ordersEmptyTitle => 'Nenhum pedido ainda';

  @override
  String get ordersEmptyBody =>
      'Use Bebida, Comida ou Outro item para registrar o primeiro.';

  @override
  String orderEachPrice(String price) {
    return '$price cada';
  }

  @override
  String get ordersEveryone => 'Todos';

  @override
  String get ordersUnassigned => 'sem pessoa';

  @override
  String get ordersMoveTo => 'Passar para outra pessoa';

  @override
  String get ordersDeleteOne => 'Excluir um';

  @override
  String noticeMovedTo(String name) {
    return 'Passado para $name';
  }

  @override
  String get moveCustomTitle => 'Este pedido tem divisão personalizada';

  @override
  String moveCustomBody(String name) {
    return 'Atualizar a divisão do custo para $name ou manter como está?';
  }

  @override
  String moveFollow(String name) {
    return 'Seguir $name';
  }

  @override
  String get moveKeepSplit => 'Manter a divisão';

  @override
  String repeatFor(String who) {
    return 'Mais uma para $who';
  }

  @override
  String repeatLeftTitle(String names) {
    return '$names saiu';
  }

  @override
  String get repeatLeftBody =>
      'Esse pedido não é repetido para quem saiu. Escolha para quem repetir.';

  @override
  String get repeatLeftAdjust => 'Escolher pessoas';

  @override
  String get tableIllustrated => 'Mesa ilustrada';

  @override
  String get tableIllustratedHint =>
      'Só uma imagem dos pedidos; a lista e os valores ficam acima.';

  @override
  String get legacyTitle => 'Conta já usada neste rolê';

  @override
  String get legacyBody =>
      'Para atribuir pedidos a pessoas, passe para o modo mesa: todos os registros do rolê entram na conta, divididos por quem bebeu. Vínculos, extras e pagamentos atuais ficam.';

  @override
  String get legacyAction => 'Usar a mesa';

  @override
  String get extraWhoPresent => 'Todos os presentes';

  @override
  String get peopleTable => 'Mesa';

  @override
  String get peopleLeftTag => 'saiu';

  @override
  String get peopleAdd => 'Pessoa';

  @override
  String get peopleAddTitle => 'Adicionar pessoa';

  @override
  String get peopleRename => 'Renomear';

  @override
  String get peopleMarkLeft => 'Marcar que saiu';

  @override
  String get peopleMarkLeftHint =>
      'Continua nos pedidos antigos e não entra em itens novos por padrão.';

  @override
  String get peopleBack => 'Voltou à mesa';

  @override
  String get peopleBackHint => 'Volta a ser escolhida nos itens novos.';

  @override
  String get peopleRemove => 'Remover da mesa';

  @override
  String get peopleRemoveHint => 'Ninguém consumiu nem paga por esta pessoa.';

  @override
  String get peopleRemoveBlocked =>
      'Tem pedidos, parcela ou pagamento: marque que saiu.';

  @override
  String peopleUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros são de pessoas que não estão na mesa',
      one: '1 registro é de uma pessoa que não está na mesa',
    );
    return '$_temp0: ficam sem atribuição, nunca viram seus.';
  }

  @override
  String peopleDrankLine(int count, String ml) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas',
      one: '1 bebida',
    );
    return '$_temp0 · $ml';
  }

  @override
  String get peopleDrinksCost => 'Bebidas';

  @override
  String get peopleFoodCost => 'Comida e outros';

  @override
  String get peopleDiscount => 'Desconto';

  @override
  String get peopleService => 'Serviço';

  @override
  String get peopleShare => 'Parcela';

  @override
  String get peoplePaidToVenue => 'Pagou ao bar';

  @override
  String get peopleCoveredByPayment =>
      'Coberto por outro pagamento: o bar está quitado';

  @override
  String peopleStillOwes(String amount) {
    return 'Ainda falta $amount da parcela';
  }

  @override
  String peoplePaidMore(String amount) {
    return 'Pagou $amount acima da parcela';
  }

  @override
  String get peopleEven => 'Parcela paga';

  @override
  String get peopleCovered => 'Bar já quitado pela mesa';

  @override
  String peopleSeeOrders(String name) {
    return 'Ver pedidos de $name';
  }

  @override
  String get billSubtotal => 'Subtotal';

  @override
  String get billSubtotalKnown => 'Subtotal conhecido';

  @override
  String get billDiscount => 'Desconto';

  @override
  String billService(String rate, String base) {
    return 'Serviço $rate sobre $base';
  }

  @override
  String get billTotal => 'Total da conta';

  @override
  String get billTotalKnown => 'Total conhecido';

  @override
  String get billYourShare => 'Sua parte';

  @override
  String billPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens sem preço: a conta é parcial',
      one: '1 item sem preço: a conta é parcial',
    );
    return '$_temp0';
  }

  @override
  String billUnassigned(String amount) {
    return 'Falta atribuir $amount';
  }

  @override
  String billOverAssigned(String amount) {
    return 'Atribuído a mais: $amount';
  }

  @override
  String get billPaidToVenue => 'Pago ao bar';

  @override
  String get billSettled => 'Bar quitado';

  @override
  String get billDue => 'A pagar ao bar';

  @override
  String billOverpaid(String amount) {
    return 'Pago a mais ao bar: $amount';
  }

  @override
  String get billNoTransfers =>
      'O app não faz cobrança nem Pix e não diz quem deve pagar quem.';

  @override
  String get billSettings => 'Serviço, desconto e itens';

  @override
  String get billSplitAndPay => 'Dividir e registrar pagamentos';

  @override
  String get formForWhom => 'Para quem?';

  @override
  String get formForWhomPending => 'Escolha para quem foi esta bebida.';

  @override
  String get formForWhomShared =>
      'Garrafa compartilhada: as pessoas ficam nas porções do pedido.';

  @override
  String get orderOpenCatalog => 'Catálogo completo, rótulo ou cardápio';

  @override
  String get bottleAddPerson => 'Adicionar pessoa';

  @override
  String get bottleAddTitle => 'Quem entra nesta garrafa?';

  @override
  String get bottleAddNone =>
      'Todas as pessoas do rolê já estão nesta garrafa.';

  @override
  String get bottleAddHint =>
      'A pessoa entra com volume desconhecido e uma parte do valor. O volume das outras não muda.';

  @override
  String bottleRemoveTooltip(String name) {
    return 'Tirar $name da garrafa';
  }

  @override
  String get bottleMinPeople =>
      'Uma garrafa precisa de pelo menos uma pessoa. Para outro uso, exclua o registro.';

  @override
  String bottleRemoveTitle(String name) {
    return 'Tirar $name?';
  }

  @override
  String bottleRemoveVolumeAsk(String name, String volume) {
    return '$name tem $volume registrados. O que fazer com esse volume?';
  }

  @override
  String get bottleRemoveVolumeLeftover => 'Passar para a sobra da garrafa';

  @override
  String bottleRemoveVolumeTo(String name) {
    return 'Passar para $name';
  }

  @override
  String bottleRemoveMoneyAsk(String name) {
    return '$name tem parte do valor. O que fazer com ela?';
  }

  @override
  String get bottleRemoveMoneySpread => 'Dividir entre quem fica pagando';

  @override
  String bottleRemoveMoneyTo(String name) {
    return 'Passar para $name';
  }

  @override
  String get bottleRemoveConfirm => 'Tirar da garrafa';

  @override
  String get bottleRemoveNoPayer =>
      'Alguém precisa continuar pagando a garrafa: passe a parte para outra pessoa.';

  @override
  String get bottleCostTitle => 'Divisão do valor';

  @override
  String get bottleCostHint =>
      'Separada do volume: cada parte conta na divisão do valor da garrafa. Zero partes = não paga nada dela.';

  @override
  String bottleCostParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partes',
      one: '1 parte',
      zero: '0 partes',
    );
    return '$_temp0';
  }

  @override
  String bottleCostLess(String name) {
    return 'Menos uma parte de $name';
  }

  @override
  String bottleCostMore(String name) {
    return 'Mais uma parte para $name';
  }

  @override
  String get bottleLeftoverLabel => 'Sobra na garrafa';

  @override
  String get bottleImpactTitle => 'O que muda ao salvar';

  @override
  String get bottleImpactBody =>
      'Pagamentos já registrados não mudam nem trocam de pessoa; só a parte de cada um na comanda e o volume.';

  @override
  String bottleImpactVolume(String before, String after) {
    return 'Volume: $before → $after';
  }

  @override
  String bottleImpactCost(String before, String after) {
    return 'Valor na comanda: $before → $after';
  }

  @override
  String get bottleImpactJoins => 'entra na garrafa';

  @override
  String get bottleImpactLeaves => 'sai da garrafa';

  @override
  String get bottleImpactNoChange => 'Sem mudança para esta pessoa.';

  @override
  String get bottleImpactConfirm => 'Salvar mesmo assim';

  @override
  String get outingRestoreConflictTitle => 'Já existe um rolê em andamento';

  @override
  String get outingRestoreConflictBody =>
      'Este rolê estava em andamento quando foi excluído. Ele pode voltar já encerrado, no horário da exclusão. O rolê atual não é alterado.';

  @override
  String get outingRestoreAsEnded => 'Restaurar encerrado';

  @override
  String get outingRestored => 'Rolê restaurado';

  @override
  String get outingRestoredEnded => 'Rolê restaurado como encerrado';

  @override
  String get outingRestoreNothing =>
      'Nada a desfazer: o rolê já foi restaurado ou mudou.';

  @override
  String get outingRestoreFailed =>
      'Não foi possível restaurar o rolê. Tente de novo.';

  @override
  String get conflictFieldName => 'Nome';

  @override
  String get conflictFieldType => 'Tipo';

  @override
  String get conflictFieldAddress => 'Endereço';

  @override
  String get conflictFieldCity => 'Cidade';

  @override
  String get conflictFieldFavorite => 'Favorito';

  @override
  String get conflictFieldStatus => 'Situação';

  @override
  String get conflictFieldMap => 'Ponto no mapa';

  @override
  String get conflictFieldCategory => 'Categoria';

  @override
  String get conflictFieldBrand => 'Marca';

  @override
  String get conflictFieldStyle => 'Estilo';

  @override
  String get conflictFieldVolume => 'Volume';

  @override
  String get conflictFieldAbv => 'Teor alcoólico';

  @override
  String get conflictFieldIngredients => 'Ingredientes';

  @override
  String get conflictFieldRecipe => 'Composição da receita';

  @override
  String get conflictNotInformed => 'não informado';

  @override
  String get conflictYes => 'sim';

  @override
  String get conflictNo => 'não';

  @override
  String get conflictArchived => 'arquivado';

  @override
  String get conflictActive => 'ativo';

  @override
  String get conflictPointSet => 'marcado';

  @override
  String get conflictPointNone => 'sem ponto';

  @override
  String get conflictDiffers => 'diferente';

  @override
  String get conflictLocalDeleted => 'Excluído neste aparelho';

  @override
  String get conflictKindPlace => 'Local';

  @override
  String get conflictKindDrink => 'Bebida pessoal';

  @override
  String get conflictKindRecipe => 'Receita pessoal';

  @override
  String get conflictWhatEdit => 'Editado em dois aparelhos.';

  @override
  String get conflictWhatCloudDeleted =>
      'Editado neste aparelho, mas excluído na nuvem.';

  @override
  String get conflictWhatLocalDeleted =>
      'Excluído neste aparelho, mas editado na nuvem.';

  @override
  String get conflictEffectKeepLocal =>
      'A versão deste aparelho passa a valer na nuvem e nos outros aparelhos. A da nuvem é substituída.';

  @override
  String get conflictEffectUseRemote =>
      'A versão da nuvem passa a valer aqui. A sua edição deste aparelho é descartada.';

  @override
  String get conflictEffectRestore =>
      'Desfaz a exclusão feita na nuvem: volta a existir em todos os aparelhos, com a versão deste aparelho.';

  @override
  String get conflictEffectAcceptDeletion =>
      'A exclusão vale também aqui e a sua edição é descartada. Registros já feitos mantêm os próprios dados.';

  @override
  String get conflictEffectKeepDeletion =>
      'A sua exclusão vale na nuvem e nos outros aparelhos. A edição da nuvem é descartada. Registros já feitos mantêm os próprios dados.';

  @override
  String get conflictEffectUndeleteRemote =>
      'A versão editada na nuvem volta a existir aqui. A sua exclusão é descartada.';

  @override
  String get conflictKeepDeletion => 'Manter a exclusão';

  @override
  String get conflictDeletionKept => 'Exclusão mantida';

  @override
  String get conflictUseRemoteRestore => 'Usar a da nuvem (volta a existir)';

  @override
  String get orderEditTitle => 'Corrigir pedido';

  @override
  String get orderSaveEdit => 'Salvar correção';

  @override
  String get orderQuantity => 'Quantidade';

  @override
  String get orderKindAlcoholic => 'Bebida';

  @override
  String get orderKindSoft => 'Sem álcool';

  @override
  String get orderKindFood => 'Comida';

  @override
  String get orderKindOther => 'Outro';

  @override
  String get orderWhoConsumed => 'Quem consumiu?';

  @override
  String get orderConsumedHint =>
      'Quem participou do pedido. Isso não muda quem paga.';

  @override
  String get orderWhoPays => 'Quem paga?';

  @override
  String get orderPayersHint =>
      'Quem assume o custo. Isso não muda quem consumiu.';

  @override
  String get orderPayEqual => 'Dividir igual';

  @override
  String get orderPayCustom => 'Valores personalizados';

  @override
  String orderPayerAmountLabel(String name) {
    return 'Valor de $name';
  }

  @override
  String orderPayerBears(String name, String amount) {
    return '$name paga $amount';
  }

  @override
  String get orderPayersPending =>
      'Sem valor ainda: quem paga fica guardado e o valor fica pendente.';

  @override
  String get orderPayersExact => 'A soma fecha com o total.';

  @override
  String orderPayersMissing(String amount) {
    return 'Falta distribuir $amount.';
  }

  @override
  String orderPayersOver(String amount) {
    return 'Passou $amount do total.';
  }

  @override
  String get orderErrNobodyConsumed => 'Escolha quem consumiu.';

  @override
  String get orderErrNobodyPays => 'Escolha quem paga.';

  @override
  String orderErrUnits(int count) {
    return 'As unidades das pessoas precisam somar $count.';
  }

  @override
  String get orderErrPayersSum =>
      'Os valores precisam somar o total do pedido.';

  @override
  String get orderUnitsPerPerson => 'Informar unidades por pessoa';

  @override
  String get orderUnitsHint =>
      'Sem isso, cada unidade é um pedido compartilhado.';

  @override
  String orderSummaryPays(String who) {
    return 'Paga: $who';
  }

  @override
  String get orderBalanceTitle => 'Saldos atualizados';

  @override
  String get orderBalanceBody =>
      'Os pagamentos registrados foram mantidos. Saldo de quem mudou (antes → depois):';

  @override
  String orderBalanceLine(String name, String before, String after) {
    return '$name: $before → $after';
  }

  @override
  String ordersPays(String names) {
    return 'Paga: $names';
  }

  @override
  String get tileOrders => 'Pedidos';

  @override
  String get tileShared => 'Compartilhados';

  @override
  String get peopleDrankNothing => 'Nenhum pedido ainda.';

  @override
  String peopleOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
    );
    return '$_temp0';
  }

  @override
  String peopleSharedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Participou de $count pedidos compartilhados',
      one: 'Participou de 1 pedido compartilhado',
    );
    return '$_temp0';
  }

  @override
  String statsSharedNote(String count) {
    return '$count compartilhados';
  }

  @override
  String tableSharedPeople(String count) {
    return 'Pedido compartilhado por $count pessoas';
  }

  @override
  String get bafoTitle => 'Bafômetro';

  @override
  String get bafoHubBody => 'Escolha alguém do rolê, sopre e veja o medidor.';

  @override
  String get bafoWho => 'Quem vai soprar?';

  @override
  String get bafoEmptyTitle => 'Sem rolê por aqui';

  @override
  String get bafoEmptyBody =>
      'Comece um rolê e adicione as pessoas para usar o Bafômetro.';

  @override
  String get bafoSimulation => 'Simulação';

  @override
  String get bafoAnother => 'Outra pessoa';

  @override
  String bafoMeterSemantics(String name) {
    return 'Medidor de $name';
  }

  @override
  String get bafoBlowPrompt => 'Sopre no microfone';

  @override
  String get bafoHoldPrompt => 'Segure o botão';

  @override
  String get bafoHintLouder => 'Chegue mais perto do microfone.';
}
