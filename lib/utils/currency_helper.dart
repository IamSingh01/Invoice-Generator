class CurrencyHelper {
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'INR': '₹',
    'AED': 'د.إ',
  };

  static String getSymbol(String code) {
    return currencySymbols[code] ?? code;
  }
}
