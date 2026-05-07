import 'dart:async';

/// AI service that generates local dummy AI responses.
/// No real API is used — all responses are generated locally.
class AIService {
  AIService._();

  /// Simulate AI delay for realistic feel.
  static Future<String> _simulateDelay(String response) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return response;
  }

  /// Get travel suggestions for a destination.
  static Future<String> getTravelSuggestions(String destination) async {
    return _simulateDelay('''
🌟 **Top Suggestions for $destination**

📍 **Must-Visit Places:**
• Visit the most popular tourist spots and hidden gems
• Explore local markets and cultural landmarks
• Check out scenic viewpoints for amazing photos

🍽️ **Food Recommendations:**
• Try the famous local cuisine and street food
• Visit highly-rated restaurants for authentic taste
• Don't miss the regional specialty dishes

🏨 **Stay Options:**
• Budget hostels starting from ₹500/night
• Mid-range hotels around ₹2000-4000/night
• Premium resorts for luxury experience

💡 **Pro Tips:**
• Best time to visit: October to March
• Book accommodations 2-3 weeks in advance
• Carry cash as some places don't accept cards
• Download offline maps before traveling
''');
  }

  /// Get AI itinerary recommendations.
  static Future<String> getItineraryRecommendation(
      String destination, int days) async {
    final buffer = StringBuffer();
    buffer.writeln('📋 **Suggested $days-Day Itinerary for $destination**\n');
    for (int i = 1; i <= days; i++) {
      buffer.writeln('**Day $i:**');
      buffer.writeln('🌅 Morning: Explore local attractions & breakfast');
      buffer.writeln('☀️ Afternoon: Activities & sightseeing');
      buffer.writeln('🌙 Evening: Leisure, dinner & local experience\n');
    }
    buffer.writeln('💡 *Tip: Keep Day 1 light for travel recovery!*');
    return _simulateDelay(buffer.toString());
  }

  /// Get budget tips.
  static Future<String> getBudgetTips(double budget, int people) async {
    final perPerson = budget / people;
    return _simulateDelay('''
💰 **Budget Analysis**

📊 **Total Budget:** ₹${budget.toStringAsFixed(0)}
👥 **Per Person:** ₹${perPerson.toStringAsFixed(0)}

📋 **Suggested Allocation:**
• 🏨 Accommodation: ${(budget * 0.35).toStringAsFixed(0)} (35%)
• 🍔 Food: ${(budget * 0.25).toStringAsFixed(0)} (25%)
• ✈️ Transport: ${(budget * 0.20).toStringAsFixed(0)} (20%)
• 🎯 Activities: ${(budget * 0.15).toStringAsFixed(0)} (15%)
• 📦 Miscellaneous: ${(budget * 0.05).toStringAsFixed(0)} (5%)

💡 **Money-Saving Tips:**
• Book transportation in advance for discounts
• Eat at local restaurants instead of tourist spots
• Use group discounts for activities
• Share accommodation costs
''');
  }

  /// Chat with AI assistant.
  static Future<String> chat(String message) async {
    final lower = message.toLowerCase();

    if (lower.contains('hotel') || lower.contains('stay')) {
      return _simulateDelay(
          '🏨 I recommend looking for stays on booking apps. For budget trips, hostels offer great value. For groups, Airbnb-style stays work best as you can split costs!');
    }
    if (lower.contains('food') || lower.contains('eat') || lower.contains('restaurant')) {
      return _simulateDelay(
          '🍽️ Try the local street food for an authentic experience! Ask locals for their favorite spots. Group dining is always more fun and cost-effective.');
    }
    if (lower.contains('budget') || lower.contains('money') || lower.contains('cost')) {
      return _simulateDelay(
          '💰 Great question! I suggest allocating 35% for accommodation, 25% for food, 20% for transport, and keeping 20% for activities and emergencies.');
    }
    if (lower.contains('pack') || lower.contains('carry') || lower.contains('luggage')) {
      return _simulateDelay(
          '🧳 Pack light! Essentials: comfortable shoes, weather-appropriate clothes, medications, charger, power bank, and a reusable water bottle.');
    }
    if (lower.contains('safe') || lower.contains('safety')) {
      return _simulateDelay(
          '🛡️ Always share your itinerary with someone, keep copies of documents, use registered transport, and stay aware of your surroundings.');
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return _simulateDelay(
          '👋 Hello! I\'m your AI Travel Assistant. Ask me about destinations, budgets, packing tips, or anything travel-related!');
    }

    return _simulateDelay(
        '✨ That\'s a great question! For the best travel experience, I recommend planning ahead, setting a clear budget, and being flexible with your itinerary. Would you like specific tips on destinations, budget, or activities?');
  }
}
