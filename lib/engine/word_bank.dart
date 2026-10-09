/// The Hangman word bank: [word, category] pairs grouped by difficulty tier.
///
/// Easy = 3-5 letters, Medium = 6-8 letters, Hard = 9-12 letters (RULES.md).
/// All words are plain A-Z; the engine uppercases defensively anyway.
class HangWord {
  final String text;
  final String category;
  const HangWord(this.text, this.category);
}

class WordBank {
  static const List<HangWord> easy = [
    // --- Animals ---
    HangWord('LION', 'Animals'), HangWord('TIGER', 'Animals'),
    HangWord('WOLF', 'Animals'), HangWord('FOX', 'Animals'),
    HangWord('BEAR', 'Animals'), HangWord('ZEBRA', 'Animals'),
    HangWord('HIPPO', 'Animals'), HangWord('RHINO', 'Animals'),
    HangWord('PANDA', 'Animals'), HangWord('KOALA', 'Animals'),
    HangWord('EAGLE', 'Animals'), HangWord('OWL', 'Animals'),
    HangWord('SNAKE', 'Animals'), HangWord('SHARK', 'Animals'),
    HangWord('CAMEL', 'Animals'), HangWord('OTTER', 'Animals'),
    HangWord('LLAMA', 'Animals'),
    // --- Food ---
    HangWord('PIZZA', 'Food'), HangWord('BURGER', 'Food'),
    HangWord('PASTA', 'Food'), HangWord('MANGO', 'Food'),
    HangWord('BANANA', 'Food'), HangWord('APPLE', 'Food'),
    HangWord('GRAPES', 'Food'), HangWord('CHEESE', 'Food'),
    HangWord('COOKIE', 'Food'), HangWord('CAKE', 'Food'),
    HangWord('MUFFIN', 'Food'), HangWord('DONUT', 'Food'),
    HangWord('SOUP', 'Food'), HangWord('SALAD', 'Food'),
    HangWord('TACOS', 'Food'), HangWord('SUSHI', 'Food'),
    HangWord('CURRY', 'Food'), HangWord('BREAD', 'Food'),
    HangWord('HONEY', 'Food'), HangWord('ORANGE', 'Food'),
    // --- Space ---
    HangWord('STAR', 'Space'), HangWord('MOON', 'Space'),
    HangWord('COMET', 'Space'), HangWord('ORBIT', 'Space'),
    HangWord('MARS', 'Space'), HangWord('VENUS', 'Space'),
    HangWord('ALIEN', 'Space'), HangWord('SOLAR', 'Space'),
    // --- Nature ---
    HangWord('RIVER', 'Nature'), HangWord('OCEAN', 'Nature'),
    HangWord('CLOUD', 'Nature'), HangWord('STORM', 'Nature'),
    HangWord('LEAF', 'Nature'), HangWord('TREE', 'Nature'),
    HangWord('SUN', 'Nature'), HangWord('RAIN', 'Nature'),
    // --- Sports ---
    HangWord('BALL', 'Sports'), HangWord('GOAL', 'Sports'),
    HangWord('RACE', 'Sports'), HangWord('CHESS', 'Sports'),
    HangWord('MEDAL', 'Sports'),
    // --- Music ---
    HangWord('PIANO', 'Music'), HangWord('DRUM', 'Music'),
    HangWord('FLUTE', 'Music'), HangWord('SONG', 'Music'),
    HangWord('TEMPO', 'Music'),
  ];

  static const List<HangWord> medium = [
    // --- Animals ---
    HangWord('ELEPHANT', 'Animals'), HangWord('GIRAFFE', 'Animals'),
    HangWord('KANGAROO', 'Animals'), HangWord('PENGUIN', 'Animals'),
    HangWord('DOLPHIN', 'Animals'), HangWord('LEOPARD', 'Animals'),
    HangWord('MONKEY', 'Animals'), HangWord('OCTOPUS', 'Animals'),
    HangWord('PARROT', 'Animals'), HangWord('JAGUAR', 'Animals'),
    HangWord('HAMSTER', 'Animals'), HangWord('BADGER', 'Animals'),
    HangWord('BEAVER', 'Animals'), HangWord('FLAMINGO', 'Animals'),
    HangWord('ANTEATER', 'Animals'),
    // --- Food ---
    HangWord('PANCAKE', 'Food'), HangWord('SANDWICH', 'Food'),
    HangWord('POPCORN', 'Food'), HangWord('NOODLES', 'Food'),
    HangWord('WAFFLES', 'Food'), HangWord('PICKLES', 'Food'),
    HangWord('CARROT', 'Food'), HangWord('TOMATO', 'Food'),
    HangWord('MELON', 'Food'), HangWord('PUDDING', 'Food'),
    HangWord('MUFFIN', 'Food'),
    // --- Space ---
    HangWord('ROCKET', 'Space'), HangWord('PLANET', 'Space'),
    HangWord('GALAXY', 'Space'), HangWord('ASTEROID', 'Space'),
    HangWord('NEBULA', 'Space'), HangWord('ECLIPSE', 'Space'),
    HangWord('JUPITER', 'Space'), HangWord('SATURN', 'Space'),
    HangWord('MERCURY', 'Space'), HangWord('URANUS', 'Space'),
    HangWord('NEPTUNE', 'Space'), HangWord('METEOR', 'Space'),
    HangWord('GRAVITY', 'Space'), HangWord('CRATER', 'Space'),
    HangWord('MILKYWAY', 'Space'),
    // --- Nature ---
    HangWord('FOREST', 'Nature'), HangWord('MEADOW', 'Nature'),
    HangWord('VALLEY', 'Nature'), HangWord('ISLAND', 'Nature'),
    HangWord('THUNDER', 'Nature'), HangWord('RAINBOW', 'Nature'),
    HangWord('SUNSET', 'Nature'), HangWord('VOLCANO', 'Nature'),
    // --- Sports ---
    HangWord('SOCCER', 'Sports'), HangWord('TENNIS', 'Sports'),
    HangWord('BOXING', 'Sports'), HangWord('KARATE', 'Sports'),
    HangWord('MARATHON', 'Sports'), HangWord('SPRINT', 'Sports'),
    HangWord('GOALIE', 'Sports'),
    // --- Music ---
    HangWord('GUITAR', 'Music'), HangWord('VIOLIN', 'Music'),
    HangWord('TRUMPET', 'Music'), HangWord('CONCERT', 'Music'),
    HangWord('MELODY', 'Music'), HangWord('RHYTHM', 'Music'),
    HangWord('CHORUS', 'Music'), HangWord('SYMPHONY', 'Music'),
  ];

