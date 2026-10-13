<p align="center">
  <img src="assets/branding/logo_cap.png" width="112" alt="Bebômetro">
</p>

<h1 align="center">Bebômetro</h1>

<p align="center">Tus bebidas, tus gastos y tus salidas — con una mesa que cuenta la historia.</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/platforms-Android_·_iOS_·_Web-555555" alt="Android · iOS · Web">
</p>

<p align="center"><a href="README.md">English</a> · <a href="README.pt-BR.md">Português</a> · <b>Español</b></p>

---

Bebômetro es una app centrada en Brasil para registrar un *rolê*: una salida a un bar, una barbacoa, una fiesta o una noche con amigos. Inicia una sesión, registra bebidas, repite el pedido con **Mais uma** (“Una más”) y termina con un resumen de lo registrado y gastado.

## Disponibilidad

- **Plataformas:** Android e iOS son prioritarias; el proyecto también contempla Flutter web.
- **Idioma de la app:** portugués de Brasil. Estos README están en inglés, portugués y español; esto no implica una interfaz multilingüe.
- **Apariencia:** tema oscuro, detalles ámbar, icono con una **B** en una chapa de botella y logotipo escrito independiente.
- **Etapa:** desarrollo activo; no hay un lanzamiento en tiendas documentado en este repositorio.

> **Estado de validación — 13/10/2026:** las funciones siguientes están implementadas en código. El documento de continuidad informa que esta entrega no se ha compilado, ejecutado en Flutter ni validado visualmente. Las consultas a la API de Supabase no demuestran sincronización de extremo a extremo desde la app. Consulta el [checklist](docs/development-progress.md).

## Cómo funciona una salida

1. Inicia una sesión con un apodo o una dirección y un ambiente.
2. Elige un producto, receta o bebida propia; indica tu porción y, opcionalmente, el precio.
3. Repite el pedido con **Mais uma** o registra agua por separado.
4. Consulta la lista o la mesa ilustrada, con gastos y presupuesto.
5. Finaliza, revisa el resumen y vuelve a consultarlo en el historial.
6. En una apertura posterior, cuenta cómo fue, si quieres.

## Funciones

**Salidas y registro rápido**

- Una sesión activa, recuperada del almacenamiento local; horarios y registros editables.
- Repetición con un toque y opción de deshacer, conservando receta y porción. El agua no sustituye el acceso a la última bebida alcohólica.
- Botellas compartidas con reparto igual o personalizado y sobrantes. Una botella de 600 ml repartida por igual entre tres personas registra 200 ml para el usuario.
- Consumo y pago separados: pagar la botella no significa beberla entera.

**Catálogo y recetas**

- Catálogo incluido y versionado de cervezas, cervezas de barril, productos sin alcohol, destilados y aperitivos, además de recetas de referencia.
- Búsqueda por producto, marca, estilo y alias; filtros por categoría, marca, estilo y presentación, favoritos y recientes.
- Detalles con presentaciones, ingredientes declarados, graduación y fuentes cuando se conocen.
- Componentes y unidades editables; actualmente las bebidas y recetas personales pueden editarse, duplicarse y eliminarse sin modificar registros anteriores.
- Cada consumo conserva una copia de sus datos. Las actualizaciones del catálogo o de una receta no reescriben el historial.

**Bebidas por foto (solo en la salida)**

- *Etiqueta:* foto desde cámara o galería, girar/cambiar, lectura local del texto, revisión y luego “Confirmar y continuar” (abre el formulario normal de consumo) o “Guardar solo en esta salida” (no se registra consumo).
- *Carta:* una o más fotos generan candidatos revisables; corrige, descarta o añade artículos a mano. Guardar los artículos no registra consumo, y el precio anunciado es solo una sugerencia: tú confirmas lo realmente pagado.
- *Lectura no disponible* (web, permiso denegado, resultado vacío): la foto sigue visible y escribes o pegas el texto, o rellenas el artículo a mano. Nunca se simulan resultados.
- *Registro manual dentro de la salida* usa la misma pantalla de revisión. Fuera de una salida, “Mis bebidas” funciona como antes.
- Todo lo creado así pertenece al ID de esa salida: no entra al catálogo global, a “Mis bebidas”, favoritos, recientes, otras salidas ni a futuras sugerencias de precio, y permanece en el historial de la salida, también pasada la medianoche. Las lecturas inconclusas siguen ligadas a su salida de origen.
- Las fotos son archivos locales (no base64) y pueden borrarse sin perder los datos confirmados de la bebida. Un bucket privado en la nube las recibe cuando la sincronización funciona.

**La mesa**

