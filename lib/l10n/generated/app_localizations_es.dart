// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountAllConfirmed => 'Todo confirmado en la nube';

  @override
  String get accountAllSentNow => 'Todo enviado. Ya puedes cerrar sesión.';

  @override
  String get accountChangePassword => 'Cambiar contraseña';

  @override
  String get accountCloud => 'Nube';

  @override
  String get accountCodeField => 'Código recibido por correo';

  @override
  String get accountCodeSent => 'Enviamos un código a tu correo.';

  @override
  String accountConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios por resolver',
      one: '1 cambio por resolver',
    );
    return '$_temp0';
  }

  @override
  String get accountDelete => 'Eliminar cuenta';

  @override
  String get accountEditName => 'Editar nombre';

  @override
  String get accountEmailConfirmed => 'Correo confirmado';

  @override
  String get accountEmailNotConfirmed => 'Correo no confirmado';

  @override
  String get accountHistoryNotDone =>
      'El historial de la nube aún no terminó de llegar a este dispositivo.';

  @override
  String accountLastSync(String when) {
    return 'Última sincronización completa: $when';
  }

  @override
  String get accountLastSyncNever =>
      'Última sincronización completa: todavía no hubo.';

  @override
  String get accountLegacy => 'Registros antiguos de este dispositivo';

  @override
  String get accountLegacyDecide =>
      'Registros antiguos de este dispositivo: importar o exportar';

  @override
  String get accountName => 'Nombre';

  @override
  String get accountNameUpdated => 'Nombre actualizado';

  @override
  String get accountNoName => 'Sin nombre';

  @override
  String get accountNothingWaiting => 'Nada pendiente de envío.';

  @override
  String accountOnlyHerePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'También $count fotos pendientes de envío.',
      one: 'También 1 foto pendiente de envío.',
    );
    return '$_temp0';
  }

  @override
  String accountOnlyHereRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardado solo en este dispositivo por ahora: $count registros.',
      one: 'Guardado solo en este dispositivo por ahora: 1 registro.',
    );
    return '$_temp0';
  }

  @override
  String get accountPasswordChanged => 'Contraseña cambiada';

  @override
  String get accountResendCode => 'Enviar el código de nuevo';

  @override
  String get accountRestoring => 'Recuperando…';

  @override
  String get accountSaveNewPassword => 'Guardar nueva contraseña';

  @override
  String get accountSession => 'Sesión';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutClean =>
      'Tus datos están en la nube y vuelven cuando inicies sesión de nuevo. En este dispositivo quedan guardados solo para esta cuenta.';

  @override
  String accountSignOutConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'También hay $count cambios por resolver.',
      one: 'También hay 1 cambio por resolver.',
    );
    return '$_temp0';
  }

  @override
  String accountSignOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count cambios sin enviar.',
      one: 'Hay 1 cambio sin enviar.',
    );
    return '$_temp0 Siguen guardados en este dispositivo, vinculados a esta cuenta, y solo vuelven a aparecer cuando inicies sesión en ella.';
  }

  @override
  String get accountSignOutTitle => '¿Cerrar sesión?';

  @override
  String get accountStillPending =>
      'Aún hay pendientes: quedan guardados en este dispositivo.';

  @override
  String get accountSyncFirst => 'Sincronizar antes';

  @override
  String get accountYourData => 'Tus datos';

  @override
  String get accountYourName => 'Tu nombre';

  @override
  String alcoholAtLeast(String amount) {
    return 'al menos $amount';
  }

  @override
  String get alcoholDeclared => 'Alcohol puro declarado';

  @override
  String get alcoholExplain =>
      'Calculado solo con lo informado: volumen × graduación en bebidas simples y cantidad × graduación de cada componente en los cócteles. En cócteles vale la receta declarada, no lo que sirvió el bar. No es la concentración de alcohol en sangre y no indica si puedes conducir.';

  @override
  String alcoholIncompletePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count registros con graduación o cantidad desconocida: el total es un mínimo',
      one: '1 registro con graduación o cantidad desconocida: el total es un mínimo',
    );
    return '$_temp0';
  }

  @override
  String alcoholNoVolumePill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros sin volumen informado (no entran en el volumen)',
      one: '1 registro sin volumen informado (no entra en el volumen)',
    );
    return '$_temp0';
  }

  @override
  String get appName => 'Bebômetro';

  @override
  String get authAlreadyConfirmed => 'Ya confirmé: iniciar sesión';

  @override
  String get authCancelAndLeave => 'Cancelar y salir';

  @override
  String get authCheckEmail => 'Revisa el correo que escribiste.';

  @override
  String authCheckInboxBody(String email) {
    return 'Enviamos un enlace a $email. Ábrelo en este dispositivo para terminar.';
  }

  @override
  String get authCheckInboxTitle => 'Revisa tu correo';

  @override
  String get authChoosePassword => 'Elige tu contraseña';

  @override
  String get authChoosePasswordBody =>
      'Correo confirmado. Ahora elige la contraseña para entrar en otros dispositivos.';

  @override
  String get authCloudDown =>
      'No se pudo contactar con el servidor ahora. Revisa internet e inténtalo de nuevo en un momento.';

  @override
  String get authConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authConvertBody =>
      'Tus registros de este dispositivo siguen contigo. Después de confirmar el correo, eliges la contraseña.';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateWithRecords => 'Crear cuenta con tus registros';

  @override
  String get authDifferentAccount =>
      'La cuenta es distinta de la sesión actual.';

  @override
  String get authEmail => 'Correo';

  @override
  String get authEmailExists =>
      'Ya existe una cuenta con este correo. Inicia sesión o recupera la contraseña.';

  @override
  String get authEmailNotConfirmed =>
      'Confirma tu correo antes de entrar. Busca el enlace en tu bandeja de entrada (y en spam).';

  @override
  String get authEnterEmail => 'Escribe tu correo.';

  @override
  String get authEnterPassword => 'Escribe tu contraseña.';

  @override
  String get authForgot => 'Olvidé mi contraseña';

  @override
  String get authGenericError =>
      'No se pudo completar ahora. Inténtalo de nuevo.';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authLinkInvalid =>
      'Este enlace caducó o ya se usó. Pide otro y ábrelo en este dispositivo. Si confirmaste el correo en otro dispositivo, solo inicia sesión con correo y contraseña.';

  @override
  String get authLinkingDisabled =>
      'La conversión de la cuenta antigua aún no está habilitada en el servidor. Puedes crear una cuenta nueva e importar los registros después.';

  @override
  String get authNameMissing => '¿Cómo te llamamos?';

  @override
  String get authNeedsCode =>
      'Por seguridad, confirma con el código enviado a tu correo.';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String authNewPasswordFor(String email) {
    return 'Crea una nueva contraseña para $email.';
  }

  @override
  String get authNewPasswordTitle => 'Nueva contraseña';

  @override
  String get authNoConnection =>
      'Sin conexión. Revisa internet e inténtalo de nuevo.';

  @override
  String get authNoOldSession => 'No hay una sesión antigua para convertir.';

  @override
  String get authNotArrived =>
      '¿No llegó? Revisa el spam y que la dirección sea correcta. El enlace vale por tiempo limitado.';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHelper =>
      'Al menos 8 caracteres, con letras y números.';

  @override
  String get authPasswordMin => 'Usa al menos 8 caracteres.';

  @override
  String get authPasswordMix => 'Combina letras y números.';

  @override
  String get authPasswordsDiffer => 'Las contraseñas no coinciden.';

  @override
  String get authRecoverBody =>
      'Enviaremos un enlace para crear una nueva contraseña. Ábrelo en este dispositivo.';

  @override
  String get authRecoverSent =>
      'Si hay una cuenta con este correo, el enlace llega en un momento. Revisa también el spam.';

  @override
  String get authRecoverTitle => 'Recuperar contraseña';

  @override
  String get authResend => 'Reenviar correo';

  @override
  String authResendIn(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String authResendWait(int seconds) {
    return 'Espera $seconds s para pedir otro correo.';
  }

  @override
  String get authResent => 'Enviamos otro correo. Revisa también el spam.';

  @override
  String get authSamePassword =>
      'La nueva contraseña debe ser distinta de la actual.';

  @override
  String get authSavePassword => 'Guardar contraseña';

  @override
  String get authSendAgain => 'Enviar de nuevo';

  @override
  String get authSendConfirmation => 'Enviar confirmación';

  @override
  String get authSendLink => 'Enviar enlace';

  @override
  String get authServerUnreachable =>
      'Sin conexión con el servidor ahora. Inténtalo de nuevo en un momento.';

  @override
  String get authSessionEnded => 'Tu sesión terminó. Vuelve a iniciar sesión.';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignInAgainBody =>
      'Tu sesión terminó en el servidor. Tus registros siguen en este dispositivo y vuelven cuando inicies sesión en la misma cuenta.';

  @override
  String get authSignInAgainTitle => 'Vuelve a iniciar sesión';

  @override
  String get authSignInAgainToContinue =>
      'Vuelve a iniciar sesión para continuar.';

  @override
  String get authSignInBody =>
      'Tus salidas se guardan en tu cuenta y vuelven en cualquier dispositivo.';

  @override
  String get authSignUpNote =>
      'Enviaremos un enlace para confirmar el correo. Tu nombre y correo solo sirven para tu cuenta.';

  @override
  String get authSignupDisabled =>
      'El registro está desactivado en el servidor por ahora.';

  @override
  String get authTooManyAttempts =>
      'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get authTooManyShort => 'Demasiados intentos. Espera unos minutos.';

  @override
  String get authUseOtherEmail => 'Usar otro correo';

  @override
  String get authUseOtherEmailBack => 'Volver y usar otro correo';

  @override
  String get authWeakPassword =>
      'Contraseña débil. Usa al menos 8 caracteres, combinando letras y números.';

  @override
  String get authWrongCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authYourAccount => 'tu cuenta';

  @override
  String get authYourEmail => 'tu correo';

  @override
  String get budgetDialogTitle => 'Presupuesto para bebidas';

  @override
  String get budgetEdit => 'Editar presupuesto';

  @override
  String budgetLeft(String amount) {
    return 'Quedan $amount del presupuesto.';
  }

  @override
  String budgetLeftIncomplete(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Según los gastos informados, quedan $amount del presupuesto (parcial: faltan precios de $count bebidas).',
      one:
          'Según los gastos informados, quedan $amount del presupuesto (parcial: falta el precio de 1 bebida).',
    );
    return '$_temp0';
  }

  @override
  String budgetLine(String budget, String spent) {
    return 'Presupuesto $budget · gasto informado $spent';
  }

  @override
  String get budgetMustBePositive => 'Indica un valor mayor que cero';

  @override
  String get budgetOptionalNote =>
      'Opcional. Solo compara con los gastos que informaste.';

  @override
  String budgetOver(String amount) {
    return 'Superaste el presupuesto en $amount.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'Los gastos informados ya superan el presupuesto en $amount y aún faltan precios.';
  }

  @override
  String budgetReached(String budget, int percent, String spent) {
    return 'Los gastos informados llegaron al $percent % del presupuesto ($spent de $budget).';
  }

  @override
  String get budgetReachedIncomplete =>
      'Hay bebidas sin precio: el total real puede ser mayor.';

  @override
  String get budgetSet => 'Definir presupuesto';

  @override
  String get budgetValue => 'Valor';

  @override
  String get commonAdjust => 'Ajustar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonError => 'Algo salió mal';

  @override
  String get commonLater => 'Más tarde';

  @override
  String get commonMoreOptions => 'Más opciones';

  @override
  String get commonNotNow => 'Ahora no';

  @override
  String get commonOptional => '(opcional)';

  @override
  String get commonOptions => 'Opciones';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonRetry => 'Intentar de nuevo';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String get conflictAcceptDeletion => 'Aceptar la eliminación';

  @override
  String get conflictApplyFailed => 'No se pudo aplicar. No se perdió nada.';

  @override
  String get conflictCloud => 'En la nube';

  @override
  String get conflictCloudDeleted => 'En la nube (eliminado)';

  @override
  String get conflictCustomDrink =>
      'Bebida personal modificada en dos dispositivos';

  @override
  String get conflictDeletionAccepted => 'Eliminación aceptada';

  @override
  String get conflictDrink => 'Bebida editada en dos dispositivos';

  @override
  String conflictEditedAt(String when) {
    return 'Editado el $when';
  }

  @override
  String conflictEnd(String when) {
    return 'Fin: $when';
  }

  @override
  String get conflictEndHere => 'Terminar la de este dispositivo';

  @override
  String get conflictEndOther => 'Terminar la del otro dispositivo';

  @override
  String get conflictFromHere => 'De este dispositivo';

  @override
  String get conflictFromOther => 'Del otro dispositivo';

  @override
  String get conflictHere => 'En este dispositivo';

  @override
  String get conflictIntro =>
      'Estos cambios se hicieron en más de un dispositivo a la vez. Elige qué versión vale. La otra se descarta solo cuando elijas.';

  @override
  String get conflictItem => 'Elemento modificado en dos dispositivos';

  @override
  String get conflictKeepLocal => 'Mantener la de este dispositivo';

  @override
  String get conflictKeptLocal => 'Se mantuvo la versión de este dispositivo';

  @override
  String get conflictNone => 'Nada por resolver. Todo bien.';

  @override
  String get conflictOuting => 'Salida modificada en dos dispositivos';

  @override
  String get conflictOutingEnded => 'Salida terminada';

  @override
  String conflictOutingLine(String label, String name) {
    return '$label: $name';
  }

  @override
  String conflictPaid(String amount) {
    return 'Pagado: $amount';
  }

  @override
  String get conflictPlace => 'Lugar modificado en dos dispositivos';

  @override
  String get conflictRemoteUnreadable =>
      'No se pudo leer la versión de la nube ahora. Puedes mantener la de este dispositivo o intentarlo más tarde.';

  @override
  String get conflictRestore => 'Restaurar con la versión de este dispositivo';

  @override
  String get conflictRestored => 'Restaurado con tu versión';

  @override
  String conflictSince(String when) {
    return 'desde $when';
  }

  @override
  String conflictStart(String when) {
    return 'Inicio: $when';
  }

  @override
  String get conflictTab => 'Cuenta modificada en dos dispositivos';

  @override
  String conflictTabPayments(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagos registrados: $amount',
      one: '1 pago registrado: $amount',
      zero: 'Ningún pago registrado',
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
      other: '$extras extras',
      one: '1 extra',
      zero: 'ningún extra',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get conflictTitle => 'Cambios por resolver';

  @override
  String get conflictTwoActiveBody =>
      'Una se empezó en este dispositivo y otra en otro dispositivo, sin internet. Las dos se guardaron con sus bebidas. Elige cuál terminar ahora.';

  @override
  String get conflictUseRemote => 'Usar la de la nube';

  @override
  String get conflictUsedRemote => 'Se usó la versión de la nube';

  @override
  String dateAtTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get deleteBody =>
      'Esto elimina para siempre tu cuenta, todas las salidas, bebidas, lugares, cuentas y fotos guardadas en la nube, y los datos de esta cuenta en este dispositivo. No se puede deshacer.';

  @override
  String get deleteConfirmPassword => 'Confirma tu contraseña.';

  @override
  String get deleteConfirmPasswordAgain => 'Confirma tu contraseña de nuevo.';

  @override
  String get deleteExportFirst =>
      'Si quieres guardar una copia, exporta tus datos antes (Ajustes > Exportar mis datos).';

  @override
  String get deleteOffline => 'Sin conexión. No se borró nada.';

  @override
  String get deletePartial =>
      'La eliminación empezó pero no terminó. No se borró nada del dispositivo. Toca \"Eliminar cuenta\" de nuevo para continuar.';

  @override
  String get deleteTickFirst => 'Marca la confirmación para continuar.';

  @override
  String get deleteUnavailable =>
      'La eliminación aún no está disponible en el servidor. No se borró nada. Inténtalo más tarde.';

  @override
  String get deleteUnderstand => 'Entiendo que la eliminación es permanente.';

  @override
  String get deleteYourPassword => 'Tu contraseña';

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
  String get drinkShared => 'compartida';

  @override
  String get drinkWater => 'Agua';

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
  String get entryAlcoholIncomplete => 'alcohol incompleto';

  @override
  String get entryCorrect => 'Corregir';

  @override
  String get entryOptions => 'Opciones del registro';

  @override
  String entrySharedPart(int count, String mine, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tu parte $mine de $total ($count personas)',
      one: 'tu parte $mine de $total (1 persona)',
    );
    return '$_temp0';
  }

  @override
  String get feedbackDontAsk => 'No preguntar';

  @override
  String get feedbackFreeNote => 'Nota libre';

  @override
  String get feedbackFreeNoteHint => 'Algo que quieras recordar de esta salida';

  @override
  String get feedbackHangover => 'Resaca';

  @override
  String get feedbackHowItWent => 'Cómo fue';

  @override
  String get feedbackNote =>
      'Es solo tu relato de cómo fue la noche. No mide nada ni indica cuánto es seguro beber.';

  @override
  String get feedbackOptional =>
      'Todo opcional. Es solo un registro personal, sin nota ni comparación.';

  @override
  String get feedbackReviewForgotten => 'Revisar bebidas olvidadas';

  @override
  String get feedbackSave => 'Guardar relato';

  @override
  String get feedbackTellMore => '¿Quieres contar más?';

  @override
  String get feedbackTitle => '¿Cómo fue la última salida?';

  @override
  String get feedbackWake => 'Cómo despertaste';

  @override
  String get feedbackYourAccount => 'Tu relato';

  @override
  String get fileGenerationFailed => 'No se pudo generar el archivo.';

  @override
  String financeInformed(String amount) {
    return '$amount informados';
  }

  @override
  String get financeNoRecords => 'Sin registros todavía';

  @override
  String get financeNoValue => 'Ningún valor informado';

  @override
  String financeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas sin precio',
      one: '1 bebida sin precio',
    );
    return '$_temp0';
  }

  @override
  String get finishAndSummary => 'Terminar y ver resumen';

  @override
  String finishBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros.',
      one: '1 registro.',
      zero: 'Ningún registro.',
    );
    return '$_temp0 Podrás corregir registros después, desde el historial.';
  }

  @override
  String finishEnd(String when) {
    return 'Fin: $when';
  }

  @override
  String get finishKeepGoing => 'Seguir con la salida';

  @override
  String get finishTitle => '¿Terminar salida?';

  @override
  String get glassBigSubtitle => 'El volumen informado, sumado, en un vaso.';

  @override
  String get glassBigTitle => 'Vasote (opcional)';

  @override
  String get glassTipPlay => 'Jugar a voltear el vaso';

  @override
  String get groupRecipeAdjusted => 'receta ajustada';

  @override
  String groupSharedPart(String mine, String total) {
    return '$mine tuyos de $total';
  }

  @override
  String groupTimes(int count) {
    return '$count×';
  }

  @override
  String get groupVolumeUnknown => 'volumen desconocido';

  @override
  String get groupVolumeUnknownShort => 'volumen ?';

  @override
  String get hangoverMild => 'Leve';

  @override
  String get hangoverModerate => 'Moderada';

  @override
  String get hangoverNone => 'Ninguna';

  @override
  String get hangoverStrong => 'Fuerte';

  @override
  String get homeContinueOuting => 'Continuar salida';

  @override
  String get homeDrinks => 'Bebidas';

  @override
  String get homeFirstBody =>
      'Cuando termines una salida, el resumen del mes aparece aquí, solo con lo que registraste.';

  @override
  String get homeFirstTitle => 'Tu primera salida empieza aquí';

  @override
  String get homeIdleBody =>
      'Anota lo que bebiste y cuánto gastaste, sin complicaciones.';

  @override
  String get homeIdleTitle => '¿Salimos?';

  @override
  String get homeInformedSpent => 'Gasto informado';

  @override
  String get homeLastOuting => 'Última salida';

  @override
  String get homeNoneThisMonth => 'Ninguna salida terminada este mes todavía.';

  @override
  String get homeOutingRunning => 'Salida en curso';

  @override
  String get homeOutings => 'Salidas';

  @override
  String get homeSpent => 'Gasto';

  @override
  String get homeStartOuting => 'Iniciar salida';

  @override
  String get homeThisMonth => 'Este mes';

  @override
  String get homeTime => 'Tiempo';

  @override
  String homeUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin precio',
      one: '1 sin precio',
    );
    return '$_temp0';
  }

  @override
  String get itemFallbackName => 'Elemento';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get languageMoneyNote =>
      'Los valores siguen en reales (R\$) en cualquier idioma.';

  @override
  String get languagePt => 'Português (Brasil)';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageSystemHint =>
      'Portugués, inglés o español según el dispositivo; otros idiomas usan portugués.';

  @override
  String get legacyAnonBody =>
      'Si ya usabas la app en este dispositivo, tus registros se guardaron. Crea tu cuenta para seguir con ellos y recuperarlos en otro dispositivo.';

  @override
  String get legacyAnonCreate => 'Crear cuenta con mis registros';

  @override
  String get legacyAnonHaveAccount => 'Ya tengo cuenta';

  @override
  String get legacyAnonHaveAccountHint =>
      'Los registros antiguos quedan separados en este dispositivo; después decides si los importas a la cuenta.';

  @override
  String get legacyAnonTitle => 'Ahora Bebômetro usa cuentas';

  @override
  String get legacyAnonView => 'Ver o exportar los registros antiguos';

  @override
  String get legacyDrinks => 'Bebidas';

  @override
  String get legacyExport => 'Exportar registros antiguos (JSON)';

  @override
  String get legacyImport => 'Importar a mi cuenta';

  @override
  String get legacyImportAsEnded => 'Importar como terminada';

  @override
  String get legacyImportExplain =>
      'Importar copia los registros a la cuenta actual con nuevos identificadores (las fotos se vuelven a enviar). Una cuenta anónima antigua no se puede recuperar sin su sesión: lo que se importa es lo que está en este dispositivo.';

  @override
  String get legacyImportFailed =>
      'La importación no terminó. No se borró nada; inténtalo de nuevo.';

  @override
  String legacyImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Importación completada: $count registros copiados a tu cuenta. La copia antigua sigue guardada en este dispositivo.',
      one: 'Importación completada: 1 registro copiado a tu cuenta. La copia antigua sigue guardada en este dispositivo.',
    );
    return '$_temp0';
  }

  @override
  String get legacyKeep => 'Mantener separados por ahora';

  @override
  String get legacyKept =>
      'Los registros antiguos siguen separados en este dispositivo. Puedes importarlos cuando quieras desde \"Mi cuenta\".';

  @override
  String get legacyNeverSent => 'Nunca enviados';

  @override
  String get legacyNone => 'No hay registros antiguos en este dispositivo.';

  @override
  String get legacyNotice =>
      'Hay registros antiguos en este dispositivo. Están guardados: después de entrar puedes importarlos. Toca para ver o exportar.';

  @override
  String legacyOfferBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hay $count salidas de antes de que Bebômetro usara cuentas. Están guardadas y no entran en tu cuenta sin que lo elijas.',
      one: 'Hay 1 salida de antes de que Bebômetro usara cuentas. Está guardada y no entra en tu cuenta sin que lo elijas.',
    );
    return '$_temp0';
  }

  @override
  String get legacyOfferOpen => 'Ver y decidir';

  @override
  String get legacyOfferTitle => 'Registros antiguos en este dispositivo';

  @override
  String get legacyOutings => 'Salidas';

  @override
  String get legacyStatusAdopted =>
      'Estos registros ya son de tu cuenta (creada a partir de ellos).';

  @override
  String get legacyStatusImported =>
      'Estos registros ya se importaron a una cuenta. La copia antigua queda aquí por seguridad.';

  @override
  String get legacyStatusKept => 'Elegiste mantener estos registros separados.';

  @override
  String get legacyStatusPending =>
      'Registros hechos antes de que Bebômetro usara cuentas. No se borraron.';

  @override
  String get legacyTitle => 'Registros antiguos';

  @override
  String get legacyTwoActiveBody =>
      'Tu cuenta ya tiene una salida en curso y los registros antiguos también. Para importar, la salida antigua entra como terminada ahora. Sus bebidas siguen en ella, sin mezclarse.';

  @override
  String get legacyTwoActiveTitle => 'Dos salidas en curso';

  @override
  String get moneyFieldHelper => 'Valores en reales (R\$). Ej.: 15 o 15,50.';

  @override
  String get moodCheerful => 'Alegre';

  @override
  String get moodDrunk => 'Borracho';

  @override
  String get moodSmooth => 'Tranquilo';

  @override
  String get moodWasted => 'Muy borracho';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navGames => 'Juegos';

  @override
  String get navHistory => 'Historial';

  @override
  String get navHome => 'Inicio';

  @override
  String noticeAnotherOne(String name) {
    return 'Otra más: $name';
  }

  @override
  String get noticeEntryDeleted => 'Registro eliminado';

  @override
  String get noticeWater => 'Agua registrada';

  @override
  String get numberAmbiguous =>
      'Formato ambiguo. Usa coma o punto solo para los centavos (ej.: 1500 o 15,50).';

  @override
  String get numberInvalid => 'Número no válido.';

  @override
  String get outingAddDrink => 'Agregar bebida';

  @override
  String outingAlcoholIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count con alcohol incompleto',
      one: '1 con alcohol incompleto',
    );
    return '$_temp0';
  }

  @override
  String get outingAlreadyEnded => 'Esta salida ya terminó.';

  @override
  String outingConfirmAnother(String drink) {
    return '¿Registrar otra más: $drink?';
  }

  @override
  String get outingConfirmWater => '¿Registrar un vaso de agua?';

  @override
  String get outingDrinkLogged => 'Bebida registrada';

  @override
  String get outingEntryUpdated => 'Registro actualizado';

  @override
  String get outingFallbackName => 'Salida';

  @override
  String get outingFinish => 'Terminar salida';

  @override
  String get outingFirstDrinkHint =>
      'Registra la primera bebida y el botón \"Otra más\" aparece aquí abajo.';

  @override
  String get outingHideHere => 'Ocultar en esta salida';

  @override
  String get outingInProgress => 'En curso';

  @override
  String get outingLockScreenRequest => 'Pedido desde la pantalla de bloqueo';

  @override
  String get outingLog => 'Registrar';

  @override
  String get outingNoDrinks => 'Ninguna bebida todavía';

  @override
  String get outingNoDrinksBody =>
      'Registra la primera y el botón \"Otra más\" aparece aquí abajo.';

  @override
  String outingNoVolume(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin volumen',
      one: '1 sin volumen',
    );
    return '$_temp0';
  }

  @override
  String get outingNotFound => 'No se encontró esta salida.';

  @override
  String get outingNothingToRepeat =>
      'No hay bebida para repetir en esta salida.';

  @override
  String get outingOpenScan =>
      'Hay una lectura de etiqueta o carta abierta. Sigue vinculada a esta salida y aparece en su resumen.';

  @override
  String outingRecords(int count) {
    return 'Registros ($count)';
  }

  @override
  String get outingRunningFor => 'En marcha hace';

  @override
  String get outingShowOnLock => 'Mostrar en la pantalla de bloqueo';

  @override
  String get outingTrackingBack =>
      'El seguimiento en la pantalla de bloqueo volvió.';

  @override
  String get outingTrackingHidden =>
      'Oculto de la pantalla de bloqueo en esta salida.';

  @override
  String get outingTypeBar => 'Bar';

  @override
  String get outingTypeBarbecue => 'Asado';

  @override
  String get outingTypeBeach => 'Playa';

  @override
  String get outingTypeClub => 'Discoteca';

  @override
  String get outingTypeHome => 'Casa';

  @override
  String get outingTypeOther => 'Otro';

  @override
  String get outingTypeRestaurant => 'Restaurante';

  @override
  String outingTypeSince(String time, String type) {
    return '$type · desde las $time';
  }

  @override
  String get outingYourVolume => 'Tu volumen';

  @override
  String get placeCorrect => 'Corregir lugar';

  @override
  String get placeOpenInMaps => 'Abrir en el mapa';

  @override
  String get priceComplimentary => 'Cortesía';

  @override
  String get priceNone => 'Sin precio';

  @override
  String get priceUnknown => 'sin precio';

  @override
  String repeatAdjusted(String name) {
    return '$name (ajustada)';
  }

  @override
  String get repeatButton => 'Otra más';

  @override
  String repeatSemantics(String drink) {
    return 'Otra más: $drink';
  }

  @override
  String repeatYourPart(String amount) {
    return 'tu parte $amount';
  }

  @override
  String get repoAbvRange => 'La graduación va de 0 a 100 %.';

  @override
  String get repoActiveExists => 'Ya hay una salida en curso.';

  @override
  String repoCopyName(String name) {
    return '$name (copia)';
  }

  @override
  String get repoDrinkName => 'Ponle un nombre a la bebida.';

  @override
  String get repoDrinkVolume => 'Indica el volumen en ml.';

  @override
  String get repoEndBeforeStart => 'El fin no puede ser antes del inicio.';

  @override
  String get repoEndFuture => 'El fin no puede estar en el futuro.';

  @override
  String get repoNicknameOrAddress => 'Escribe un apodo o una dirección.';

  @override
  String get repoPlaceMissing =>
      'Escribe un apodo o una dirección para el lugar.';

  @override
  String get repoPointNeedsName =>
      'Ponle un apodo a este punto para guardarlo.';

  @override
  String get repoRecipeIngredient => 'Agrega al menos un ingrediente.';

  @override
  String get repoRecipeName => 'Ponle un nombre a la receta.';

  @override
  String get repoStateFormat => 'El estado tiene 2 letras (ej.: SP).';

  @override
  String get restoreBody =>
      'Trayendo tus salidas, bebidas, lugares y cuentas desde la nube.';

  @override
  String get restoreConnecting => 'Conectando…';

  @override
  String get restoreFailedBody =>
      'Sin conexión con la nube. No se perdió nada: inténtalo de nuevo cuando tengas internet.';

  @override
  String get restoreFailedTitle => 'No se pudo recuperar ahora';

  @override
  String restoreReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros recibidos hasta ahora',
      one: '1 registro recibido hasta ahora',
    );
    return '$_temp0';
  }

  @override
  String get restoreTitle => 'Recuperando tu historial';

  @override
  String get restoreUseApp => 'Usar la app mientras tanto';

  @override
  String get restoreUseAppHint =>
      'Si continúas ahora, el historial aparece a medida que llega. Los registros nuevos se guardan en este dispositivo y se envían después.';

  @override
  String get settingsAccount => 'Mi cuenta';

  @override
  String get settingsBudget => 'Presupuesto';

  @override
  String get settingsBudgetAlerts => 'Avisos de presupuesto';

  @override
  String get settingsBudgetAlertsHint =>
      'Un aviso al llegar al 80 % y al 100 % del presupuesto de la salida, una vez por nivel.';

  @override
  String get settingsDrinkRecords => 'Registros de bebida';

  @override
  String get settingsExport => 'Exportar mis datos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String settingsLastSync(String when) {
    return 'Última sincronización: $when';
  }

  @override
  String get settingsLastSyncNever => 'Última sincronización: todavía no hubo.';

  @override
  String get settingsLocalRisk =>
      'Mientras tanto, si desinstalas la app o borras los datos del navegador, lo que está solo en este dispositivo se perderá.';

  @override
  String get settingsLockScreen => 'Salida en la pantalla de bloqueo';

  @override
  String get settingsMyDrinks => 'Mis bebidas';

  @override
  String get settingsMyDrinksAndRecipes => 'Mis bebidas y recetas';

  @override
  String get settingsNotYetInCloud =>
      'Algunos datos aún no llegaron a la nube.';

  @override
  String get settingsOutingsHere => 'Salidas en este dispositivo';

  @override
  String settingsPendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes de envío.',
      one: '1 cambio pendiente de envío.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavedPlaces => 'Lugares guardados';

  @override
  String get settingsStorage => 'ALMACENAMIENTO';

  @override
  String get settingsSync => 'SINCRONIZACIÓN';

  @override
  String get settingsSyncDone => 'Todo sincronizado.';

  @override
  String settingsSyncDoneConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado, pero hay $count cambios por resolver en Mi cuenta.',
      one: 'Enviado, pero hay 1 cambio por resolver en Mi cuenta.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncFailed => 'No se pudo sincronizar ahora.';

  @override
  String get settingsSyncNow => 'Sincronizar ahora';

  @override
  String get settingsSyncState => 'Estado';

  @override
  String settingsSyncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aún hay $count cambios por enviar.',
      one: 'Aún hay 1 cambio por enviar.',
    );
    return '$_temp0';
  }

  @override
  String get settingsTable => 'Mesa de la salida';

  @override
  String get settingsTableAnimations => 'Animaciones de la mesa';

  @override
  String get settingsTableAnimationsHint =>
      'Los recipientes se vacían como ilustración. Desactivado, la mesa queda estática.';

  @override
  String get settingsTableDefault => 'Mostrar la mesa por defecto';

  @override
  String get settingsTableDefaultHint =>
      'En la pantalla de la salida, la mesa ilustrada se abre antes que la lista.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get shareUnavailableCopied =>
      'Compartir no está disponible aquí. El contenido se copió: pégalo en un archivo para guardarlo.';

  @override
  String get shellBackToOuting => 'Volver a la salida';

  @override
  String shellOutingRunning(String name) {
    return 'Salida en curso · $name';
  }

  @override
  String staleBody(String duration, String name, String start) {
    return '$name empezó el $start y lleva abierta $duration.';
  }

  @override
  String get staleEndOtherTime => 'Terminar con otra hora';

  @override
  String get staleNote =>
      'Al terminar eliges la hora final. Nada se termina automáticamente.';

  @override
  String get staleTitle => '¿Esta salida sigue en curso?';

  @override
  String get startFailed => 'No se pudo iniciar la salida. Inténtalo de nuevo.';

  @override
  String get startFuture => 'El inicio no puede estar en el futuro.';

  @override
  String get startPlaceError =>
      'Escribe un apodo (ej.: Casa de Samara) o una dirección';

  @override
  String get stateTwoLetters => 'El estado tiene 2 letras';

  @override
  String get summaryAccountNote =>
      'Relato personal: no mide nada ni indica un límite de consumo.';

  @override
  String get summaryAddAccount => 'Agregar relato';

  @override
  String get summaryAddForgotten => 'Agregar bebida olvidada';

  @override
  String get summaryConsumption => 'Consumo';

  @override
  String get summaryDone => 'Listo';

  @override
  String get summaryDuration => 'Duración';

  @override
  String get summaryEditAccount => 'Editar relato';

  @override
  String get summaryEnd => 'Fin';

  @override
  String get summaryFillPrices => 'Completar precios faltantes';

  @override
  String summaryHangover(String level) {
    return 'Resaca: $level';
  }

  @override
  String get summaryNoAccount => 'Sin relato todavía.';

  @override
  String get summaryNoRecords => 'Ningún registro en esta salida';

  @override
  String get summaryRetro =>
      'Retrospectiva ilustrativa de los registros. Los números reales están abajo.';

  @override
  String get summaryShare => 'Compartir resumen';

  @override
  String get summarySpending => 'Gastos';

  @override
  String get summarySpentOnDrinks => 'Gastos registrados en bebidas';

  @override
  String get summaryStart => 'Inicio';

  @override
  String get summaryTab => 'Cuenta';

  @override
  String get summaryTapToCorrect =>
      'Toca un registro para corregirlo; el resumen se recalcula.';

  @override
  String get summaryTitle => 'Resumen de la salida';

  @override
  String summaryUnpricedPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas sin precio: el total puede ser mayor',
      one: '1 bebida sin precio: el total puede ser mayor',
    );
    return '$_temp0';
  }

  @override
  String get summaryUpdated => 'Registro actualizado, resumen recalculado';

  @override
  String summaryWoke(String feeling) {
    return 'Despertaste: $feeling';
  }

  @override
  String get summaryYourAccount => 'Tu relato';

  @override
  String get summaryYourAccountTag => 'tu relato';

  @override
  String syncLabelConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por resolver',
      one: '1 por resolver',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelFailed => 'Error al sincronizar';

  @override
  String get syncLabelLocalOnly => 'Solo en este dispositivo';

  @override
  String syncLabelPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes de envío',
      one: '1 pendiente de envío',
    );
    return '$_temp0';
  }

  @override
  String get syncLabelSynced => 'Sincronizado';

  @override
  String get syncLabelSyncing => 'Sincronizando…';

  @override
  String get syncNoticeActiveConflict =>
      'El servidor ya tiene otra salida en curso. No se borró nada: los datos siguen guardados en el dispositivo.';

  @override
  String get syncNoticeLocalOnly =>
      'La nube aún no está disponible. Tus registros están guardados solo en este dispositivo y se enviarán cuando sea posible.';

  @override
  String get syncNoticeOffline => 'Sin conexión. Lo intentaremos de nuevo.';

  @override
  String get syncNoticePhotos =>
      'Algunas fotos aún no se enviaron. Siguen guardadas en el dispositivo y se volverá a intentar el envío.';

  @override
  String get syncNoticePlaceLink =>
      'El servidor no aceptó vincular una salida con el lugar guardado. No se cambió nada: los datos siguen guardados en el dispositivo.';

  @override
  String get syncNoticeRejected =>
      'El servidor rechazó algunos cambios. Tus datos siguen guardados en el dispositivo.';

  @override
  String get syncNoticeSchemaGap =>
      'Parte de los datos nuevos espera una actualización del servidor. El resto ya se envió y no se perdió nada.';

  @override
  String get syncNoticeSignInAgain =>
      'Vuelve a iniciar sesión para enviar y recibir los datos. Todo sigue guardado en este dispositivo.';

  @override
  String get syncNoticeWaitingPlace =>
      'Algunas salidas esperan el envío del lugar guardado. No se perdió nada.';

  @override
  String get tableAboutMenu =>
      'Animación ilustrativa de las bebidas registradas';

  @override
  String get tableChangeScene => 'Cambiar escenario';

  @override
  String get tableOptions => 'Opciones de la mesa';

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
    return '$known (+$count sin volumen)';
  }

  @override
  String get volumeUnknown => 'desconocido';

  @override
  String get wakeBad => 'Mal';

  @override
  String get wakeGreat => 'Bien';

  @override
  String get wakeOk => 'Normal';

  @override
  String get wakeTired => 'Cansado';

  @override
  String get startTitle => 'Iniciar salida';

  @override
  String get startWhatKind => '¿Qué tipo de salida?';

  @override
  String get startWhere => '¿Dónde?';

  @override
  String get startSearchPlace => 'Buscar bar o dirección';

  @override
  String get startSearchPlaceHint =>
      'O usar tu ubicación y comprobarla en el mapa';

  @override
  String get startSavedPlaces => 'Lugares guardados';

  @override
  String get startOrNickname => 'O solo un apodo';

  @override
  String get startNicknameLabel => 'Apodo del lugar';

  @override
  String get startNicknameHint => 'Ej.: Bar MELT, Casa de Samara';

  @override
  String get startAddAddress => 'Escribir dirección (opcional)';

  @override
  String get startAddressLabel => 'Dirección (opcional)';

  @override
  String get startAddressHint => 'Calle, número, barrio';

  @override
  String get startAddressHelper => 'Con un apodo o una dirección basta.';

  @override
  String get startCityLabel => 'Ciudad (opcional)';

  @override
  String get startStateLabel => 'Estado';

  @override
  String get startSavePlace => 'Guardar este lugar';

  @override
  String get startSavePlaceHint =>
      'Para elegirlo de nuevo en próximas salidas. Queda privado en tu perfil.';

  @override
  String get startWhen => '¿Cuándo empezó?';

  @override
  String get startBudgetSection => 'Presupuesto (opcional)';

  @override
  String get startBudgetLabel => 'Presupuesto para bebidas';

  @override
  String get startBudgetHelper =>
      'Puedes definirlo o cambiarlo después, durante la salida. Valores en reales (R\$).';

  @override
  String get startBegin => 'Empezar la salida';

  @override
  String get startWillSavePlace => 'Se guardará en tus lugares';

  @override
  String get startChangePlace => 'Cambiar';

  @override
  String priceFixApplyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Aplicar a $count registros?',
      one: '¿Aplicar a 1 registro?',
    );
    return '$_temp0';
  }

  @override
  String priceFixReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya tenían precio y serán reemplazados.',
      one: '1 ya tenía precio y será reemplazado.',
    );
    return '$_temp0';
  }

  @override
  String get priceFixYourShare => 'tu parte';

  @override
  String get priceFixUpdated => 'Precios actualizados';

  @override
  String get priceFixPaidLabel => 'Precio pagado';

  @override
  String get priceFixPaidShared => 'Cuánto pagaste';

  @override
  String get priceFixSharedNote =>
      'Bebida compartida: indica tu parte, no el precio de la botella. El consumo no cambia.';

  @override
  String get priceFixEnterValue => 'Indica un valor';

  @override
  String get priceFixTitle => 'Precios faltantes';

  @override
  String get priceFixNoneTitle => 'Ningún precio faltante';

  @override
  String get priceFixNoneBody =>
      'Todos los registros de esta salida tienen precio o cortesía indicados.';

  @override
  String get priceFixIntro =>
      'Rellénalos uno por uno, o elige varios registros iguales y aplica el mismo precio tras ver la vista previa. Los precios ya indicados no cambian, salvo que los incluyas y selecciones a propósito.';

  @override
  String get priceFixIncludePriced =>
      'Incluir también registros que ya tienen precio';

  @override
  String get priceFixForSelected => 'Precio para los seleccionados';

  @override
  String get priceFixSharedHint =>
      'En una bebida compartida vale lo que pagaste (tu parte), nunca el precio de la botella.';

  @override
  String priceFixSelectAll(String count) {
    return 'Seleccionar los $count';
  }

  @override
  String get priceFixClear => 'Quitar';

  @override
  String priceFixCurrent(String price) {
    return 'Precio actual: $price';
  }

  @override
  String get priceFixOnlyThis => 'Indicar solo este precio';

  @override
  String get priceFixSelectRecords => 'Selecciona registros';

  @override
  String priceFixPreview(String count) {
    return 'Ver vista previa ($count)';
  }

  @override
  String get originGeneric => 'Genérico';

  @override
  String get originUser => 'Creada por ti';

  @override
  String get originVerified => 'Datos del fabricante';

  @override
  String get originMixed => 'Fabricante + etiqueta (fuente secundaria)';

  @override
  String get originSecondary => 'Etiqueta en fuente secundaria';

  @override
  String get originRecipe => 'Receta de referencia';

  @override
  String get kindCan => 'Lata';

  @override
  String get kindLongNeck => 'Long neck';

  @override
  String get kindBottle => 'Botella';

  @override
  String get kindGlass => 'Vaso/copa';

  @override
  String get kindShot => 'Dosis';

  @override
  String get presCan => 'Lata';

  @override
  String get presBottle => 'Botella';

  @override
  String get presGlass => 'Vaso';

  @override
  String get presMug => 'Jarra';

  @override
  String get presTulip => 'Tulipa';

  @override
  String get presWineGlass => 'Copa';

  @override
  String get presShot => 'Dosis';

  @override
  String get presDoubleShot => 'Dosis doble';

  @override
  String unitLiters(String value) {
    return '$value L';
  }

  @override
  String get abvVaries => 'la graduación varía';

  @override
  String get categoryBeer => 'Cerveza';

  @override
  String get categoryDraft => 'Cerveza de barril';

  @override
  String get categoryCocktail => 'Cóctel';

  @override
  String get categorySpirit => 'Destilado/dosis';

  @override
  String get categoryWine => 'Vino';

  @override
  String get categoryNonAlcoholic => 'Sin alcohol';

  @override
  String get categoryWater => 'Agua';

  @override
  String get abvSourceLabel => 'Etiqueta (foto), revisada por ti';

  @override
  String get abvSourceMenu => 'Carta (foto), revisada por ti';

  @override
  String get abvSourceTyped => 'Indicado por ti';

  @override
  String get abvSourceCatalog => 'Copiado del catálogo';

  @override
  String get styleLagerPilsen => 'Lager/Pilsen';

  @override
  String get styleDark => 'Oscura';

  @override
  String get styleWhiteRum => 'Ron blanco';

  @override
  String get styleAperitif => 'Aperitivo';

  @override
  String get styleBitterAperitif => 'Aperitivo bitter';

  @override
  String get styleSweetVermouth => 'Vermut dulce';

  @override
  String get styleDryVermouth => 'Vermut seco';

  @override
  String get styleAgaveTequila => 'Tequila 100% agave';

  @override
  String get roleCachaca => 'Cachaça';

  @override
  String get roleVodka => 'Vodka';

  @override
  String get roleGin => 'Ginebra';

  @override
  String get roleRum => 'Ron';

  @override
  String get roleTequila => 'Tequila';

  @override
  String get roleWhisky => 'Whisky';

  @override
  String get roleOrangeLiqueur => 'Licor de naranja';

  @override
  String get roleCampari => 'Campari';

  @override
  String get roleAperol => 'Aperol';

  @override
  String get roleSweetVermouth => 'Vermut dulce';

  @override
  String get roleDryVermouth => 'Vermut seco';

  @override
  String get roleSparklingWine => 'Espumoso';

  @override
  String get roleBitters => 'Bitter';

  @override
  String get recipeUnitMl => 'ml (mililitros)';

  @override
  String get recipeUnitG => 'g (gramos)';

  @override
  String get recipeUnitUnit => 'unidad';

  @override
  String get recipeUnitTsp => 'cucharadita';

  @override
  String get recipeUnitTbsp => 'cucharada';

  @override
  String get recipeUnitLeaf => 'hoja';

  @override
  String get recipeUnitDrop => 'gota';

  @override
  String get recipeUnitToTaste => 'al gusto';

  @override
  String get recipeUnitOther => 'texto de la receta';

  @override
  String get recipeShortUnit => 'ud.';

  @override
  String get recipeShortTsp => 'cdta.';

  @override
  String get recipeShortTbsp => 'cda.';

  @override
  String get recipeShortLeaf => 'hoja(s)';

  @override
  String get recipeShortDrop => 'gota(s)';

  @override
  String get recipeAmountUnknown => 'cantidad no indicada';

  @override
  String get recipeGapAbv => 'graduación desconocida';

  @override
  String get recipeGapNotMl => 'la cantidad no está en ml';

  @override
  String get recipeGapAmount => 'cantidad desconocida';

  @override
  String get addDrinkTitle => 'Añadir bebida';

  @override
  String get catalogMyDrinksTooltip => 'Mis bebidas y recetas';

  @override
  String get catalogSearchHint => 'Buscar marca, producto o estilo';

  @override
  String get catalogMoreFilters => 'Más filtros';

  @override
  String get catalogAll => 'Todas';

  @override
  String get catalogScanLabel => 'Leer etiqueta';

  @override
  String get catalogScanMenu => 'Leer carta';

  @override
  String get catalogCreate => 'Crear una bebida';

  @override
  String get catalogCreateOuting => 'Crear una bebida para esta salida';

  @override
  String get catalogNeedOutingTitle => 'Necesitas una salida en curso';

  @override
  String get catalogNeedOutingBody =>
      'Las bebidas leídas de una etiqueta o carta se guardan en la salida donde se crearon. ¿Quieres iniciar una ahora?';

  @override
  String get catalogSavedToOuting => 'Guardada en \"Bebidas de esta salida\"';

  @override
  String catalogMenuSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count elementos en \"Bebidas de esta salida\". Elige uno para registrar.',
      one:
          '1 elemento en \"Bebidas de esta salida\". Elige uno para registrar.',
    );
    return '$_temp0';
  }

  @override
  String get catalogDrinkSaved => 'Bebida guardada en Mis bebidas';

  @override
  String get catalogRecipeSaved => 'Receta guardada en Mis bebidas';

  @override
  String get catalogDeleteTitle => '¿Eliminar esta bebida?';

  @override
  String get catalogDeleteBody =>
      'Sale del catálogo. Los registros que ya hiciste con ella quedan como están.';

  @override
  String get catalogClearFilters => 'Quitar filtros';

  @override
  String get catalogRemoveFilter => 'Quitar filtro';

  @override
  String get catalogFilters => 'Filtros';

  @override
  String get catalogOnlyNoAlcohol => 'Solo sin alcohol';

  @override
  String get catalogStyle => 'Estilo';

  @override
  String get catalogPresentation => 'Presentación';

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
  String get catalogRecents => 'Recientes';

  @override
  String get catalogFavorites => 'Favoritas';

  @override
  String get catalogAllDrinks => 'Todas las bebidas';

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
  String get catalogEmptyTitle => 'No se encontró ninguna bebida';

  @override
  String get catalogEmptyOuting =>
      'Crea una bebida solo para esta salida, o lee una etiqueta o una carta.';

  @override
  String get catalogEmptyNoFilter =>
      'Crea la tuya y queda guardada para próximas salidas.';

  @override
  String get catalogEmptyFilter =>
      'Prueba quitando algún filtro o crea la tuya.';

  @override
  String catalogSizes(String count) {
    return '$count tamaños';
  }

  @override
  String get catalogDetails => 'Detalles';

  @override
  String get catalogUnfavorite => 'Quitar de favoritas';

  @override
  String get catalogFavorite => 'Añadir a favoritas';

  @override
  String get entryDeleteTitle => '¿Eliminar registro?';

  @override
  String get entryDeleteBody => 'Sale de la salida y del resumen.';

  @override
  String get entryDiscardTitle => '¿Descartar cambios?';

  @override
  String get entryDiscardBody => 'Lo que rellenaste aquí se perderá.';

  @override
  String get entryKeepEditing => 'Seguir editando';

  @override
  String get entryDiscard => 'Descartar';

  @override
  String get entryFix => 'Corregir registro';

  @override
  String get entryLogCocktail => 'Registrar cóctel';

  @override
  String get entryLogDrink => 'Registrar bebida';

  @override
  String get entryDrinkAndSize => 'Bebida y tamaño';

  @override
  String get entryGenericSpirit =>
      'Dosis sugeridas, editables: no son medidas oficiales de ningún establecimiento. La botella es el envase, no tu dosis.';

  @override
  String get entryGenericSizes =>
      'Tamaños sugeridos: este producto no tiene envases verificados en el catálogo. Revisa el envase.';

  @override
  String get entryVolume => 'Volumen (ml)';

  @override
  String get entryOtherSize => 'Otro tamaño (ml)';

  @override
  String get entryAbvOptional => 'Graduación alcohólica (opcional)';

  @override
  String get entryAbvBlank => 'En blanco = desconocida (no cuenta como cero).';

  @override
  String get entryAbvCheck => 'Revisa la etiqueta si puedes.';

  @override
  String get entryAbvVariantsIntro =>
      'Las fuentes difieren. Elige lo que figura en tu etiqueta o escríbelo:';

  @override
  String get entryBottleShared =>
      'Botella que se está compartiendo (rellena el volumen de la botella):';

  @override
  String entryBottlesInfo(String list) {
    return 'Envases del producto: $list. Para dividir una botella, marca \"Compartida\" abajo.';
  }

  @override
  String get entryIndividualOrShared => 'Individual o compartida';

  @override
  String get entryOnlyMine => 'Solo mía';

  @override
  String get entryShared => 'Compartida';

  @override
  String get entryPriceSection => 'Precio (opcional)';

  @override
  String get entryTimeSection => 'Hora';

  @override
  String entryYourShare(String amount) {
    return 'Tu parte: $amount';
  }

  @override
  String get entryYourShareUnknown => 'Tu parte: —';

  @override
  String get entrySaveChanges => 'Guardar cambios';

  @override
  String entryIngredients(String list) {
    return 'Ingredientes (texto original): $list';
  }

  @override
  String entrySharedLine(String count, String total) {
    return 'de $total · $count personas, contigo';
  }

  @override
  String get entryPeople => 'Personas (contigo incluido)';

  @override
  String get entryFewerPeople => 'Una persona menos';

  @override
  String get entryMorePeople => 'Una persona más';

  @override
  String get entryAdjustShare => 'Ajustar parte y sobrante';

  @override
  String get entryYourShareMl => 'Tu parte (ml)';

  @override
  String get entryEqualSplit => 'División igual por defecto.';

  @override
  String get entryLeftover => 'Sobrante en la botella (ml)';

  @override
  String get entryOptionalDot => 'Opcional.';

  @override
  String entryOthersEach(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'para cada una de las otras $count personas',
      one: 'para la otra persona',
    );
    return 'Quedan $amount $_temp0.';
  }

  @override
  String get entryPriceValue => 'Valor';

  @override
  String get entryPriceDontKnow => 'No sé';

  @override
  String get entryBillTotal => 'Total de la cuenta/botella (opcional)';

  @override
  String get entryPaidHelper => 'Lo que pagaste, no lo que bebiste.';

  @override
  String entrySplitEqually(String count) {
    return 'Dividir por igual ($count personas)';
  }

  @override
  String entryComplimentaryNote(String amount) {
    return 'La cortesía cuenta como $amount indicado.';
  }

  @override
  String get entryNoPriceNote =>
      'Sin precio: aparece como \"sin precio\" en el resumen.';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get entryAddIngredient => 'Añadir ingrediente';

  @override
  String get entryIngredientField => 'Ingrediente';

  @override
  String get entryHasAlcohol => 'Tiene alcohol';

  @override
  String get entrySaveRecipeTitle => 'Guardar como mi receta';

  @override
  String entryMineSuffix(String name) {
    return '$name (mía)';
  }

  @override
  String get entryRecipeName => 'Nombre de la receta';

  @override
  String get entrySaveRecipeBody =>
      'Guarda ingredientes, cantidades y graduaciones para reutilizar. Los registros antiguos no cambian.';

  @override
  String get entryRecipeSaved => 'Receta guardada en tu catálogo';

  @override
  String get entryCompositionTitle => 'Composición';

  @override
  String get entryCompositionSimple => 'Indica solo lo que sepas.';

  @override
  String entryCompositionReference(String source) {
    return 'Receta de referencia ($source). Ajústala a lo que realmente se sirvió.';
  }

  @override
  String get entryCompositionAdjusted => 'Composición ajustada';

  @override
  String get entryCompositionView => 'Ver y ajustar la composición';

  @override
  String get entryNoIngredients => 'Aún no hay ingredientes';

  @override
  String get entryDrinkVolumeSection => 'Volumen del cóctel (opcional)';

  @override
  String get entryServedVolume => 'Volumen servido (ml)';

  @override
  String get entryServedVolumeHelper =>
      'Si no lo sabes, déjalo en blanco: el resumen lo muestra como desconocido. El tamaño del vaso y el hielo no cuentan como volumen bebido.';

  @override
  String get entryPureAlcohol => 'Alcohol puro de la composición anterior';

  @override
  String entryAtLeast(String amount) {
    return 'al menos $amount';
  }

  @override
  String entryMissingParts(String list) {
    return 'Faltan graduación o cantidad de: $list';
  }

  @override
  String get entryDeclaredNote =>
      'Vale la composición declarada, asumiendo la porción entera. No es concentración en sangre.';

  @override
  String entryOptionalMark(String name) {
    return '$name (opcional)';
  }

  @override
  String get entryRemoveIngredient => 'Quitar ingrediente';

  @override
  String entryInRecipe(String text) {
    return 'En la receta: $text';
  }

  @override
  String get entryAmount => 'Cantidad';

  @override
  String get entryAmountUnknown => 'En blanco = desconocida.';

  @override
  String get entryChooseProduct => 'Elegir marca/producto';

  @override
  String get entryComponentAbv => 'Graduación alcohólica (% vol.)';

  @override
  String get entryComponentAbvUnknown =>
      'Desconocida: sin ella el alcohol total queda incompleto.';

  @override
  String entryComponentAlcoholNone(String reason) {
    return 'Alcohol de este ingrediente: no calculado ($reason).';
  }

  @override
  String entryComponentAlcohol(String amount) {
    return 'Alcohol de este ingrediente: $amount';
  }

  @override
  String get entryIncompleteData => 'datos incompletos';

  @override
  String entryWhichProduct(String name) {
    return '¿Cuál $name?';
  }

  @override
  String get entryNoBrand => 'Sin marca: indicar la graduación';

  @override
  String entryProductAbv(String abv) {
    return 'Graduación $abv';
  }

  @override
  String get entryProductAbvVaries => 'La graduación varía según la fuente';

  @override
  String get entryProductAbvUnknown => 'Graduación no indicada';

  @override
  String get entryMenuPrice => 'Precio de la carta';

  @override
  String entryMenuPriceBody(String price) {
    return 'La carta anunciaba $price. Es solo una sugerencia: confirma lo que realmente se pagó, pues puede haber promoción u otro pedido. Si es una botella o jarra compartida, marca \"Compartida\": el valor pasa a ser el total de la cuenta, no tu parte.';
  }

  @override
  String get entryUseAsBillTotal => 'Usar como total de la cuenta';

  @override
  String get entryUseAsPaid => 'Usar como lo que pagué';

  @override
  String get entryHistory => 'Tu historial';

  @override
  String entryHistoryShare(String date, String price, String scope) {
    return 'Tu parte fue $price $scope el $date.';
  }

  @override
  String entryHistoryPaid(String date, String price, String scope) {
    return 'Pagaste $price $scope el $date.';
  }

  @override
  String get entryUseAsShare => 'Usar como mi parte';

  @override
  String get entryUseValue => 'Usar este valor';

  @override
  String entryHistoryTotal(String date, String price) {
    return 'El total de la botella/porción fue $price el $date.';
  }

  @override
  String get entryUseAsTotal => 'Usar como total';

  @override
  String get entryScopeAtPlace => 'en este lugar';

  @override
  String get entryScopeAtOuting => 'en esta salida';

  @override
  String get draftVolumeInvalid => 'Volumen no válido';

  @override
  String get draftAbvRange => 'La graduación va de 0 a 100%';

  @override
  String get draftAmountInvalid => 'Cantidad no válida';

  @override
  String get draftVolumeRequired => 'Indica el volumen en ml';

  @override
  String get draftVolumeTooHigh => 'Volumen demasiado alto';

  @override
  String get draftShareRequired => 'Indica tu parte en ml';

  @override
  String draftShareOver(String volume) {
    return 'Tu parte + sobrante superan el volumen ($volume)';
  }

  @override
  String draftBeforeStart(String time) {
    return 'Antes del inicio de la salida ($time)';
  }

  @override
  String get draftNotFuture => 'La hora no puede estar en el futuro';

  @override
  String draftAfterEnd(String time) {
    return 'Después del fin de la salida ($time)';
  }

  @override
  String get draftPaidRequired => 'Indica el valor o elige otra opción';

  @override
  String get formSaveRecipeFailed => 'No se pudo guardar la receta.';

  @override
  String get formSaveFailed =>
      'No se pudo guardar. No se perdió nada, inténtalo de nuevo.';

  @override
  String get formDeleteFailed => 'No se pudo eliminar. Inténtalo de nuevo.';

  @override
  String get detailNotGiven => 'No indicado';

  @override
  String get detailAbv => 'Graduación alcohólica';

  @override
  String detailAbvFrom(String source) {
    return 'Graduación: $source. No es dato del fabricante.';
  }

  @override
  String get detailIngredients => 'Ingredientes declarados (texto original)';

  @override
  String get detailIngredientsNone => 'No indicados';

  @override
  String get detailPresentations => 'Presentaciones';

  @override
  String get detailBottleNotDose =>
      'El tamaño de la botella no es el tamaño de la dosis. Al registrar, eliges una dosis sugerida (editable) o compartes la botella.';

  @override
  String get detailUnverifiedPackages =>
      'Envases no verificados para este producto. Al registrar, puedes elegir un tamaño sugerido o escribir el volumen.';

  @override
  String get detailPackagesNote =>
      'Envases citados por el fabricante. El tamaño del envase no es lo que bebiste: eso lo defines al registrar.';

  @override
  String get detailMakeMine => 'Crear mi versión';

  @override
  String get detailSourceTitle => 'Fuente de los datos';

  @override
  String detailSourceLine(String date, String source) {
    return '$source · consultado el $date';
  }

  @override
  String get detailCopyAddress => 'Copiar dirección';

  @override
  String get detailAddressCopied => 'Dirección copiada';

  @override
  String get detailMayVary =>
      'Los datos pueden variar según la versión y el mercado. Revisa siempre la etiqueta del envase.';

  @override
  String detailAbvVaries(String lines) {
    return 'Varía según la fuente, sin un valor único:\n$lines';
  }

  @override
  String get detailRecipeReference =>
      'Receta de referencia: muestra cómo se publica la receta, no lo que sirvió un bar.';

  @override
  String get detailRecipeMine =>
      'Tu receta guardada. Al registrar, ajustas lo que realmente se sirvió.';

  @override
  String get detailNoIngredientsYet =>
      'Aún sin ingredientes: los armas al registrar.';

  @override
  String get detailAlcoholLegend =>
      'Los ingredientes con una copa al lado tienen alcohol. La graduación de cada uno se indica al registrar; sin ella el alcohol total queda incompleto. El hielo no se cuenta.';

  @override
  String get detailMethod => 'Preparación';

  @override
  String detailGarnish(String text) {
    return 'Decoración: $text';
  }

  @override
  String get customEditTitle => 'Editar bebida';

  @override
  String get customSaveFailed => 'No se pudo guardar. Tus datos siguen aquí.';

  @override
  String get customEditNote =>
      'Los cambios valen para los próximos registros. Lo que ya registraste queda como estaba.';

  @override
  String get customNewNote =>
      'Queda guardada para usarla de nuevo en próximas salidas.';

  @override
  String get customType => 'Tipo';

  @override
  String get customIdentification => 'Identificación';

  @override
  String get customName => 'Nombre de la bebida';

  @override
  String get customNameRequired => 'Ponle un nombre a la bebida';

  @override
  String get customBrand => 'Marca (opcional)';

  @override
  String get customStyle => 'Estilo (opcional)';

  @override
  String get customSizeAndAbv => 'Tamaño y graduación';

  @override
  String get customSize => 'Tamaño (ml)';

  @override
  String get customSizeRequired => 'Indica el tamaño en ml';

  @override
  String get customAbvHelper => 'En blanco = desconocida, no cuenta como cero.';

  @override
  String get customIngredients => 'Ingredientes (opcional)';

  @override
  String get customIngredientsHelper => 'Separa con comas. Solo lo que sepas.';

  @override
  String get customSaveUse => 'Guardar y usar';

  @override
  String get recipeUnitLabel => 'Unidad';

  @override
  String get myDrinksNeedOuting =>
      'Inicia una salida para registrar una bebida.';

  @override
  String get myDrinksLogged => 'Bebida registrada';

  @override
  String get myDrinksCopied => 'Copia creada';

  @override
  String myDrinksDeleteTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get myDrinksDeleteBody =>
      'Sale de tu catálogo. Los registros que ya hiciste quedan como están.';

  @override
  String get myDrinksDeleted => 'Eliminada';

  @override
  String myDrinksRecipeSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Receta · $count ingredientes',
      one: 'Receta · 1 ingrediente',
    );
    return '$_temp0';
  }

  @override
  String get myDrinksTitle => 'Mis bebidas y recetas';

  @override
  String get myDrinksEmptyTitle => 'Nada por aquí todavía';

  @override
  String get myDrinksEmptyBody =>
      'Las bebidas y recetas que crees quedan aquí para reutilizarlas en próximas salidas.';

  @override
  String get myDrinksStartFirst => 'Para registrar, inicia primero una salida.';

  @override
  String get myDrinksActionLog => 'Registrar';

  @override
  String get myDrinksActionDuplicate => 'Duplicar';

  @override
  String get myDrinksNewDrink => 'Nueva bebida';

  @override
  String get myDrinksNewRecipe => 'Nueva receta';

  @override
  String recipeEditorNameCopy(String name) {
    return '$name (mi versión)';
  }

  @override
  String get recipeEditorNeedName => 'Ponle un nombre a la receta.';

  @override
  String get recipeEditorNeedIngredient => 'Añade al menos un ingrediente.';

  @override
  String get recipeEditorIngredientName =>
      'Todo ingrediente necesita un nombre.';

  @override
  String recipeEditorAbvRange(String name) {
    return 'La graduación de \"$name\" va de 0 a 100%.';
  }

  @override
  String recipeEditorAmountInvalid(String name) {
    return 'La cantidad de \"$name\" no es válida.';
  }

  @override
  String recipeEditorNumberProblem(String name, String problem) {
    return '\"$name\": $problem';
  }

  @override
  String get recipeEditorEditTitle => 'Editar receta';

  @override
  String get recipeEditorNewTitle => 'Nueva receta';

  @override
  String get recipeEditorIntro =>
      'Registra solo lo que sepas. Una cantidad o graduación en blanco queda como desconocida y el alcohol total aparece como incompleto.';

  @override
  String get recipeEditorNameSection => 'Nombre';

  @override
  String get recipeEditorNameRequired => 'Ponle un nombre a la receta';

  @override
  String get recipeEditorIngredients => 'Ingredientes';

  @override
  String get recipeEditorNoneYet => 'Aún no hay ingredientes.';

  @override
  String get recipeEditorAlcoholSection => 'Alcohol de la composición';

  @override
  String get recipeEditorDeclaredAlcohol => 'Alcohol puro declarado';

  @override
  String get recipeEditorSaveRecipe => 'Guardar receta';

  @override
  String get recipeEditorMoveUp => 'Mover hacia arriba';

  @override
  String get recipeEditorMoveDown => 'Mover hacia abajo';

  @override
  String recipeEditorOriginal(String text) {
    return 'En la receta original: $text';
  }

  @override
  String get recipeEditorRole => 'Tipo (para elegir la marca al registrar)';

  @override
  String get recipeEditorNoRole => 'Sin tipo';

  @override
  String get recipeEditorRemove => 'Quitar';

  @override
  String get scanLabelPhotoGone =>
      'La foto de esta lectura ya no está disponible en este dispositivo. Se conservó el texto: toma otra foto o continúa sin ella.';

  @override
  String get scanPhotoSaveFailed =>
      'No se pudo guardar la foto en el dispositivo.';

  @override
  String get scanRotateFailed => 'No se pudo girar la imagen.';

  @override
  String get scanPhotoUnavailableToRead =>
      'La foto no está disponible para leer. Toma otra.';

  @override
  String get scanNoTextFound =>
      'No se encontró texto. Prueba con otra foto, más de cerca y con buena luz, o escribe el texto.';

  @override
  String get scanLabelTip =>
      'Encuadra la etiqueta completa, de frente, con buena luz y sin reflejos. El volumen y la graduación suelen estar en otro lado del envase: fotografía ese lado o complétalos en la revisión. Lo revisas todo antes de guardar.';

  @override
  String get scanLabelEnded =>
      'Esta salida ya terminó. Lo que leas queda guardado en ella.';

  @override
  String get scanWebPhotoSession =>
      'En el navegador la foto solo se guarda durante esta sesión.';

  @override
  String get scanPhoto => 'Foto';

  @override
  String get scanTakePhoto => 'Tomar foto';

  @override
  String get scanChooseGallery => 'Elegir de la galería';

  @override
  String get scanRotateLeft => 'Girar a la izquierda';

  @override
  String get scanRotateRight => 'Girar a la derecha';

  @override
  String get scanNewPhoto => 'Nueva foto';

  @override
  String get scanReplacePhoto => 'Cambiar';

  @override
  String get scanDiscardReading => 'Descartar lectura';

  @override
  String get scanReadingOnDevice =>
      'Leyendo el texto de la foto en este dispositivo…';

  @override
  String get scanCancelReading => 'Cancelar lectura';

  @override
  String get scanReadAgain => 'Leer de nuevo';

  @override
  String get scanOcrUnavailable =>
      'La lectura automática no está disponible aquí (solo en la app para Android e iOS). Mira la foto y escribe o pega el texto de la etiqueta, o rellénalo directamente.';

  @override
  String get scanLabelText => 'Texto de la etiqueta';

  @override
  String get scanTextHintCanRead =>
      'El texto leído aparece aquí. Puedes corregirlo.';

  @override
  String get scanTextHintManual =>
      'Escribe o pega el texto de la etiqueta (opcional)';

  @override
  String get scanInterpret => 'Interpretar texto';

  @override
  String get scanFillManually => 'Rellenar manualmente';

  @override
  String get photoUnavailable =>
      'Foto no disponible ahora: aún no la subió el otro dispositivo, o no hay conexión. El registro sigue guardado.';

  @override
  String get photoDelete => 'Eliminar foto';

  @override
  String get photoDeleteTitle => '¿Eliminar esta foto?';

  @override
  String get photoDeleteBody =>
      'Solo se va la foto. Las bebidas y los datos que confirmaste siguen en la salida.';

  @override
  String get captureCameraUnavailable =>
      'La cámara no está disponible aquí. Elige una foto de la galería.';

  @override
  String get captureGalleryUnavailable => 'La galería no está disponible aquí.';

  @override
  String get capturePermissionCamera =>
      'Sin permiso para usar la cámara. Actívalo en los ajustes del dispositivo o elige otra opción.';

  @override
  String get capturePermissionGallery =>
      'Sin permiso para usar la galería. Actívalo en los ajustes del dispositivo o elige otra opción.';

  @override
  String get captureOpenCameraFailed => 'No se pudo abrir la cámara.';

  @override
  String get captureOpenGalleryFailed => 'No se pudo abrir la galería.';

  @override
  String get captureFailed => 'No se pudo abrir la captura de imagen.';

  @override
  String get captureUnreadable => 'No se pudo leer esta imagen.';

  @override
  String get captureTooBig =>
      'La imagen es demasiado grande. Prueba con una foto más pequeña.';

  @override
  String get captureNotImage => 'Este archivo no parece ser una imagen válida.';

  @override
  String get ocrUnavailable =>
      'La lectura automática no está disponible en este dispositivo.';

  @override
  String get ocrReadFailed => 'No se pudo leer el texto de esta foto.';

  @override
  String matchOtherCategory(String category) {
    return 'Categoría distinta (catálogo: $category)';
  }

  @override
  String matchSameSize(String size) {
    return 'Mismo tamaño ($size)';
  }

  @override
  String matchOtherSize(String sizes) {
    return 'Otro tamaño (catálogo: $sizes)';
  }

  @override
  String matchSameAbv(String abv) {
    return 'Misma graduación ($abv)';
  }

  @override
  String matchOtherAbv(String catalog, String yours) {
    return 'Graduación distinta (catálogo: $catalog, la tuya: $yours)';
  }

  @override
  String get matchAbvVaries =>
      'La graduación del catálogo varía según la fuente';

  @override
  String get matchNoAbv => 'El catálogo no tiene graduación para comparar';

  @override
  String matchOtherBrand(String brand) {
    return 'Otra marca ($brand)';
  }

  @override
  String get matchRecipe =>
      'Receta de referencia: el cóctel servido puede ser distinto';

  @override
  String get matchSimilar =>
      'Parecida por el nombre: confirma que es el mismo producto';

  @override
  String parseManyVolumes(String list) {
    return 'Más de un volumen en el texto ($list). Elige el del envase.';
  }

  @override
  String parseManyAbvs(String list) {
    return 'Más de una graduación en el texto ($list). Revísalo en la etiqueta.';
  }

  @override
  String get parseCheckName =>
      'Revisa el nombre y la marca. Toca las sugerencias para cambiarlos.';

  @override
  String menuNoteColumns(String count) {
    return 'La carta parece tener $count columnas. Comprueba que cada precio esté en el elemento correcto.';
  }

  @override
  String menuNoteOrphans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se ignoraron $count precios sin elemento claro. Añade el elemento manualmente si lo necesitas.',
      one: 'Se ignoró 1 precio sin elemento claro. Añade el elemento manualmente si lo necesitas.',
    );
    return '$_temp0';
  }

  @override
  String get menuNoteNone =>
      'No se identificó ningún elemento. Pega o escribe el texto, o añade los elementos manualmente.';

  @override
  String get scanMenuReviewTitle => 'Elementos de la carta';

  @override
  String scanMenuLostPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos de esta lectura ya no están disponibles. Se conservaron sus elementos para que los revises.',
      one: 'Una foto de esta lectura ya no está disponible. Se conservaron sus elementos para que los revises.',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoItemsRead =>
      'No se identificó ningún elemento. Gira la foto, prueba de más cerca o pega el texto de la carta.';

  @override
  String get scanMenuNoItems => 'No se identificó ningún elemento.';

  @override
  String get scanMenuNoneSelected => 'Ningún elemento seleccionado.';

  @override
  String get scanMenuUnnamed =>
      'Hay un elemento sin nombre. Corrígelo o descártalo.';

  @override
  String get scanMenuNeedType =>
      'Elige el tipo de los elementos marcados con \"¿Tipo?\".';

  @override
  String get scanMenuSaveFailed =>
      'No se pudo guardar. Tus elementos siguen aquí.';

  @override
  String get scanMenuDiscardTitle => '¿Descartar esta lectura?';

  @override
  String get scanMenuDiscardBody =>
      'Las fotos y los elementos aún no confirmados se borrarán.';

  @override
  String get scanMenuTip =>
      'Fotografía una página a la vez, de frente y con buena luz, sin cortar los precios. Puedes añadir varias fotos. Revisas y corriges cada elemento antes de guardar.';

  @override
  String get scanMenuEnded =>
      'Esta salida ya terminó. Los elementos quedan guardados en ella.';

  @override
  String get scanMenuWebPhotos =>
      'En el navegador las fotos solo se guardan durante esta sesión.';

  @override
  String scanMenuPhotos(String count) {
    return 'Fotos ($count)';
  }

  @override
  String scanMenuPhotoN(String number) {
    return 'Foto $number';
  }

  @override
  String get scanMenuRead => 'Leída';

  @override
  String get scanMenuUnread => 'Aún sin leer';

  @override
  String get scanRemovePhoto => 'Quitar foto';

  @override
  String get scanAnotherPhoto => 'Otra foto';

  @override
  String get scanMenuReadingMany =>
      'Leyendo el texto de las fotos en este dispositivo…';

  @override
  String get scanMenuSeeRead => 'Ver elementos leídos';

  @override
  String get scanMenuOcrUnavailable =>
      'La lectura automática no está disponible aquí (solo en la app para Android e iOS). Mira las fotos y escribe o pega el texto de la carta, o añade los elementos a mano.';

  @override
  String get scanMenuPastedSection => 'Texto de la carta (opcional)';

  @override
  String get scanMenuPastedHint =>
      'Un elemento por línea, con el precio en la misma línea o en la siguiente. Ej.: Caipirinha R\$ 18,00';

  @override
  String get scanMenuAddManual => 'Añadir un elemento a mano';

  @override
  String scanMenuSeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count elementos',
      one: 'Ver 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuReviewIntro =>
      'Marca los elementos que quieres dejar disponibles en esta salida. Nada se registra como consumo ahora: eliges la bebida y confirmas el precio cuando pidas.';

  @override
  String get scanMenuPhotosAndReading => 'Fotos y lectura';

  @override
  String get scanMenuAddItem => 'Añadir elemento';

  @override
  String scanMenuSave(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count elementos en esta salida',
      one: 'Guardar 1 elemento en esta salida',
    );
    return '$_temp0';
  }

  @override
  String get scanMenuNoName => '(sin nombre)';

  @override
  String scanMenuSize(String size) {
    return 'Tamaño en la carta: $size';
  }

  @override
  String scanMenuIngredientsCited(String list) {
    return 'Ingredientes citados: $list';
  }

  @override
  String get scanMenuEditItem => 'Editar elemento';

  @override
  String get scanMenuTypeHint => '¿Tipo?';

  @override
  String get scanMenuDuplicate => 'Repetido en otra foto';

  @override
  String get scanMenuPromo => 'Posible promoción: confirma el valor';

  @override
  String scanMenuPriceOnMenu(String price) {
    return '$price en la carta';
  }

  @override
  String get scanMenuNoPriceRead => 'Sin precio leído';

  @override
  String get scanMenuPriceUnsure =>
      'No se pudo estar seguro del precio. Elige el correcto o déjalo sin precio:';

  @override
  String get scanMenuChangePrice => 'Cambiar precio';

  @override
  String get scanMenuNewItem => 'Nuevo elemento';

  @override
  String get scanMenuName => 'Nombre';

  @override
  String get scanMenuDescription => 'Descripción (opcional)';

  @override
  String get scanMenuSizeOptional => 'Tamaño (opcional)';

  @override
  String get scanMenuPriceOptional => 'Precio (opcional)';

  @override
  String get scanMenuCitedOptional => 'Ingredientes citados (opcional)';

  @override
  String get scanMenuCitedHelper => 'Separa con comas. Sin cantidades.';

  @override
  String get scanMenuNeedName => 'Ponle un nombre al elemento.';

  @override
  String get scanMenuInvalidSize => 'Tamaño no válido.';

  @override
  String get scanMenuInvalidPrice => 'Precio no válido.';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get originManual => 'Creada en esta salida';

  @override
  String get originPhotoLabel => 'Foto de la etiqueta';

  @override
  String get originMenu => 'Foto de la carta';

  @override
  String get outingReviewEditTitle => 'Editar bebida de la salida';

  @override
  String get outingReviewTitle => 'Bebida de esta salida';

  @override
  String get outingReviewIsolation =>
      'Esta bebida existe solo en esta salida. No entra en el catálogo, ni en Mis bebidas, ni en otras salidas.';

  @override
  String get outingReviewEnded =>
      'Esta salida ya terminó. El elemento queda guardado en ella.';

  @override
  String get outingReviewDrinkSection => 'Bebida';

  @override
  String get outingReviewNeedName => 'Ponle un nombre a la bebida.';

  @override
  String get outingReviewNeedType => 'Elige el tipo de bebida.';

  @override
  String get outingReviewVolumePositive =>
      'El volumen debe ser mayor que cero.';

  @override
  String get outingReviewAbvRange => 'La graduación va de 0 a 100%.';

  @override
  String get outingReviewOtherLines => 'Otras líneas leídas (toca para usar):';

  @override
  String get outingReviewPickType => 'Elige el tipo de bebida';

  @override
  String get outingReviewTypeUnknown => 'Tipo no identificado: elige uno.';

  @override
  String get outingReviewDescription => 'Descripción de la carta (opcional)';

  @override
  String get outingReviewPackageVolume => 'Volumen del envase (opcional)';

  @override
  String get outingReviewVolumeHelper =>
      'Es el tamaño del producto, no cuánto bebiste. En blanco = desconocido.';

  @override
  String outingReviewAbvSource(String source) {
    return 'Origen: $source';
  }

  @override
  String get outingReviewIngredientsIntro =>
      'Solo lo que indicaron la carta o tú. Las cantidades quedan desconocidas hasta que las completes al registrar; el alcohol solo se calcula con volumen y graduación conocidos.';

  @override
  String get outingReviewAlcoholChip => 'Alcohol';

  @override
  String get outingReviewDeclaredOptional =>
      'Ingredientes declarados (opcional)';

  @override
  String get outingReviewDeclaredHelper =>
      'Separa con comas. Solo lo que está escrito.';

  @override
  String get outingReviewAdvertisedSection => 'Precio anunciado';

  @override
  String get outingReviewMenuPriceOptional => 'Precio de la carta (opcional)';

  @override
  String get outingReviewMenuPriceHelper =>
      'Solo una sugerencia: al registrar confirmas lo que pagaste. Valores en reales (R\$).';

  @override
  String get outingReviewSimilar => 'Parecidas en el catálogo';

  @override
  String get outingReviewSearch => 'Buscar';

  @override
  String get outingReviewSimilarNote =>
      'Opcional. Elegir una es solo una referencia: el producto del catálogo nunca se modifica y nada se vincula solo.';

  @override
  String get outingReviewNothingSimilar =>
      'No se encontró nada parecido. Este elemento queda solo en la salida.';

  @override
  String get outingReviewReferenceChosen => 'Referencia elegida';

  @override
  String get outingReviewUseReference => 'Usar como referencia';

  @override
  String get outingReviewFillEmpty => 'Rellenar campos vacíos';

  @override
  String get outingReviewCopyIngredients =>
      'Copiar ingredientes (sin cantidades)';

  @override
  String get outingReviewOriginSection => 'Origen de los datos';

  @override
  String get outingReviewOriginManual => 'Rellenado por ti.';

  @override
  String get outingReviewOriginPhoto =>
      'Leído de la foto y revisado por ti. La lectura automática puede fallar: revisa cada campo.';

  @override
  String get outingReviewReferenceNote =>
      'Con referencia del catálogo (no es el mismo registro).';

  @override
  String get outingReviewSourceText => 'Texto leído de la foto';

  @override
  String get outingReviewConfirmContinue => 'Confirmar y continuar';

  @override
  String get outingReviewSaveOnly => 'Guardar solo en esta salida';

  @override
  String get outingDrinksSectionTitle => 'Bebidas de esta salida';

  @override
  String get outingDrinksTapToLog =>
      'Solo existen en esta salida. Toca para registrar una.';

  @override
  String get outingDrinksRemoveTitle => '¿Quitar de la lista de la salida?';

  @override
  String get outingDrinksRemoveBody =>
      'Sale de \"Bebidas de esta salida\". Los registros que ya hiciste siguen en el historial.';

  @override
  String get outingDrinksRemove => 'Quitar';

  @override
  String get outingDrinksMoreActions => 'Más acciones';

  @override
  String get outingDrinksRemoveFromList => 'Quitar de la lista';

  @override
  String outingDrinksMenuPrice(String price) {
    return 'carta $price';
  }

  @override
  String get outingScanUnfinishedMenu => 'Lectura de carta sin terminar';

  @override
  String get outingScanUnfinishedLabel => 'Lectura de etiqueta sin terminar';

  @override
  String get outingScanUnfinishedNote =>
      'Sigue vinculada a esta salida. Si la terminas ahora, el resultado queda guardado en ella, no en otra.';

  @override
  String get outingScanOnlyHere => 'Existen solo en esta salida.';

  @override
  String get outingScanPhotosTitle => 'Fotos de la salida';

  @override
  String get outingScanAllUploaded =>
      'Las fotos también se guardan en la nube, en un archivo privado.';

  @override
  String outingScanPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos aún solo en este dispositivo; el envío se reintenta solo.',
      one: '1 foto aún solo en este dispositivo; el envío se reintenta solo.',
    );
    return '$_temp0';
  }

  @override
  String outingScanLocalOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos solo en este dispositivo.',
      one: '1 foto solo en este dispositivo.',
    );
    return '$_temp0';
  }

  @override
  String get photoKindLabel => 'Etiqueta';

  @override
  String get photoKindMenu => 'Carta';
}
