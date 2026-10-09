import 'package:flutter/material.dart';

/// Theme and chalk-style catalogs for Hangman.
///
/// The art direction is the old schoolhouse: real chalkboards, wooden
/// frames and gallows, chalk letters, paper letter-tiles. Variety comes
/// from different board slates, woods, chalk tints and tile papers —
/// never neon, never cyberpunk.
class ChalkThemeDef {
  final String id;
  final String name;
  final Color boardDark;
  final Color boardMid;
  final Color boardDeep;
  final Color frameDark; // wood: gallows + frame
  final Color frameMid;
  final Color frameDeep;
  final Color chalk; // main chalk tint
  final Color chalkAccent;
  final Color tileFace; // letter tiles
  final Color tileEdge;
  final Color ink; // ink on tiles

  const ChalkThemeDef({
    required this.id,
    required this.name,
    required this.boardDark,
    required this.boardMid,
    required this.boardDeep,
    required this.frameDark,
    required this.frameMid,
    required this.frameDeep,
    required this.chalk,
    required this.chalkAccent,
    required this.tileFace,
    required this.tileEdge,
    required this.ink,
  });
}

class ChalkThemes {
  /// First 4 are the FREE starter themes. The rest are PRO.
  static const List<String> freeThemeIds = [
    'classic',
    'midnight',
    'harvest',
    'meadow',
  ];