- Alternancia Mesa/Lista y seis ambientes: bar, discoteca, barbacoa, casa, playa y restaurante.
- Latas, botellas, vasos y otros recipientes ilustrados, agrupados cuando hay muchos registros.
- Vaciado decorativo opcional, reducción de movimiento y resumen con recipientes vacíos.
- Vaso de volumen acumulado e cerveza independiente a pantalla completa para “inclinar el vaso”: el propio móvil es el vaso, controlado por el acelerómetro en Android/iOS y por arrastre en la web o sin sensor. Es solo visual y no modifica los consumos.

**Lugares y gastos**

- Lugares guardados con apodo o dirección, ciudad/estado opcionales, favoritos y archivo.
- Al iniciar una salida: buscar un bar o una dirección, usar la ubicación actual (solo después de tocar), revisar y ajustar el punto en el mapa, poner un apodo ("Casa da Samara"), elegir un lugar guardado o escribir solo un apodo. El apodo se muestra como nombre; la dirección queda en los detalles. Cada salida guarda su propia copia del lugar, y corregir el lugar de una salida cambia solo esa salida.
- Detalles del lugar con mapa, "Abrir en el mapa" (coordenadas o dirección, nunca el apodo), "Iniciar salida aquí", visitas, última visita y el gasto informado en tus bebidas (separado del total de la mesa de la cuenta).
- Búsqueda y mapa con Geoapify (datos de OpenStreetMap, con atribución), activados por la clave `GEOAPIFY_KEY`. Sin ella, apodo, dirección escrita y lugares guardados siguen funcionando.
- Presupuesto opcional, avisos configurables y corrección de precios ausentes individual o por lotes.
- Sugerencias de precios a partir de registros comparables del propio usuario, aceptadas explícitamente. No son promedios públicos del mercado.
- Importe pagado, cortesía y precio desconocido diferenciados.

**Cuenta y división (opcional)**

- Una “Comanda” dentro de la salida y de su resumen (sin pestaña nueva): pedidos equivalentes agrupados (“Caña 400 ml · 12 × R$ 15 = R$ 180”), extras como tapas, cubierto, transporte o una bebida que existe solo en la cuenta.
- Las bebidas registradas se vinculan por id, nunca se copian: corregir el registro corrige la cuenta. Una botella compartida cuenta una vez; si solo se conoce la parte personal, el total de la mesa sigue desconocido.
- Servicio opcional (atajo del 10%, editable) y descuento (R$ o %), siempre en el mismo orden: subtotal → descuento → servicio sobre los ítems elegibles → total. Los precios ausentes dejan la cuenta y la división como parciales.
- Participantes solo por apodo, división igual, por ítem (con pesos) o con importes personalizados; los centavos se reparten de forma determinista y siempre suman el total.
- Los pagos se registran por persona y solo afectan al saldo. No hay Pix, banco ni cobro, y la app nunca dice quién debe transferir a quién. Un resumen en texto se puede ver, copiar o compartir a petición.
- Consumo, coste asignado y pago permanecen separados: la cuenta nunca crea registros de bebida ni estadísticas de alcohol de nadie.

**Historial y estadísticas personales**

- Historial mensual con filtros por lugar, período y tipo de salida.
- Estadísticas de 7, 30 o 90 días o período personalizado: salidas, categorías, volúmenes conocidos, alcohol calculado, gastos registrados y lugares.
- Valoración opcional posterior, notas sobre la mañana siguiente y resaca; un recordatorio de sesión abierta nunca la finaliza automáticamente.
- La información ausente se identifica. Un día sin registros no equivale a un día sin beber.

**Salida en la pantalla de bloqueo (opcional)**

- iOS 16.2+: una Live Activity en la pantalla de bloqueo y, en los iPhone compatibles, en la Dynamic Island, con el tiempo y la cantidad de registros de bebida alcohólica. Android: una notificación silenciosa, de baja importancia, actualizada en su lugar, con cronómetro nativo (sin servicio en primer plano). Web: sin superficie nativa; el seguimiento queda dentro de la app.
- Desactivado hasta que lo actives (se ofrece una vez, en la primera salida, y en Ajustes). Los gastos y el apodo del lugar están ocultos por defecto; la dirección nunca aparece. Se puede ocultar por salida y quitar en cualquier momento, y lo que quitaste no vuelve en esa salida.
- “Abrir”, “Otra más” y “Agua” abren la app en la salida correcta y piden confirmación; nada se registra solo por tocar. El contador cuenta registros, no dosis estándar, y una botella compartida es un registro.

**Resenha: juegos sin conexión**

- Yo nunca, Quién es más probable y Verdad o reto.
- Apodos, modos suave/adultos, puntos opcionales, tarjetas propias y partidas reanudables.
- Saltar no tiene castigo. Los juegos no exigen beber ni registran bebidas automáticamente.

**Compartir y exportar**

