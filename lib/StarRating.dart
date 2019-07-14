import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final String baseIconString;
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  //Image.asset(widget.imageUrl, scale: 1.2),

  StarRating({this.baseIconString, this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color});

  Widget buildStar(BuildContext context, int index) {
    String iconString;
    if (index >= rating) {
      iconString = this.baseIconString;
    }

    else if (index > rating - 1 && index < rating) {
      var temp = this.baseIconString.split('/');
      iconString = temp[0] + "/half" + temp[1];
    } else {
      var temp = this.baseIconString.split('/');
      iconString = temp[0] + "/full" + temp[1];
    }
    return new InkResponse(
      onTap: onRatingChanged == null ? null : () {
        if(rating == 0.5) {
          onRatingChanged(0);
        }
        else if(index+1 == rating) {
          onRatingChanged(index + 0.5);
        }
        else onRatingChanged(index + 1.0);
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(iconString, scale: 4.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(children: new List.generate(starCount, (index) => buildStar(context, index)));
  }
}