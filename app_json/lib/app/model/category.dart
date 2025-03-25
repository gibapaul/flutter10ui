class CategoryModel {
  int id;
  String name;
  String description;
  String img;

  CategoryModel({
    this.id = 0, // Giá trị mặc định
    required this.name,
    this.description = '', // Giá trị mặc định
    required this.img,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      img: json['img'] ?? 'default.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'img': img,
    };
  }
}
