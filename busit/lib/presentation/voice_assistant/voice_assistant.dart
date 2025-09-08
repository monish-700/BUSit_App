import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chat_bubble.dart';
import './widgets/language_selector.dart';
import './widgets/quick_action_button.dart';
import './widgets/voice_settings_panel.dart';
import './widgets/voice_wave_animation.dart';

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({Key? key}) : super(key: key);

  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant>
    with TickerProviderStateMixin {
  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isListening = false;
  bool _isProcessing = false;
  String? _recordingPath;

  // Chat data
  final List<Map<String, dynamic>> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  // Settings
  String _selectedLanguage = 'en';
  double _speechRate = 1.0;
  double _pitch = 1.0;
  String _voiceGender = 'female';
  bool _showSettings = false;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Mock conversation data
  final List<Map<String, dynamic>> _mockConversations = [
    {
      "id": 1,
      "message": "When is the next bus to City Center?",
      "isUser": true,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "language": "en"
    },
    {
      "id": 2,
      "message":
          "The next bus to City Center (Route 42) will arrive at Central Station in 8 minutes at 5:53 PM. The bus is currently running on time.",
      "isUser": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "language": "en"
    },
    {
      "id": 3,
      "message": "बस 101 कहाँ है?",
      "isUser": true,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "language": "hi"
    },
    {
      "id": 4,
      "message":
          "बस 101 अभी मॉल रोड पर है और 12 मिनट में आपके स्टेशन पहुंचेगी। यह समय पर चल रही है।",
      "isUser": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "language": "hi"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMockConversations();
    _requestMicrophonePermission();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadMockConversations() {
    setState(() {
      _chatHistory.addAll(_mockConversations);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _requestMicrophonePermission() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Microphone Permission Required',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Please grant microphone permission to use voice features.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startListening() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isListening = true;
        });

        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'recording.m4a',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      _showErrorMessage('Failed to start recording. Please try again.');
    }
  }

  Future<void> _stopListening() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isListening = false;
        _isProcessing = true;
        _recordingPath = path;
      });

      // Simulate voice processing
      await Future.delayed(const Duration(seconds: 2));
      _processVoiceInput();
    } catch (e) {
      setState(() {
        _isListening = false;
        _isProcessing = false;
      });
      _showErrorMessage('Failed to process voice input.');
    }
  }

  void _processVoiceInput() {
    // Mock voice recognition results
    final mockQueries = [
      "Track bus 205",
      "When is next bus to Mall Road?",
      "Buy ticket for Route 15",
      "Show me nearby bus stops",
      "What's the fare to Downtown?",
    ];

    final randomQuery =
        mockQueries[DateTime.now().millisecond % mockQueries.length];

    _addUserMessage(randomQuery);

    // Generate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      _generateAIResponse(randomQuery);
    });

    setState(() {
      _isProcessing = false;
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _chatHistory.add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "message": message,
        "isUser": true,
        "timestamp": DateTime.now(),
        "language": _selectedLanguage,
      });
    });
    _scrollToBottom();
  }

  void _generateAIResponse(String query) {
    String response = _getContextualResponse(query);

    setState(() {
      _chatHistory.add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "message": response,
        "isUser": false,
        "timestamp": DateTime.now(),
        "language": _selectedLanguage,
      });
    });
    _scrollToBottom();
  }

  String _getContextualResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('track') || lowerQuery.contains('bus')) {
      return "Bus 205 is currently at Green Park Station and will reach your location in 7 minutes. It's running 2 minutes behind schedule due to traffic.";
    } else if (lowerQuery.contains('next bus') || lowerQuery.contains('when')) {
      return "The next bus to Mall Road (Route 18) will arrive in 12 minutes at 6:05 PM. There's also Route 25 arriving in 18 minutes.";
    } else if (lowerQuery.contains('buy') || lowerQuery.contains('ticket')) {
      return "I can help you buy a ticket for Route 15. The fare is ₹25. Would you like to proceed with UPI payment or use your wallet?";
    } else if (lowerQuery.contains('nearby') || lowerQuery.contains('stops')) {
      return "I found 3 bus stops near you: Central Station (200m), Mall Junction (350m), and Park Street (450m). Which one would you like directions to?";
    } else if (lowerQuery.contains('fare') || lowerQuery.contains('cost')) {
      return "The fare to Downtown varies by route: Route 12 (₹18), Route 24 (₹22), Route 35 (₹25). Route 12 is the most economical option.";
    } else {
      return "I understand you're asking about bus services. Could you please be more specific? I can help with bus tracking, ticket booking, route information, and fare details.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTextMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      _addUserMessage(message);
      _textController.clear();

      Future.delayed(const Duration(milliseconds: 500), () {
        _generateAIResponse(message);
      });
    }
  }

  void _handleQuickAction(String action) {
    String query = '';
    switch (action) {
      case 'Find Buses':
        query = 'Show me nearby buses';
        break;
      case 'Check ETA':
        query = 'When is the next bus?';
        break;
      case 'Buy Ticket':
        query = 'I want to buy a bus ticket';
        break;
      case 'Track Route':
        query = 'Track my bus route';
        break;
    }

    if (query.isNotEmpty) {
      _addUserMessage(query);
      Future.delayed(const Duration(milliseconds: 500), () {
        _generateAIResponse(query);
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });

    if (_showSettings) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Voice Assistant',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Language Selector
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: LanguageSelector(
                  selectedLanguage: _selectedLanguage,
                  onLanguageChanged: (language) {
                    setState(() {
                      _selectedLanguage = language;
                    });
                  },
                ),
              ),

              // Quick Actions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      QuickActionButton(
                        title: 'Find Buses',
                        iconName: 'directions_bus',
                        onTap: () => _handleQuickAction('Find Buses'),
                      ),
                      SizedBox(width: 2.w),
                      QuickActionButton(
                        title: 'Check ETA',
                        iconName: 'schedule',
                        onTap: () => _handleQuickAction('Check ETA'),
                      ),
                      SizedBox(width: 2.w),
                      QuickActionButton(
                        title: 'Buy Ticket',
                        iconName: 'confirmation_number',
                        onTap: () => _handleQuickAction('Buy Ticket'),
                      ),
                      SizedBox(width: 2.w),
                      QuickActionButton(
                        title: 'Track Route',
                        iconName: 'my_location',
                        onTap: () => _handleQuickAction('Track Route'),
                      ),
                    ],
                  ),
                ),
              ),

              // Chat History
              Expanded(
                child: _chatHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        itemCount: _chatHistory.length,
                        itemBuilder: (context, index) {
                          final chat = _chatHistory[index];
                          return ChatBubble(
                            message: chat['message'],
                            isUser: chat['isUser'],
                            timestamp: chat['timestamp'],
                            language: chat['language'],
                          );
                        },
                      ),
              ),

              // Processing Indicator
              if (_isProcessing)
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Processing your voice...',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Section
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Type your message or use voice...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.w),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            suffixIcon: IconButton(
                              onPressed: _sendTextMessage,
                              icon: CustomIconWidget(
                                iconName: 'send',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 5.w,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      GestureDetector(
                        onTap: _isListening ? _stopListening : _startListening,
                        child: VoiceWaveAnimation(
                          isListening: _isListening,
                          size: 12.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Settings Panel
          if (_showSettings)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: VoiceSettingsPanel(
                  speechRate: _speechRate,
                  pitch: _pitch,
                  voiceGender: _voiceGender,
                  onSpeechRateChanged: (value) {
                    setState(() {
                      _speechRate = value;
                    });
                  },
                  onPitchChanged: (value) {
                    setState(() {
                      _pitch = value;
                    });
                  },
                  onVoiceGenderChanged: (gender) {
                    setState(() {
                      _voiceGender = gender;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'mic',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.3),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'Start a conversation',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap the microphone or type to ask about buses,\nroutes, tickets, and more!',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}