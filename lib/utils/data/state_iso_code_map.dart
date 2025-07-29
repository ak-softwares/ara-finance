class StateData{
  // Method to get the state name from the ISO code
  static String getStateFromISOCode(String isoCode) {
    return indianStateISOCodeMap.entries
        .firstWhere((entry) => entry.value == isoCode, orElse: () => const MapEntry('', ''))
        .key;
  }

  // Method to get the ISO code from the state name
  static String getISOFromState(String state) {
    return indianStateISOCodeMap[state] ?? '';
  }

  static final List<String> indianStates = indianStateISOCodeMap.keys.toList();

  static final Map<String, String> indianStateISOCodeMap = {
    'Andhra Pradesh': 'AP',
    'Andaman and Nicobar Islands': 'AN',
    'Arunachal Pradesh': 'AR',
    'Assam': 'AS',
    'Bihar': 'BR',
    'Chandigarh': 'CH',
    'Chhattisgarh': 'CG',
    'Daman and Diu': 'DN',
    'Delhi': 'DL',
    'Goa': 'GA',
    'Gujarat': 'GJ',
    'Haryana': 'HR',
    'Himachal Pradesh': 'HP',
    'Jammu and Kashmir': 'JK',
    'Jharkhand': 'JH',
    'Karnataka': 'KA',
    'Kerala': 'KL',
    'Ladakh': 'LA',
    'Lakshadweep': 'LD',
    'Madhya Pradesh': 'MP',
    'Maharashtra': 'MH',
    'Manipur': 'MN',
    'Meghalaya': 'ML',
    'Mizoram': 'MZ',
    'Nagaland': 'NL',
    'Odisha': 'OR',
    'Puducherry': 'PY',
    'Punjab': 'PB',
    'Rajasthan': 'RJ',
    'Sikkim': 'SK',
    'Tamil Nadu': 'TN',
    'Telangana': 'TG',
    'Tripura': 'TR',
    'Uttar Pradesh': 'UP',
    'Uttarakhand': 'UK',
    'West Bengal': 'WB',
  };

  // Extra aliases
  static final Map<String, String> isoCodeAliases = {
    'CT': 'CG', // CT -> Chhattisgarh
    'TS': 'TG', // TS -> Telangana
    'OD': 'OR', // OD -> Odisha
  };

  static String? getStateNameFromCodeOrName(String input) {
    // Direct name match
    if (indianStateISOCodeMap.containsKey(input)) return input;

    // Normalize code using aliases
    String normalizedCode = isoCodeAliases[input] ?? input;

    // Match ISO code
    if (indianStateISOCodeMap.containsValue(normalizedCode)) {
      return indianStateISOCodeMap.entries
          .firstWhere((e) => e.value == normalizedCode)
          .key;
    }

    return null;
  }
}

class CountryData {
  // Method to get the country name from the ISO code
  static String getCountryFromISOCode(String isoCode) {
    return countryISOCodeMap.entries
        .firstWhere((entry) => entry.value == isoCode, orElse: () => const MapEntry('', ''))
        .key;
  }

  // Method to get the ISO code from the country name
  static String getISOFromCountry(String country) {
    return countryISOCodeMap[country] ?? '';
  }

  static final List<String> countries = countryISOCodeMap.keys.toList();

  static final Map<String, String> countryISOCodeMap = {
    'India': 'IN',
    'China': 'CN',
    'United States': 'US',
    'Australia': 'AU',
    'Singapore': 'SG',
    'United Kingdom': 'GB',
    'Canada': 'CA',
    'Germany': 'DE',
    'Japan': 'JP',
    'South Korea': 'KR',
    'France': 'FR',
    'Italy': 'IT',
    'Brazil': 'BR',
    'Spain': 'ES',
    'Netherlands': 'NL',
    'Switzerland': 'CH',
    'Thailand': 'TH',
    'Sweden': 'SE',
    'Indonesia': 'ID',
    'Saudi Arabia': 'SA',
    'Mexico': 'MX',
    'Turkey': 'TR',
    'Poland': 'PL',
    'Iran': 'IR',
    'Belgium': 'BE',
    'Norway': 'NO',
    'Austria': 'AT',
    'United Arab Emirates': 'AE',
    'South Africa': 'ZA',
    'Denmark': 'DK',
  };

}