  static const List<ChalkThemeDef> all = [
    ChalkThemeDef(
      id: 'classic',
      name: 'Classic Chalkboard',
      boardDark: Color(0xFF1E3A2B),
      boardMid: Color(0xFF2A4F3A),
      boardDeep: Color(0xFF101E15),
      frameDark: Color(0xFF5C3A21),
      frameMid: Color(0xFF7A5230),
      frameDeep: Color(0xFF2E1D0E),
      chalk: Color(0xFFF5F1E4),
      chalkAccent: Color(0xFFE8CE7A),
      tileFace: Color(0xFFF8F3E2),
      tileEdge: Color(0xFFC9BFA4),
      ink: Color(0xFF2E3A2B),
    ),
    ChalkThemeDef(
      id: 'midnight',
      name: 'Midnight Study',
      boardDark: Color(0xFF1B2438),
      boardMid: Color(0xFF27334E),
      boardDeep: Color(0xFF0E1424),
      frameDark: Color(0xFF4A2E1C),
      frameMid: Color(0xFF6B4429),
      frameDeep: Color(0xFF241309),
      chalk: Color(0xFFF2EEE4),
      chalkAccent: Color(0xFFC0C6D4),
      tileFace: Color(0xFFF5F1E4),
      tileEdge: Color(0xFFBFB49A),
      ink: Color(0xFF232B40),
    ),
    ChalkThemeDef(
      id: 'harvest',
      name: 'Harvest Oak',
      boardDark: Color(0xFF3A2E1A),
      boardMid: Color(0xFF50401F),
      boardDeep: Color(0xFF1E160A),
      frameDark: Color(0xFF8A5A2E),
      frameMid: Color(0xFFAA7740),
      frameDeep: Color(0xFF4A2F14),
      chalk: Color(0xFFFBF6E9),
      chalkAccent: Color(0xFFD99A2B),
      tileFace: Color(0xFFFFF8E8),
      tileEdge: Color(0xFFD8C89E),
      ink: Color(0xFF4A3A1A),
    ),
    ChalkThemeDef(
      id: 'meadow',
      name: 'Meadow Schoolhouse',
      boardDark: Color(0xFF2E4030),
      boardMid: Color(0xFF3F5A41),
      boardDeep: Color(0xFF182218),
      frameDark: Color(0xFF6E4E2E),
      frameMid: Color(0xFF8F683D),
      frameDeep: Color(0xFF3A2812),
      chalk: Color(0xFFF8FBEF),
      chalkAccent: Color(0xFFA3BE8C),
      tileFace: Color(0xFFFDFBF0),
      tileEdge: Color(0xFFC4C9A8),
      ink: Color(0xFF2E4030),
    ),
    ChalkThemeDef(
      id: 'crimson',
      name: 'Crimson Study',
      boardDark: Color(0xFF42202A),
      boardMid: Color(0xFF5A2C38),
      boardDeep: Color(0xFF221016),
      frameDark: Color(0xFF5C3A21),
      frameMid: Color(0xFF7A5230),
      frameDeep: Color(0xFF2E1D0E),
      chalk: Color(0xFFF8F1E2),
      chalkAccent: Color(0xFFE8A0A0),
      tileFace: Color(0xFFFDF3E4),
      tileEdge: Color(0xFFD8BCA4),
      ink: Color(0xFF4A2230),
    ),
    ChalkThemeDef(
      id: 'harbor',
      name: 'Harbor Blue',
      boardDark: Color(0xFF1E3242),
      boardMid: Color(0xFF2A4459),
      boardDeep: Color(0xFF0E1A26),
      frameDark: Color(0xFF4A3B24),
      frameMid: Color(0xFF66522F),
      frameDeep: Color(0xFF241A0E),
      chalk: Color(0xFFF2F4F8),
      chalkAccent: Color(0xFF8AB4D8),
      tileFace: Color(0xFFF6F2E8),
      tileEdge: Color(0xFFB4BCC4),
      ink: Color(0xFF1E3242),
    ),
    ChalkThemeDef(
      id: 'desert',
      name: 'Desert Chalk',
      boardDark: Color(0xFF4A3A24),
      boardMid: Color(0xFF63502F),
      boardDeep: Color(0xFF241B0E),
      frameDark: Color(0xFF7A4E24),
      frameMid: Color(0xFF9C6834),
      frameDeep: Color(0xFF3E2810),
      chalk: Color(0xFFFFFBF0),
      chalkAccent: Color(0xFFE0A83C),
      tileFace: Color(0xFFFFF6DE),
      tileEdge: Color(0xFFD8C08A),
      ink: Color(0xFF4A3A24),
    ),
    ChalkThemeDef(
      id: 'forest',
      name: 'Forest Cabin',
      boardDark: Color(0xFF24382A),
      boardMid: Color(0xFF334D38),
      boardDeep: Color(0xFF111C14),
      frameDark: Color(0xFF4E3420),
      frameMid: Color(0xFF6B482A),
      frameDeep: Color(0xFF251A0C),
      chalk: Color(0xFFF0F4E8),
      chalkAccent: Color(0xFF7FB069),
      tileFace: Color(0xFFF6F4E2),
      tileEdge: Color(0xFFB0BC98),
      ink: Color(0xFF24382A),
    ),
    ChalkThemeDef(
      id: 'ember',
      name: 'Ember Hearth',
      boardDark: Color(0xFF3E2620),
      boardMid: Color(0xFF57342A),
      boardDeep: Color(0xFF1E120E),
      frameDark: Color(0xFF5C3A21),
      frameMid: Color(0xFF7A5230),
      frameDeep: Color(0xFF2E1D0E),
      chalk: Color(0xFFF9EFE4),
      chalkAccent: Color(0xFFE07A3C),
      tileFace: Color(0xFFFDF0E0),
      tileEdge: Color(0xFFD8AE8A),
      ink: Color(0xFF4A2620),
    ),
    ChalkThemeDef(
      id: 'parchment',
      name: 'Parchment Hall',
      boardDark: Color(0xFFE8DCc2),
      boardMid: Color(0xFFF2E8D0),
      boardDeep: Color(0xFFC4B28C),
      frameDark: Color(0xFF5C3A21),
      frameMid: Color(0xFF7A5230),
      frameDeep: Color(0xFF2E1D0E),
      chalk: Color(0xFF2E3A2B),
      chalkAccent: Color(0xFF8A6D1A),
      tileFace: Color(0xFFFFFBF0),
      tileEdge: Color(0xFFD0BE98),
      ink: Color(0xFF2E3A2B),
    ),
    ChalkThemeDef(
      id: 'slate',
      name: 'Slate Academy',
      boardDark: Color(0xFF2E3440),
      boardMid: Color(0xFF434C5E),
      boardDeep: Color(0xFF161A22),
      frameDark: Color(0xFF3B2416),
      frameMid: Color(0xFF5C3A21),
      frameDeep: Color(0xFF1A0F08),
      chalk: Color(0xFFECEFF4),
      chalkAccent: Color(0xFFEBCB8B),
      tileFace: Color(0xFFF4F1E8),
      tileEdge: Color(0xFFB4BCC8),
      ink: Color(0xFF2E3440),
    ),
    ChalkThemeDef(
      id: 'vineyard',
      name: 'Vineyard Hall',
      boardDark: Color(0xFF33222E),
      boardMid: Color(0xFF462E40),
      boardDeep: Color(0xFF181016),
      frameDark: Color(0xFF5C3A21),
      frameMid: Color(0xFF7A5230),
      frameDeep: Color(0xFF2E1D0E),
      chalk: Color(0xFFF6EFE8),
      chalkAccent: Color(0xFFC98AB0),
      tileFace: Color(0xFFFBEFE8),
      tileEdge: Color(0xFFD0AEA8),
      ink: Color(0xFF3A2438),
    ),
    ChalkThemeDef(
      id: 'copper',
      name: 'Copper Mine',
      boardDark: Color(0xFF38281E),
      boardMid: Color(0xFF4E382A),
      boardDeep: Color(0xFF1A120C),
      frameDark: Color(0xFF7A4A22),
      frameMid: Color(0xFF9C6234),
      frameDeep: Color(0xFF3A2410),
      chalk: Color(0xFFF6F0E4),
      chalkAccent: Color(0xFFE09E5A),
      tileFace: Color(0xFFFDF4E6),
      tileEdge: Color(0xFFD4B08A),
      ink: Color(0xFF38281E),
    ),
    ChalkThemeDef(
      id: 'frost',
      name: 'Frost Cabin',
      boardDark: Color(0xFF2A3A44),
      boardMid: Color(0xFF3A505E),
      boardDeep: Color(0xFF121C22),
      frameDark: Color(0xFF4A3B28),
      frameMid: Color(0xFF66543A),
      frameDeep: Color(0xFF221A10),
      chalk: Color(0xFFF4FAFF),
      chalkAccent: Color(0xFF9AD0E8),
      tileFace: Color(0xFFF8FAFA),
      tileEdge: Color(0xFFB4C8D4),
      ink: Color(0xFF2A3A44),
    ),
  ];

