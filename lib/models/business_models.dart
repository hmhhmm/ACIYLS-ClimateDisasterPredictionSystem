

// B2B Subscription Models
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingCycle; // monthly, yearly
  final List<String> features;
  final int apiCallLimit;
  final bool customAlerts;
  final bool advancedAnalytics;
  final bool prioritySupport;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.features,
    required this.apiCallLimit,
    required this.customAlerts,
    required this.advancedAnalytics,
    required this.prioritySupport,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      billingCycle: json['billingCycle'],
      features: List<String>.from(json['features']),
      apiCallLimit: json['apiCallLimit'],
      customAlerts: json['customAlerts'],
      advancedAnalytics: json['advancedAnalytics'],
      prioritySupport: json['prioritySupport'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'billingCycle': billingCycle,
      'features': features,
      'apiCallLimit': apiCallLimit,
      'customAlerts': customAlerts,
      'advancedAnalytics': advancedAnalytics,
      'prioritySupport': prioritySupport,
    };
  }
}

class B2BClient {
  final String id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final String industry; // insurance, logistics, municipality
  final String subscriptionPlanId;
  final DateTime subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isActive;
  final Map<String, dynamic> customSettings;

  B2BClient({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.industry,
    required this.subscriptionPlanId,
    required this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.isActive,
    required this.customSettings,
  });

  factory B2BClient.fromJson(Map<String, dynamic> json) {
    return B2BClient(
      id: json['id'],
      companyName: json['companyName'],
      contactPerson: json['contactPerson'],
      email: json['email'],
      phone: json['phone'],
      industry: json['industry'],
      subscriptionPlanId: json['subscriptionPlanId'],
      subscriptionStartDate: DateTime.parse(json['subscriptionStartDate']),
      subscriptionEndDate: json['subscriptionEndDate'] != null 
          ? DateTime.parse(json['subscriptionEndDate']) 
          : null,
      isActive: json['isActive'],
      customSettings: json['customSettings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'industry': industry,
      'subscriptionPlanId': subscriptionPlanId,
      'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isActive': isActive,
      'customSettings': customSettings,
    };
  }
}

// CSR Sponsorship Models
class CSRSponsorship {
  final String id;
  final String sponsorName;
  final String sponsorLogo;
  final String sponsorshipType; // water_hub, relief_point, equipment
  final String locationId;
  final String locationName;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final Map<String, dynamic> brandingSettings;
  final List<String> mediaAssets;

  CSRSponsorship({
    required this.id,
    required this.sponsorName,
    required this.sponsorLogo,
    required this.sponsorshipType,
    required this.locationId,
    required this.locationName,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.brandingSettings,
    required this.mediaAssets,
  });

