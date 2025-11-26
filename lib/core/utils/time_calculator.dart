import '../models/chat_message.dart';

class TimeCalculator {
  // Average time to look up information and send WhatsApp (in seconds)
  static const double averageLookupTime = 120.0; // 2 minutes
  
  // Switching cost between tasks (in seconds)
  static const double switchingCost = 30.0; // 30 seconds

  /// Calculate time saved based on AI messages
  /// Formula: (AI_messages × lookup_time) + (switches × switching_cost)
  static double calculateTimeSaved(List<ChatMessage> messages) {
    int aiMessageCount = 0;
    int switches = 0;
    
    // Count AI messages and switches (each AI response is a switch)
    for (final message in messages) {
      if (message.message.isAI) {
        aiMessageCount++;
        switches++; // Each AI response represents a switch/task
      }
    }
    
    return (aiMessageCount * averageLookupTime) + (switches * switchingCost);
  }

  /// Calculate time saved for a specific time period
  static double calculateTimeSavedForPeriod(
    List<ChatMessage> messages,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredMessages = messages.where((msg) {
      return msg.time.isAfter(startDate) && msg.time.isBefore(endDate);
    }).toList();
    
    return calculateTimeSaved(filteredMessages);
  }
}