  static ChalkThemeDef byId(String id, {ChalkThemeDef? custom}) {
    if (id == 'custom') {
      return custom ?? all.first;
    }
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }

  static bool isProTheme(String id) =>
      !freeThemeIds.contains(id) && id != 'custom';
}

/// Chalk styles: the tint of letters, keys and accents. 0-2 = FREE, 3+ = PRO.
class ChalkStyles {
  static const names = [
    'Classic White',
    'Ivory Cream',
    'Golden Hour',
    'Rose Petal',
    'Mint Leaf',
    'Sky Blue',
    'Copper Penny',
    'Lilac Dusk',
    'Ember Orange',
  ];
  static const descriptions = [
    'Plain white classroom chalk',
    'Warm ivory handwriting chalk',
    'Sunlit golden chalk dust',
    'Soft rose-tinted chalk',
    'Fresh mint green chalk',
    'Clear sky-blue chalk',
    'Warm copper chalk',
    'Dusky lilac chalk',
    'Glowing ember-orange chalk',
  ];

  /// (chalk, chalkAccent) pairs.
  static const List<List<int>> colors = [
    [0xFFF5F1E4, 0xFFE8CE7A],
    [0xFFFDF6E3, 0xFFD8C690],
    [0xFFFFF3D6, 0xFFD9A441],
    [0xFFFBEAE8, 0xFFE08A8A],
    [0xFFEAF6E8, 0xFF7FB069],
    [0xFFE8F2FA, 0xFF6FA8D8],
    [0xFFF6E8D8, 0xFFC97B3C],
    [0xFFF0E8F6, 0xFF9A7FB8],
    [0xFFFBE8D8, 0xFFE07A3C],
  ];

  /// Styles free players may use.
  static const freeCount = 3;
  static bool isPro(int index) => index >= freeCount;

  static Color chalk(int index) => Color(colors[index][0]);
  static Color chalkAccent(int index) => Color(colors[index][1]);
}
