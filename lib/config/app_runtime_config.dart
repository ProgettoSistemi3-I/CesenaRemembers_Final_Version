class AppRuntimeConfig {
  const AppRuntimeConfig._();

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const String mapTilerApiKey = String.fromEnvironment(
    'MAPTILER_API_KEY',
    defaultValue: '',
  );

  static const String stadiaMapsApiKey = String.fromEnvironment(
    'STADIA_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String grokApiKey = String.fromEnvironment(
    'GROK_API_KEY',
    defaultValue: '',
  );

  static const String grokModel = String.fromEnvironment(
    'GROK_MODEL',
    defaultValue: 'grok-3-mini',
  );
}
