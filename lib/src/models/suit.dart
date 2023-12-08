/// An enum that expresses a suit of [Card].
enum Suits {
  spade,
  heart,
  diamond,
  club;

  /// Returns a [Suit] from an integer value. The value must be 0 <= value <= 3.
  factory Suits.fromIndex(int index) {
    assert(index >= 0 && index <= 3);

    switch (index) {
      case 0:
        return Suits.spade;
      case 1:
        return Suits.heart;
      case 2:
        return Suits.diamond;
      default:
        return Suits.club;
    }
  }

  /// Parses a char (1-charactor-length string) and returns a [Suit]. The value must be one of `"s"`, `"h"`, `"d"` or `"c"`.
  ///
  /// ```dart
  /// assert(Suit.parse("s") == Suit.spade);
  /// assert(Suit.parse("c") == Suit.club);
  /// ```
  ///
  /// If any string else is given, this throws a [SuitParseFailureException].
  ///
  /// ```dart
  /// Suit.parse("sc");  // throws SuitParseFailureException
  /// Suit.parse("S");   // throws SuitParseFailureException
  /// ```
  factory Suits.parse(String value) {
    switch (value) {
      case 's':
        return Suits.spade;
      case 'h':
        return Suits.heart;
      case 'd':
        return Suits.diamond;
      case 'c':
        return Suits.club;
      default:
        throw SuitParseFailureException(value: value);
    }
  }

  /// Returns 1-char length string.
  ///
  /// ```dart
  /// assert(Suit.heart.toString(), "h");
  /// assert(Suit.diamond.toString(), "d");
  /// ```
  @override
  String toString() {
    switch (this) {
      case Suits.spade:
        return 's';
      case Suits.heart:
        return 'h';
      case Suits.diamond:
        return 'd';
      default:
        return 'c';
    }
  }
}

class SuitParseFailureException implements Exception {
  SuitParseFailureException({required this.value});

  final String value;

  String get message => '$value is not a valid string as a rank.';
}
