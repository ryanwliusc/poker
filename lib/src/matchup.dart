import "dart:math" show Random;
import "card.dart" show Card, Rank, Suit;
import "card_pair.dart" show CardPair;
import "hand.dart" show Hand;

class Matchup {
  Matchup({
    Set<Card> this.communityCards,
    List<Set<CardPairCombinationsGeneratable>> this.players,
  })  : playerCardPairCombinations = players
            .map<Set<CardPair>>((player) => player.fold(<CardPair>{},
                (combs, player) => combs..addAll(player.cardPairCombinations)))
            .toList(),
        orderedPlayerIndexes = List.generate(players.length, (index) => index) {
    orderedPlayerIndexes.sort((a, b) {
      if (playerCardPairCombinations[a].length == 1) {
        return -2;
      }

      if (playerCardPairCombinations[b].length == 1) {
        return -2;
      }

      if (playerCardPairCombinations[a].length <= players.length) {
        return -1;
      }

      if (playerCardPairCombinations[b].length <= players.length) {
        return -1;
      }

      return 0;
    });
  }

  final Set<Card> communityCards;

  final List<Set<CardPairCombinationsGeneratable>> players;

  final List<Set<CardPair>> playerCardPairCombinations;

  final List<int> orderedPlayerIndexes;

  MatchupResult evaluate() {
    final deck = {
      const Card(rank: Rank.ace, suit: Suit.spade),
      const Card(rank: Rank.deuce, suit: Suit.spade),
      const Card(rank: Rank.three, suit: Suit.spade),
      const Card(rank: Rank.four, suit: Suit.spade),
      const Card(rank: Rank.five, suit: Suit.spade),
      const Card(rank: Rank.six, suit: Suit.spade),
      const Card(rank: Rank.seven, suit: Suit.spade),
      const Card(rank: Rank.eight, suit: Suit.spade),
      const Card(rank: Rank.nine, suit: Suit.spade),
      const Card(rank: Rank.ten, suit: Suit.spade),
      const Card(rank: Rank.jack, suit: Suit.spade),
      const Card(rank: Rank.queen, suit: Suit.spade),
      const Card(rank: Rank.king, suit: Suit.spade),
      const Card(rank: Rank.ace, suit: Suit.heart),
      const Card(rank: Rank.deuce, suit: Suit.heart),
      const Card(rank: Rank.three, suit: Suit.heart),
      const Card(rank: Rank.four, suit: Suit.heart),
      const Card(rank: Rank.five, suit: Suit.heart),
      const Card(rank: Rank.six, suit: Suit.heart),
      const Card(rank: Rank.seven, suit: Suit.heart),
      const Card(rank: Rank.eight, suit: Suit.heart),
      const Card(rank: Rank.nine, suit: Suit.heart),
      const Card(rank: Rank.ten, suit: Suit.heart),
      const Card(rank: Rank.jack, suit: Suit.heart),
      const Card(rank: Rank.queen, suit: Suit.heart),
      const Card(rank: Rank.king, suit: Suit.heart),
      const Card(rank: Rank.ace, suit: Suit.diamond),
      const Card(rank: Rank.deuce, suit: Suit.diamond),
      const Card(rank: Rank.three, suit: Suit.diamond),
      const Card(rank: Rank.four, suit: Suit.diamond),
      const Card(rank: Rank.five, suit: Suit.diamond),
      const Card(rank: Rank.six, suit: Suit.diamond),
      const Card(rank: Rank.seven, suit: Suit.diamond),
      const Card(rank: Rank.eight, suit: Suit.diamond),
      const Card(rank: Rank.nine, suit: Suit.diamond),
      const Card(rank: Rank.ten, suit: Suit.diamond),
      const Card(rank: Rank.jack, suit: Suit.diamond),
      const Card(rank: Rank.queen, suit: Suit.diamond),
      const Card(rank: Rank.king, suit: Suit.diamond),
      const Card(rank: Rank.ace, suit: Suit.club),
      const Card(rank: Rank.deuce, suit: Suit.club),
      const Card(rank: Rank.three, suit: Suit.club),
      const Card(rank: Rank.four, suit: Suit.club),
      const Card(rank: Rank.five, suit: Suit.club),
      const Card(rank: Rank.six, suit: Suit.club),
      const Card(rank: Rank.seven, suit: Suit.club),
      const Card(rank: Rank.eight, suit: Suit.club),
      const Card(rank: Rank.nine, suit: Suit.club),
      const Card(rank: Rank.ten, suit: Suit.club),
      const Card(rank: Rank.jack, suit: Suit.club),
      const Card(rank: Rank.queen, suit: Suit.club),
      const Card(rank: Rank.king, suit: Suit.club),
    };

    deck.removeAll(this.communityCards);

    final finalCommunityCards = {...this.communityCards};
    final List<CardPair> playerHoleCards = List(players.length);

    for (final playerIndex in orderedPlayerIndexes) {
      final cardPairCombinations = {...playerCardPairCombinations[playerIndex]};

      while (cardPairCombinations.length >= 1) {
        final cardPairIndex = Random().nextInt(cardPairCombinations.length);
        final cardPair = cardPairCombinations.elementAt(cardPairIndex);

        cardPairCombinations.remove(cardPair);

        if (deck.contains(cardPair.a) && deck.contains(cardPair.b)) {
          playerHoleCards[playerIndex] = cardPair;
          deck.remove(cardPair.a);
          deck.remove(cardPair.b);

          break;
        }
      }

      if (playerHoleCards[playerIndex] == null) {
        throw NoPossibleMatchupException();
      }
    }

    while (finalCommunityCards.length < 5) {
      final i = Random().nextInt(deck.length);
      final card = deck.elementAt(i);

      finalCommunityCards.add(card);
      deck.remove(card);
    }

    return MatchupResult(
      communityCards: finalCommunityCards,
      holeCards: playerHoleCards,
    );
  }
}

