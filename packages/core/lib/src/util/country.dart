abstract final class Country {
  const Country._();

  static String flagEmoji(String alpha2) {
    final code = alpha2.trim().toUpperCase();
    if (code.length != 2) return '';
    final first = code.codeUnitAt(0);
    final second = code.codeUnitAt(1);
    const a = 0x41;
    const z = 0x5A;
    if (first < a || first > z || second < a || second > z) return '';
    return String.fromCharCode(0x1F1E6 + (first - a)) +
        String.fromCharCode(0x1F1E6 + (second - a));
  }

  static String localizedName({
    required String alpha2,
    required String fallback,
    required String languageCode,
  }) {
    if (languageCode == 'es') {
      final name = _esNames[alpha2.trim().toUpperCase()];
      if (name != null) return name;
    }
    return fallback.isEmpty ? alpha2.toUpperCase() : fallback;
  }

  static const Map<String, String> _esNames = {
    'AR': 'Argentina',
    'AU': 'Australia',
    'AT': 'Austria',
    'BE': 'Bélgica',
    'BO': 'Bolivia',
    'BR': 'Brasil',
    'CA': 'Canadá',
    'CL': 'Chile',
    'CN': 'China',
    'CO': 'Colombia',
    'CR': 'Costa Rica',
    'CU': 'Cuba',
    'CZ': 'Chequia',
    'DK': 'Dinamarca',
    'DO': 'República Dominicana',
    'EC': 'Ecuador',
    'EG': 'Egipto',
    'SV': 'El Salvador',
    'FI': 'Finlandia',
    'FR': 'Francia',
    'DE': 'Alemania',
    'GR': 'Grecia',
    'GT': 'Guatemala',
    'HN': 'Honduras',
    'HK': 'Hong Kong',
    'HU': 'Hungría',
    'IS': 'Islandia',
    'IN': 'India',
    'ID': 'Indonesia',
    'IE': 'Irlanda',
    'IL': 'Israel',
    'IT': 'Italia',
    'JP': 'Japón',
    'MX': 'México',
    'NL': 'Países Bajos',
    'NZ': 'Nueva Zelanda',
    'NI': 'Nicaragua',
    'NO': 'Noruega',
    'PA': 'Panamá',
    'PY': 'Paraguay',
    'PE': 'Perú',
    'PH': 'Filipinas',
    'PL': 'Polonia',
    'PT': 'Portugal',
    'PR': 'Puerto Rico',
    'RO': 'Rumanía',
    'RU': 'Rusia',
    'RS': 'Serbia',
    'SG': 'Singapur',
    'SK': 'Eslovaquia',
    'SI': 'Eslovenia',
    'ZA': 'Sudáfrica',
    'KR': 'Corea del Sur',
    'ES': 'España',
    'SE': 'Suecia',
    'CH': 'Suiza',
    'TW': 'Taiwán',
    'TH': 'Tailandia',
    'TR': 'Turquía',
    'UA': 'Ucrania',
    'GB': 'Reino Unido',
    'US': 'Estados Unidos',
    'UY': 'Uruguay',
    'VE': 'Venezuela',
  };
}
