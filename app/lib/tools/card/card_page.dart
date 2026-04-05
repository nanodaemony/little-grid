import 'dart:math';
import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final Random _random = Random();
  PlayingCard? _currentCard;
  bool _isFlipping = false;

  final List<String> _suits = ['♠', '♥', '♣', '♦'];
  final List<String> _ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

  void _drawCard() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentCard = PlayingCard(
          suit: _suits[_random.nextInt(_suits.length)],
          rank: _ranks[_random.nextInt(_ranks.length)],
        );
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻扑克牌'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 扑克牌
            GestureDetector(
              onTap: _drawCard,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  color: _currentCard == null ? Colors.blue.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _isFlipping
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _currentCard == null
                        ? Center(
                            child: Icon(
                              Icons.style,
                              size: 64,
                              color: Colors.blue.shade900,
                            ),
                          )
                        : _buildCardFace(_currentCard!),
              ),
            ),

            const SizedBox(height: 48),

            // 翻牌按钮
            ElevatedButton.icon(
              onPressed: _isFlipping ? null : _drawCard,
              icon: const Icon(Icons.style),
              label: const Text('翻牌'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace(PlayingCard card) {
    final isRed = card.suit == '♥' || card.suit == '♦';
    final color = isRed ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 左上角
          Row(
            children: [
              Text(
                card.rank,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                card.suit,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                ),
              ),
            ],
          ),

          // 中间
          Expanded(
            child: Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  fontSize: 64,
                  color: color,
                ),
              ),
            ),
          ),

          // 右下角（旋转180度）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: 3.14159,
                child: Row(
                  children: [
                    Text(
                      card.rank,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      card.suit,
                      style: TextStyle(
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayingCard {
  final String suit;
  final String rank;

  PlayingCard({required this.suit, required this.rank});
}
