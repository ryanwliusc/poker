import 'dart:collection';
import 'package:fixnum/fixnum.dart';
import 'package:bitcount/bitcount.dart';
import 'package:meta/meta.dart';
import './card.dart';

/// An efficient equivalent expression to `Set<Card>`.
///
/// ImmutableCardSet is more efficient type when you want to express a `Set<Card>` value because ImmutableCardSet internally holds elements in a sum of int values. You can do any operation that `Set<Card>` has.
///
/// ```dart
/// final cardSet = ImmutableCardSet({ Card(Rank.ace, Suit.spade), Card(Rank.queen, Suit.heart) });
///
/// cardSet.contains(Card(Rank.ace, Suit.spade));  // => true
/// cardSet.containsAll([Card(Rank.ace, Suit.spade), Card(Rank.queen, Suit.heart)]);  // => true
/// cardSet.containsAll([Card(Rank.ace, Suit.spade), Card(Rank.king, Suit.club)]);  // => false
/// ```
///
/// Since ImmutableCardSet holds elements as sum of int, you can compare two different ImmutableCardSet by `==` without performance concern.
///
/// ```dart
/// ImmutableCardSet({ Card(Rank.ace, Suit.spade), Card(Rank.queen, Suit.heart) }) == Card(Rank.ace, Suit.spade), Card(Rank.queen, Suit.heart);  // => true
/// ImmutableCardSet({ Card(Rank.ace, Suit.spade), Card(Rank.queen, Suit.heart) }) == Card(Rank.king, Suit.club), Card(Rank.jack, Suit.diamond);  // => false
/// ```
@immutable
class ImmutableCardSet with IterableMixin<Card> {
  /// Creates a ImmutableCardSet from a hash [int] value.
  const ImmutableCardSet._(this._indexUnion);

  /// An empty ImmutableCardSet.
  const ImmutableCardSet.empty() : _indexUnion = Int64.ZERO;

  /// A full-deck ImmutableCardSet.
  const ImmutableCardSet.full() : _indexUnion = Int64.MAX_VALUE;

  /// Creates a ImmutableCardSet from a `Iterable<Card>`.
  ImmutableCardSet.of(Iterable<Card> cards)
      : _indexUnion = cards.fold<Int64>(Int64.ZERO, (s, card) => s | card.index);

  /// Parses a [String] to create a ImmutableCardSet.
  ///
  /// This method expects a String sequence of a String for [Card.parse()].
  factory ImmutableCardSet.parse(String value) {
    Int64 indexUnion = Int64.ZERO;

    for (int i = 0; i < value.length; i += 2) {
      try {
        indexUnion |= Card.parse(value.substring(i, i + 2)).index;
      } catch (_) {
        throw ImmutableCardSetParseFailure(value);
      }
    }

    return ImmutableCardSet._(indexUnion);
  }

  final Int64 _indexUnion;

  @override
  int get length => _indexUnion.toInt().bitCount();

  @override
  bool contains(Object? element) {
    if (element is ImmutableCardSet) {
      return (_indexUnion & element._indexUnion == element._indexUnion);
    }

    if (element is Card) {
      return (_indexUnion & element.index == element.index);
    }

    throw UnsupportedError('');
  }

  bool containsAll(ImmutableCardSet other) =>
      (_indexUnion & other._indexUnion == other._indexUnion);

  ImmutableCardSet addedAll(ImmutableCardSet other) =>
      ImmutableCardSet._(_indexUnion | other._indexUnion);

  ImmutableCardSet added(Card card) =>
      ImmutableCardSet._(_indexUnion | card.index);

  ImmutableCardSet removedAll(ImmutableCardSet other) =>
      ImmutableCardSet._(_indexUnion & ~other._indexUnion);

  ImmutableCardSet removed(Card card) =>
      ImmutableCardSet._(_indexUnion & ~card.index);

  @override
  Iterator<Card> get iterator => _CardSetIterator(_indexUnion);

  @override
  int get hashCode => _indexUnion.hashCode;

  @override
  operator ==(Object other) =>
      other is ImmutableCardSet && _indexUnion == other._indexUnion;
}

///

class _CardSetIterator implements Iterator<Card> {
  _CardSetIterator(this._remaining) : _current = null;

  Int64 _remaining;

  Card? _current;

  @override
  Card get current => _current!;

  @override
  bool moveNext() {
    if (_remaining > Int64.ZERO) {
      _current = Card.fromIndex((_remaining & -_remaining).toInt());
      _remaining = _remaining & (_remaining - Int64.ONE);

      return true;
    }

    return false;
  }
}

class ImmutableCardSetParseFailure implements Exception {
  ImmutableCardSetParseFailure(this.value);

  final String value;

  @override
  String toString() {
    return 'CardSetParseFailure: $value is not a valid string.';
  }
}

class CardPair with IterableMixin<Card> implements ImmutableCardSet {
  const CardPair(this.a, this.b);

  /// ```dart
  /// CardPair.parse("5s5h");  // => CardPair(Card(rank: Rank.five, suit: Suit.spade), Card(rank: Rank.five, suit: Suit.heart))
  /// ```
  factory CardPair.parse(String value) {
    assert(value.length == 4);

    return CardPair(
      Card.parse(value.substring(0, 2)),
      Card.parse(value.substring(2, 4)),
    );
  }

  final Card a;

  final Card b;

  @override
  Int64 get _indexUnion => Int64(a.index) | Int64(b.index);

  @override
  int get length => _indexUnion.toInt().bitCount();

  @override
  bool contains(Object? element) {
    if (element is ImmutableCardSet) {
      return (_indexUnion & element._indexUnion == element._indexUnion);
    }

    if (element is Card) {
      return (_indexUnion & element.index == element.index);
    }

    throw UnsupportedError('');
  }

  @override
  bool containsAll(ImmutableCardSet other) =>
      (_indexUnion & other._indexUnion == other._indexUnion);

  @override
  ImmutableCardSet addedAll(ImmutableCardSet other) =>
      ImmutableCardSet._(_indexUnion | other._indexUnion);

  @override
  ImmutableCardSet added(Card card) =>
      ImmutableCardSet._(_indexUnion | card.index);

  @override
  ImmutableCardSet removedAll(ImmutableCardSet other) =>
      ImmutableCardSet._(_indexUnion & ~other._indexUnion);

  @override
  ImmutableCardSet removed(Card card) =>
      ImmutableCardSet._(_indexUnion & ~card.index);

  /// Returns a string expression.
  String toSortedString() {
    if (a.rank.power > b.rank.power) {
      return '$a$b';
    }

    if (a.rank.power < b.rank.power) {
      return '$b$a';
    }

    if (b.suit.index < a.suit.index) {
      return '$b$a';
    }

    return '$a$b';
  }

  @override
  Iterator<Card> get iterator => _CardSetIterator(_indexUnion);

  @override
  int get hashCode => _indexUnion.hashCode;

  @override
  operator ==(Object other) =>
      other is CardPair && other._indexUnion == _indexUnion;
}
