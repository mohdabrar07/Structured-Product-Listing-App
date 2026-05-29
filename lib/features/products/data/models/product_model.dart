class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // Factory constructor to create a Product object from a JSON Map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      rating: Rating.fromJson(json['rating'] ?? {}),
    );
  }

  // Method to convert a Product instance into a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}