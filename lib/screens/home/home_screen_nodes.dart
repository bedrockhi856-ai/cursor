import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/router/app_router.dart';
import '../../data/models/progress_node.dart';
import '../../data/models/player_stats.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/game_provider.dart';

/// Node-based home screen inspired by Duolingo's path system
class HomeScreenNodes extends ConsumerStatefulWidget {
  const HomeScreenNodes({super.key});

  @override
  ConsumerState<HomeScreenNodes> createState() => _HomeScreenNodesState();
}

class _HomeScreenNodesState extends ConsumerState<HomeScreenNodes>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ScrollController _scrollController;
  int _currentSectionIndex = 0;
  // Cached section list so _onScroll can reference it without a rebuild
  List<Section> _activeSections = [];
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Section index is initialised to 0 here; it gets refined as soon as
    // _scrollToActiveNode runs (which has user data).
    _currentSectionIndex = 0;
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Listen to scroll changes to update section card
    _scrollController.addListener(_onScroll);
    
    // Auto-scroll to active node after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveNode();
    });
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;

    // Each node is spaced 120 px apart (plus 100 px top padding).
    final nodeIndex = ((scrollOffset + 60) / 120.0).round();

    // One section = one month = nodesPerSection days
    final maxSection = (_activeSections.length - 1).clamp(0, 99);
    final sectionIndex =
        (nodeIndex ~/ ProgressPathGenerator.nodesPerSection).clamp(0, maxSection);

    if (_currentSectionIndex != sectionIndex) {
      setState(() => _currentSectionIndex = sectionIndex);
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToActiveNode() {
    if (!_scrollController.hasClients) return;

    // Find active node
    final gameState = ref.read(gameStateProvider);
    final user     = ref.read(userProvider);
    final startingMinutes     = user?.startingCommitmentMinutes ?? 20;
    final ultimateGoalMinutes = user?.ultimateGoalMinutes ?? 90;
    final goalSpeedMonths     = user?.goalSpeedMonths ?? 4.0;
    final completedNodes      = gameState.totalSessionsCompleted;

    final nodes = ProgressPathGenerator.generatePath(
      startingMinutes: startingMinutes,
      ultimateGoalMinutes: ultimateGoalMinutes,
      completedNodes: completedNodes,
      goalSpeedMonths: goalSpeedMonths,
    );
    
    final activeNode = nodes.firstWhere(
      (node) => node.status == NodeStatus.active,
      orElse: () => nodes.first,
    );
    
    // Calculate scroll position to place active node in center of viewport
    final totalHeight = nodes.length > 1 
        ? (nodes.length - 1) * 120.0 
        : 120.0;
    final activeNodeY = activeNode.position.dy * totalHeight;
    final viewportHeight = MediaQuery.of(context).size.height;
    
    // Position active node in center of screen for comfortable viewing
    final targetScroll = (activeNodeY - (viewportHeight * 0.4)).clamp(0.0, totalHeight);
    
    // Animate to position
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final streak    = gameState.currentStreak;
    final user      = ref.watch(userProvider);

    // Get onboarding data or use defaults
    final startingMinutes     = user?.startingCommitmentMinutes ?? 20;
    final ultimateGoalMinutes = user?.ultimateGoalMinutes ?? 90;
    final goalSpeedMonths     = user?.goalSpeedMonths ?? 4.0;
    final completedNodes      = gameState.totalSessionsCompleted;

    final nodes = ProgressPathGenerator.generatePath(
      startingMinutes: startingMinutes,
      ultimateGoalMinutes: ultimateGoalMinutes,
      completedNodes: completedNodes,
      goalSpeedMonths: goalSpeedMonths,
    );

    // Cache unique sections for use by _onScroll (preserves insertion order)
    final seenIds = <int>{};
    _activeSections = [
      for (final n in nodes)
        if (seenIds.add(n.section.id)) n.section,
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with stats
            _buildHeader(gameState, streak),

            // Section card (changes with scroll)
            _buildSectionCard(_activeSections),
            
            // Progress path
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Fixed 120px spacing between nodes for even distribution
                  final height = nodes.length > 1 
                      ? (nodes.length - 1) * 120.0 
                      : 120.0;
                  
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Draw section dividers and nodes
                            ...List.generate(nodes.length, (index) {
                              final node = nodes[index];
                              final widgets = <Widget>[];
                              
                              // Add section divider text before the first node of each new section
                              if (index > 0 && index % ProgressPathGenerator.nodesPerSection == 0) {
                                final prevNode = nodes[index - 1];
                                final dividerY = (prevNode.position.dy + node.position.dy) / 2;
                                
                                widgets.add(
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: (dividerY * height) - 15,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            node.section.dividerText,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              // Add node
                              double nodeSize = 80;
                              widgets.add(
                                Positioned(
                                  left: (node.position.dx * width) - (nodeSize / 2),
                                  top: (node.position.dy * height) - (nodeSize / 2),
                                  child: _buildNode(node),
                                ),
                              );
                              
                              return widgets;
                            }).expand((list) => list),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerStats gameState, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Streak
          _buildMiniStat(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            color: const Color(0xFFFF9500),
          ),
          const SizedBox(width: 24),
          // Diamonds
          _buildMiniStat(
            icon: Icons.diamond_rounded,
            value: '${gameState.totalGems}',
            color: const Color(0xFF1CB0F6),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionCard(List<Section> sections) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final safeIndex = _currentSectionIndex.clamp(0, sections.length - 1);
    final section   = sections[safeIndex];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: section.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: section.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'SECTION ${section.id}',
                    key: ValueKey('section-${section.id}'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    section.name,
                    key: ValueKey('name-${section.id}'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNode(ProgressNode node) {
    final isActive = node.status == NodeStatus.active;
    final isCompleted = node.status == NodeStatus.completed;
    final isLocked = node.status == NodeStatus.locked;
    
    // All nodes are the same size
    double nodeSize = 80;
    
    // Use green SVG for completed/active, grey for locked
    final svgAsset = (isCompleted || isActive)
        ? 'assets/illustrations/green.svg'
        : 'assets/illustrations/grey.svg';
    
    Widget nodeContent = _buildRegularNode(node, isActive, isCompleted, isLocked, svgAsset, nodeSize);
    
    final nodeWidget = GestureDetector(
      onTap: isLocked ? null : () => _onNodeTap(node),
      child: nodeContent,
    );
    
    // Add pulse animation to active node
    if (isActive) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: nodeWidget,
      );
    }
    
    return nodeWidget;
  }

  Widget _buildRegularNode(ProgressNode node, bool isActive, bool isCompleted, bool isLocked, String svgAsset, double nodeSize) {
    return Column(
      children: [
        // Node with colored ring for active (using section color)
        Stack(
          alignment: Alignment.center,
          children: [
            // Colored circular ring for active node based on section
            if (isActive)
              Container(
                width: nodeSize + 16,
                height: nodeSize + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: node.section.color.withOpacity(0.3),
                    width: 6,
                  ),
                ),
              ),
            
            // 3D SVG Node
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: node.section.color.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // SVG Icon
                  SvgPicture.asset(
                    svgAsset,
                    width: nodeSize,
                    height: nodeSize,
                  ),
                  
                  // Checkmark for completed
                  if (isCompleted)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF58CC02),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        
        if (!isLocked) ...[
          const SizedBox(height: 8),
          // Duration label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              '${node.durationMinutes} min',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildMilestoneNode(ProgressNode node, bool isActive, bool isCompleted, bool isLocked) {
    final color = isLocked ? const Color(0xFF4B5563) : const Color(0xFF58CC02);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dark ring for active
            if (isActive)
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 6,
                  ),
                ),
              ),
            
            // Sun-burst badge shape
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Badge pattern
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: BadgePainter(color: color.withOpacity(0.5)),
                  ),
                  // Star icon instead of number
                  Icon(
                    Icons.star,
                    size: 60,
                    color: isLocked ? const Color(0xFF6B7280) : Colors.white,
                  ),
                  // Checkmark if completed
                  if (isCompleted)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF58CC02),
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (!isLocked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: const Text(
              'MILESTONE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildChestNode(ProgressNode node, bool isActive, bool isCompleted, bool isLocked) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dark ring for active
            if (isActive)
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 6,
                  ),
                ),
              ),
            
            // Chest illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked ? const Color(0xFF374151) : const Color(0xFF8B4513),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.card_giftcard,
                  size: 50,
                  color: isLocked ? const Color(0xFF6B7280) : const Color(0xFFFFD700),
                ),
              ),
            ),
            
            // Checkmark if completed
            if (isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF58CC02),
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        if (!isLocked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: const Text(
              'BONUS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildCharacterNode(ProgressNode node, bool isActive, bool isCompleted, bool isLocked) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dark ring for active
            if (isActive)
              Container(
                width: 166,
                height: 166,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 6,
                  ),
                ),
              ),
            
            // Character illustration placeholder
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked ? const Color(0xFF374151) : const Color(0xFF58CC02),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  node.emoji,
                  style: const TextStyle(fontSize: 70),
                ),
              ),
            ),
            
            // Checkmark if completed
            if (isCompleted)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF58CC02),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrophyNode(ProgressNode node, bool isActive, bool isCompleted, bool isLocked) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dark ring for active
            if (isActive)
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 6,
                  ),
                ),
              ),
            
            // Trophy
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked ? const Color(0xFF4B5563) : const Color(0xFFFFD700),
                boxShadow: [
                  BoxShadow(
                    color: isLocked 
                        ? Colors.black.withOpacity(0.3)
                        : const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                size: 70,
                color: isLocked ? const Color(0xFF6B7280) : Colors.white,
              ),
            ),
            
            // Checkmark if completed
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF58CC02),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
        if (!isLocked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 2,
              ),
            ),
            child: const Text(
              'ULTIMATE GOAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  void _onNodeTap(ProgressNode node) {
    HapticFeedback.mediumImpact();
    
    if (node.status == NodeStatus.completed) {
      // Show completed dialog or replay option
      _showNodeCompletedDialog(node);
    } else if (node.status == NodeStatus.active) {
      // Start focus session
      context.push('${AppRoutes.focusTimer}?duration=${node.durationMinutes}');
    }
  }
  
  void _showNodeCompletedDialog(ProgressNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(node.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Text(
              'Completed!',
              style: TextStyle(color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Text(
          'You\'ve already completed this ${node.durationMinutes}-minute session.\n\nWant to do it again?',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('${AppRoutes.focusTimer}?duration=${node.durationMinutes}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Again'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing connecting lines between nodes
class PathLinePainter extends CustomPainter {
  final List<ProgressNode> nodes;
  final double width;
  final double height;
  
  PathLinePainter({
    required this.nodes,
    required this.width,
    required this.height,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Duolingo colors
    final completedPaint = Paint()
      ..color = const Color(0xFF58CC02)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final incompletePaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < nodes.length - 1; i++) {
      final currentNode = nodes[i];
      final nextNode = nodes[i + 1];
      
      final start = Offset(
        currentNode.position.dx * width,
        currentNode.position.dy * height,
      );
      
      final end = Offset(
        nextNode.position.dx * width,
        nextNode.position.dy * height,
      );
      
      // Use completed color if current node is completed
      final paint = currentNode.status == NodeStatus.completed
          ? completedPaint
          : incompletePaint;
      
      // Draw curved path
      final path = Path();
      path.moveTo(start.dx, start.dy);
      
      final controlPoint1 = Offset(
        start.dx,
        start.dy - (start.dy - end.dy) / 3,
      );
      
      final controlPoint2 = Offset(
        end.dx,
        end.dy + (start.dy - end.dy) / 3,
      );
      
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(PathLinePainter oldDelegate) => false;
}

/// Custom painter for milestone badge pattern
class BadgePainter extends CustomPainter {
  final Color color;
  
  BadgePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw sun-burst rays
    const rayCount = 12;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 360 / rayCount) * 3.14159 / 180;
      final x1 = center.dx + (radius * 0.7) * cos(angle);
      final y1 = center.dy + (radius * 0.7) * sin(angle);
      final x2 = center.dx + radius * cos(angle);
      final y2 = center.dy + radius * sin(angle);
      
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint..strokeWidth = 3,
      );
    }
  }
  
  @override
  bool shouldRepaint(BadgePainter oldDelegate) => false;
  
  double cos(double radians) {
    // Simple cosine approximation
    while (radians > 6.28318530718) radians -= 6.28318530718;
    while (radians < 0) radians += 6.28318530718;
    
    if (radians < 1.5708) {
      return 1 - (radians * radians) / 2 + (radians * radians * radians * radians) / 24;
    } else if (radians < 3.14159) {
      final x = radians - 1.5708;
      return -(x - (x * x * x) / 6 + (x * x * x * x * x) / 120);
    } else if (radians < 4.71239) {
      final x = radians - 3.14159;
      return -(1 - (x * x) / 2 + (x * x * x * x) / 24);
    } else {
      final x = radians - 4.71239;
      return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
    }
  }
  
  double sin(double radians) {
    return cos(radians - 1.5708);
  }
}
