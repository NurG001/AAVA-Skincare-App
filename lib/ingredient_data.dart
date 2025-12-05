import 'package:flutter/material.dart';

class IngredientData {
  // 0 = Safe (Green), 1 = Caution (Orange), 2 = Avoid/Risk (Red)
  static final Map<String, Map<String, dynamic>> db = {
    // --- RISKY / COMEDOGENIC ---
    "COCONUT OIL": {
      "rating": 2,
      "tag": "High Comedogenic",
      "desc": "Rating: 4/5. Highly pore-clogging. Can cause severe breakouts for acne-prone skin."
    },
    "ISOPROPYL MYRISTATE": {
      "rating": 2,
      "tag": "Pore Clogger",
      "desc": "Rating: 5/5. A synthetic oil that is notorious for causing blackheads and whiteheads."
    },
    "LANOLIN": {
      "rating": 2,
      "tag": "Allergen / Heavy",
      "desc": "Sheep wool grease. Great for dry skin, but too heavy/occlusive for acne types."
    },
    "SODIUM LAURYL SULFATE": {
      "rating": 2,
      "tag": "Irritant",
      "desc": "SLS. A harsh surfactant that strips the skin barrier, leading to irritation and more acne."
    },
    "ALCOHOL DENAT": {
      "rating": 2,
      "tag": "Drying",
      "desc": "Can damage the skin barrier and increase oil production as a rebound effect."
    },
    "COCOA BUTTER": {
      "rating": 1,
      "tag": "Comedogenic",
      "desc": "Rating: 4/5. Very rich and clogging. Avoid on face, okay for body."
    },

    // --- GOOD / BENEFICIAL ---
    "NIACINAMIDE": {
      "rating": 0,
      "tag": "Acne Fighter",
      "desc": "Vitamin B3. Reduces inflammation, controls oil, and brightens dark spots."
    },
    "SALICYLIC ACID": {
      "rating": 0,
      "tag": "Exfoliant",
      "desc": "BHA. Dissolves oil inside the pore to unclog it. The gold standard for acne."
    },
    "GLYCERIN": {
      "rating": 0,
      "tag": "Hydrator",
      "desc": "A humectant that pulls moisture into the skin without clogging pores."
    },
    "ZINC OXIDE": {
      "rating": 0,
      "tag": "Soothing / SPF",
      "desc": "Calms redness and protects against UV rays."
    },
    "HYALURONIC ACID": {
      "rating": 0,
      "tag": "Moisture Magnet",
      "desc": "Holds 1000x its weight in water. Plumps skin instantly."
    },
  };

  static Color getColor(int rating) {
    if (rating == 2) return const Color(0xFFE27D60); // Red/Coral
    if (rating == 1) return const Color(0xFFE8A87C); // Orange
    return const Color(0xFF8DA399); // Sage Green
  }

  static IconData getIcon(int rating) {
    if (rating == 2) return Icons.warning_amber_rounded;
    if (rating == 1) return Icons.info_outline_rounded;
    return Icons.check_circle_outline_rounded;
  }
}