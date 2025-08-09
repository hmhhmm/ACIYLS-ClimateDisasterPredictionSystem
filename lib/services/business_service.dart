import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_models.dart';

class BusinessService {
  static const String baseUrl = 'https://api.climateaction.com'; // Replace with your API
  static const String apiKey = 'your_api_key_here'; // Replace with actual API key

  // B2B Subscription Management
  static Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription-plans'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subscription plans');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockSubscriptionPlans();
    }
  }

  static Future<B2BClient> createB2BClient(B2BClient client) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/b2b-clients'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(client.toJson()),
      );

      if (response.statusCode == 201) {
        return B2BClient.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create B2B client');
      }
    } catch (e) {
      // Return mock client for development
      return client;
    }
  }

  static Future<List<B2BClient>> getB2BClients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/b2b-clients'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => B2BClient.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load B2B clients');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockB2BClients();
    }
  }

  // CSR Sponsorship Management
  static Future<List<CSRSponsorship>> getCSRSponsorships() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/csr-sponsorships'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CSRSponsorship.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load CSR sponsorships');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockCSRSponsorships();
    }
  }

  static Future<CSRSponsorship> createCSRSponsorship(CSRSponsorship sponsorship) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/csr-sponsorships'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(sponsorship.toJson()),
      );

      if (response.statusCode == 201) {
        return CSRSponsorship.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create CSR sponsorship');
      }
    } catch (e) {
      // Return mock sponsorship for development
      return sponsorship;
    }
  }

  // ROI Analytics
  static Future<List<ROIAnalytics>> getROIAnalytics(String clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roi-analytics?clientId=$clientId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ROIAnalytics.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ROI analytics');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockROIAnalytics(clientId);
    }
  }

  static Future<ROIAnalytics> generateROIReport(String clientId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roi-analytics/generate'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'clientId': clientId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return ROIAnalytics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to generate ROI report');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockROIAnalytics(clientId).first;
    }
  }

  // Data Licensing
  static Future<List<DataLicense>> getDataLicenses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/data-licenses'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DataLicense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data licenses');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockDataLicenses();
    }
  }

  // Advertising
  static Future<List<Advertisement>> getActiveAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/advertisements/active'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Advertisement.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load advertisements');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockAdvertisements();
    }
  }

  // Revenue Tracking
  static Future<List<RevenueMetrics>> getRevenueMetrics(DateTime startDate, DateTime endDate) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/revenue-metrics?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RevenueMetrics.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load revenue metrics');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockRevenueMetrics(startDate, endDate);
    }
  }

  // Mock Data for Development
  static List<SubscriptionPlan> _getMockSubscriptionPlans() {
    return [
      SubscriptionPlan(
        id: 'basic',
        name: 'Basic Plan',
        description: 'Essential climate monitoring for small organizations',
        price: 99.0,
        currency: 'USD',
        billingCycle: 'monthly',
        features: ['Basic API access', 'Standard alerts', 'Email support'],
        apiCallLimit: 1000,
        customAlerts: false,
        advancedAnalytics: false,
        prioritySupport: false,
      ),
      SubscriptionPlan(
        id: 'professional',
        name: 'Professional Plan',
        description: 'Advanced analytics for growing businesses',
        price: 299.0,
        currency: 'USD',
        billingCycle: 'monthly',
        features: ['Advanced API access', 'Custom alerts', 'Priority support', 'ROI analytics'],
        apiCallLimit: 10000,
        customAlerts: true,
        advancedAnalytics: true,
        prioritySupport: true,
      ),
      SubscriptionPlan(
        id: 'enterprise',
        name: 'Enterprise Plan',
        description: 'Full-featured solution for large organizations',
        price: 999.0,
        currency: 'USD',
        billingCycle: 'monthly',
        features: ['Unlimited API access', 'Custom integrations', 'Dedicated support', 'White-label options'],
        apiCallLimit: -1, // Unlimited
        customAlerts: true,
        advancedAnalytics: true,
        prioritySupport: true,
      ),
    ];
  }

  static List<B2BClient> _getMockB2BClients() {
    return [
      B2BClient(
        id: 'client1',
        companyName: 'Global Insurance Co.',
        contactPerson: 'John Smith',
        email: 'john@globalinsurance.com',
        phone: '+1-555-0123',
        industry: 'insurance',
        subscriptionPlanId: 'enterprise',
        subscriptionStartDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        customSettings: {'riskThreshold': 0.7, 'alertFrequency': 'immediate'},
      ),
      B2BClient(
        id: 'client2',
        companyName: 'City Municipality',
        contactPerson: 'Sarah Johnson',
        email: 'sarah@city.gov',
        phone: '+1-555-0456',
        industry: 'municipality',
        subscriptionPlanId: 'professional',
        subscriptionStartDate: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
        customSettings: {'emergencyContacts': ['emergency@city.gov'], 'responseTime': '15min'},
      ),
    ];
  }

  static List<CSRSponsorship> _getMockCSRSponsorships() {
    return [
      CSRSponsorship(
        id: 'sponsor1',
        sponsorName: 'CleanWater Corp',
        sponsorLogo: 'https://example.com/cleanwater-logo.png',
        sponsorshipType: 'water_hub',
        locationId: 'hub001',
        locationName: 'Downtown Water Hub',
        amount: 50000.0,
        currency: 'USD',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 300)),
        isActive: true,
        brandingSettings: {'logoPlacement': 'prominent', 'colorScheme': 'blue'},
        mediaAssets: ['https://example.com/cleanwater-video.mp4'],
      ),
      CSRSponsorship(
        id: 'sponsor2',
        sponsorName: 'SolarTech Solutions',
        sponsorLogo: 'https://example.com/solartech-logo.png',
        sponsorshipType: 'equipment',
        locationId: 'relief001',
        locationName: 'Emergency Relief Center',
        amount: 25000.0,
        currency: 'USD',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 180)),
        isActive: true,
        brandingSettings: {'logoPlacement': 'standard', 'colorScheme': 'green'},
        mediaAssets: [],
      ),
    ];
  }

  static List<ROIAnalytics> _getMockROIAnalytics(String clientId) {
    return [
      ROIAnalytics(
        clientId: clientId,
        date: DateTime.now(),
        costSavings: 125000.0,
        avoidedDamage: 500000.0,
        livesSaved: 15,
        infrastructureProtected: 8,
        publicReach: 25000.0,
        csrImpact: 0.85,
        detailedMetrics: {
          'responseTimeReduction': '40%',
          'insuranceClaimsReduced': '60%',
          'communitySatisfaction': '92%',
        },
      ),
    ];
  }

  static List<DataLicense> _getMockDataLicenses() {
    return [
      DataLicense(
        id: 'climate_research',
        dataType: 'climate',
        licenseType: 'research',
        price: 5000.0,
        currency: 'USD',
        description: 'Comprehensive climate data for academic research',
        includedData: ['temperature', 'precipitation', 'wind_speed', 'humidity'],
        terms: {'usage': 'academic_only', 'attribution': 'required'},
      ),
      DataLicense(
        id: 'infrastructure_commercial',
        dataType: 'infrastructure',
        licenseType: 'commercial',
        price: 15000.0,
        currency: 'USD',
        description: 'Infrastructure data for commercial applications',
        includedData: ['water_points', 'roads', 'buildings', 'utilities'],
        terms: {'usage': 'commercial', 'redistribution': 'prohibited'},
      ),
    ];
  }

  static List<Advertisement> _getMockAdvertisements() {
    return [
      Advertisement(
        id: 'ad1',
        advertiserName: 'WaterFilter Pro',
        advertiserLogo: 'https://example.com/waterfilter-logo.png',
        title: 'Emergency Water Filtration',
        description: 'Portable water filters for disaster relief',
        imageUrl: 'https://example.com/waterfilter-ad.jpg',
        targetAudience: 'emergency_responders',
        targetRegions: ['US', 'CA'],
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 50)),
        isActive: true,
        budget: 10000.0,
        currency: 'USD',
        targetingSettings: {'emergencyMode': false, 'userType': 'professional'},
      ),
    ];
  }

  static List<RevenueMetrics> _getMockRevenueMetrics(DateTime startDate, DateTime endDate) {
    return [
      RevenueMetrics(
        date: DateTime.now(),
        subscriptionRevenue: 45000.0,
        csrRevenue: 75000.0,
        dataLicenseRevenue: 20000.0,
        advertisingRevenue: 15000.0,
        totalRevenue: 155000.0,
        breakdown: {
          'monthly_recurring': 45000.0,
          'one_time': 110000.0,
        },
      ),
    ];
  }
}
