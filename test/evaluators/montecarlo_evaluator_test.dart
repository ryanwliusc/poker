// ignore_for_file: avoid_relative_lib_imports

import 'package:test/test.dart';
import '../../lib/src/evaluators/evaluator.dart';
import '../../lib/src/evaluators/montecarlo_evaluator.dart';
import '../../lib/src/models/immutable_card_set.dart';
import '../../lib/src/models/hand_range.dart';

void main() {
  group('MontecarloEvaluator', () {
    test('MontecarloEvaluator iterates Matchups', () {
      final times = 158928;
      final threshold = (times / 10).round();
      final evaluator = MontecarloEvaluator(
        communityCards: ImmutableCardSet.parse(''),
        players: [
          HandRange.parse('AsAh'),
          HandRange.parse('8d8h'),
        ],
      );

      int length = 0;
      List<int> wins = [0, 0];
      for (final matchup in evaluator.take(times)) {
        for (final i in matchup.wonPlayerIndexes) {
          wins[i] += 1;
        }

        length += 1;
      }
      print(ImmutableCardSet.parse('3c6dTs'));
    });

    test(
        "MontecarloEvaluator throws NoPossibleCombinationException when it found there's no possible combination while it iterates",
        () {
      final evaluator = MontecarloEvaluator(
        communityCards: ImmutableCardSet.parse('3c6dAs'),
        players: [
          HandRange.parse('AA'),
          HandRange.parse('AKs'),
          HandRange.parse('AJo+'),
        ],
      );

      expect(
        () => evaluator.take(1),
        throwsA(isA<NoPossibleCombinationException>()),
      );
    });
  });
}
