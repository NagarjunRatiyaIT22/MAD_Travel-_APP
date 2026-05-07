import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _chatCtrl = TextEditingController();
  final _chatMessages = <Map<String, String>>[];
  final _scrollCtrl = ScrollController();
  bool _chatLoading = false;
  String? _suggestion;
  String? _itinerary;
  String? _budgetTip;
  bool _suggLoading = false;
  bool _itinLoading = false;
  bool _budgetLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _chatMessages.add({'role': 'ai', 'text': '👋 Hello! I\'m your AI Travel Assistant. Ask me anything about travel planning, budgets, destinations, or packing tips!'});
  }

  @override
  void dispose() { _tabCtrl.dispose(); _chatCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant'), bottom: TabBar(controller: _tabCtrl, labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12), tabs: const [
        Tab(text: '💬 Chat'), Tab(text: '🗺️ Suggest'), Tab(text: '📋 Itinerary'), Tab(text: '💰 Budget'),
      ])),
      body: TabBarView(controller: _tabCtrl, children: [
        _buildChatTab(isDark),
        _buildSuggestTab(isDark),
        _buildItineraryTab(isDark),
        _buildBudgetTab(isDark),
      ]),
    );
  }

  Widget _buildChatTab(bool isDark) {
    return Column(children: [
      Expanded(child: ListView.builder(controller: _scrollCtrl, padding: const EdgeInsets.all(16), itemCount: _chatMessages.length + (_chatLoading ? 1 : 0), itemBuilder: (_, i) {
        if (i == _chatMessages.length) return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(8), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
        final msg = _chatMessages[i];
        final isUser = msg['role'] == 'user';
        return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(16).copyWith(bottomRight: isUser ? const Radius.circular(4) : null, bottomLeft: !isUser ? const Radius.circular(4) : null),
          ),
          child: Text(msg['text']!, style: GoogleFonts.poppins(fontSize: 13, color: isUser ? Colors.white : null)),
        ));
      })),
      Container(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(children: [
        Expanded(child: TextField(controller: _chatCtrl, decoration: InputDecoration(hintText: 'Ask anything...', contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true), onSubmitted: (_) => _sendChat())),
        const SizedBox(width: 8),
        CircleAvatar(backgroundColor: AppColors.primary, child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sendChat)),
      ])),
    ]);
  }

  Future<void> _sendChat() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() { _chatMessages.add({'role': 'user', 'text': text}); _chatLoading = true; });
    _chatCtrl.clear();
    _scrollToBottom();
    final reply = await AIService.chat(text);
    setState(() { _chatMessages.add({'role': 'ai', 'text': reply}); _chatLoading = false; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _buildSuggestTab(bool isDark) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text('🗺️', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('AI Travel Suggestions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _suggLoading ? null : () async {
        setState(() => _suggLoading = true);
        _suggestion = await AIService.getTravelSuggestions('Goa');
        setState(() => _suggLoading = false);
      }, child: _suggLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Get Suggestions for Goa')),
      if (_suggestion != null) ...[const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)), child: Text(_suggestion!, style: GoogleFonts.poppins(fontSize: 13)))],
    ]));
  }

  Widget _buildItineraryTab(bool isDark) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text('📋', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('AI Itinerary Planner', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _itinLoading ? null : () async {
        setState(() => _itinLoading = true);
        _itinerary = await AIService.getItineraryRecommendation('Manali', 5);
        setState(() => _itinLoading = false);
      }, child: _itinLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Generate 5-Day Manali Plan')),
      if (_itinerary != null) ...[const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)), child: Text(_itinerary!, style: GoogleFonts.poppins(fontSize: 13)))],
    ]));
  }

  Widget _buildBudgetTab(bool isDark) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text('💰', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('AI Budget Advisor', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _budgetLoading ? null : () async {
        setState(() => _budgetLoading = true);
        _budgetTip = await AIService.getBudgetTips(25000, 4);
        setState(() => _budgetLoading = false);
      }, child: _budgetLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Get Budget Tips (₹25K / 4 people)')),
      if (_budgetTip != null) ...[const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)), child: Text(_budgetTip!, style: GoogleFonts.poppins(fontSize: 13)))],
    ]));
  }
}