  static const List<HangWord> hard = [
    // --- Animals ---
    HangWord('CROCODILE', 'Animals'), HangWord('BUTTERFLY', 'Animals'),
    HangWord('CHIMPANZEE', 'Animals'), HangWord('HIPPOPOTAMUS', 'Animals'),
    HangWord('PORCUPINE', 'Animals'), HangWord('SALAMANDER', 'Animals'),
    HangWord('JELLYFISH', 'Animals'), HangWord('ARMADILLO', 'Animals'),
    HangWord('CHAMELEON', 'Animals'), HangWord('PLATYPUS', 'Animals'),
    // --- Food ---
    HangWord('CHOCOLATE', 'Food'), HangWord('SPAGHETTI', 'Food'),
    HangWord('STRAWBERRY', 'Food'), HangWord('WATERMELON', 'Food'),
    HangWord('CROISSANT', 'Food'), HangWord('PINEAPPLE', 'Food'),
    HangWord('MEATBALLS', 'Food'), HangWord('CHEESECAKE', 'Food'),
    HangWord('HAMBURGER', 'Food'), HangWord('BUTTERSCOTCH', 'Food'),
    // --- Space ---
    HangWord('ASTRONAUT', 'Space'), HangWord('SATELLITE', 'Space'),
    HangWord('TELESCOPE', 'Space'), HangWord('BLACKHOLE', 'Space'),
    HangWord('SUPERNOVA', 'Space'), HangWord('SPACESHIP', 'Space'),
    // --- Nature ---
    HangWord('WATERFALL', 'Nature'), HangWord('LIGHTNING', 'Nature'),
    HangWord('AVALANCHE', 'Nature'), HangWord('EVERGREEN', 'Nature'),
    HangWord('SEASHORE', 'Nature'),
    // --- Sports ---
    HangWord('CHAMPIONSHIP', 'Sports'), HangWord('BASKETBALL', 'Sports'),
    HangWord('SKATEBOARD', 'Sports'), HangWord('GYMNASTICS', 'Sports'),
    HangWord('TOURNAMENT', 'Sports'),
    // --- Music ---
    HangWord('SAXOPHONE', 'Music'), HangWord('ORCHESTRA', 'Music'),
    HangWord('HARMONICA', 'Music'), HangWord('UKULELE', 'Music'),
    HangWord('XYLOPHONE', 'Music'),
  ];

  /// All words of a difficulty tier, defensively filtered to its length band.
  static List<HangWord> forDifficulty(HangDifficulty d) {
    final src = switch (d) {
      HangDifficulty.easy => easy,
      HangDifficulty.medium => medium,
      HangDifficulty.hard => hard,
    };
    final (lo, hi) = d.lengthBand;
    return src.where((w) => w.text.length >= lo && w.text.length <= hi).toList();
  }
}

/// 0 = Easy (3-5 letters), 1 = Medium (6-8), 2 = Hard (9-12). Hard is Pro.
enum HangDifficulty { easy, medium, hard }

extension HangDifficultyX on HangDifficulty {
  (int, int) get lengthBand => switch (this) {
        HangDifficulty.easy => (3, 5),
        HangDifficulty.medium => (6, 8),
        HangDifficulty.hard => (9, 12),
      };

  String get label => switch (this) {
        HangDifficulty.easy => 'Easy',
        HangDifficulty.medium => 'Medium',
        HangDifficulty.hard => 'Hard',
      };

  String get blurb => switch (this) {
        HangDifficulty.easy => '3–5 letters · 8 misses',
        HangDifficulty.medium => '6–8 letters · 6 misses',
        HangDifficulty.hard => '9–12 letters · 5 misses',
      };

  /// Wrong-guess budget per word (RULES.md §2): easier tiers forgive more.
  int get maxWrong => switch (this) {
        HangDifficulty.easy => 8,
        HangDifficulty.medium => 6,
        HangDifficulty.hard => 5,
      };

  /// Seconds per word in Timed mode (RULES.md §7).
  int get timeLimitSecs => switch (this) {
        HangDifficulty.easy => 75,
        HangDifficulty.medium => 90,
        HangDifficulty.hard => 120,
      };
}