  factory CSRSponsorship.fromJson(Map<String, dynamic> json) {
    return CSRSponsorship(
      id: json['id'],
      sponsorName: json['sponsorName'],
      sponsorLogo: json['sponsorLogo'],
      sponsorshipType: json['sponsorshipType'],
      locationId: json['locationId'],
      locationName: json['locationName'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      brandingSettings: json['brandingSettings'] ?? {},
      mediaAssets: List<String>.from(json['mediaAssets'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsorName': sponsorName,
      'sponsorLogo': sponsorLogo,
      'sponsorshipType': sponsorshipType,
      'locationId': locationId,
      'locationName': locationName,
      'amount': amount,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'brandingSettings': brandingSettings,
      'mediaAssets': mediaAssets,
    };
  }
}

// ROI Analytics Models
class ROIAnalytics {
  final String clientId;
  final DateTime date;
  final double costSavings;
  final double avoidedDamage;
  final int livesSaved;
  final int infrastructureProtected;
  final double publicReach;
  final double csrImpact;
  final Map<String, dynamic> detailedMetrics;

  ROIAnalytics({
    required this.clientId,
    required this.date,
    required this.costSavings,
    required this.avoidedDamage,
    required this.livesSaved,
    required this.infrastructureProtected,
    required this.publicReach,
    required this.csrImpact,
    required this.detailedMetrics,
  });

  factory ROIAnalytics.fromJson(Map<String, dynamic> json) {
    return ROIAnalytics(
      clientId: json['clientId'],
      date: DateTime.parse(json['date']),
      costSavings: json['costSavings'].toDouble(),
      avoidedDamage: json['avoidedDamage'].toDouble(),
      livesSaved: json['livesSaved'],
      infrastructureProtected: json['infrastructureProtected'],
      publicReach: json['publicReach'].toDouble(),
      csrImpact: json['csrImpact'].toDouble(),
      detailedMetrics: json['detailedMetrics'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'date': date.toIso8601String(),
      'costSavings': costSavings,
      'avoidedDamage': avoidedDamage,
      'livesSaved': livesSaved,
      'infrastructureProtected': infrastructureProtected,
      'publicReach': publicReach,
      'csrImpact': csrImpact,
      'detailedMetrics': detailedMetrics,
    };
  }
}

// Data Licensing Models
class DataLicense {
  final String id;
  final String dataType; // climate, infrastructure, usage
  final String licenseType; // research, commercial, government
  final double price;
  final String currency;
  final String description;
  final List<String> includedData;
  final Map<String, dynamic> terms;

  DataLicense({
    required this.id,
    required this.dataType,
    required this.licenseType,
    required this.price,
    required this.currency,
    required this.description,
    required this.includedData,
    required this.terms,
  });

  factory DataLicense.fromJson(Map<String, dynamic> json) {
    return DataLicense(
      id: json['id'],
      dataType: json['dataType'],
      licenseType: json['licenseType'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      description: json['description'],
      includedData: List<String>.from(json['includedData']),
      terms: json['terms'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataType': dataType,
      'licenseType': licenseType,
      'price': price,
      'currency': currency,
      'description': description,
      'includedData': includedData,
      'terms': terms,
    };
  }
}

// Advertising Models
class Advertisement {
  final String id;
  final String advertiserName;
  final String advertiserLogo;
  final String title;
  final String description;
  final String imageUrl;
  final String targetAudience;
  final List<String> targetRegions;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double budget;
  final String currency;
  final Map<String, dynamic> targetingSettings;

  Advertisement({
    required this.id,
    required this.advertiserName,
    required this.advertiserLogo,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAudience,
    required this.targetRegions,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.budget,
    required this.currency,
    required this.targetingSettings,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      advertiserName: json['advertiserName'],
      advertiserLogo: json['advertiserLogo'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      targetAudience: json['targetAudience'],
      targetRegions: List<String>.from(json['targetRegions']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      budget: json['budget'].toDouble(),
      currency: json['currency'],
      targetingSettings: json['targetingSettings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advertiserName': advertiserName,
      'advertiserLogo': advertiserLogo,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'targetAudience': targetAudience,
      'targetRegions': targetRegions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'budget': budget,
      'currency': currency,
      'targetingSettings': targetingSettings,
    };
  }
}

// Revenue Tracking Models
class RevenueMetrics {
  final DateTime date;
  final double subscriptionRevenue;
  final double csrRevenue;
  final double dataLicenseRevenue;
  final double advertisingRevenue;
  final double totalRevenue;
  final Map<String, dynamic> breakdown;

  RevenueMetrics({
    required this.date,
    required this.subscriptionRevenue,
    required this.csrRevenue,
    required this.dataLicenseRevenue,
    required this.advertisingRevenue,
    required this.totalRevenue,
    required this.breakdown,
  });

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) {
    return RevenueMetrics(
      date: DateTime.parse(json['date']),
      subscriptionRevenue: json['subscriptionRevenue'].toDouble(),
      csrRevenue: json['csrRevenue'].toDouble(),
      dataLicenseRevenue: json['dataLicenseRevenue'].toDouble(),
      advertisingRevenue: json['advertisingRevenue'].toDouble(),
      totalRevenue: json['totalRevenue'].toDouble(),
      breakdown: json['breakdown'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'subscriptionRevenue': subscriptionRevenue,
      'csrRevenue': csrRevenue,
      'dataLicenseRevenue': dataLicenseRevenue,
      'advertisingRevenue': advertisingRevenue,
      'totalRevenue': totalRevenue,
      'breakdown': breakdown,
    };
  }
}
