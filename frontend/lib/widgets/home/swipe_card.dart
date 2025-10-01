import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCard extends StatefulWidget {
  final List<String> items;
  final VoidCallback onStackFinishedCallback;
  final void Function(int remainingCount) onItemChangedCallback;
  final void Function(String itemJson) onLikeAction;

  const SwipeCard({
    super.key, 
    required this.items,
    required this.onStackFinishedCallback,
    required this.onItemChangedCallback,
    required this.onLikeAction,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = <SwipeItem>[];

  @override
  void initState() {
    super.initState();
    _initializeSwipeItems(widget.items);
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  SwipeItem _createSwipeItem(String content) {
    return SwipeItem(
      content: content,
      likeAction: () { widget.onLikeAction(content); },
      nopeAction: () { print("Nope $content"); },
    );
  }

  void _initializeSwipeItems(List<String> items) {
    _swipeItems.clear(); 
    for (var item in items) {
      _swipeItems.add(_createSwipeItem(item));
    }
  }

  Widget _DescriptionText({required String text}) {
   return _ExpandableDescription(text: text);
  }

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          minWidth: vw * 0.9,
          maxWidth: vw * 0.9,
          minHeight: vh * 0.4,
          maxHeight: vh * 0.7,
        ),
        child: SwipeCards(
          matchEngine: _matchEngine,
          itemBuilder: (BuildContext context, int index) {
            String itemJsonString = _swipeItems[index].content as String;
            try {
              final Map<String, dynamic> itemData = jsonDecode(itemJsonString);
              return Card(
                margin: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/login/login_bg_1.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black54, // Medium transparency black
                                Colors.black87, // High transparency black
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.5, 0.75, 1.0], // Control where the gradient starts and ends
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemData['name']?.toString() ?? 'No Name',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                _DescriptionText(text: itemData['description']),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Owner: ${itemData['ownerEmail']?.toString() ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.white54),
                                    ),
                                    Text(
                                      'Rating: ${itemData['ownerRatingScore']?.toString() ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.white54),
                                    ),
                                  ],
                                )
                              ]
                            )
                    


                    
                    // Image(
                    //   image: AssetImage('assets/login/login_bg_1.jpg'),
                    //   fit: BoxFit.fill,
                    // ),
                    // Text(
                    //   itemData['id']?.toString() ?? 'No ID',
                    //   style: TextStyle(fontSize: 24, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['name']?.toString() ?? 'No item name',
                    //   style: TextStyle(fontSize: 24, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['description']?.toString() ?? 'No description',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['ownerEmail']?.toString() ?? 'No owner',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['ownerRating']?.toString() ?? 'No rating',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['createdAt']?.toString() ?? 'No createdAt',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['updatedAt']?.toString() ?? 'No updatedAt',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['ItemCategories']?.toString() ?? 'No categoryies',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                    // Text(
                    //   itemData['ItemPictures']?.toString() ?? 'No pictures',
                    //   style: TextStyle(fontSize: 16, color: Colors.white),
                    // ),
                      ),
                    ),
                  ]
              
                ),
                )
            );
          } catch(e) {
              return Card(
                color: Colors.red,
                child: Center(
                  child: Text('Error parsing item data: $e'),
                ),
              );
            }
          },
          onStackFinished: () {
            widget.onStackFinishedCallback();
          },
          itemChanged: (SwipeItem item, int index) {
            int remainingCount = _swipeItems.length - (index + 1);
            widget.onItemChangedCallback(remainingCount);
          },
          upSwipeAllowed: false,
          fillSpace: true,
        ),
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => __ExpandableDescriptionState();
}

class __ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  final int _maxLines = 3;
  final int _maxCharacters = 150;

  @override
  Widget build(BuildContext context) {
    final bool isTooLong = widget.text.length > _maxCharacters ||
                          (widget.text.split('\n').length > _maxLines && !widget.text.contains(RegExp(r'\n{2,}')));
    
    int? lines = _isExpanded ? null : _maxLines;
    TextOverflow? overflow = _isExpanded ? null : TextOverflow.ellipsis;

    String displayText = widget.text;
    if (!_isExpanded && isTooLong) {
      if (widget.text.length > _maxCharacters) {
        // Truncate by character limit
        displayText = widget.text.substring(0, _maxCharacters) + '... (tap to read more)';
      } else {
        // Truncate by lines
        displayText = widget.text;
      }
    }

    return GestureDetector(
      // Only allow tapping if the text is long enough to expand
      onTap: isTooLong
          ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          : null,
      child: Container(
        // The expanded text should be scrollable within the card's maximum height
        // We use SingleChildScrollView here, which works well inside the Positioned widget.
        child: SingleChildScrollView(
          physics: _isExpanded ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
          // When expanded, the column's height will be constrained by the parent card's height, 
          // making the SingleChildScrollView effective.
          child: Text(
            displayText,
            maxLines: lines,
            overflow: overflow,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}