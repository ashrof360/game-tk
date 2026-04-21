class Category {
  final String name;
  final String nameId;
  final String icon;
  final List<GameItem> items;

  Category({required this.name, required this.nameId, required this.icon, required this.items});
}

class GameItem {
  final String name;
  final String nameId;
  final String image;
  final String audio;
  final String? description; 

  GameItem({
    required this.name,
    required this.nameId,
    required this.image,
    required this.audio,
    this.description,
  });
}
