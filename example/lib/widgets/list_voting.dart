import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart' as strings;

class Voting {
  Voting({
    @required this.title,
    this.number = 0,
    this.onTap,
  }) : assert(strings.isNotEmpty(title));

  final String title;
  final int number;
  final VoidCallback onTap;
}

class ListVotingBar extends StatelessWidget {
  const ListVotingBar({
    Key key,
    this.votings,
    this.selected,
  })  : assert(votings != null && votings.length > 0),
        assert(
            selected == null || (selected >= 0 && selected < votings.length)),
        super(key: key);

  final List<Voting> votings;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 11.5, top: 14.0, right: 9.5, bottom: 14.0),
      decoration: ShapeDecoration(
        color: Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
        ),
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: votings.map((Voting voting) {
          if (selected != null) {
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              int index = votings
                  .indexWhere((Voting element) => identical(element, voting));
              bool isSelected = index == selected;
              List<Widget> backgrounds = <Widget>[];
              if ((voting.number ?? 0) > 0) {
                int total = votings
                    .map((Voting element) => element.number ?? 0)
                    .reduce((int value, int element) => value + element);
                double width = math.max(
                    28.0, voting.number / total * constraints.maxWidth);
                backgrounds.add(Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(0.5),
                  child: Container(
                    width: width,
                    decoration: ShapeDecoration(
                      color: isSelected ? Color(0xFFA2DBFE) : Color(0xFFE7E7E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.5),
                      ),
                    ),
                  ),
                ));
              }
              return Container(
                width: double.infinity,
                height: 28.0,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Color(0xFF3688FF) : Color(0xFFDDDDDD),
                        width: 0.5),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ...backgrounds,
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 14.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            voting.title,
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF3688FF)
                                  : Color(0xFF666666),
                              fontSize: 14.0,
                              height: 1.43,
                            ),
                          ),
                          Text(
                            '${voting.number}',
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF3688FF)
                                  : Color(0xFF666666),
                              fontSize: 14.0,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            });
          }
          return GestureDetector(
            onTap: voting.onTap,
            child: Container(
              alignment: Alignment.center,
              height: 28.0,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              child: Text(
                voting.title,
                style: TextStyle(
                  color: Color(0xFF547FB3),
                  fontSize: 14.0,
                  height: 1.43,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
