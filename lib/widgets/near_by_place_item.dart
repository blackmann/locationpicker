import 'package:flutter/material.dart';
import 'package:place_picker/entities/entities.dart';

class NearbyPlaceItem extends StatelessWidget {
  final NearbyPlace nearbyPlace;
  final VoidCallback onTap;

  NearbyPlaceItem(this.nearbyPlace, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: <Widget>[
              Image.network(nearbyPlace.icon!, width: 16),
              SizedBox(width: 24),
              Expanded(child: Text("${nearbyPlace.name}", style: TextStyle(fontSize: 16)))
            ],
          ),
        ),
      ),
    );
  }
}
