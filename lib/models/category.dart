class Category {
  final String name;
  final String icon;
  final List<GameItem> items;

  Category({required this.name, required this.icon, required this.items});
}

class GameItem {
  final String name;
  final String image;
  final String audio;
  final String?
  description; // optional for additional info like color, function

  GameItem({
    required this.name,
    required this.image,
    required this.audio,
    this.description,
  });
}
