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

    if (lower.contains('hotel') || lower.contains('stay') || lower.contains('accommodation')) {
      return _simulateDelay(
          '🏨 For stays, I recommend checking booking apps. If you are on a budget, hostels offer great value. For groups, Airbnb-style stays work best since you can easily split costs!');
    }
    if (lower.contains('food') || lower.contains('eat') || lower.contains('restaurant')) {
      return _simulateDelay(
          '🍽️ You absolutely must try the local street food! Ask locals for their favorite hidden spots. Group dining is always fun and a great way to try more dishes while sharing the cost.');
    }
    if (lower.contains('budget') || lower.contains('money') || lower.contains('cost') || lower.contains('expensive')) {
      return _simulateDelay(
          '💰 Let\'s talk budget! A smart allocation is 35% for accommodation, 25% for food, 20% for transport, and 20% for activities/emergencies. Always track expenses daily.');
    }
    if (lower.contains('pack') || lower.contains('carry') || lower.contains('luggage') || lower.contains('clothes')) {
      return _simulateDelay(
          '🧳 Packing tip: Pack light! Bring comfortable walking shoes, weather-appropriate layers, basic medications, a power bank, and definitely a reusable water bottle.');
    }
    if (lower.contains('safe') || lower.contains('safety') || lower.contains('danger')) {
      return _simulateDelay(
          '🛡️ Safety first! Always share your live location/itinerary with someone back home, keep digital copies of documents, and stay aware of your surroundings in crowded tourist spots.');
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return _simulateDelay(
          '👋 Hello there! I\'m your AI Travel Assistant. Ask me about destinations, budgets, packing tips, or anything travel-related!');
    }
    if (lower.contains('goa') || lower.contains('beach')) {
      return _simulateDelay(
          '🌴 Goa is fantastic! Make sure to explore both North Goa (for parties and vibrant beaches like Baga) and South Goa (for pristine, quiet beaches like Palolem). Renting a scooter is the best way to get around!');
    }
    if (lower.contains('plan') || lower.contains('itinerary') || lower.contains('trip to')) {
      return _simulateDelay(
          '🗺️ Planning a trip requires a good balance! Don\'t overpack your schedule. I recommend picking 1-2 major activities per day, and leaving the evening open for exploring local culture and food. Where are you thinking of going?');
    }

    // Dynamic Fallback
    final responses = [
      '✨ That sounds exciting! When planning your travels, it\'s great to remain flexible. What specific aspects are you looking for help with? (e.g., Budgeting, Food, Stays?)',
      '🌍 Travel opens up so many possibilities! Whether you\'re looking for adventure or relaxation, I\'m here to help you structure your itinerary. Could you share a bit more detail?',
      '🎒 Got it! A well-planned trip makes all the difference. Make sure to use the "Trip Dashboard" in the app to track your group\'s expenses. What destination is on your mind?',
      '🧭 Interesting! If you want a tailored recommendation, just tell me the destination or the type of vibe you\'re going for (like beaches, mountains, or city life).',
    ];
    
    // Pick a pseudo-random response based on message length so it feels dynamic
    final index = message.length % responses.length;
    return _simulateDelay(responses[index]);
  }
}
