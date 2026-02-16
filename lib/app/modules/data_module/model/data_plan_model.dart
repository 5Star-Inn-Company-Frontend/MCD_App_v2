class DataPlanModel {
  final String name;
  final String coded;
  final String price;
  final String network;
  final String category;
  final int id;
  final String? operatorId;

  DataPlanModel({
    required this.name,
    required this.coded,
    required this.price,
    required this.network,
    required this.category,
    required this.id,
    this.operatorId,});

  factory DataPlanModel.fromJson(Map<String, dynamic> json) {
    return DataPlanModel(
      name: json['name'] ?? '',
      coded: json['coded'] ?? '',
      price: json['price']?.toString() ?? '0',
      network: json['network'] ?? '',
      category: json['category'] ?? 'Unknown',
      id: json['id'] ?? 0,
      operatorId: json['operatorId'] ?? '',
    );
  }
}