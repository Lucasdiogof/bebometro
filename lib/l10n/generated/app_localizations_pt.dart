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
  String get accountLegacy => 'Registros antigos deste aparelho';

  @override
  String get accountLegacyDecide =>
      'Registros antigos deste aparelho: importar ou exportar';

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
  String get authAlreadyConfirmed => 'Já confirmei: entrar';

  @override
  String get authCancelAndLeave => 'Cancelar e sair';

  @override
  String get authCheckEmail => 'Confira o e-mail digitado.';

  @override
  String authCheckInboxBody(String email) {
    return 'Enviamos um link para $email. Abra o link neste aparelho para concluir.';
  }

  @override
  String get authCheckInboxTitle => 'Confira seu e-mail';

  @override
  String get authChoosePassword => 'Escolha sua senha';

  @override
  String get authChoosePasswordBody =>
      'E-mail confirmado. Agora escolha a senha para entrar em outros aparelhos.';

  @override
  String get authCloudDown =>
      'Não foi possível falar com o servidor agora. Confira a internet e tente de novo em instantes.';

  @override
  String get authConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authConvertBody =>
      'Seus registros deste aparelho continuam com você. Depois de confirmar o e-mail, você escolhe a senha.';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authCreateWithRecords => 'Criar conta com seus registros';

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
  String get authLinkingDisabled =>
      'A conversão da conta antiga não está liberada no servidor ainda. Você pode criar uma conta nova e importar os registros depois.';

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
  String get authNoOldSession => 'Não há uma sessão antiga para converter.';

  @override
  String get authNotArrived =>
      'Não chegou? Confira o spam e se o endereço está certo. O link vale por tempo limitado.';

  @override
  String get authPassword => 'Senha';

  @override
  String get authPasswordHelper =>
      'Pelo menos 8 caracteres, com letras e números.';

  @override
  String get authPasswordMin => 'Use pelo menos 8 caracteres.';

  @override
  String get authPasswordMix => 'Misture letras e números.';

  @override
  String get authPasswordsDiffer => 'As senhas não são iguais.';

  @override
  String get authRecoverBody =>
      'Enviamos um link para criar uma nova senha. Abra-o neste aparelho.';

  @override
  String get authRecoverSent =>
      'Se houver uma conta com esse e-mail, o link chega em instantes. Confira também o spam.';

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
  String get authResent => 'Enviamos outro e-mail. Confira também o spam.';

  @override
  String get authSamePassword => 'A nova senha precisa ser diferente da atual.';

  @override
  String get authSavePassword => 'Salvar senha';

  @override
  String get authSendAgain => 'Enviar de novo';

  @override
  String get authSendConfirmation => 'Enviar confirmação';

  @override
  String get authSendLink => 'Enviar link';

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
      'Vamos enviar um link para confirmar o e-mail. Seu nome e e-mail só servem para a sua conta.';

  @override
  String get authSignupDisabled =>
      'Cadastro desativado no servidor no momento.';

  @override
  String get authTooManyAttempts =>
      'Muitas tentativas. Espere alguns minutos e tente de novo.';

  @override
  String get authTooManyShort => 'Muitas tentativas. Espere alguns minutos.';

  @override
  String get authUseOtherEmail => 'Usar outro e-mail';

  @override
  String get authUseOtherEmailBack => 'Voltar e usar outro e-mail';

  @override
  String get authWeakPassword =>
      'Senha fraca. Use pelo menos 8 caracteres, misturando letras e números.';

  @override
  String get authWrongCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authYourAccount => 'sua conta';

  @override
  String get authYourEmail => 'o seu e-mail';

  @override
  String get budgetDialogTitle => 'Orçamento para bebidas';

  @override
  String get budgetEdit => 'Editar orçamento';

  @override
  String budgetLeft(String amount) {
    return 'Sobram $amount do orçamento.';
  }

  @override
  String budgetLeftIncomplete(String amount, int count) {
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
      'Opcional. Compara só com os gastos que você informou.';

  @override
  String budgetOver(String amount) {
    return 'Passou $amount do orçamento.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'Os gastos informados já passaram $amount do orçamento e ainda faltam preços.';
  }

  @override
  String budgetReached(String budget, int percent, String spent) {
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
  String conflictTabPayments(String amount, int count) {
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
  String conflictTabPeople(int extras, int people) {
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
  String get homeInformedSpent => 'Gasto informado';

  @override
  String get homeLastOuting => 'Último rolê';

  @override
  String get homeNoneThisMonth => 'Nenhum rolê encerrado neste mês ainda.';

  @override
  String get homeOutingRunning => 'Rolê em andamento';

  @override
  String get homeOutings => 'Rolês';

  @override
  String get homeSpent => 'Gasto';

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
  String get legacyAnonBody =>
      'Se você já usava o app neste aparelho, seus registros foram guardados. Crie sua conta para continuar com eles e recuperá-los em outro aparelho.';

  @override
  String get legacyAnonCreate => 'Criar conta com meus registros';

  @override
  String get legacyAnonHaveAccount => 'Já tenho conta';

  @override
  String get legacyAnonHaveAccountHint =>
      'Os registros antigos ficam separados neste aparelho; você decide depois se importa para a conta.';

  @override
  String get legacyAnonTitle => 'Agora o Bebômetro usa conta';

  @override
  String get legacyAnonView => 'Ver ou exportar os registros antigos';

  @override
  String get legacyDrinks => 'Bebidas';

  @override
  String get legacyExport => 'Exportar registros antigos (JSON)';

  @override
  String get legacyImport => 'Importar para minha conta';

  @override
  String get legacyImportAsEnded => 'Importar como encerrado';

  @override
  String get legacyImportExplain =>
      'Importar copia os registros para a conta atual com novos identificadores (as fotos são reenviadas). Uma conta anônima antiga não pode ser recuperada sem a sessão dela: o que importa é o que está neste aparelho.';

  @override
  String get legacyImportFailed =>
      'A importação não terminou. Nada foi apagado; tente de novo.';

  @override
  String legacyImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Importação concluída: $count registros copiados para a sua conta. A cópia antiga continua guardada neste aparelho.',
      one: 'Importação concluída: 1 registro copiado para a sua conta. A cópia antiga continua guardada neste aparelho.',
    );
    return '$_temp0';
  }

  @override
  String get legacyKeep => 'Manter separados por enquanto';

  @override
  String get legacyKept =>
      'Os registros antigos continuam separados neste aparelho. Você pode importar quando quiser, por \"Minha conta\".';

  @override
  String get legacyNeverSent => 'Nunca enviados';

  @override
  String get legacyNone => 'Não há registros antigos neste aparelho.';

  @override
  String get legacyNotice =>
      'Há registros antigos neste aparelho. Eles estão guardados: depois de entrar, você pode importá-los. Toque para ver ou exportar.';

  @override
  String legacyOfferBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Há $count rolês de antes de o Bebômetro usar contas. Eles estão guardados e não entram na sua conta sem você escolher.',
      one: 'Há 1 rolê de antes de o Bebômetro usar contas. Ele está guardado e não entra na sua conta sem você escolher.',
    );
    return '$_temp0';
  }

  @override
  String get legacyOfferOpen => 'Ver e decidir';

  @override
  String get legacyOfferTitle => 'Registros antigos neste aparelho';

  @override
  String get legacyOutings => 'Rolês';

  @override
  String get legacyStatusAdopted =>
      'Estes registros já são da sua conta (criada a partir deles).';

  @override
  String get legacyStatusImported =>
      'Estes registros já foram importados para uma conta. A cópia antiga fica guardada aqui por segurança.';

  @override
  String get legacyStatusKept =>
      'Você escolheu manter estes registros separados.';

  @override
  String get legacyStatusPending =>
      'Registros feitos antes de o Bebômetro usar contas. Eles não foram apagados.';

  @override
  String get legacyTitle => 'Registros antigos';

  @override
  String get legacyTwoActiveBody =>
      'Sua conta já tem um rolê em andamento e os registros antigos também. Para importar, o rolê antigo entra como encerrado agora. As bebidas dele continuam nele, sem se misturar.';

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
  String outingTypeSince(String time, String type) {
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
  String get restoreBody =>
      'Trazendo seus rolês, bebidas, locais e comandas da nuvem.';

  @override
  String get restoreConnecting => 'Conectando…';

  @override
  String get restoreFailedBody =>
      'Sem conexão com a nuvem. Nada foi perdido: tente de novo quando estiver com internet.';

  @override
  String get restoreFailedTitle => 'Não deu para recuperar agora';

  @override
  String restoreReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros recebidos até agora',
      one: '1 registro recebido até agora',
    );
    return '$_temp0';
  }

  @override
  String get restoreTitle => 'Recuperando seu histórico';

  @override
  String get restoreUseApp => 'Usar o app enquanto isso';

  @override
  String get restoreUseAppHint =>
      'Se continuar agora, o histórico aparece conforme chegar. Os registros novos ficam salvos neste aparelho e são enviados depois.';

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
  String staleBody(String duration, String name, String start) {
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
  String get summarySpentOnDrinks => 'Gastos registrados em bebidas';

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
  String volumeKnownPlusUnknown(int count, String known) {
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
  String entrySharedLine(String count, String total) {
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
  String entryHistoryShare(String date, String price, String scope) {
    return 'Sua parcela foi $price $scope em $date.';
  }

  @override
  String entryHistoryPaid(String date, String price, String scope) {
    return 'Você pagou $price $scope em $date.';
  }

  @override
  String get entryUseAsShare => 'Usar como minha parcela';

  @override
  String get entryUseValue => 'Usar este valor';

  @override
  String entryHistoryTotal(String date, String price) {
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
  String detailSourceLine(String date, String source) {
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
}