- Tarjeta de resumen configurable; excluye la dirección completa y el relato de embriaguez.
- Exportación de registros personales a JSON y de salidas y bebidas a CSV.
- Compartir mediante el sistema cuando sea compatible, con alternativas de copiar texto. En la web depende del navegador.

## Reglas de datos y cálculos

Un volumen, precio o graduación desconocidos no son cero. El alcohol se calcula únicamente con componentes cuyos datos declarados sean suficientes, indicando los registros incompletos; hojas, cucharadas y otras unidades no compatibles no se convierten silenciosamente a ml.

La app registra consumo; **no** mide alcohol en sangre o aliento, certifica sobriedad ni establece un límite personal seguro. La animación de la mesa es ilustrativa: no mide el ritmo de consumo ni la eliminación de alcohol.

## Arquitectura y sincronización

Organización por funcionalidad con separación de dominio, datos y presentación, Cubits para el estado y `get_it` para inyección de dependencias.

- **Primero local:** SharedPreferences conserva registros y una cola duradera de envíos pendientes con versiones.
- **Cuenta:** obligatoria, con correo y contraseña (Supabase Auth, enlaces PKCE). Los datos quedan separados por cuenta en el dispositivo y funcionan sin conexión una vez iniciada la sesión. Los registros de versiones antiguas (sesión anónima) se conservan y pueden convertirse, importarse o exportarse.
- **Supabase:** PostgreSQL con migraciones RLS versionadas.
- **Envíos y lectura:** UUID estables del cliente, upserts, reintentos y sincronización manual. Una operación deja de estar pendiente solo tras la confirmación del servidor para esa versión. La lectura de la nube recupera el historial en otro dispositivo (paginada, reanudable); las ediciones concurrentes se detectan por la revisión del servidor y van a "Cambios por resolver".
- **Dependencias:** los lugares se envían antes de sus salidas y estas antes de las bebidas. Los vínculos rechazados quedan pendientes, sin eliminarse silenciosamente.
- **Limitación actual:** no hay recuperación desde la nube ni cuenta permanente para restaurar datos en otro dispositivo. Subir datos todavía no ofrece restauración. Algunas preferencias son locales.

## Tecnologías

| Capa | Tecnología |
| --- | --- |
| App | Flutter / Dart |
| Estado | `flutter_bloc` / Cubit |
| Inyección de dependencias | `get_it` |
| Persistencia local | `shared_preferences`, archivos locales de foto (`path_provider`) |
| Fotos y lectura de texto | `image_picker`, `image`, `google_mlkit_text_recognition` (en el dispositivo, Android/iOS) |
| Backend | Supabase Auth, PostgreSQL, RLS |
| Gráficos | Widgets Flutter y custom painters |
| Compartir | `share_plus` |
| Movimiento del dispositivo | `sensors_plus` |
| Formato / IDs | `intl`, `uuid` |

Cloudflare forma parte de la infraestructura prevista, no de una dependencia desplegada de la app actual.

## Estructura del proyecto

```text
lib/
  core/                  configuración, DI, tema, almacenamiento local, sync
  shell/                 navegación principal
  home/  outings/        inicio y ciclo de las salidas
  drinks/                catálogo, recetas, porciones y registros
  scan/  outing_drinks/  lectura de etiqueta/carta, fotos y bebidas solo de la salida
  tab/                   cuenta, división y pagos
  tracking/              seguimiento en pantalla de bloqueo (Live Activity / notificación)
  places/  history/      lugares guardados e historial
  stats/  settings/      estadísticas y preferencias
  table/  glass/         ambientes, recipientes e interacciones con el vaso
  games/                 juegos sin conexión
  share/  export/        tarjetas y exportación personal
assets/
  branding/              chapa y logotipo escrito
  catalog/               productos y recetas de referencia
  games/                 tarjetas de los juegos
supabase/migrations/     esquema versionado de la base de datos
docs/                    checklist de desarrollo
```

## Ejecución local

Usa un SDK Flutter cuyo Dart cumpla la restricción de [`pubspec.yaml`](pubspec.yaml), actualmente `^3.13.3`. Android e iOS necesitan sus herramientas de plataforma; iOS requiere macOS/Xcode.

Para tu propio proyecto Supabase, aplica las [migraciones](supabase/migrations/) en orden, publica la función `supabase/functions/delete-account` y configura el acceso por correo (redirect `bebometro://auth-callback`, SMTP propio para usuarios reales; ver `docs/accounts-sync-checklist.md`). La configuración se lee desde [`Env`](lib/core/config/env.dart); sustituye los valores de desarrollo incluidos para apuntar a tu proyecto.

```bash
git clone https://github.com/Lucasdiogof/bebometro.git
cd bebometro
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_CLAVE_PUBLICABLE --dart-define=GEOAPIFY_KEY=TU_CLAVE_GEOAPIFY
```

