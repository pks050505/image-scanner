class DishEntity {
  final String name;
  final List<String> ingredients;
  final bool isVeg;
  // add more fields later: allergens, calories, etc.

  DishEntity({
    required this.name,
    required this.ingredients,
    required this.isVeg,
  });


  factory DishEntity.fromMap(Map<String, dynamic> map) {
    return DishEntity(
      name: map['name'] ?? 'Unknown',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      isVeg: map['is_veg'] ?? true,
    );
  }
}
