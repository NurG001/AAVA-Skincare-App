import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  // --- EXTENDED BLOG DATA SOURCE ---
  final List<Map<String, String>> _tips = const [
    {
      "title": "Hydration is Key",
      "desc": "Water is the foundation of healthy skin. Drinking 8 glasses a day helps flush toxins and maintains elasticity.",
      "category": "LIFESTYLE",
      "readTime": "2 min read",
      "image": "assets/tip_image2.png",
      "content": """
True skin hydration starts from within. While topical moisturizers are essential, they can only do so much if your body is dehydrated.

Why Water Matters:
Your skin is an organ—the largest one in your body—and it's made up of cells. And skin cells, like any other cell in the body, are made up of water. Without water, the organs will certainly not function at their best.

Signs of Dehydration:
• Dullness and lack of radiance
• More visible fine lines
• Itchiness
• Dark circles under eyes

The 8x8 Rule:
Health authorities commonly recommend eight 8-ounce glasses, which equals about 2 liters, or half a gallon. This is called the 8x8 rule and is very easy to remember.

Pro Tip: Add a slice of lemon or cucumber to your water for extra antioxidants and flavor!
      """
    },
    {
      "title": "The SPF Rule",
      "desc": "UV rays are the #1 cause of premature aging. Apply SPF 30+ every single day, even when it's cloudy.",
      "category": "PROTECTION",
      "readTime": "3 min read",
      "image": "assets/tip_image3.png",
      "content": """
Sunscreen isn't just for the beach. It's the most powerful anti-aging tool in your arsenal.

UVA vs. UVB:
• UVA rays penetrate deep into the skin and are responsible for premature aging (wrinkles, sagging). They can pass through windows!
• UVB rays damage the surface and cause sunburns.

The Golden Rules:
1. Wear it daily: Rain or shine, indoors or outdoors.
2. The Amount: Use two finger-lengths of product for your face and neck.
3. Reapply: Every 2 hours if you are outdoors.

Chemical vs. Mineral:
Mineral sunscreens (Zinc Oxide) sit on top of the skin and reflect rays. Chemical sunscreens absorb rays. For acne-prone skin, mineral is often safer as it is less irritating.
      """
    },
    {
      "title": "Gentle Cleansing",
      "desc": "Avoid the 'squeaky clean' feeling. That means your barrier is stripped. Use gentle, pH-balanced cleansers.",
      "category": "ROUTINE",
      "readTime": "4 min read",
      "image": "assets/tip_image4.png",
      "content": """
If your skin feels tight after washing, your cleanser is too harsh.

The Acid Mantle:
Your skin has a natural protective barrier called the acid mantle, which is slightly acidic (pH ~5.5). Traditional soaps are alkaline (pH 9-10) and destroy this barrier, letting bacteria (acne) in and moisture out.

Double Cleansing:
For the best clean without stripping:
1. Oil Cleanse: Use a cleansing balm or oil to dissolve makeup and sunscreen.
2. Water Cleanse: Follow with a gentle foam or gel to remove sweat and dirt.

Water Temperature:
Always use lukewarm water. Hot water strips natural oils, and cold water doesn't effectively remove dirt.
      """
    },
    {
      "title": "Night Repair",
      "desc": "Your skin heals while you sleep. Never skip your night routine, especially removing makeup.",
      "category": "RECOVERY",
      "readTime": "2 min read",
      "image": "assets/tip_image5.png",
      "content": """
Nighttime is when your skin switches from "defense mode" to "repair mode."

The Science of Sleep:
During deep sleep, your body's production of growth hormones peaks, which stimulates cell and tissue repair.

Essential Night Steps:
1. Cleanse: Never sleep with makeup on. It clogs pores and traps free radicals.
2. Treat: This is the best time for actives like Retinol or AHAs, as they can make skin sensitive to sunlight.
3. Moisturize: You lose more water at night (Transepidermal Water Loss), so use a slightly thicker cream than in the morning.

Silk Pillowcases:
Consider switching to silk. It causes less friction and absorbs less product from your face than cotton!
      """
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text("Skincare Journal", style: GoogleFonts.tenorSans(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          final tip = _tips[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 200),
            duration: const Duration(milliseconds: 800),
            child: _buildBlogCard(context, tip),
          );
        },
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Map<String, String> tip) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(tip: tip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE HEADER (With Hero Animation)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Hero(
                tag: tip['title']!, // Unique tag for smooth transition
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.asset(
                    tip['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(Icons.spa, size: 50, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),

            // 2. CONTENT PREVIEW
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DA399).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tip['category']!,
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8DA399),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    tip['title']!,
                    style: GoogleFonts.tenorSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    tip['desc']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(tip['readTime']!, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Text(
                        "Read Article",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3A3A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW CLASS: THE FULL ARTICLE PAGE ---
class ArticleDetailPage extends StatelessWidget {
  final Map<String, String> tip;

  const ArticleDetailPage({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. EXPANDING HEADER IMAGE
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: tip['title']!,
                child: Image.asset(
                  tip['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. ARTICLE CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Data
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8DA399).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tip['category']!,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8DA399),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(tip['readTime']!, style: GoogleFonts.lato(fontSize: 14, color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Main Title
                  Text(
                    tip['title']!,
                    style: GoogleFonts.tenorSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3A3A),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // The Content (With basic styling)
                  Text(
                    tip['content']!,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      height: 1.8,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Footer
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("AAVA Skincare Guide", style: GoogleFonts.tenorSans(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}