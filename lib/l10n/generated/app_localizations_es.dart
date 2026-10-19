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
  String get authCancelAndLeave => 'Cancelar y salir';

  @override
  String get authCheckEmail => 'Revisa el correo que escribiste.';

  @override
  String get authCloudDown =>
      'No se pudo contactar con el servidor ahora. Revisa internet e inténtalo de nuevo en un momento.';

  @override
  String get authConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

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
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHelper => 'Al menos 8 caracteres.';

  @override
  String get authPasswordMin => 'Usa al menos 8 caracteres.';

  @override
  String get authPasswordMix => 'Combina letras y números.';

  @override
  String get authPasswordsDiffer => 'Las contraseñas no coinciden.';

  @override
  String get authCodeTitle => 'Escribe el código';

  @override
  String authCodeBody(String email) {
    return 'Enviamos un código de 6 dígitos a $email. Escríbelo abajo; vale por poco tiempo.';
  }

  @override
  String get authCodeLabel => 'Código de 6 dígitos';

  @override
  String get authCodeVerify => 'Confirmar código';

  @override
  String get authCodeInvalid =>
      'Código inválido o caducado. Revisa los 6 dígitos o pide uno nuevo.';

  @override
  String get authCodeIncomplete => 'Escribe los 6 dígitos del código.';

  @override
  String get authHaveCode => 'Ya tengo un código';

  @override
  String get authRecoverBody =>
      'Enviaremos un código de 6 dígitos a tu correo. Lo escribes aquí en la app, en cualquier dispositivo.';

  @override
  String get authRecoverSent =>
      'Si hay una cuenta con este correo, el código llega en un momento. Revisa también el spam.';

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
  String get authSamePassword =>
      'La nueva contraseña debe ser distinta de la actual.';

  @override
  String get authSavePassword => 'Guardar contraseña';

  @override
  String get authSendLink => 'Enviar código';

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
      'Tu nombre y correo solo sirven para tu cuenta. Entras directamente, sin confirmar el correo.';

  @override
  String get authSignupDisabled =>
      'El registro está desactivado en el servidor por ahora.';

  @override
  String get authTooManyAttempts =>
      'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get authTooManyShort => 'Demasiados intentos. Espera unos minutos.';

  @override
  String get authWeakPassword => 'Contraseña débil. Usa al menos 8 caracteres.';

  @override
  String get authWrongCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authYourAccount => 'tu cuenta';

  @override
  String get budgetDialogTitle => 'Presupuesto para bebidas';

  @override
  String get budgetEdit => 'Editar presupuesto';

  @override
  String budgetLeft(String amount) {
    return 'Quedan $amount del presupuesto.';
  }

  @override
  String budgetLeftIncomplete(int count, String amount) {
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
      'Opcional. Solo compara con los gastos informados en tus bebidas; lo que gasta la mesa queda en la cuenta.';

  @override
  String budgetOver(String amount) {
    return 'Superaste el presupuesto en $amount.';
  }

  @override
  String budgetOverIncomplete(String amount) {
    return 'Los gastos informados ya superan el presupuesto en $amount y aún faltan precios.';
  }

  @override
  String budgetReached(int percent, String spent, String budget) {
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
  String conflictTabPayments(int count, String amount) {
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
  String get entryRepeat => 'Repetir';

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
  String get homeInformedSpent => 'Tu gasto informado';

  @override
  String get homeLastOuting => 'Última salida';

  @override
  String get homeNoneThisMonth => 'Ninguna salida terminada este mes todavía.';

  @override
  String get homeOutingRunning => 'Salida en curso';

  @override
  String get homeOutings => 'Salidas';

  @override
  String get homeSpent => 'Tu gasto';

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
  String outingTypeSince(String type, String time) {
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
  String staleBody(String name, String start, String duration) {
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
  String get summarySpentOnDrinks => 'Tus gastos registrados en bebidas';

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
  String volumeKnownPlusUnknown(String known, int count) {
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
  String get categoryReadyToDrink => 'Bebida lista';

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
  String entrySharedLine(String total, String count) {
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
  String entryHistoryShare(String price, String scope, String date) {
    return 'Tu parte fue $price $scope el $date.';
  }

  @override
  String entryHistoryPaid(String price, String scope, String date) {
    return 'Pagaste $price $scope el $date.';
  }

  @override
  String get entryUseAsShare => 'Usar como mi parte';

  @override
  String get entryUseValue => 'Usar este valor';

  @override
  String entryHistoryTotal(String price, String date) {
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
  String get priceBulkTitle => '¿Aplicar este precio a las mismas bebidas?';

  @override
  String priceBulkBody(
    String name,
    String price,
    int total,
    int unpriced,
    int differing,
  ) {
    return '$name por $price. En este rolê hay $total registros iguales: $unpriced sin precio y $differing con otro precio. Nada cambia sin tu elección.';
  }

  @override
  String priceBulkUnpriced(int count) {
    return 'Aplicar a los $count sin precio';
  }

  @override
  String priceBulkAll(int count) {
    return 'Aplicar a los $count iguales';
  }

  @override
  String get priceBulkOnlyThis => 'Solo este registro';

  @override
  String get priceBulkConfirmTitle => '¿Reemplazar precios?';

  @override
  String priceBulkConfirmBody(int count) {
    return 'Esto reemplaza el precio de $count registros que ya tenían otro valor. Los demás rolês no cambian.';
  }

  @override
  String get priceBulkReplace => 'Reemplazar';

  @override
  String priceBulkApplied(int count) {
    return 'Precio aplicado a $count registros.';
  }

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
  String detailSourceLine(String source, String date) {
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

  @override
  String get pickerStartTitle => '¿Dónde es la salida?';

  @override
  String get pickerChangeTitle => 'Corregir lugar';

  @override
  String get pickerLocateTitle => 'Ubicación del lugar';

  @override
  String get pickerAlreadySavedTitle => 'Lugar ya guardado';

  @override
  String pickerAlreadySavedBody(String name) {
    return 'Este lugar ya está en tus lugares como \"$name\". ¿Usarlo aquí también?';
  }

  @override
  String get pickerUseAnyway => 'Usar de todos modos';

  @override
  String get pickerSearchHint => 'Buscar bar, restaurante o dirección';

  @override
  String get pickerClearSearch => 'Borrar búsqueda';

  @override
  String get pickerUseLocation => 'Usar mi ubicación';

  @override
  String get pickerApproximate =>
      'Ubicación aproximada: revisa el lugar en la lista o en el mapa.';

  @override
  String get pickerLocationHint =>
      'Muestra lugares cercanos. Siempre confirmas dónde estás.';

  @override
  String get pickerNicknameOnly => 'Indicar solo un apodo';

  @override
  String get pickerNicknameOnlyExample =>
      'Sin mapa ni dirección. Ej.: Casa de Samara';

  @override
  String get pickerNicknameOnlyShort => 'Sin mapa ni dirección.';

  @override
  String get pickerYourPlaces => 'Tus lugares';

  @override
  String get pickerNotConfiguredFull =>
      'La búsqueda de lugares y el mapa no están configurados en esta versión. Apodos, direcciones escritas y lugares guardados funcionan con normalidad.';

  @override
  String get pickerNearYou => 'Cerca de ti';

  @override
  String get pickerNothingNearby =>
      'No se encontró ningún bar o restaurante muy cerca. Puedes buscar por nombre o marcar solo el punto.';

  @override
  String get pickerPinOnly => 'Marcar solo este punto en el mapa';

  @override
  String get pickerPinOnlyHint => 'Puedes ponerle un apodo después.';

  @override
  String get pickerNotConfigured =>
      'La búsqueda de lugares no está configurada en esta versión.';

  @override
  String get pickerMinChars => 'Escribe al menos 3 letras para buscar.';

  @override
  String get pickerNothingFound =>
      'No se encontró nada. Prueba con el nombre y el barrio o la ciudad, o indica solo un apodo.';

  @override
  String get pickerResults => 'Resultados';

  @override
  String get pickerErrorOffline =>
      'Sin internet ahora. Aún puedes usar un lugar guardado o indicar un apodo.';

  @override
  String get pickerErrorUnavailable =>
      'La búsqueda no está disponible por ahora. Aún puedes usar un lugar guardado o indicar un apodo.';

  @override
  String get pickerLocServiceOff =>
      'La ubicación del dispositivo está desactivada.';

  @override
  String get pickerOpenSettings => 'Abrir ajustes';

  @override
  String get pickerLocDenied =>
      'Sin permiso de ubicación. Puedes buscar por nombre o dirección con normalidad.';

  @override
  String get pickerLocDeniedForever =>
      'Se denegó la ubicación para Bebômetro. Si quieres usarla, actívala en los ajustes del dispositivo. La búsqueda funciona sin ella.';

  @override
  String get pickerLocTimeout => 'No se pudo obtener la ubicación a tiempo.';

  @override
  String get pickerLocUnavailable =>
      'La ubicación no está disponible aquí. Busca por nombre o dirección.';

  @override
  String pickerSavedAs(String name) {
    return 'Guardado como \"$name\"';
  }

  @override
  String get pickerManualNickname => 'Apodo';

  @override
  String get pickerManualHint => 'Ej.: Casa de Samara';

  @override
  String get pickerManualHelper => 'El apodo solo ya basta.';

  @override
  String get pickerAddAddress => 'Añadir dirección (opcional)';

  @override
  String get pickerNeedNicknameOrAddress =>
      'Indica un apodo (ej.: Casa de Samara) o una dirección';

  @override
  String get pickerStateTwoLetters => 'La sigla del estado tiene 2 letras';

  @override
  String get placeSaveToMine => 'Guardar en mis lugares';

  @override
  String get placeSaveToMineHint =>
      'Para elegirlo de nuevo en próximas salidas. Queda privado.';

  @override
  String get pickerUseThisPlace => 'Usar este lugar';

  @override
  String distanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get confirmTitle => 'Revisar lugar';

  @override
  String get confirmTapMap =>
      'Toca el mapa para ajustar el punto, si hace falta.';

  @override
  String get confirmMapFailed =>
      'El mapa no cargó. Puedes confirmar con los datos de abajo.';

  @override
  String get confirmNoAddress => 'Sin dirección confirmada para este punto.';

  @override
  String confirmAdjustedWas(String name) {
    return 'Punto ajustado: \"$name\" y su dirección ya no valen para este punto.';
  }

  @override
  String get confirmAdjusted => 'Punto ajustado por ti.';

  @override
  String get confirmLookUp => 'Buscar la dirección de este punto';

  @override
  String get confirmNoAddressFound =>
      'No se encontró ninguna dirección para este punto.';

  @override
  String get confirmOfflinePointKept => 'Sin internet. El punto sigue marcado.';

  @override
  String get confirmLookUpFailed => 'No se pudo buscar la dirección ahora.';

  @override
  String confirmAlreadySaved(String name) {
    return 'Ya guardaste este lugar como \"$name\". Se reutilizará.';
  }

  @override
  String confirmAlreadySavedNick(String name) {
    return 'Ya guardaste este lugar como \"$name\". Se reutilizará y el apodo continúa.';
  }

  @override
  String get confirmNicknameSection => 'Apodo (opcional)';

  @override
  String get confirmNicknameHelper =>
      'Aparece en lugar del nombre. La dirección queda en los detalles.';

  @override
  String confirmUseAsNickname(String name) {
    return 'Usar \"$name\" como apodo';
  }

  @override
  String get confirmNeedNickname => 'Ponle un apodo para guardar este punto.';

  @override
  String get placeFallbackName => 'Lugar';

  @override
  String get placePointOnMap => 'Punto en el mapa';

  @override
  String get changePlaceTitle => '¿Cambiar el lugar de esta salida?';

  @override
  String changePlaceBody(String name) {
    return 'La salida pasa a ser \"$name\". Solo cambia esta salida: las bebidas, fotos y la cuenta siguen en ella, y las otras salidas no se modifican.';
  }

  @override
  String get changePlaceConfirm => 'Cambiar lugar';

  @override
  String get changePlaceDone => 'Lugar de la salida actualizado';

  @override
  String get changePlaceFailed =>
      'No se pudo cambiar el lugar. No se modificó nada.';

  @override
  String get openMapsFailed => 'No se pudo abrir una aplicación de mapas.';

  @override
  String get mapSemantics => 'Mapa con el punto del lugar';

  @override
  String get mapZoomIn => 'Acercar';

  @override
  String get mapZoomOut => 'Alejar';

  @override
  String get mapCenter => 'Centrar en el punto';

  @override
  String get placeNotFound => 'No se encontró este lugar.';

  @override
  String get placeScreenTitle => 'Lugar';

  @override
  String get placeReactivated => 'Lugar reactivado';

  @override
  String get placeArchivedToast => 'Lugar archivado';

  @override
  String get placeReactivate => 'Reactivar';

  @override
  String get placeArchive => 'Archivar';

  @override
  String get placeArchivedPill => 'Archivado';

  @override
  String get placeStatOutings => 'Salidas';

  @override
  String get placeStatDrinks => 'Tus bebidas';

  @override
  String get placeStatSpent => 'Tu gasto informado';

  @override
  String placeLastVisit(String date) {
    return 'Última visita: $date';
  }

  @override
  String get placeStartHere => 'Iniciar salida aquí';

  @override
  String get placeOpenMap => 'Abrir en el mapa';

  @override
  String get placeSpendNote =>
      'Gasto informado: lo que registraste en tus bebidas aquí. El total de la mesa y los pagos de la cuenta están en el resumen de cada salida y no entran en esta suma.';

  @override
  String get placePriceHistory => 'Tu historial de precios';

  @override
  String get placePriceHistoryNone =>
      'Aún no hay precios indicados por ti aquí. Cuando los haya, el último precio y el rango observado aparecen en este lugar.';

  @override
  String get placePriceHistoryNote =>
      'Tu historial: solo lo que tú mismo indicaste en este lugar, por bebida y tamaño. No es un promedio del mercado, de la ciudad ni del estado.';

  @override
  String placeVisits(String count) {
    return 'Salidas en este lugar ($count)';
  }

  @override
  String get placeNoVisits => 'Aún no hay ninguna salida registrada aquí.';

  @override
  String get placeVisitInProgress => 'en curso';

  @override
  String get placeNoValues => 'sin valores';

  @override
  String rangeTo(String from, String to) {
    return '$from a $to';
  }

  @override
  String placePriceLast(String price, String date) {
    return 'Último: $price el $date';
  }

  @override
  String placePriceLastShared(String price, String date) {
    return 'Último: $price el $date (total de la botella/porción)';
  }

  @override
  String placePriceRangeLine(String range, int count, String period) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return 'Rango observado: $range · $_temp0 · $period';
  }

  @override
  String get placeAlreadyActive =>
      'Ya hay una salida en curso. Termínala antes.';

  @override
  String get placeFieldMapName => 'Nombre en el mapa';

  @override
  String get placeFieldAddress => 'Dirección';

  @override
  String get placeFieldCity => 'Ciudad';

  @override
  String get placeFieldOrigin => 'Origen';

  @override
  String get placeSourceSearch => 'Elegido en la búsqueda (OpenStreetMap)';

  @override
  String get placeSourceLocation => 'Tu ubicación, revisada en el mapa';

  @override
  String get placeSourceAdjusted => 'Punto ajustado por ti';

  @override
  String get placeSourceManual => 'Indicado por ti';

  @override
  String get placeDetailsTitle => 'Detalles';

  @override
  String get placeNoPointNoAddress =>
      'Sin dirección ni punto en el mapa. Puedes buscar en \"Editar\".';

  @override
  String get placesEmptyTitle => 'Ningún lugar guardado';

  @override
  String get placesEmptyBody =>
      'Guarda los lugares a los que sueles ir para elegirlos rápido al iniciar una salida. Quedan privados en tu perfil.';

  @override
  String get placesArchivedSection => 'Archivados';

  @override
  String get placesNew => 'Nuevo lugar';

  @override
  String placesVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salidas',
      one: '1 salida',
    );
    return '$_temp0';
  }

  @override
  String get placeEditTitle => 'Editar lugar';

  @override
  String get placeEditorNote =>
      'Los cambios valen para las próximas salidas. Las salidas que ya ocurrieron mantienen el nombre y la dirección que tenían cuando se hicieron.';

  @override
  String get placeEditorLocation => 'Ubicación';

  @override
  String get placeEditorSourceSearch =>
      'Elegido en la búsqueda (datos de OpenStreetMap)';

  @override
  String get placeEditorSourceAdjusted => 'Punto ajustado por ti en el mapa';

  @override
  String get placeEditorNoPointHint =>
      'Opcional. Con un apodo o una dirección basta.';

  @override
  String get placeEditorPointSaved => 'Punto guardado';

  @override
  String get placeEditorNoPoint => 'Sin punto en el mapa';

  @override
  String get placeEditorSearchMap => 'Buscar en el mapa';

  @override
  String get placeEditorSearchAdjust => 'Buscar o ajustar';

  @override
  String get placeEditorRemoveFromMap => 'Quitar del mapa';

  @override
  String get placeEditorAddressHelper =>
      'Con un apodo, el nombre del lugar o una dirección basta.';

  @override
  String get placeEditorPrivate =>
      'Tus lugares y direcciones son privados: solo los ves tú.';

  @override
  String get placeEditorSave => 'Guardar lugar';

  @override
  String get tabMe => 'Tú';

  @override
  String get tabCatFood => 'Aperitivo / comida';

  @override
  String get tabCatSoft => 'Agua / refresco';

  @override
  String get tabCatCover => 'Cubierto';

  @override
  String get tabCatStarter => 'Entrada';

  @override
  String get tabCatTransport => 'Transporte';

  @override
  String get tabCatOther => 'Otros';

  @override
  String get tabCatDrink => 'Bebida solo de la cuenta';

  @override
  String get tabSplitEqual => 'Por igual';

  @override
  String get tabSplitItem => 'Por elemento';

  @override
  String get tabSplitCustom => 'Valores personalizados';

  @override
  String get tabShared => 'compartida';

  @override
  String tabShareHeader(String title) {
    return 'Cuenta · $title';
  }

  @override
  String get tabShareNoItems => 'Sin elementos en la cuenta.';

  @override
  String get tabShareItems => 'Elementos';

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
    return '• $title · $count × sin precio';
  }

  @override
  String tabShareLine(String title, String price) {
    return '• $title · $price';
  }

  @override
  String tabShareLineNoPrice(String title) {
    return '• $title · sin precio';
  }

  @override
  String tabShareSubtotalKnown(String amount) {
    return 'Subtotal conocido: $amount';
  }

  @override
  String tabShareSubtotal(String amount) {
    return 'Subtotal: $amount';
  }

  @override
  String tabShareDiscount(String amount) {
    return 'Descuento: -$amount';
  }

  @override
  String tabShareService(String pct, String base, String amount) {
    return 'Servicio ($pct sobre $base): $amount';
  }

  @override
  String tabShareTotalKnown(String amount) {
    return 'Total conocido: $amount';
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
      other: 'Cuenta parcial: $count elementos sin precio.',
      one: 'Cuenta parcial: 1 elemento sin precio.',
    );
    return '$_temp0';
  }

  @override
  String tabShareSplitHeader(String mode) {
    return 'División ($mode)';
  }

  @override
  String tabShareSplitLine(String name, String amount) {
    return '• $name: $amount';
  }

  @override
  String tabSharePaid(String amount) {
    return ' · pagó $amount';
  }

  @override
  String get tabShareCovered => ' · cubierto por otro pago';

  @override
  String tabShareMissing(String amount) {
    return ' · falta $amount';
  }

  @override
  String tabShareOver(String amount) {
    return ' · de más $amount';
  }

  @override
  String tabShareUnassigned(String amount) {
    return 'Aún sin dividir: $amount';
  }

  @override
  String tabShareOverTotal(String amount) {
    return 'Por encima del total: $amount';
  }

  @override
  String get tabShareSplitPartial =>
      'División parcial: los valores pueden cambiar.';

  @override
  String get tabTitle => 'Cuenta';

  @override
  String get tabShareSplitTooltip => 'Compartir la división';

  @override
  String get tabIntro =>
      'Opcional. La cuenta no registra consumo: lo que bebiste sigue en tus registros.';

  @override
  String get tabEnded =>
      'Salida terminada. La cuenta sigue editable; terminar no marca la cuenta como pagada.';

  @override
  String tabItemsTitle(String count) {
    return 'Elementos ($count)';
  }

  @override
  String get tabEmptyTitle => 'Cuenta vacía';

  @override
  String get tabEmptyBody =>
      'Añade aperitivos y otros gastos, o incluye las bebidas que ya registraste.';

  @override
  String get tabNoDrinksToLink => 'Ninguna bebida registrada para incluir';

  @override
  String tabLinkDrinks(String count) {
    return 'Incluir bebidas registradas ($count)';
  }

  @override
  String get tabSplitBill => 'Dividir la cuenta';

  @override
  String get tabSubtotalKnown => 'Subtotal conocido';

  @override
  String get tabSubtotal => 'Subtotal';

  @override
  String get tabDiscount => 'Descuento';

  @override
  String tabServiceLine(String pct, String base) {
    return 'Servicio $pct sobre $base';
  }

  @override
  String get tabTotalKnown => 'Total conocido';

  @override
  String get tabTotalTab => 'Total de la cuenta';

  @override
  String tabPartialPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count elementos sin precio: la cuenta y la división son parciales.',
      one: '1 elemento sin precio: la cuenta y la división son parciales.',
    );
    return '$_temp0';
  }

  @override
  String get tabYourShareProvisional => 'Tu parte (provisional)';

  @override
  String get tabYourShare => 'Tu parte';

  @override
  String get tabOrderNote =>
      'Orden: subtotal → descuento → servicio sobre los elementos con servicio, ya con descuento → total.';

  @override
  String get tabServiceAndDiscount => 'Servicio y descuento';

  @override
  String tabServiceSummary(String pct) {
    return 'servicio $pct';
  }

  @override
  String get tabNoService => 'sin servicio';

  @override
  String tabDiscountSummary(String amount) {
    return 'descuento $amount';
  }

  @override
  String get tabChargeService => 'Cobrar servicio';

  @override
  String get tabChargeServiceHint =>
      'Solo en los elementos marcados con servicio. Transporte y entrada empiezan sin él.';

  @override
  String get tabPercent => 'Porcentaje';

  @override
  String tabServiceBase(String base, String service) {
    return 'Base $base → $service';
  }

  @override
  String get tabDiscountNone => 'Ninguno';

  @override
  String get tabDiscountAmountLabel => 'Valor del descuento';

  @override
  String get tabDiscountPercentLabel => 'Porcentaje del descuento';

  @override
  String tabDiscountCapped(String amount) {
    return 'Limitado al subtotal: $amount';
  }

  @override
  String get tabDiscountHelper =>
      'Sobre el subtotal de los elementos, repartido entre ellos.';

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
    return '$title · $count × sin precio';
  }

  @override
  String tabGroupQtyNoPrice(String title, String qty) {
    return '$title · $qty× sin precio';
  }

  @override
  String tabGroupQtyTotal(String title, String qty, String total) {
    return '$title · $qty× = $total';
  }

  @override
  String get tabComplimentary => 'cortesía';

  @override
  String get tabNoPrice => 'sin precio';

  @override
  String tabPersonalOnly(String amount) {
    return 'solo se conoce tu parte ($amount) · total de la botella desconocido';
  }

  @override
  String get tabPersonalOnlyShort =>
      'solo se conoce la parte personal; total desconocido';

  @override
  String tabLineOnlyYourShare(String amount) {
    return 'solo tu parte $amount';
  }

  @override
  String tabLineDiscount(String amount) {
    return 'desc. −$amount';
  }

  @override
  String tabLineService(String amount) {
    return 'servicio +$amount';
  }

  @override
  String get tabLineRegisteredDrink => 'Bebida registrada';

  @override
  String get tabLineItem => 'Elemento de la cuenta';

  @override
  String get tabActions => 'Acciones';

  @override
  String get tabFillTotalTitle => 'Total de la botella/jarra';

  @override
  String get tabFillPriceTitle => 'Precio';

  @override
  String get tabFillTotalLabel => 'Total de la cuenta de este elemento';

  @override
  String get tabFillTotal => 'Indicar total';

  @override
  String get tabFillPrice => 'Indicar precio';

  @override
  String get tabNoServiceItem => 'Sin servicio en este elemento';

  @override
  String get tabRemoveFromTab => 'Quitar de la cuenta';

  @override
  String get tabDeleteItem => 'Eliminar elemento';

  @override
  String get splitTitle => 'Dividir la cuenta';

  @override
  String get splitRename => 'Renombrar';

  @override
  String splitRemoveTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String splitRemoveBody(String name, String share) {
    return '$name tiene $share asignados. Elige qué pasa con ellos:';
  }

  @override
  String splitRemoveBodyPay(String name, String share, int count, String paid) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagos',
      one: '1 pago',
    );
    return '$name tiene $share asignados y $_temp0 ($paid). Elige qué pasa con ellos:';
  }

  @override
  String get splitPassTo => 'Pasar a';

  @override
  String get splitNobody => 'Nadie (redistribuir)';

  @override
  String get splitRedistributeNote =>
      'Los elementos solo de esta persona vuelven a dividirse entre todos y sus pagos se borran.';

  @override
  String get splitTransferNote =>
      'Elementos, valores y pagos pasan a esa persona.';

  @override
  String get splitRegisterPayment => 'Registrar pago';

  @override
  String get splitEditPayment => 'Editar pago';

  @override
  String get splitWhoPaid => 'Quién pagó';

  @override
  String get splitPaidAmount => 'Valor pagado';

  @override
  String get splitNoteOptional => 'Observación (opcional)';

  @override
  String get splitPaymentPositive => 'Indica un valor mayor que cero.';

  @override
  String splitTotalKnown(String amount) {
    return 'Total conocido $amount';
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
          '$count elementos sin precio: la división y los saldos son provisionales.',
      one: '1 elemento sin precio: la división y los saldos son provisionales.',
    );
    return '$_temp0';
  }

  @override
  String get splitComplete => 'División completa: las partes suman el total.';

  @override
  String splitMissing(String amount) {
    return 'Falta repartir $amount.';
  }

  @override
  String splitOver(String amount) {
    return 'Repartido $amount más que el total.';
  }

  @override
  String get splitPeople => 'Personas';

  @override
  String get splitAddPerson => 'Añadir persona (apodo)';

  @override
  String get splitNicknamesOnly =>
      'Solo apodos, sin inicio de sesión ni invitación. Quedan solo en esta cuenta.';

  @override
  String get splitHow => 'Cómo dividir';

  @override
  String get splitModeEqualShort => 'Igual';

  @override
  String get splitModeItemShort => 'Por elemento';

  @override
  String get splitModeValuesShort => 'Valores';

  @override
  String get splitModeEqualNote =>
      'Modo activo: por igual. El total se divide entre las personas marcadas.';

  @override
  String get splitModeItemNote =>
      'Modo activo: por elemento. Cada pedido se divide entre quienes participan, con el servicio y el descuento del propio elemento.';

  @override
  String get splitModeCustomNote =>
      'Modo activo: valores personalizados. Escribes la parte de cada uno; solo cierra cuando la suma coincide con el total.';

  @override
  String get splitAddItemsHint =>
      'Añade elementos a la cuenta para dividir por elemento.';

  @override
  String get splitFillEqually => 'Rellenar por igual';

  @override
  String get splitAllDistributed => 'Todo repartido.';

  @override
  String splitNotDistributed(String amount) {
    return 'Aún sin repartir: $amount';
  }

  @override
  String splitPassedTotal(String amount) {
    return 'Se pasó del total en $amount';
  }

  @override
  String get splitResult => 'Resultado';

  @override
  String get splitProvisionalNote =>
      'Provisional: los valores cambian si cambia la cuenta.';

  @override
  String get splitAttributedNote =>
      'Asignado es lo que le corresponde a cada uno; pagado es lo que la persona dijo haber pagado al establecimiento.';

  @override
  String splitPaidLine(String paid, String balance) {
    return 'Pagó $paid · $balance';
  }

  @override
  String get splitBalanceCovered => 'cubierto por otro pago (local saldado)';

  @override
  String splitBalanceMissing(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'falta pagar $amount$_temp0';
  }

  @override
  String splitBalanceOver(String amount, String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'pagó $amount de más$_temp0';
  }

  @override
  String splitBalanceEven(String provisional) {
    String _temp0 = intl.Intl.selectLogic(provisional, {
      'true': ' (provisional)',
      'other': '',
    });
    return 'al día$_temp0';
  }

  @override
  String get splitPayments => 'Pagos';

  @override
  String get splitNoPayments => 'Ningún pago registrado.';

  @override
  String get splitRemovedPerson => 'Persona eliminada';

  @override
  String get splitDeletePayment => 'Eliminar pago';

  @override
  String get splitPaymentNote =>
      'Registrar un pago no cambia el total, el consumo ni el presupuesto: solo el saldo. La app no cobra, no hace Pix ni transferencias, y no dice quién debe pagar a quién. El precio de un consumo no cuenta como pago.';

  @override
  String get splitAssignEveryone => 'Todos dividen';

  @override
  String get splitAssignNobody => 'Nadie';

  @override
  String get splitAssignIntro =>
      'Quién participa y con qué peso. Quien no participa no recibe parte de este elemento.';

  @override
  String splitWeight(String number) {
    return 'peso $number';
  }

  @override
  String get tabExtraNew => 'Nuevo elemento de la cuenta';

  @override
  String get tabExtraNote =>
      'Solo en la cuenta de esta salida. No se vuelve consumo ni entra en el catálogo.';

  @override
  String get tabExtraDescription => 'Descripción';

  @override
  String get tabExtraHintTransport => 'Ej.: Uber de vuelta (opcional)';

  @override
  String get tabExtraHint => 'Ej.: Ración de papas fritas';

  @override
  String get tabBasisUnit => 'Precio de cada uno';

  @override
  String tabBasisTotal(String qty) {
    return 'Total de los $qty';
  }

  @override
  String get tabValueEach => 'Valor de cada unidad';

  @override
  String tabValueTotalQty(String qty) {
    return 'Valor total de los $qty';
  }

  @override
  String get tabExtraServiceItem => 'Cobrar servicio en este elemento';

  @override
  String get tabExtraServiceHint => 'Solo vale si el servicio está activado.';

  @override
  String get tabExtraWho => 'Quién comparte este elemento';

  @override
  String get tabExtraAll => 'Todos';

  @override
  String tabExtraSome(String count, String total) {
    return '$count de $total';
  }

  @override
  String get tabExtraWhoNote =>
      'Vale en el modo \"Por elemento\" de la división.';

  @override
  String get tabExtraSave => 'Guardar elemento';

  @override
  String get tabExtraNeedValue => 'Indica el valor, o elige Cortesía / No sé.';

  @override
  String tabExtraHelperUnit(String qty, String unit, String total) {
    return '$qty × $unit = $total';
  }

  @override
  String tabExtraHelperLine(String amount) {
    return 'Total de la línea: $amount';
  }

  @override
  String get tabExtraNoPrice =>
      'Sin precio: la cuenta queda parcial hasta que lo rellenes.';

  @override
  String tabLinkSharedTotal(String amount) {
    return 'compartida · total $amount';
  }

  @override
  String tabLinkSharedPersonal(String amount) {
    return 'compartida · solo se conoce tu parte ($amount)';
  }

  @override
  String get tabLinkSameBottleTitle => '¿La misma botella u otra?';

  @override
  String tabLinkSameBottleBody(String count, String name, String total) {
    return '$count registros compartidos de \"$name\" tienen el mismo total ($total). ¿Fue la misma botella/jarra o $count separadas?\n\nEl total entra en la cuenta una vez por botella; la app no adivina.';
  }

  @override
  String tabLinkSeparate(String count) {
    return '$count separadas';
  }

  @override
  String get tabLinkSame => 'La misma botella';

  @override
  String get tabLinkTitle => 'Bebidas ya registradas';

  @override
  String get tabLinkNote =>
      'Solo se vinculan a la cuenta: el precio sigue en el registro y una corrección allí vale aquí. Tus registros no muestran todo lo que pidió la mesa.';

  @override
  String get tabLinkAll => 'Todas';

  @override
  String get tabLinkNone => 'Ninguna';

  @override
  String tabLinkInclude(String count) {
    return 'Incluir $count en la cuenta';
  }

  @override
  String get tabSharePreview =>
      'Vista previa del texto. No se envía nada hasta que toques Compartir.';

  @override
  String get tabShareIncludePayments => 'Incluir pagos y saldos';

  @override
  String get tabShareOffDefault => 'Desactivado por defecto.';

  @override
  String get tabShareExcludes =>
      'No incluye dirección, fotos, notas personales ni relato de embriaguez.';

  @override
  String get tabShareButton => 'Compartir';

  @override
  String get tabCopyText => 'Copiar texto';

  @override
  String get tabTextCopied => 'Texto copiado';

  @override
  String get tabShareSubject => 'División de la cuenta';

  @override
  String get tabShareFailed =>
      'No se pudo abrir el menú de compartir. Copia el texto.';

  @override
  String get tabCardHint =>
      'Opcional: aperitivos, servicio y división de la cuenta.';

  @override
  String tabCardTotalPartial(String amount) {
    return 'Total de la cuenta (parcial): $amount';
  }

  @override
  String tabCardTotal(String amount) {
    return 'Total de la cuenta: $amount';
  }

  @override
  String tabCardShareProv(String amount) {
    return 'Tu parte de la cuenta (provisional): $amount';
  }

  @override
  String tabCardShare(String amount) {
    return 'Tu parte de la cuenta: $amount';
  }

  @override
  String tabCardLineTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String tabCardLineKnown(String amount) {
    return 'Total conocido $amount';
  }

  @override
  String tabCardLineTotalShare(String amount, String mine) {
    return 'Total $amount · tu parte $mine';
  }

  @override
  String tabCardLineKnownShare(String amount, String mine) {
    return 'Total conocido $amount · tu parte $mine';
  }

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String statsPresetDays(String days) {
    return '$days días';
  }

  @override
  String get statsPresetCustom => 'Personalizado';

  @override
  String statsRangeLine(String from, String to, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$from a $to · $_temp0';
  }

  @override
  String get statsEmptyTitle => 'Nada registrado en este período';

  @override
  String get statsEmptyBody =>
      'Solo significa que aquí no hay registros, no que no hubo salida.';

  @override
  String get statsSummary => 'Resumen';

  @override
  String get statsOutingsOfPeriod => 'Salidas del período';

  @override
  String get statsDrinksLogged => 'Tus bebidas registradas';

  @override
  String get statsDrinksOfPeriod => 'Tus bebidas del período';

  @override
  String get statsPricedRecords => 'Registros con precio';

  @override
  String get statsVolumeSection => 'Volumen personal informado';

  @override
  String get statsAlcoholicVolume => 'Bebidas con alcohol';

  @override
  String get statsNonAlcoholicVolume => 'Agua y sin alcohol';

  @override
  String statsUnknownVolume(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros sin volumen: no entran en las sumas',
      one: '1 registro sin volumen: no entra en las sumas',
    );
    return '$_temp0';
  }

  @override
  String get statsAlcoholSection => 'Alcohol calculado';

  @override
  String get statsPureAlcohol => 'Alcohol puro de los datos conocidos';

  @override
  String statsIncompleteAlcohol(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros con graduación o cantidad desconocidas',
      one: '1 registro con graduación o cantidad desconocidas',
    );
    return '$_temp0';
  }

  @override
  String get statsAlcoholNote =>
      'Volumen × graduación (o cantidad × graduación de los componentes de los cócteles). No es concentración en sangre.';

  @override
  String get statsAlcoholByCategory => 'Con alcohol, por categoría';

  @override
  String statsNoVolumeNote(String count) {
    return '$count sin volumen';
  }

  @override
  String get statsNonAlcoholicSection => 'Agua y sin alcohol, aparte';

  @override
  String get statsTopPlaces => 'Lugares más visitados';

  @override
  String get statsPlacesNote =>
      'Los lugares solo se agrupan cuando son el mismo lugar guardado; los nombres parecidos no se unen.';

  @override
  String get statsMoods => 'Relatos tras la salida';

  @override
  String get statsNoMoods => 'Ningún relato en este período.';

  @override
  String statsWithoutMood(String count) {
    return '$count sin relato.';
  }

  @override
  String get statsMoodsNote =>
      'Los relatos son personales: no miden tolerancia y no indican un límite seguro.';

  @override
  String get statsPrevious => 'Período anterior';

  @override
  String get statsFootnote =>
      'Un día sin registro no significa un día sin beber: los números reflejan solo lo registrado.';

  @override
  String statsNoBaseline(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Sin base de comparación: no hay salidas registradas en los $days días anteriores a este período.',
      one: 'Sin base de comparación: no hay salidas registradas el día anterior a este período.',
    );
    return '$_temp0';
  }

  @override
  String statsComparedTo(int days, String from, String to) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Comparado con los $days días inmediatamente anteriores ($from a $to).',
      one: 'Comparado con el día inmediatamente anterior ($from a $to).',
    );
    return '$_temp0';
  }

  @override
  String get statsIncompleteCompare =>
      'Hay bebidas sin precio en uno de los períodos: el gasto real puede ser mayor que el informado.';

  @override
  String statsLineBefore(String now, String before) {
    return '$now  (antes: $before)';
  }

  @override
  String get statsNoSavedPlace => 'Sin lugar guardado';

  @override
  String get statsSavedPlaceFallback => 'Lugar guardado';

  @override
  String get recordsUnknownVolume => 'volumen desconocido';

  @override
  String get historyEmptyTitle => 'Ninguna salida terminada';

  @override
  String get historyEmptyBody => 'Cuando termines una salida, aparece aquí.';

  @override
  String get historySearchHint => 'Buscar por lugar, bebida o persona';

  @override
  String get historyNoMatchTitle => 'Ninguna salida con estos filtros';

  @override
  String get historyNoMatchBody => 'Prueba con otro nombre, período o tipo.';

  @override
  String get historyPeriodAll => 'Todo';

  @override
  String get historyPeriodMonth => 'Este mes';

  @override
  String get historyAllTypes => 'Todos los tipos';

  @override
  String get historyNoValues => 'Sin valores';

  @override
  String get exportTitle => 'Exportar mis datos';

  @override
  String get exportIntro =>
      'Tus registros, tal como están en el dispositivo. No se envía nada a nadie: tú eliges dónde guardarlo. Ningún dato de acceso o sesión entra en los archivos.';

  @override
  String get exportJsonTitle => 'Todo en JSON';

  @override
  String get exportJsonBody =>
      'Lugares, salidas, bebidas, composiciones, cuentas y tus bebidas propias, con todos los detalles. Claves y códigos fijos, independientes del idioma de la app.';

  @override
  String get exportOutingsCsvTitle => 'Salidas en CSV';

  @override
  String get exportOutingsCsvBody =>
      'Un resumen por salida. Separador \";\", decimal con coma, UTF-8. Columnas y códigos fijos, independientes del idioma de la app.';

  @override
  String get exportDrinksCsvTitle => 'Bebidas en CSV';

  @override
  String get exportDrinksCsvBody =>
      'Una fila por registro. Campo vacío = desconocido, nunca cero. Columnas y códigos fijos, independientes del idioma de la app.';

  @override
  String get exportButton => 'Exportar';

  @override
  String get exportCopy => 'Copiar';

  @override
  String get exportCopied => 'Copiado';

  @override
  String get exportShareUnavailable =>
      'Compartir no está disponible aquí. Usa \"Copiar texto\" para guardar el contenido.';

  @override
  String get exportFailed => 'No se pudo generar el archivo.';

  @override
  String get exportJsonNote =>
      'Datos personales exportados por la propia persona. Valores en centavos (BRL), volúmenes en ml, horas en UTC. Los campos nulos son desconocidos, no cero.';

  @override
  String get shareCardTitle => 'Compartir resumen';

  @override
  String get shareCardIntro =>
      'Elige qué aparece. La dirección y tu relato nunca entran, y nada se publica solo.';

  @override
  String get shareCardWhat => 'Qué mostrar';

  @override
  String get shareCardPlaceName => 'Nombre del lugar';

  @override
  String get shareCardPlaceNameHint => 'Solo el nombre, nunca la dirección.';

  @override
  String get shareCardSpendHint =>
      'Hay bebidas sin precio: el total es parcial.';

  @override
  String get shareCardFailed =>
      'No se pudo abrir el menú de compartir. Puedes copiar el texto del resumen.';

  @override
  String get shareCardCaptureFailed =>
      'No se pudo crear la imagen. Puedes copiar el texto del resumen.';

  @override
  String get shareCardMyOuting => 'Mi salida';

  @override
  String shareCardOthers(String count) {
    return '+ $count más';
  }

  @override
  String shareCardSpendText(String amount) {
    return 'Gasto informado: $amount';
  }

  @override
  String shareCardSpendTextPartial(String amount) {
    return 'Gasto informado: $amount (hay bebidas sin precio)';
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
      'No disponible en el navegador: el seguimiento solo funciona dentro de la app.';

  @override
  String get trackingIosOld =>
      'No disponible en esta versión de iOS (necesita iOS 16.2 o más reciente).';

  @override
  String get trackingUnsupported => 'No disponible en este dispositivo.';

  @override
  String get trackingDisabled => 'Desactivado por ti.';

  @override
  String get trackingPermission =>
      'Permiso del sistema no disponible. Activa las notificaciones de Bebômetro en los ajustes del dispositivo.';

  @override
  String get trackingSystemOffIos =>
      'Desactivado en los ajustes del iPhone (Actividades en vivo).';

  @override
  String get trackingSystemOffAndroid =>
      'Notificaciones desactivadas en los ajustes del dispositivo.';

  @override
  String get trackingNoOuting => 'Disponible durante una salida.';

  @override
  String trackingHidden(String action) {
    return 'Oculto en esta salida. Usa \"$action\" en la pantalla de la salida.';
  }

  @override
  String trackingDismissed(String action) {
    return 'Lo quitaste de la pantalla de bloqueo en esta salida. Usa \"$action\" en la pantalla de la salida.';
  }

  @override
  String get trackingActive => 'Activo ahora.';

  @override
  String get trackingPending =>
      'Activado, pero aún no apareció. En iPhone solo empieza con la app abierta; abre la salida.';

  @override
  String get trackingAwaitingSave => 'esperando registro';

  @override
  String get trackingNoPermissionToast =>
      'Sin permiso de notificaciones. Puedes activarlo en los ajustes del dispositivo.';

  @override
  String get trackingEnable => 'Activar seguimiento';

  @override
  String get trackingEnableHint =>
      'Muestra el tiempo y el recuento de la salida en curso en la pantalla de bloqueo. Sin sonido ni vibración.';

  @override
  String get trackingShowSpend => 'Mostrar gastos';

  @override
  String get trackingShowSpendHint =>
      'Cuánto indicaste haber gastado en bebidas, no el total de la mesa.';

  @override
  String get trackingShowPlace => 'Mostrar nombre del lugar';

  @override
  String get trackingShowPlaceHint =>
      'Desactivado, solo aparece \"Salida en curso\". La dirección nunca aparece.';

  @override
  String get trackingCountNote =>
      'El contador muestra cuántos registros de bebida alcohólica hiciste (el agua no cuenta; una botella compartida es un registro). No son dosis ni miden la alcoholemia. El sistema puede terminar la visualización por su cuenta pasadas unas horas, sin terminar la salida.';

  @override
  String get trackingOfferBody =>
      'Mira el tiempo y el recuento de bebidas de la salida sin abrir la app. Por defecto no muestra gastos ni el nombre del lugar. Sin sonido ni vibración, y puedes ocultarlo en cada salida o desactivarlo cuando quieras en Ajustes.';

  @override
  String get trackingOfferActivate => 'Activar';

  @override
  String get trackingTitleFallback => 'Salida en curso';

  @override
  String trackingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros de bebida alcohólica',
      one: '1 registro de bebida alcohólica',
      zero: 'Ningún registro de bebida alcohólica',
    );
    return '$_temp0';
  }

  @override
  String trackingSpend(String amount) {
    return '$amount informados';
  }

  @override
  String trackingSpendUnpriced(String amount, String count) {
    return '$amount informados · $count sin precio';
  }

  @override
  String get trackingOpen => 'Abrir';

  @override
  String get trackingAnother => 'Otra más';

  @override
  String trackingAnotherWith(String next) {
    return 'Otra más · $next';
  }

  @override
  String trackingAnotherA11y(String next) {
    return 'Otra más, $next';
  }

  @override
  String get trackingWater => 'Agua';

  @override
  String get trackingChannelDescription =>
      'Tiempo y recuento de la salida en la pantalla de bloqueo. Sin sonido ni vibración.';

  @override
  String get vesselCan => 'Lata';

  @override
  String get vesselLongNeck => 'Long neck';

  @override
  String get vesselBottle => 'Botella';

  @override
  String get vesselBeerGlass => 'Vaso de cerveza';

  @override
  String get vesselDraftMug => 'Jarra de cerveza de barril';

  @override
  String get vesselShot => 'Dosis';

  @override
  String get vesselWineGlass => 'Copa de vino';

  @override
  String get vesselCocktailGlass => 'Vaso de cóctel';

  @override
  String get vesselWaterGlass => 'Vaso de agua';

  @override
  String get vesselGlass => 'Vaso';

  @override
  String get scenarioBar => 'Bar';

  @override
  String get scenarioClub => 'Discoteca';

  @override
  String get scenarioBarbecue => 'Asado';

  @override
  String get scenarioHome => 'Casa';

  @override
  String get scenarioBeach => 'Playa';

  @override
  String get scenarioRestaurant => 'Restaurante';

  @override
  String tableSemanticsMany(String count, String name) {
    return '$count registros de $name';
  }

  @override
  String get tableSemanticsSharedPart => 'tu parte de una bebida compartida';

  @override
  String get tableSemanticsTap => 'Toca para ver los detalles.';

  @override
  String tableOthersTitle(String count) {
    return 'Otros registros ($count)';
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
      other: 'Mesa de la salida con $count registros',
      one: 'Mesa de la salida con 1 registro',
    );
    return '$_temp0';
  }

  @override
  String tableSemanticsTable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mesa con $count registros',
      one: 'Mesa con 1 registro',
    );
    return '$_temp0';
  }

  @override
  String get tableEmpty => 'La mesa está vacía';

  @override
  String tableOverflowSemantics(String count) {
    return '$count registros más. Toca para ver la lista.';
  }

  @override
  String tableYours(String amount) {
    return '$amount tuyos';
  }

  @override
  String get tableYourVolume => 'Tu volumen';

  @override
  String tableSharedLine(String mine, String total, String count) {
    return 'Tu parte: $mine de $total ($count personas)';
  }

  @override
  String get tableRecipeAdjusted => 'Receta ajustada';

  @override
  String get tableScenarioTitle => 'Escenario de la mesa';

  @override
  String get tableScenarioNote =>
      'Solo cambia la ilustración. El lugar, el tipo y los registros de la salida siguen igual.';

  @override
  String get tableAboutTitle => 'Sobre la mesa';

  @override
  String get tableAboutBody =>
      'Animación ilustrativa de las bebidas registradas.\n\nLos recipientes se vacían solo como efecto visual, según la hora del registro. Esto no mide cuánto bebiste, no indica alcohol en el cuerpo y no cambia ningún registro: los totales vienen solo de lo que indicaste.';

  @override
  String get tableUnderstood => 'Entendido';

  @override
  String glassSemantics(String total, String scale, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', más $unknown registros sin volumen',
      one: ', más 1 registro sin volumen',
      zero: '',
    );
    return 'Vasazo: $total de volumen informado, en una escala de hasta $scale$_temp0.';
  }

  @override
  String get glassVolumeReported => 'Volumen informado';

  @override
  String glassScale(String scale) {
    return 'Escala: hasta $scale';
  }

  @override
  String glassAlcoholic(String amount) {
    return 'Con alcohol: $amount';
  }

  @override
  String glassOther(String amount) {
    return 'Agua y sin alcohol: $amount';
  }

  @override
  String glassNoVolume(String count) {
    return '+ $count sin volumen (no entran)';
  }

  @override
  String get glassNote =>
      'Solo una forma de ver la suma de los volúmenes registrados. No representa alcohol en el cuerpo, capacidad ni meta.';

  @override
  String get tipNoSensor => 'Sin sensor de movimiento. Arrastra para inclinar.';

  @override
  String get tipHintTilt => 'Inclina el móvil para mover la cerveza.';

  @override
  String get tipHintDrag => 'Arrastra para inclinar.';

  @override
  String get tipNoReading =>
      'Sin lectura de movimiento. Arrastra para inclinar.';

  @override
  String get tipReactMotion => 'Reaccionar al movimiento';

  @override
  String get tipWebNote =>
      'No disponible en el navegador: arrastra para inclinar.';

  @override
  String get tipOffNote => 'Desactivado, arrastras el dedo para inclinar.';

  @override
  String get tipBubbles => 'Burbujas y olas';

  @override
  String get tipBubblesNote => 'Desactívalo para una cerveza más tranquila.';

  @override
  String get tipLevel => 'Nivelar';

  @override
  String get tipVisualNote =>
      'Solo visual: el vaso no mide ni registra consumo, y llenarlo no es una meta.';

  @override
  String get tipSemantics =>
      'Cerveza que ocupa la pantalla. Inclina el móvil para mover el líquido. Solo visual, no registra consumo.';

  @override
  String get tipRefill => 'Rellenar';

  @override
  String get tipRefillAgain => 'Llenar de nuevo';

  @override
  String get gameNeverTitle => 'Yo nunca';

  @override
  String get gameNeverDesc => 'Quien lo ha hecho, lo cuenta. Sin presión.';

  @override
  String get gameMostTitle => 'Quién es más probable';

  @override
  String get gameMostDesc => 'El grupo señala a quién le va mejor la frase.';

  @override
  String get gameTruthTitle => 'Verdad o reto';

  @override
  String get gameTruthDesc => 'Cada uno en su turno, con opción de pasar.';

  @override
  String get gameModeLight => 'Ligero';

  @override
  String get gameModeAdult => '+18';

  @override
  String get gameKindCard => 'Carta';

  @override
  String get gameKindTruth => 'Verdad';

  @override
  String get gameKindDare => 'Reto';

  @override
  String get resenhaIntro =>
      'Juegos para la mesa, que funcionan sin internet. Las cartas no piden beber y no registran ninguna bebida.';

  @override
  String get resenhaInProgress => 'Partida en curso';

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
  String get resenhaGames => 'Juegos';

  @override
  String get resenhaPlay => 'Diversión';

  @override
  String get resenhaTipTitle => 'Inclinar el vaso';

  @override
  String get resenhaTipBody =>
      'La pantalla se convierte en un vaso: inclina el móvil. Solo visual.';

  @override
  String get resenhaCards => 'Cartas';

  @override
  String get resenhaMyCards => 'Mis cartas';

  @override
  String resenhaMyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creadas por ti',
      one: '1 creada por ti',
      zero: 'Ninguna creada por ti',
    );
    return '$_temp0';
  }

  @override
  String get gameAlreadyPlayer => 'Ya hay alguien con ese apodo.';

  @override
  String get gameMaxPlayers => 'Máximo 20 participantes.';

  @override
  String get gameWhoPlays => '¿Quién va a jugar?';

  @override
  String get gameAddPlayerTooltip => 'Añadir participante';

  @override
  String gameNeedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añade al menos $count participantes.',
      one: 'Añade al menos 1 participante.',
    );
    return '$_temp0';
  }

  @override
  String gameRemovePlayer(String name) {
    return 'Quitar a $name';
  }

  @override
  String get gameMode => 'Modo';

  @override
  String get gameLightNote => 'Sin contenido sexual. Para cualquier grupo.';

  @override
  String get gameAdultNote =>
      'Mezcla las cartas ligeras con coqueteo y humor para adultos. Nada explícito, y todo se puede saltar sin castigo.';

  @override
  String get gameAdultConfirm =>
      'Confirmo que todas las personas que van a jugar son adultas (18+) y aceptaron el modo +18.';

  @override
  String get gameNoDrinkNote =>
      'Las cartas nunca piden beber, tomar chupitos ni acumular bebidas, y nada aquí registra bebidas en tu salida.';

  @override
  String get gameStart => 'Empezar';

  @override
  String get gameFinishTitle => '¿Terminar la partida?';

  @override
  String get gameFinishBody =>
      'No quedará guardada. Para hacer solo una pausa, vuelve y retómala después.';

  @override
  String get gameKeepPlaying => 'Seguir jugando';

  @override
  String get gameFinish => 'Terminar';

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
  String get gameOutOfCards => 'Se acabaron las cartas';

  @override
  String get gameOutOfCardsHint =>
      'Puedes barajar todo de nuevo o terminar la partida.';

  @override
  String get gameReshuffle => 'Barajar de nuevo';

  @override
  String gameReaderCall(String name) {
    return '$name, lee la pregunta';
  }

  @override
  String get gameReaderLabel => 'Te toca leer';

  @override
  String gameResponder(String name) {
    return 'Responde: $name';
  }

  @override
  String get gameEveryoneAnswers => 'Todos responden';

  @override
  String get gamePassTurn => 'Pasar el turno';

  @override
  String get gameChangeReader => 'Cambiar lector';

  @override
  String get gameChooseReader => '¿Quién lee?';

  @override
  String get gameImportFromOuting => 'Personas de la salida';

  @override
  String get gameImportTitle => '¿Quién de la salida juega?';

  @override
  String get gameImportUse => 'Usar seleccionados';

  @override
  String get bafoTitle => 'Alcoholímetro de broma';

  @override
  String get bafoHubBody =>
      'Sopla (o mantén el botón) y mira un resultado inventado, al azar.';

  @override
  String get bafoDisclaimer =>
      'De broma: no mide alcohol ni nada de tu cuerpo y no dice si alguien puede conducir.';

  @override
  String get bafoWho => '¿Quién sopla? (opcional)';

  @override
  String get bafoSomeone => 'Alguien';

  @override
  String get bafoMicNote =>
      'Al tocar en Empezar, la app pide el micrófono solo para sentir la fuerza del soplido, como juego. El sonido se procesa en el dispositivo: no se graba ni se envía.';

  @override
  String get bafoStart => 'Empezar';

  @override
  String get bafoHoldOption => 'Prefiero mantener el botón (sin micrófono)';

  @override
  String get bafoBlowPrompt =>
      'Sopla en el micrófono hasta que se llene la barra';

  @override
  String get bafoHoldPrompt => 'Mantén el botón hasta que se llene la barra';

  @override
  String get bafoHoldButton => 'Mantener para jugar';

  @override
  String get bafoHoldNote =>
      'Modo manual: no se detecta nada, solo cuenta el tiempo que mantienes.';

  @override
  String get bafoDenied =>
      'Sin acceso al micrófono. Puedes jugar manteniendo el botón.';

  @override
  String get bafoUnsupported =>
      'Este dispositivo no puede usar el micrófono aquí. Puedes jugar manteniendo el botón.';

  @override
  String get bafoHintLouder => 'Acércate y sopla con ganas.';

  @override
  String get bafoStop => 'Parar';

  @override
  String get bafoReveal => 'La máquina de mentira está pensando…';

  @override
  String bafoResultFor(String name) {
    return 'Resultado de broma para $name';
  }

  @override
  String get bafoResultAnon => 'Resultado de broma';

  @override
  String get bafoFictional => 'Sorteado al azar. No es una medición.';

  @override
  String get bafoAgain => 'Intentar de nuevo';

  @override
  String get bafoDone => 'Terminar';

  @override
  String get bafoDialSemantics => 'Esfera del alcoholímetro de broma';

  @override
  String get bafoR1T => 'Respiración de nube';

  @override
  String get bafoR1L => 'Ligera como un suspiro de dibujo animado.';

  @override
  String get bafoR2T => 'Viento de ventilador';

  @override
  String get bafoR2L => 'La máquina de mentira recibió una brisa simpática.';

  @override
  String get bafoR3T => 'Soplido de vela de pastel';

  @override
  String get bafoR3L => 'Hora de pedir un deseo... de botana.';

  @override
  String get bafoR4T => 'Huracán de karaoke';

  @override
  String get bafoR4L => 'Tu aliento cantó más fuerte que el aparato.';

  @override
  String get bafoR5T => 'Dragón de cartón';

  @override
  String get bafoR5L => 'Soltó fuego imaginario. Nadie salió herido.';

  @override
  String get bafoR6T => 'Ventolera de historieta';

  @override
  String get bafoR6L => 'La aguja giró por puro dramatismo.';

  @override
  String get bafoR7T => 'Globo de fiesta';

  @override
  String get bafoR7L => 'Se infló y se desinfló, sin exagerar.';

  @override
  String get bafoR8T => 'Silbido de tetera';

  @override
  String get bafoR8L => 'Casi silbó. Recuerda: la máquina es de mentira.';

  @override
  String get homeYourDrinks => 'Tus bebidas';

  @override
  String outingRecordsTable(int count) {
    return 'Registros de la mesa ($count)';
  }

  @override
  String get summaryPeopleTitle => 'Personas y cuenta';

  @override
  String summaryPersonLine(String name, String share, String paid) {
    return '$name · parte $share · pagó $paid';
  }

  @override
  String summaryPersonDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas',
      one: '1 bebida',
      zero: 'Ninguna bebida',
    );
    return '$_temp0';
  }

  @override
  String get entrySharedUseOrder =>
      'Para dividir una botella o jarra entre personas de la mesa, usa \"Nuevo pedido\" en la pantalla de la salida y elige \"Botella o jarra compartida\": ahí indicas cuánto tomó cada uno.';

  @override
  String get formPortionsTitle => 'Cuánto tomó cada persona';

  @override
  String get formPortionsHint =>
      'Déjalo en blanco si no lo sabes: queda desconocido, nunca cero. La suma no puede superar el tamaño de la botella.';

  @override
  String get formPortionMl => 'ml';

  @override
  String drinkCountYours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bebidas tuyas',
      one: '1 bebida tuya',
    );
    return '$_temp0';
  }

  @override
  String get outingEditTitle => 'Editar salida';

  @override
  String get outingEditKind => 'Tipo de salida';

  @override
  String get outingEditStart => 'Inicio';

  @override
  String get outingStartFuture => 'El inicio no puede estar en el futuro.';

  @override
  String get outingStartAfterEnd =>
      'El inicio debe ser antes del final de la salida.';

  @override
  String get outingStartAfterRecords =>
      'Hay bebidas registradas antes de esa hora. Elige un inicio anterior al primer registro.';

  @override
  String get outingDelete => 'Eliminar salida';

  @override
  String get outingDeleteTitle => '¿Eliminar esta salida?';

  @override
  String get outingDeleteBody =>
      'La salida, sus registros de bebida, la cuenta y las personas desaparecen de tus listas y de tus otros dispositivos. No se puede deshacer.';

  @override
  String get outingDeleted => 'Salida eliminada';

  @override
  String gameTurnOf(String name) {
    return 'Turno: $name';
  }

  @override
  String get gameTruthOrDareQ => '¿Verdad o reto?';

  @override
  String get gameNoTruthLeft => 'Se acabaron las cartas de verdad. Elige otra.';

  @override
  String get gameNoDareLeft => 'Se acabaron las cartas de reto. Elige otra.';

  @override
  String get gameOptional => 'Opcional: se puede saltar sin castigo.';

  @override
  String get gameSkip => 'Pasar';

  @override
  String get gameNext => 'Siguiente';

  @override
  String gameSavedNote(String hub) {
    return 'La partida queda guardada: puedes salir y retomarla en $hub.';
  }

  @override
  String get gameNewCard => 'Nueva carta';

  @override
  String get gameCardHintNever => 'Yo nunca…';

  @override
  String get gameCardHintMost => '¿Quién es más probable que…?';

  @override
  String get gameCardText => 'Texto de la carta';

  @override
  String get gameCardRules =>
      'Sin exposición, grabación, coerción, conducción, violencia, actividades peligrosas ni beber como penalización.';

  @override
  String get gameCardCreated => 'Carta creada';

  @override
  String get gameCardDeleteTitle => '¿Eliminar esta carta?';

  @override
  String get gameCardsEmptyTitle => 'Aún no tienes cartas propias';

  @override
  String get gameCardsEmptyBody =>
      'Crea cartas para tus juegos. Entran en el sorteo de las próximas partidas.';

  @override
  String get gameCardDelete => 'Eliminar carta';

  @override
  String gameCardLine(String game, String mode) {
    return '$game · $mode';
  }

  @override
  String gameCardLineKind(String game, String mode, String kind) {
    return '$game · $mode · $kind';
  }

  @override
  String get gameCardNeedText => 'Escribe el texto de la carta.';

  @override
  String get gameCardTooLong => 'Texto demasiado largo.';

  @override
  String get provenanceOfficial => 'Fabricante / ficha oficial';

  @override
  String get provenanceLabel => 'Etiqueta en fuente secundaria';

  @override
  String get provenancePackagingRegistry => 'Registro público de envase';

  @override
  String get provenanceSecondary => 'Fuente secundaria';

  @override
  String get provenanceRecipe => 'Receta de referencia';

  @override
  String get provenanceUser => 'Información tuya';

  @override
  String get provenanceSuggestion => 'Volumen sugerido';

  @override
  String get provenanceGeneric => 'Referencia genérica';

  @override
  String get provenanceGeneral => 'Fuente general del producto';

  @override
  String get provenanceSuggestionLine =>
      'Tamaños comunes para facilitar el registro, no envases documentados de este producto.';

  @override
  String get aboutDataTitle => 'Sobre estos datos';

  @override
  String get aboutDataFallback =>
      'Sin fuente específica para este campo; vale la fuente general del producto.';

  @override
  String get aboutDataGeneralTitle => 'Fuente general del producto';

  @override
  String get aboutDataVariantsTitle =>
      'Graduaciones documentadas (sin promedio)';

  @override
  String get aboutDataDivergence => 'Las fuentes no coinciden en la graduación';

  @override
  String get aboutDataRegistryNote =>
      'El registro muestra que el envase existió en el mercado; no indica que se venda hoy.';

  @override
  String get aboutDataOpenFailed =>
      'No se pudo abrir la dirección. Cópiala y ábrela en el navegador.';

  @override
  String aboutDataMarket(String market) {
    return 'Mercado: $market';
  }

  @override
  String aboutDataConsulted(String date) {
    return 'Consultado el $date';
  }

  @override
  String get pendingTitle => 'Registros pendientes';

  @override
  String get pendingIntro =>
      'Toques en \"Otra más\" en la pantalla de bloqueo que no se pudieron registrar solos. Nada entra en tu historial hasta que lo confirmes aquí.';

  @override
  String get pendingEmpty => 'No hay registros pendientes.';

  @override
  String get pendingReasonEnded =>
      'La salida terminó antes del registro. Revísalo para añadirlo a ella.';

  @override
  String get pendingReasonOutside =>
      'La hora del toque está fuera del período de la salida. Ajusta la hora en la revisión.';

  @override
  String get pendingReasonNoDrink =>
      'No se puede saber qué bebida repetir. Elige la bebida y revísala.';

  @override
  String get pendingReasonNotPersonal =>
      'El pedido que mostraba el botón pasó a otra persona o se volvió botella compartida. Elige qué registrar para ti y revísalo.';

  @override
  String get pendingReasonFailed =>
      'No se pudo guardar. Puedes intentarlo de nuevo.';

  @override
  String get pendingReasonUnsupported =>
      'Esta versión de la app no reconoce esta solicitud. Puedes descartarla.';

  @override
  String get pendingReasonInReview => 'En revisión.';

  @override
  String get pendingDrinkUnknown => 'Bebida no identificada';

  @override
  String get pendingRetry => 'Intentar de nuevo';

  @override
  String get pendingRetryFailed => 'Todavía no se pudo registrar.';

  @override
  String get pendingSaved => 'Registrado.';

  @override
  String get pendingDiscard => 'Descartar';

  @override
  String get pendingDiscardTitle => '¿Descartar este toque?';

  @override
  String get pendingDiscardBody =>
      'La solicitud sale de esta lista. No se borra ningún registro ya guardado.';

  @override
  String get pendingDiscarded => 'Descartado.';

  @override
  String get pendingNoDrinkToChoose =>
      'Esta salida no tiene bebida alcohólica registrada para repetir.';

  @override
  String get pendingChooseTitle => '¿Qué bebida era?';

  @override
  String get pendingChooseDrink => 'Elegir bebida';

  @override
  String get pendingReviewAdd => 'Revisar y añadir';

  @override
  String pendingNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count toques de la pantalla de bloqueo te esperan',
      one: '1 toque de la pantalla de bloqueo te espera',
    );
    return '$_temp0';
  }

  @override
  String pendingOutingOn(String date) {
    return 'Salida del $date';
  }

  @override
  String pendingTappedAt(String time) {
    return 'Toque el $time';
  }

  @override
  String pendingReviewNote(String time) {
    return 'Toque original en la pantalla de bloqueo: $time';
  }

  @override
  String get entryFromLockScreen => 'Añadido desde la pantalla de bloqueo';

  @override
  String entryOriginalTap(String time) {
    return 'Toque original: $time';
  }

  @override
  String entryOriginalTapCorrected(String time) {
    return 'Hora corregida. Toque original: $time';
  }

  @override
  String get syncLabelOffline => 'Sin conexión';

  @override
  String get startWho => '¿Quién está en la salida?';

  @override
  String get startWhoHint =>
      'Tú ya estás. Añade a quien va a pedir o dividir la cuenta; puedes cambiarlo después.';

  @override
  String get startWhoName => 'Nombre de la persona';

  @override
  String get startWhoAdd => 'Añadir';

  @override
  String startWhoRemove(String name) {
    return 'Quitar a $name';
  }

  @override
  String get orderTitle => 'Nuevo pedido';

  @override
  String get orderWhat => '¿Qué se pidió?';

  @override
  String get orderNameLabel => 'Nombre del pedido';

  @override
  String get orderNameHint => 'Escribe el nombre o busca en el catálogo';

  @override
  String orderFromCatalog(String name) {
    return 'Del catálogo: $name';
  }

  @override
  String get orderUseTextOnly => 'Usar solo el texto';

  @override
  String orderNotInCatalog(String text) {
    return '¿No está en el catálogo? No pasa nada: se guarda como “$text” solo en esta salida.';
  }

  @override
  String get orderKind => 'Tipo';

  @override
  String get orderFor => '¿Para quién?';

  @override
  String get orderForHint => 'Toca a quien va a beber y di cuántas.';

  @override
  String get orderEach => 'Cada uno la suya';

  @override
  String get orderSharedBottle => 'Botella o jarra compartida';

  @override
  String orderMore(String name) {
    return 'Uno más para $name';
  }

  @override
  String orderLess(String name) {
    return 'Uno menos para $name';
  }

  @override
  String get orderSharers => '¿Quién comparte?';

  @override
  String orderPortionMl(String name) {
    return 'ml de $name';
  }

  @override
  String get orderPortionHint => 'Opcional. En blanco = no sé.';

  @override
  String get orderDivideVolume => 'Dividir el volumen por igual';

  @override
  String get orderDivideNote =>
      'Es una estimación: supone que cada uno bebió lo mismo. Dividir solo el precio no lo demuestra.';

  @override
  String get orderBottles => 'Botellas';

  @override
  String get orderLeftover => 'Sobra (ml)';

  @override
  String get orderPrice => 'Precio';

  @override
  String get orderPriceEach => 'Por unidad';

  @override
  String get orderPriceTotal => 'Total del pedido';

  @override
  String get orderPriceEachLabel => 'Precio de cada una';

  @override
  String get orderPriceTotalLabel => 'Precio total del pedido';

  @override
  String get orderPriceTotalHelper =>
      '¿Promoción? Indica el total: la app lo reparte en centavos exactos.';

  @override
  String get orderPriceBottleLabel => 'Precio de la botella (total)';

  @override
  String orderLineSummary(int count, String price, String total) {
    return '$count × $price = $total';
  }

  @override
  String orderSplitEach(String each) {
    return 'Cada uno paga $each si se divide por igual.';
  }

  @override
  String get orderDetails => 'Detalles (opcional)';

  @override
  String get orderVolume => 'Volumen servido (ml)';

  @override
  String get orderVolumeNote =>
      'Sugerencias editables; no son el tamaño oficial de la marca ni del bar.';

  @override
  String get orderAbv => 'Graduación (%)';

  @override
  String get orderUseRecipe => 'Usar la receta de referencia';

  @override
  String get orderUseRecipeNote =>
      'Solo si así lo preparó el bar. Sin confirmar, el trago queda sin composición.';

  @override
  String orderSummaryFor(String who) {
    return 'Para: $who';
  }

  @override
  String get orderSave => 'Añadir a la salida';

  @override
  String get orderErrName => 'Di qué se pidió.';

  @override
  String get orderErrNobody => 'Elige al menos una persona.';

  @override
  String get orderErrSharers => 'Para compartir, elige al menos dos personas.';

  @override
  String get orderErrPortions =>
      'Las porciones y la sobra superan el tamaño de la botella.';

  @override
  String get orderErrPrice => 'Indica el precio o elige otra opción.';

  @override
  String get orderErrVolume => 'Volumen no válido.';

  @override
  String get orderErrAbv => 'La graduación va de 0 a 100%.';

  @override
  String orderAdded(String summary) {
    return 'Añadido: $summary';
  }

  @override
  String get actionDrink => 'Bebida';

  @override
  String get actionFood => 'Comida';

  @override
  String get actionOther => 'Otro ítem';

  @override
  String get tabOrders => 'Pedidos';

  @override
  String get tabPeople => 'Por persona';

  @override
  String get tabBill => 'Cuenta';

  @override
  String get tileItems => 'Ítems';

  @override
  String get tileTableTotal => 'Total de la mesa';

  @override
  String get tileYourShare => 'Tu parte';

  @override
  String get tileTheirShare => 'Parte';

  @override
  String get tileVolume => 'Volumen';

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
  String get ordersEmptyTitle => 'Ningún pedido todavía';

  @override
  String get ordersEmptyBody =>
      'Usa Bebida, Comida u Otro ítem para registrar el primero.';

  @override
  String orderEachPrice(String price) {
    return '$price cada uno';
  }

  @override
  String get ordersEveryone => 'Todos';

  @override
  String get ordersUnassigned => 'sin persona';

  @override
  String get ordersMoveTo => 'Pasar a otra persona';

  @override
  String get ordersDeleteOne => 'Eliminar uno';

  @override
  String noticeMovedTo(String name) {
    return 'Pasado a $name';
  }

  @override
  String get moveCustomTitle => 'Este pedido tiene una división personalizada';

  @override
  String moveCustomBody(String name) {
    return '¿Actualizar la división del costo a $name o dejarla como está?';
  }

  @override
  String moveFollow(String name) {
    return 'Seguir a $name';
  }

  @override
  String get moveKeepSplit => 'Mantener la división';

  @override
  String repeatFor(String who) {
    return 'Uno más para $who';
  }

  @override
  String repeatLeftTitle(String names) {
    return '$names se fue';
  }

  @override
  String get repeatLeftBody =>
      'Este pedido no se repite para quien se fue. Elige para quién repetirlo.';

  @override
  String get repeatLeftAdjust => 'Elegir personas';

  @override
  String get tableIllustrated => 'Mesa ilustrada';

  @override
  String get tableIllustratedHint =>
      'Solo una imagen de los pedidos; la lista y los valores están arriba.';

  @override
  String get legacyTitle => 'Esta salida ya tiene una cuenta';

  @override
  String get legacyBody =>
      'Para asignar pedidos a personas, pasa al modo mesa: todos los registros de la salida entran en la cuenta, divididos por quien bebió. Los vínculos, extras y pagos actuales se mantienen.';

  @override
  String get legacyAction => 'Usar la mesa';

  @override
  String get extraWhoPresent => 'Todos los presentes';

  @override
  String get peopleTable => 'Mesa';

  @override
  String get peopleLeftTag => 'se fue';

  @override
  String get peopleAdd => 'Persona';

  @override
  String get peopleAddTitle => 'Añadir persona';

  @override
  String get peopleRename => 'Renombrar';

  @override
  String get peopleMarkLeft => 'Marcar que se fue';

  @override
  String get peopleMarkLeftHint =>
      'Sigue en los pedidos anteriores y no se elige por defecto en los nuevos.';

  @override
  String get peopleBack => 'Volvió a la mesa';

  @override
  String get peopleBackHint => 'Vuelve a elegirse en los ítems nuevos.';

  @override
  String get peopleRemove => 'Quitar de la mesa';

  @override
  String get peopleRemoveHint =>
      'No hay consumo, parte ni pago de esta persona.';

  @override
  String get peopleRemoveBlocked =>
      'Tiene pedidos, parte o pago: márcala como que se fue.';

  @override
  String peopleUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros son de personas que no están en la mesa',
      one: '1 registro es de alguien que no está en la mesa',
    );
    return '$_temp0: quedan sin asignar, nunca son tuyos.';
  }

  @override
  String get peopleDrankNothing => 'Todavía no bebió nada.';

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
  String get peopleFoodCost => 'Comida y otros';

  @override
  String get peopleDiscount => 'Descuento';

  @override
  String get peopleService => 'Servicio';

  @override
  String get peopleShare => 'Parte';

  @override
  String get peoplePaidToVenue => 'Pagó al local';

  @override
  String get peopleCoveredByPayment =>
      'Cubierto por otro pago: el local está saldado';

  @override
  String peopleStillOwes(String amount) {
    return 'Aún falta $amount de la parte';
  }

  @override
  String peoplePaidMore(String amount) {
    return 'Pagó $amount por encima de la parte';
  }

  @override
  String get peopleEven => 'Parte pagada';

  @override
  String get peopleCovered => 'Local ya saldado por la mesa';

  @override
  String peopleSeeOrders(String name) {
    return 'Ver pedidos de $name';
  }

  @override
  String get billSubtotal => 'Subtotal';

  @override
  String get billSubtotalKnown => 'Subtotal conocido';

  @override
  String get billDiscount => 'Descuento';

  @override
  String billService(String rate, String base) {
    return 'Servicio $rate sobre $base';
  }

  @override
  String get billTotal => 'Total de la cuenta';

  @override
  String get billTotalKnown => 'Total conocido';

  @override
  String get billYourShare => 'Tu parte';

  @override
  String billPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ítems sin precio: la cuenta es parcial',
      one: '1 ítem sin precio: la cuenta es parcial',
    );
    return '$_temp0';
  }

  @override
  String billUnassigned(String amount) {
    return 'Falta asignar $amount';
  }

  @override
  String billOverAssigned(String amount) {
    return 'Asignado de más: $amount';
  }

  @override
  String get billPaidToVenue => 'Pagado al local';

  @override
  String get billSettled => 'Local saldado';

  @override
  String get billDue => 'Pendiente con el local';

  @override
  String billOverpaid(String amount) {
    return 'Pagado de más al local: $amount';
  }

  @override
  String get billNoTransfers =>
      'La app no cobra ni hace Pix ni dice quién debe pagar a quién.';

  @override
  String get billSettings => 'Servicio, descuento e ítems';

  @override
  String get billSplitAndPay => 'Dividir y registrar pagos';

  @override
  String get formForWhom => '¿Para quién?';

  @override
  String get formForWhomPending => 'Elige para quién es esta bebida.';

  @override
  String get formForWhomShared =>
      'Botella compartida: las personas están en las porciones del pedido.';

  @override
  String get orderOpenCatalog => 'Catálogo completo, etiqueta o menú';

  @override
  String get bottleAddPerson => 'Añadir persona';

  @override
  String get bottleAddTitle => '¿Quién entra en esta botella?';

  @override
  String get bottleAddNone =>
      'Todas las personas de la salida ya están en esta botella.';

  @override
  String get bottleAddHint =>
      'La persona entra con volumen desconocido y una parte del valor. El volumen de las demás no cambia.';

  @override
  String bottleRemoveTooltip(String name) {
    return 'Quitar a $name de la botella';
  }

  @override
  String get bottleMinPeople =>
      'Una botella compartida necesita al menos dos personas. Para otro uso, elimina el registro.';

  @override
  String bottleRemoveTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String bottleRemoveVolumeAsk(String name, String volume) {
    return '$name tiene $volume registrados. ¿Qué hacer con ese volumen?';
  }

  @override
  String get bottleRemoveVolumeLeftover =>
      'Pasarlo a lo que sobró de la botella';

  @override
  String bottleRemoveVolumeTo(String name) {
    return 'Pasarlo a $name';
  }

  @override
  String bottleRemoveMoneyAsk(String name) {
    return '$name tiene parte del valor. ¿Qué hacer con ella?';
  }

  @override
  String get bottleRemoveMoneySpread =>
      'Dividirla entre quienes siguen pagando';

  @override
  String bottleRemoveMoneyTo(String name) {
    return 'Pasarla a $name';
  }

  @override
  String get bottleRemoveConfirm => 'Quitar de la botella';

  @override
  String get bottleRemoveNoPayer =>
      'Alguien tiene que seguir pagando la botella: pasa la parte a otra persona.';

  @override
  String get bottleCostTitle => 'División del valor';

  @override
  String get bottleCostHint =>
      'Separada del volumen: cada parte cuenta en la división del valor de la botella. Cero partes = no paga nada.';

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
    return 'Una parte menos para $name';
  }

  @override
  String bottleCostMore(String name) {
    return 'Una parte más para $name';
  }

  @override
  String get bottleLeftoverLabel => 'Sobra en la botella';

  @override
  String get bottleImpactTitle => 'Qué cambia al guardar';

  @override
  String get bottleImpactBody =>
      'Los pagos ya registrados no cambian ni pasan a otra persona; solo la parte de cada uno en la cuenta y el volumen.';

  @override
  String bottleImpactVolume(String before, String after) {
    return 'Volumen: $before → $after';
  }

  @override
  String bottleImpactCost(String before, String after) {
    return 'Valor en la cuenta: $before → $after';
  }

  @override
  String get bottleImpactJoins => 'entra en la botella';

  @override
  String get bottleImpactLeaves => 'sale de la botella';

  @override
  String get bottleImpactNoChange => 'Sin cambios para esta persona.';

  @override
  String get bottleImpactConfirm => 'Guardar igualmente';
}
