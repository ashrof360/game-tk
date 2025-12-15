import '../models/category.dart';

final List<Category> categories = [
  Category(
    name: 'Fruits',
    icon: 'assets/icons/fruits.png',
    items: [
      GameItem(
        name: 'Apple',
        image: 'assets/images/apple.png',
        audio: 'assets/audio/apple.mp3',
        description: 'Red, round, sweet',
      ),
      GameItem(
        name: 'Bananas',
        image: 'assets/images/bananas.png',
        audio: 'assets/audio/bananas.mp3',
        description: 'Yellow, curved, sweet',
      ),
      GameItem(
        name: 'Orange',
        image: 'assets/images/orange.png',
        audio: 'assets/audio/orange.mp3',
        description: 'Orange, round, juicy',
      ),
      GameItem(
        name: 'Grapes',
        image: 'assets/images/grapes.png',
        audio: 'assets/audio/grapes.mp3',
        description: 'Purple, small, bunch',
      ),
      GameItem(
        name: 'Blueberry',
        image: 'assets/images/blueberry.png',
        audio: 'assets/audio/blueberry.mp3',
        description: 'Purple, small, bunch',
      ),
      GameItem(
        name: 'Cherries',
        image: 'assets/images/cherries.png',
        audio: 'assets/audio/cherries.mp3',
        description: 'Purple, small, bunch',
      ),
      GameItem(
        name: 'Strawberry',
        image: 'assets/images/strawberry.png',
        audio: 'assets/audio/grapes.mp3',
        description: 'Purple, small, bunch',
      ),
    ],
  ),
  Category(
    name: 'Stationery',
    icon: 'assets/icons/stationery.png',
    items: [
      GameItem(
        name: 'Pencil',
        image: 'assets/images/pencil.png',
        audio: 'assets/audio/pencil.mp3',
        description: 'For writing',
      ),
      GameItem(
        name: 'Book',
        image: 'assets/images/book.png',
        audio: 'assets/audio/book.mp3',
        description: 'For reading',
      ),
      GameItem(
        name: 'Eraser',
        image: 'assets/images/eraser.png',
        audio: 'assets/audio/eraser.mp3',
        description: 'For correcting mistakes',
      ),
      GameItem(
        name: 'Ruler',
        image: 'assets/images/ruler.png',
        audio: 'assets/audio/ruler.mp3',
        description: 'For measuring',
      ),
    ],
  ),
  Category(
    name: 'Transportation',
    icon: 'assets/icons/transportation.png',
    items: [
      GameItem(
        name: 'Car',
        image: 'assets/images/car.png',
        audio: 'assets/audio/car.mp3',
        description: 'Road, engine sound',
      ),
      GameItem(
        name: 'Bus',
        image: 'assets/images/bus.png',
        audio: 'assets/audio/bus.mp3',
        description: 'Road, horn sound',
      ),
      GameItem(
        name: 'Truck',
        image: 'assets/images/truck.png',
        audio: 'assets/audio/truck.mp3',
        description: 'Road, cargo, engine sound',
      ),
      GameItem(
        name: 'Bike',
        image: 'assets/images/bike.png',
        audio: 'assets/audio/bike.mp3',
        description: 'Road, pedals, bell sound',
      ),
    ],
  ),
  Category(
    name: 'Cat',
    // Using the icon file that exists in assets/icons/
    icon: 'assets/icons/cat (1).png',
    items: [
      GameItem(
        name: 'Cat',
        image: 'assets/images/cat.png',
        audio: 'assets/audio/cat.mp3',
        description: 'Meow, house, playful',
      ),
      GameItem(
        name: 'Dog',
        image: 'assets/images/dog.png',
        audio: 'assets/audio/dog.mp3',
        description: 'Woof, house, loyal',
      ),
      GameItem(
        name: 'Bird',
        image: 'assets/images/bird.png',
        audio: 'assets/audio/bird.mp3',
        description: 'Chirp, sky, fly',
      ),
      GameItem(
        name: 'Elephant',
        image: 'assets/images/elephant.png',
        audio: 'assets/audio/elephant.mp3',
        description: 'Big, strong, trunk',
      ),
    ],
  ),
  Category(
    name: 'Kitchen Utensils',
    icon: 'assets/icons/kitchen.png',
    items: [
      GameItem(
        name: 'Plate',
        image: 'assets/images/plate.png',
        audio: 'assets/audio/plate.mp3',
        description: 'For serving food',
      ),
      GameItem(
        name: 'Mug',
        image: 'assets/images/mug.png',
        audio: 'assets/audio/mug.mp3',
        description: 'For drinking',
      ),
      GameItem(
        name: 'Fork',
        image: 'assets/images/fork.png',
        audio: 'assets/audio/fork.mp3',
        description: 'For eating solid food',
      ),
      GameItem(
        name: 'Pot',
        image: 'assets/images/pot.png',
        audio: 'assets/audio/pot.mp3',
        description: 'For cooking',
      ),
    ],
  ),
];
