class Product {
  final int id;
  final String name;
  final int price;
  final String img;
  final String des;
  final String catId;
  final String catName;
  final double rating;
  final int sold;
  final int reviews;
  String? element; // Thêm trường element (có thể null)

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.img,
    required this.des,
    required this.catId,
    required this.catName,
    required this.rating,
    required this.sold,
    required this.reviews,
    this.element, // element là tùy chọn
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      img: json['img'],
      des: json['des'],
      catId: json['catId'].toString(),
      catName: json['catName'],
      rating: json['rating'].toDouble(),
      sold: json['sold'],
      reviews: json['reviews'],
      element: json['element'], // Lấy giá trị element từ JSON (nếu có)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'img': img,
      'des': des,
      'catId': catId,
      'catName': catName,
      'rating': rating,
      'sold': sold,
      'reviews': reviews,
      'element': element,
    };
  }
}
