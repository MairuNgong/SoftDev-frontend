import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCard extends StatefulWidget {
  final List<String> items;
  const SwipeCard({super.key, required this.items});

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = <SwipeItem>[];

  @override
  void initState() {
    super.initState();
    // Ex data
    for (var name in widget.items) {
      _swipeItems.add(SwipeItem(
        content: name,
        likeAction: () {
          print("Liked $name");
        },
        nopeAction: () {
          print("Nope $name");
        },
      ));
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          minWidth: vw * 0.6,
          maxWidth: vw * 0.9,
          minHeight: vh * 0.4,
          maxHeight: vh * 0.7,
        ),
        child: SwipeCards(
          matchEngine: _matchEngine,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  _swipeItems[index].content,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            );
          },
          onStackFinished: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No more cards")),
            );
          },
          itemChanged: (SwipeItem item, int index) {
            Text("Item changed to ${item.content}");
          },
          upSwipeAllowed: false,
          fillSpace: true,
        ),
      ),
    );
  }
}