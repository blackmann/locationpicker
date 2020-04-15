class AddressComponent {
  String name;
  String shortName;

  AddressComponent(this.name, this.shortName);

  static AddressComponent fromJson(dynamic json) {
    return AddressComponent(json['long_name'], json['short_name']);
  }
}
