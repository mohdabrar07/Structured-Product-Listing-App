class ProductModel {
  final int? id;
  final String? title;
  final double? price;
  final String? description;
  final String? category;
  final String? image;

  ProductModel({
    this.id,
    this.title,
    this.price,
    this.description,
    this.category,
    this.image,
  });

  // ✅ SAFE JSON PARSING
  factory ProductModel.fromJson(Map<String, dynamic>? json) {

    // Prevent null crash
    if (json == null) {
      return ProductModel(
        id: 0,
        title: '',
        price: 0.0,
        description: '',
        category: '',
        image: '',
      );
    }

    return ProductModel(
      // SAFE ID
      id: json['id'] == null
          ? 0
          : int.tryParse(json['id'].toString()) ?? 0,

      // SAFE TITLE
      title: json['title']?.toString() ?? '',

      // SAFE PRICE
      price: json['price'] == null
          ? 0.0
          : double.tryParse(json['price'].toString()) ?? 0.0,

      // SAFE DESCRIPTION
      description: json['description']?.toString() ?? '',

      // SAFE CATEGORY
      category: json['category']?.toString() ?? '',

      // SAFE IMAGE
      image: json['image']?.toString() ?? '',
    );
  }

  // ✅ TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'title': title ?? '',
      'price': price ?? 0.0,
      'description': description ?? '',
      'category': category ?? '',
      'image': image ?? '',
    };
  }
}