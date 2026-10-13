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

**La mesa**

- Alternancia Mesa/Lista y seis ambientes: bar, discoteca, barbacoa, casa, playa y restaurante.
- Latas, botellas, vasos y otros recipientes ilustrados, agrupados cuando hay muchos registros.
- Vaciado decorativo opcional, reducción de movimiento y resumen con recipientes vacíos.
- Vaso de volumen acumulado e interacción independiente para “inclinar el vaso” mediante arrastre o deslizador. Ninguna modifica los consumos.

**Lugares y gastos**

- Lugares guardados con apodo o dirección, ciudad/estado opcionales, favoritos y archivo.
- Presupuesto opcional, avisos configurables y corrección de precios ausentes individual o por lotes.
- Sugerencias de precios a partir de registros comparables del propio usuario, aceptadas explícitamente. No son promedios públicos del mercado.
- Importe pagado, cortesía y precio desconocido diferenciados.

**Historial y estadísticas personales**

- Historial mensual con filtros por lugar, período y tipo de salida.
- Estadísticas de 7, 30 o 90 días o período personalizado: salidas, categorías, volúmenes conocidos, alcohol calculado, gastos registrados y lugares.
- Valoración opcional posterior, notas sobre la mañana siguiente y resaca; un recordatorio de sesión abierta nunca la finaliza automáticamente.
- La información ausente se identifica. Un día sin registros no equivale a un día sin beber.

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
- **Supabase:** autenticación anónima y PostgreSQL con migraciones RLS versionadas.
- **Envíos:** UUID estables del cliente, upserts, reintentos y sincronización manual. Una operación deja de estar pendiente solo tras la confirmación del servidor para esa versión.
- **Dependencias:** los lugares se envían antes de sus salidas y estas antes de las bebidas. Los vínculos rechazados quedan pendientes, sin eliminarse silenciosamente.
- **Limitación actual:** no hay recuperación desde la nube ni cuenta permanente para restaurar datos en otro dispositivo. Subir datos todavía no ofrece restauración. Algunas preferencias son locales.

## Tecnologías

| Capa | Tecnología |
| --- | --- |
| App | Flutter / Dart |
| Estado | `flutter_bloc` / Cubit |
| Inyección de dependencias | `get_it` |
| Persistencia local | `shared_preferences` |
| Backend | Supabase Auth, PostgreSQL, RLS |
| Gráficos | Widgets Flutter y custom painters |
| Compartir | `share_plus` |
| Formato / IDs | `intl`, `uuid` |

Cloudflare forma parte de la infraestructura prevista, no de una dependencia desplegada de la app actual.

## Estructura del proyecto

```text
lib/
  core/                  configuración, DI, tema, almacenamiento local, sync
  shell/                 navegación principal
  home/  outings/        inicio y ciclo de las salidas
  drinks/                catálogo, recetas, porciones y registros
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

Para tu propio proyecto Supabase, aplica las [migraciones](supabase/migrations/) en orden y habilita el inicio de sesión anónimo. La configuración se lee desde [`Env`](lib/core/config/env.dart); sustituye los valores de desarrollo incluidos para apuntar a tu proyecto.

```bash
git clone https://github.com/Lucasdiogof/bebometro.git
cd bebometro
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_CLAVE_PUBLICABLE
```

Para web, añade `-d chrome` al comando de ejecución. Son instrucciones de configuración, no evidencia de ejecución durante esta actualización documental. Si falla el backend, el flujo implementado conserva los registros locales y muestra la sincronización pendiente.

## Hoja de ruta y límites actuales

- **En desarrollo:** fotos de etiquetas/cartas, OCR con revisión manual y registro restringido a la salida de origen. El último commit incorpora la base de datos, servicios OCR, parsers y una migración; el flujo completo de pantallas todavía no está documentado como entregado.
- **Regla de esa entrega:** los artículos personalizados, fotos y precios de la carta pertenecen al ID de la salida, incluso después de medianoche. No entran al catálogo global, no se convierten automáticamente en artículos personales reutilizables ni alimentan sugerencias para visitas futuras. Permanecen en el historial de esa salida.
- **Más adelante:** búsqueda de lugares/mapas, actividades opcionales en pantalla bloqueada, precios regionales basados en observaciones reales y ampliación del catálogo.
- **Validación pendiente:** resolución de dependencias, compilación, flujos en dispositivo/navegador, revisión visual y sincronización de extremo a extremo. La inclinación por sensores no está implementada.

La función existente de bebidas personales reutilizables es anterior al alcance de captura por salida. La nueva regla debe implementarse conservando los registros existentes.

## Documentación

- [Documento técnico de continuidad](HANDOFF.md)
- [Progreso de desarrollo](docs/development-progress.md)
- [Datos del catálogo y recetas](assets/catalog/)
- [Migraciones](supabase/migrations/)

Todavía no se incluyen capturas: esta entrega no tiene imágenes verificadas de la app en ejecución. Los recursos de marca no se presentan como pantallas del producto.

## Licencia

No se concede una licencia de código abierto. La visibilidad del código no autoriza su reutilización. Todos los derechos reservados. Las marcas de bebidas pertenecen a sus titulares; la app no está afiliada a ellas.

## Acerca de

Un producto **Lucksrei**, desarrollado por **Lucas Diogo França**. [lucksrei.com](https://lucksrei.com/)