class MatchupResult {
  MatchupResult({this.communityCards, this.holeCards})
      : hands = holeCards
            .map((cardPair) =>
                Hand.bestFrom({...communityCards, cardPair.a, cardPair.b}))
            .toList();

  final Set<Card> communityCards;

  final List<CardPair> holeCards;

  final List<Hand> hands;

  Set<int> get bestHandIndexes {
    Set<int> bestHandIndexes = {};
    int bestHandStrongness = -1;

    for (int index = 0; index < hands.length; ++index) {
      final hand = hands[index];

      if (hand.strongness < bestHandStrongness) {
        bestHandStrongness = hand.strongness;
        bestHandIndexes = {index};
      }
    }

    return bestHandIndexes;
  }
}

class NoPossibleMatchupException implements Exception {
  const NoPossibleMatchupException();

  @override
  String toString() => "NoPossibleMatchupException";
}

mixin CardPairCombinationsGeneratable {
  Set<CardPair> get cardPairCombinations;
}

class HoleCards with CardPairCombinationsGeneratable {
  HoleCards({this.cardPair}) : cardPairCombinations = {cardPair};

  final CardPair cardPair;

  final Set<CardPair> cardPairCombinations;

  int get hashCode => cardPair.hashCode;

  operator ==(Object other) => other is HoleCards && other.cardPair == cardPair;
}

class HandRangePart with CardPairCombinationsGeneratable {
  static final _cache = <HandRangePart, Set<CardPair>>{};

  HandRangePart({this.high, this.kicker, this.isSuited = false});

  final Rank high;
  final Rank kicker;
  final bool isSuited;

  Set<CardPair> get cardPairCombinations {
    if (!_cache.containsKey(this)) {
      if (isSuited) {
        _cache[this] = Suit.values
            .map((suit) => CardPair(
                  Card(rank: high, suit: suit),
                  Card(rank: kicker, suit: suit),
                ))
            .toSet();
      } else {
        final cardPairs = <CardPair>{};

        for (final highSuit in Suit.values) {
          for (final kickerSuit in Suit.values) {
            if (kickerSuit == highSuit) continue;

            cardPairs.add(CardPair(
              Card(rank: high, suit: highSuit),
              Card(rank: kicker, suit: kickerSuit),
            ));
          }
        }

        _cache[this] = cardPairs;
      }
    }

    return _cache[this];
  }

  int get hashCode {
    int result = 17;

    result = 37 * result + high.hashCode;
    result = 37 * result + kicker.hashCode;
    result = 37 * result + isSuited.hashCode;

    return result;
  }

  operator ==(Object other) =>
      other is HandRangePart &&
      other.high == high &&
      other.kicker == kicker &&
      other.isSuited == isSuited;
}
