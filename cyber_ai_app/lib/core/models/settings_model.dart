class AppSettings {
  final bool useOnlineIntelligence;
  final String proxyUrl;

  const AppSettings({
    required this.useOnlineIntelligence,
    required this.proxyUrl,
  });

  AppSettings copyWith({bool? useOnlineIntelligence, String? proxyUrl}) => AppSettings(
        useOnlineIntelligence: useOnlineIntelligence ?? this.useOnlineIntelligence,
        proxyUrl: proxyUrl ?? this.proxyUrl,
      );

  Map<String, dynamic> toJson() => {
        'useOnlineIntelligence': useOnlineIntelligence,
        'proxyUrl': proxyUrl,
      };

  static AppSettings fromJson(Map<String, dynamic> json) => AppSettings(
        useOnlineIntelligence: json['useOnlineIntelligence'] as bool? ?? false,
        proxyUrl: json['proxyUrl'] as String? ?? '',
      );

  static const defaults = AppSettings(useOnlineIntelligence: false, proxyUrl: '');
}