`GEOAPIFY_KEY` es opcional: sin ella, la búsqueda de lugares y el mapa quedan desactivados y el resto de la app funciona. La configuración de la clave está en el [HANDOFF](HANDOFF.md) (en portugués).

Para web, añade `-d chrome` al comando de ejecución. Son instrucciones de configuración, no evidencia de ejecución durante esta actualización documental. Si falla el backend, el flujo implementado conserva los registros locales y muestra la sincronización pendiente.

## Hoja de ruta y límites actuales

- **Implementado en el código, aún no validado en ejecución:** fotos de etiqueta y carta con lectura de texto en el dispositivo (solo Android/iOS), revisión manual, bebidas y fotos solo de la salida, envío privado de fotos y la alternativa manual usada en la web. La web no tiene lectura automática y conserva las fotos solo durante la sesión. No hay lector de códigos de barras.
- **Cuenta:** escrita en el código, sin ejecutar ni analizar tras esta función; la migración `20261016000000` fue aplicada por el responsable, pero la sincronización de la cuenta desde la app aún no se observó. Aún no hay pruebas unitarias del cálculo.
- **Pantalla de bloqueo:** escrita en Dart, Swift y Kotlin, sin compilar ni ejecutar en un dispositivo. La extensión de widget de iOS se añadió al proyecto Xcode a mano y necesita el Team de firma elegido en Xcode. Las acciones rápidas abren la app para confirmar; no registran en segundo plano. El sistema limita las Live Activities (unas 8 horas, más hasta 4 en la pantalla de bloqueo).
- **No verificado:** los intérpretes de etiqueta y carta son heurísticos y no se probaron con fotos reales, por lo que no se promete precisión. La migración `20261015000000` fue aplicada por el responsable; la sincronización de esas tablas y fotos desde la app aún no se observó.
- **Regla de alcance (implementada):** los artículos personalizados, fotos y precios de la carta pertenecen al ID de la salida, incluso después de medianoche. No entran al catálogo global, no se convierten automáticamente en artículos personales reutilizables ni alimentan sugerencias para visitas futuras.
- **Lugares y mapa:** escritos en el código, sin ejecutar; búsqueda, mapa y GPS nunca se observaron funcionando. Dependen de la clave de Geoapify (aún no configurada) y de `flutter pub get` (paquetes nuevos). La migración `20261017000000` fue aplicada por el responsable.
- **Cuenta y sincronización:** escritas en el código, sin ejecutar. La migración `20261018000000` fue aplicada por el responsable; aún dependen de la función `delete-account` publicada y de la configuración de correo en Supabase (SMTP, redirecciones, manual linking, plantillas); nada de esto se observó funcionando.
- **Idiomas (pt-BR, en, es):** localización oficial de Flutter con archivos ARB, elección manual del idioma en Ajustes (preferencia del dispositivo, disponible antes de iniciar sesión, cambio sin reiniciar), contenido de catálogo/recetas/cartas traducido, textos nativos de la pantalla de bloqueo enviados por la app y exportaciones independientes del idioma. Escrito en código, sin compilar ni ejecutar. Las plantillas de correo de Supabase en los tres idiomas están preparadas en `supabase/email-templates/`, pero **no se aplicaron**; los textos de permisos de iOS siguen el idioma del sistema. Consulta el [checklist de i18n](docs/i18n-checklist.md).
- **Más adelante:** precios regionales basados en observaciones reales y ampliación del catálogo.
- **Validación pendiente:** resolución de dependencias, compilación, flujos en dispositivo/navegador, revisión visual y sincronización de extremo a extremo. La física de la cerveza a pantalla completa y los ejes del sensor están implementados en el código, pero nunca se observaron en un dispositivo.

Las bebidas personales reutilizables creadas antes de este alcance se conservaron; dentro de una salida, los nuevos registros manuales quedan solo en ella.

## Documentación

- [Documento técnico de continuidad](HANDOFF.md)
- [Progreso de desarrollo](docs/development-progress.md)
- [Checklist de producto](docs/product-checklist.md)
- [Checklist de internacionalización](docs/i18n-checklist.md), [formato de exportación](docs/export-format.md), [correos de autenticación](docs/auth-emails.md)
- [Datos del catálogo y recetas](assets/catalog/)
- [Migraciones](supabase/migrations/)

Todavía no se incluyen capturas: esta entrega no tiene imágenes verificadas de la app en ejecución. Los recursos de marca no se presentan como pantallas del producto.

## Licencia

No se concede una licencia de código abierto. La visibilidad del código no autoriza su reutilización. Todos los derechos reservados. Las marcas de bebidas pertenecen a sus titulares; la app no está afiliada a ellas.

## Acerca de

Un producto **Lucksrei**, desarrollado por **Lucas Diogo França**. [lucksrei.com](https://lucksrei.com/)
