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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'SwiftDo'**
  String get appTitle;

  /// No description provided for @agenda.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @foco.
  ///
  /// In pt, this message translates to:
  /// **'Foco'**
  String get foco;

  /// No description provided for @dados.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get dados;

  /// No description provided for @configuracoes.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get configuracoes;

  /// No description provided for @interface.
  ///
  /// In pt, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @temaEscuro.
  ///
  /// In pt, this message translates to:
  /// **'Tema Escuro'**
  String get temaEscuro;

  /// No description provided for @ajustarBrilho.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar brilho da interface'**
  String get ajustarBrilho;

  /// No description provided for @notificacoesSons.
  ///
  /// In pt, this message translates to:
  /// **'Notificações e Sons'**
  String get notificacoesSons;

  /// No description provided for @lembretesTarefas.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes de Tarefas'**
  String get lembretesTarefas;

  /// No description provided for @alertasPrazos.
  ///
  /// In pt, this message translates to:
  /// **'Alertas sobre prazos e horários'**
  String get alertasPrazos;

  /// No description provided for @somCronometro.
  ///
  /// In pt, this message translates to:
  /// **'Som do Cronômetro'**
  String get somCronometro;

  /// No description provided for @feedbackSonoro.
  ///
  /// In pt, this message translates to:
  /// **'Feedback sonoro ao concluir foco'**
  String get feedbackSonoro;

  /// No description provided for @toqueAlerta.
  ///
  /// In pt, this message translates to:
  /// **'Toque de Alerta'**
  String get toqueAlerta;

  /// No description provided for @sinoPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Sino Padrão'**
  String get sinoPadrao;

  /// No description provided for @metasDiarias.
  ///
  /// In pt, this message translates to:
  /// **'Metas Diárias'**
  String get metasDiarias;

  /// No description provided for @objetivoTarefas.
  ///
  /// In pt, this message translates to:
  /// **'Objetivo de Tarefas'**
  String get objetivoTarefas;

  /// No description provided for @metaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Meta da Semana'**
  String get metaSemana;

  /// No description provided for @sistema.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get sistema;

  /// No description provided for @idiomaApp.
  ///
  /// In pt, this message translates to:
  /// **'Idioma do App'**
  String get idiomaApp;

  /// No description provided for @portugues.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portugues;

  /// No description provided for @ingles.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get ingles;

  /// No description provided for @espanhol.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol'**
  String get espanhol;

  /// No description provided for @contaDados.
  ///
  /// In pt, this message translates to:
  /// **'Conta e Dados'**
  String get contaDados;

  /// No description provided for @acoesPermanentes.
  ///
  /// In pt, this message translates to:
  /// **'Ações permanentes na sua conta'**
  String get acoesPermanentes;

  /// No description provided for @desativarConta.
  ///
  /// In pt, this message translates to:
  /// **'Desativar minha conta'**
  String get desativarConta;

  /// No description provided for @estudante.
  ///
  /// In pt, this message translates to:
  /// **'Estudante'**
  String get estudante;

  /// No description provided for @ola.
  ///
  /// In pt, this message translates to:
  /// **'Olá'**
  String get ola;

  /// No description provided for @sairConta.
  ///
  /// In pt, this message translates to:
  /// **'Sair da Conta'**
  String get sairConta;

  /// No description provided for @ajudaSuporte.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda e Suporte'**
  String get ajudaSuporte;

  /// No description provided for @minhaEvolucao.
  ///
  /// In pt, this message translates to:
  /// **'Minha Evolução'**
  String get minhaEvolucao;

  /// No description provided for @acompanheDesempenho.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe seu desempenho acadêmico'**
  String get acompanheDesempenho;

  /// No description provided for @semana.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get semana;

  /// No description provided for @mes.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get mes;

  /// No description provided for @ano.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get ano;

  /// No description provided for @concluidas.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get concluidas;

  /// No description provided for @metaSemanal.
  ///
  /// In pt, this message translates to:
  /// **'Meta Semanal'**
  String get metaSemanal;

  /// No description provided for @tempoFoco.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de Foco'**
  String get tempoFoco;

  /// No description provided for @materias.
  ///
  /// In pt, this message translates to:
  /// **'Matérias'**
  String get materias;

  /// No description provided for @atividadeRecente.
  ///
  /// In pt, this message translates to:
  /// **'Atividade Recente'**
  String get atividadeRecente;

  /// No description provided for @temasMaterias.
  ///
  /// In pt, this message translates to:
  /// **'Temas e Matérias'**
  String get temasMaterias;

  /// No description provided for @ajustarCronometro.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar Cronômetro'**
  String get ajustarCronometro;

  /// No description provided for @tempoPausa.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de Pausa'**
  String get tempoPausa;

  /// No description provided for @aplicarAlteracoes.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar Alterações'**
  String get aplicarAlteracoes;

  /// No description provided for @editarTempos.
  ///
  /// In pt, this message translates to:
  /// **'Editar tempos'**
  String get editarTempos;

  /// No description provided for @minutos.
  ///
  /// In pt, this message translates to:
  /// **'min'**
  String get minutos;

  /// No description provided for @presetPomodoro.
  ///
  /// In pt, this message translates to:
  /// **'Pomodoro'**
  String get presetPomodoro;

  /// No description provided for @presetCurto.
  ///
  /// In pt, this message translates to:
  /// **'Curto'**
  String get presetCurto;

  /// No description provided for @presetLongo.
  ///
  /// In pt, this message translates to:
  /// **'Longo'**
  String get presetLongo;

  /// No description provided for @presets.
  ///
  /// In pt, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @pauseParaEditar.
  ///
  /// In pt, this message translates to:
  /// **'Pause o cronômetro para editar os tempos'**
  String get pauseParaEditar;

  /// No description provided for @temposAtualizados.
  ///
  /// In pt, this message translates to:
  /// **'Tempos atualizados'**
  String get temposAtualizados;

  /// No description provided for @atividadesMes.
  ///
  /// In pt, this message translates to:
  /// **'Atividades do Mês'**
  String get atividadesMes;

  /// No description provided for @nenhumaAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atividade para este dia'**
  String get nenhumaAtividade;

  /// No description provided for @novaAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Nova atividade'**
  String get novaAtividade;

  /// No description provided for @adicionarAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar atividade'**
  String get adicionarAtividade;

  /// No description provided for @adicionarPrimeiraAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Adicione sua primeira atividade para começar'**
  String get adicionarPrimeiraAtividade;

  /// No description provided for @tituloAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Título da atividade'**
  String get tituloAtividade;

  /// No description provided for @materia.
  ///
  /// In pt, this message translates to:
  /// **'Matéria'**
  String get materia;

  /// No description provided for @materiasDisponiveis.
  ///
  /// In pt, this message translates to:
  /// **'Matérias disponíveis'**
  String get materiasDisponiveis;

  /// No description provided for @selecioneMateriaPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Toque para escolher a matéria da nova atividade'**
  String get selecioneMateriaPadrao;

  /// No description provided for @carregandoMaterias.
  ///
  /// In pt, this message translates to:
  /// **'Carregando matérias...'**
  String get carregandoMaterias;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get salvar;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @campoObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o título da atividade'**
  String get campoObrigatorio;

  /// No description provided for @selecioneMateria.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma matéria'**
  String get selecioneMateria;

  /// No description provided for @erroCarregarDados.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados'**
  String get erroCarregarDados;

  /// No description provided for @erroBancoLocalTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Banco de dados local indisponível'**
  String get erroBancoLocalTitulo;

  /// No description provided for @erroBancoLocalDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'O SwiftDo não usa internet — os dados ficam no SQLite do dispositivo. Reinicie o app ou toque em tentar novamente.'**
  String get erroBancoLocalDetalhe;

  /// No description provided for @dadosVaziosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros ainda'**
  String get dadosVaziosTitulo;

  /// No description provided for @dadosVaziosDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'Adicione atividades na Agenda ou use o cronômetro de Foco para ver estatísticas aqui.'**
  String get dadosVaziosDetalhe;

  /// No description provided for @tentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tentarNovamente;

  /// No description provided for @nenhumDadoRegistrado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dado registrado'**
  String get nenhumDadoRegistrado;
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
