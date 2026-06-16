/// Represents a shop in the StoreMate system.
class ShopModel {
  final String id;
  final String shopCode;
  final String name;
  final String ownerName;
  final String? mobileNumber;
  final String? email;
  final String? address;
  final String businessType;
  final String? logoUrl;
  final String? gstNumber;
  final String invoicePrefix;
  final String? subscriptionStatus;
  final DateTime? createdAt;

  const ShopModel({
    required this.id,
    required this.shopCode,
    required this.name,
    required this.ownerName,
    this.mobileNumber,
    this.email,
    this.address,
    required this.businessType,
    this.logoUrl,
    this.gstNumber,
    this.invoicePrefix = 'INV',
    this.subscriptionStatus,
    this.createdAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      shopCode: json['shopCode'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String,
      mobileNumber: json['mobileNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      businessType: json['businessType'] as String,
      logoUrl: json['logoUrl'] as String?,
      gstNumber: json['gstNumber'] as String?,
      invoicePrefix: json['invoicePrefix'] as String? ?? 'INV',
      subscriptionStatus: json['subscriptionStatus'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopCode': shopCode,
      'name': name,
      'ownerName': ownerName,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
      'businessType': businessType,
      'logoUrl': logoUrl,
      'gstNumber': gstNumber,
      'invoicePrefix': invoicePrefix,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
