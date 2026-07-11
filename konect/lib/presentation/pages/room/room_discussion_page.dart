import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../widgets/dashed_line.dart';
import '../../../data/repositories/room_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class RoomComment {
  final String id;
  final String content;
  double? coordinateX;
  double? coordinateY;

  RoomComment({
    required this.id,
    required this.content,
    this.coordinateX,
    this.coordinateY,
  });
}

class RoomOpinion {
  final String id;
  final String text;
  int likes;
  final List<RoomComment> comments;
  final double? relevanceScore;
  double? coordinateX;
  double? coordinateY;

  RoomOpinion({
    required this.id,
    required this.text,
    this.likes = 0,
    required this.comments,
    this.relevanceScore,
    this.coordinateX,
    this.coordinateY,
  });
}

class RoomDiscussionPage extends StatefulWidget {
  const RoomDiscussionPage({super.key});

  @override
  State<RoomDiscussionPage> createState() => _RoomDiscussionPageState();
}

class _RoomDiscussionPageState extends State<RoomDiscussionPage>
    with SingleTickerProviderStateMixin {
  // We'll initialize the opinions based on the route argument roomId
  List<RoomOpinion>? _opinions;
  String? _roomId;
  String _topicTitle = 'Memuat...';
  String _topicDescription = '';
  int _participantsCount = 0;
  bool _isLoading = false;
  bool _hasError = false;
  sp.RealtimeChannel? _realtimeChannel;

  final TextEditingController _opinionController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();

  late final AnimationController _flyAnimController;
  Animation<Matrix4>? _flyAnimation;

  // Stores the canvas position to fly to after the next build
  Offset? _pendingSpotlight;

  // The id of the most recently added opinion (for highlight glow)
  String? _newlyAddedId;
  bool _hasCentered = false;

  @override
  void initState() {
    super.initState();
    _flyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flyAnimController.addListener(() {
      if (_flyAnimation != null) {
        _transformationController.value = _flyAnimation!.value;
      }
    });
  }

  @override
  void dispose() {
    _opinionController.dispose();
    _transformationController.dispose();
    _flyAnimController.dispose();
    _unsubscribeRealtime();
    super.dispose();
  }

  void _subscribeToRealtime(String roomId) {
    if (!_isValidUUID(roomId)) return;
    
    final client = sp.Supabase.instance.client;
    _unsubscribeRealtime();

    _realtimeChannel = client.channel('room_canvas_$roomId');
    
    _realtimeChannel!
      .onPostgresChanges(
        event: sp.PostgresChangeEvent.all,
        schema: 'public',
        table: 'opinions',
        callback: (payload) {
          final newRecord = payload.newRecord;
          final oldRecord = payload.oldRecord;
          if ((newRecord != null && newRecord['room_id'] == roomId) ||
              (oldRecord != null && oldRecord['room_id'] == roomId)) {
            _reloadCanvasSilent();
          }
        },
      )
      .onPostgresChanges(
        event: sp.PostgresChangeEvent.all,
        schema: 'public',
        table: 'opinion_comments',
        callback: (payload) {
          _reloadCanvasSilent();
        },
      )
      .onPostgresChanges(
        event: sp.PostgresChangeEvent.all,
        schema: 'public',
        table: 'reactions',
        callback: (payload) {
          _reloadCanvasSilent();
        },
      )
      .subscribe();
  }

  void _unsubscribeRealtime() {
    if (_realtimeChannel != null) {
      try {
        sp.Supabase.instance.client.removeChannel(_realtimeChannel!);
      } catch (_) {}
      _realtimeChannel = null;
    }
  }

  List<RoomOpinion> _mapOpinions(List<dynamic> ops) {
    return ops.map((o) {
      final commentsDyn = o['comments'] as List<dynamic>? ?? [];
      final comments = commentsDyn.map((c) {
        if (c is Map) {
          return RoomComment(
            id: c['id'] ?? '',
            content: c['content'] ?? '',
            coordinateX: c['coordinate_x'] != null ? (c['coordinate_x'] as num).toDouble() : null,
            coordinateY: c['coordinate_y'] != null ? (c['coordinate_y'] as num).toDouble() : null,
          );
        } else {
          return RoomComment(id: '', content: c.toString());
        }
      }).toList();
      return RoomOpinion(
        id: o['id'] ?? '',
        text: o['text'] ?? '',
        likes: o['likes'] ?? 0,
        comments: comments,
        relevanceScore: o['relevance_score'] != null ? (o['relevance_score'] as num).toDouble() : null,
        coordinateX: o['coordinate_x'] != null ? (o['coordinate_x'] as num).toDouble() : null,
        coordinateY: o['coordinate_y'] != null ? (o['coordinate_y'] as num).toDouble() : null,
      );
    }).toList();
  }

  Future<void> _reloadCanvasSilent() async {
    if (_roomId == null) return;
    final data = await roomRepository.getRoomCanvas(_roomId!);
    if (!mounted || data == null) return;

    setState(() {
      _topicTitle = data['title'] ?? 'Tanpa Judul';
      _topicDescription = data['description'] ?? '';
      
      final ops = data['opinions'] as List<dynamic>? ?? [];
      _opinions = _mapOpinions(ops);
      
      _participantsCount = ops.length + 1;
    });
  }

  /// Smoothly animate the canvas to center on [canvasPoint].
  /// [canvasPoint] is in canvas-local coordinates (before any transform).
  void _spotlightPoint(Offset canvasPoint, Size viewportSize) {
    final double targetScale = 1.15;

    // Target: place `canvasPoint` at the center of the viewport
    final double tx = viewportSize.width / 2 - canvasPoint.dx * targetScale;
    final double ty = viewportSize.height / 2 - canvasPoint.dy * targetScale;

    final Matrix4 targetMatrix = Matrix4.translationValues(tx, ty, 0)
      ..multiply(Matrix4.diagonal3Values(targetScale, targetScale, 1));

    final Matrix4 from = _transformationController.value.clone();

    _flyAnimation = Matrix4Tween(begin: from, end: targetMatrix).animate(
      CurvedAnimation(parent: _flyAnimController, curve: Curves.easeInOutCubic),
    );

    _flyAnimController
      ..reset()
      ..forward();
  }

  bool _isValidUUID(String str) {
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(str);
  }

  Future<void> _initializeOpinions(String roomId) async {
    if (_roomId == roomId && _opinions != null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final data = await roomRepository.getRoomCanvas(roomId);
    if (!mounted) return;

    if (data == null) {
      if (!_isValidUUID(roomId)) {
        _roomId = roomId;
        setState(() {
          _isLoading = false;
          _hasError = false;
          _topicTitle = roomId;
          
          if (roomId.contains('Padi') || roomId.contains('Pupuk')) {
            _opinions = [
              RoomOpinion(
                id: '1',
                text: 'Apakah subsidi pupuk bisa dibagikan langsung lewat Koperasi Tani?',
                likes: 14,
                comments: [
                  RoomComment(id: 'c1', content: 'Setuju, biar tidak salah sasaran.'),
                  RoomComment(id: 'c2', content: 'Betul, lewat koperasi lebih transparan.'),
                ],
              ),
              RoomOpinion(
                id: '2',
                text: 'Bibit Padi Q3 sangat tahan hama, sebaiknya segera didistribusikan.',
                likes: 8,
                comments: [
                  RoomComment(id: 'c3', content: 'Bagaimana cara pembagian kuotanya?'),
                ],
              ),
            ];
          } else if (roomId.contains('Jalan') || roomId.contains('Jembatan')) {
            _opinions = [
              RoomOpinion(
                id: '1',
                text: 'Pelebaran jalan di pertigaan pasar sangat mendesak.',
                likes: 12,
                comments: [
                  RoomComment(id: 'c4', content: 'Setuju banget, motor sering numpuk.'),
                  RoomComment(id: 'c5', content: 'Betul, parit sekarang sudah dangkal.'),
                ],
              ),
              RoomOpinion(
                id: '2',
                text: 'Gunakan aspal kualitas premium agar awet.',
                likes: 8,
                comments: [
                  RoomComment(id: 'c6', content: 'Sedang dikaji anggarannya.'),
                ],
              ),
            ];
          } else {
            _opinions = [
              RoomOpinion(
                id: '1',
                text: 'Mari kita mulai pembahasan mengenai topik: $roomId',
                likes: 3,
                comments: [
                  RoomComment(id: 'c7', content: 'Siap mendukung hasil keputusan rapat.'),
                ],
              ),
            ];
          }
          _participantsCount = _opinions!.length + 1;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _opinions = [];
        _topicTitle = 'Ruang tidak ditemukan';
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Ruang tidak ditemukan'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  if (mounted) {
                    Navigator.pop(context); // Go back
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
      return;
    }

    _roomId = data['id']?.toString() ?? roomId;

    setState(() {
      _isLoading = false;
      _topicTitle = data['title'] ?? 'Tanpa Judul';
      _topicDescription = data['description'] ?? '';
      
      final ops = data['opinions'] as List<dynamic>? ?? [];
      _opinions = _mapOpinions(ops);
      
      _participantsCount = ops.length + 1;
    });

    _subscribeToRealtime(_roomId!);

    if (!_hasCentered) {
      _hasCentered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final Size viewport = MediaQuery.of(context).size;
          _spotlightPoint(const Offset(1600.0 / 2, 100.0), viewport);
        }
      });
    }

    // Auto join room in background for history
    try {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null && mounted) {
        await roomRepository.joinRoom(roomId, currentUser.id);
      }
    } catch (_) {}
  }

  Future<void> _addOpinion(String text) async {
    if (text.trim().isEmpty) return;
    final String trimmed = text.trim();

    // Check banned words
    final bool isClean = await roomRepository.moderateComment(trimmed);
    if (!isClean) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendapat Anda mengandung kata terlarang!'),
            backgroundColor: Color(0xFFE14242),
          ),
        );
      }
      return;
    }

    final int newIndex = (_opinions?.length ?? 0);
    const double canvasWidth = 1600.0;
    final bool isLeft = newIndex % 2 == 0;
    const double cardWidth = 260.0;
    
    // Estimate layout positioning using relevance = 0.5 for new opinion
    double relevance = 0.5;
    double centerX = canvasWidth / 2;
    double maxDistX = 100.0;
    double distX = maxDistX * (1.0 - relevance);
    double cardX = isLeft ? centerX - cardWidth - distX : centerX + distX;

    double estimatedY = 220.0;
    for (int i = 0; i < newIndex; i++) {
      final int commentCount = _opinions?[i].comments.length ?? 0;
      estimatedY += 100.0 + commentCount * 65.0 + 70.0;
    }

    if (_roomId != null && _isValidUUID(_roomId!)) {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        final newOpinionId = await roomRepository.addOpinion(
          roomId: _roomId!,
          userId: currentUser.id,
          content: trimmed,
          coordinateX: cardX,
          coordinateY: estimatedY,
        );
        if (newOpinionId != null) {
          _opinionController.clear();
          _newlyAddedId = newOpinionId;
          _opinions = null;
          await _initializeOpinions(_roomId!);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_newlyAddedId != null && _opinions != null && mounted) {
              try {
                final targetOp = _opinions!.firstWhere((o) => o.id == _newlyAddedId);
                if (targetOp.coordinateX != null && targetOp.coordinateY != null) {
                  final Size viewport = MediaQuery.of(context).size;
                  _spotlightPoint(
                    Offset(targetOp.coordinateX! + cardWidth / 2, targetOp.coordinateY! + 60.0),
                    viewport,
                  );
                }
              } catch (_) {}
            }
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _newlyAddedId = null);
          });
          return;
        }
      }
    }

    // Center of the new card
    _pendingSpotlight = Offset(cardX + cardWidth / 2, estimatedY + 60.0);

    final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _opinions?.add(
        RoomOpinion(
          id: newId,
          text: trimmed,
          likes: 0,
          comments: [],
          relevanceScore: 0.5,
          coordinateX: cardX,
          coordinateY: estimatedY,
        ),
      );
      _newlyAddedId = newId;
    });
    _opinionController.clear();

    // Clear the highlight after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _newlyAddedId = null);
    });

    // Fly to the new node after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingSpotlight != null && mounted) {
        final Size viewport = MediaQuery.of(context).size;
        _spotlightPoint(_pendingSpotlight!, viewport);
        _pendingSpotlight = null;
      }
    });
  }

  Future<bool> _addComment(RoomOpinion opinion, String commentText) async {
    if (commentText.trim().isEmpty) return false;
    final String trimmed = commentText.trim();

    // Check banned words
    final bool isClean = await roomRepository.moderateComment(trimmed);
    if (!isClean) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar Anda mengandung kata terlarang!'),
            backgroundColor: Color(0xFFE14242),
          ),
        );
      }
      return false;
    }

    if (_roomId != null && _isValidUUID(_roomId!)) {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        final int commentIndex = opinion.comments.length;
        final bool isLeft = (_opinions?.indexOf(opinion) ?? 0) % 2 == 0;
        
        final double parentX = opinion.coordinateX ?? (isLeft ? 30.0 : (1600.0 - 260.0 - 30.0));
        final double parentY = opinion.coordinateY ?? 220.0;
        final double commentX = isLeft ? parentX + 40.0 : parentX + 20.0;
        final double commentY = parentY + 100.0 + 30.0 + commentIndex * 65.0;

        final success = await roomRepository.addComment(
          opinionId: opinion.id,
          userId: currentUser.id,
          content: trimmed,
          coordinateX: commentX,
          coordinateY: commentY,
        );
        if (success) {
          setState(() {
            opinion.comments.add(RoomComment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: trimmed,
              coordinateX: commentX,
              coordinateY: commentY,
            ));
          });
          _opinions = null;
          await _initializeOpinions(_roomId!);
          return true;
        }
      }
    }

    setState(() {
      opinion.comments.add(RoomComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: trimmed,
      ));
    });
    return true;
  }

  Future<void> _likeOpinion(RoomOpinion opinion) async {
    if (_roomId != null && _isValidUUID(_roomId!)) {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        final success = await roomRepository.toggleReaction(
          targetId: opinion.id,
          userId: currentUser.id,
          targetType: 'opinion',
          reaction: 'like',
        );
        if (success) {
          _opinions = null;
          await _initializeOpinions(_roomId!);
          return;
        }
      }
    }

    setState(() {
      opinion.likes += 1;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String roomId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    _initializeOpinions(roomId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Ruang tidak ditemukan atau ID tidak valid')),
      );
    }

    const double canvasWidth = 1600.0;

    // Coordinate layout math
    double currentY = 220.0; // Y offset starting point
    final List<CanvasConnection> connections = [];
    final List<Widget> positionedWidgets = [];

    // Center Topic coordinates
    const double topicWidth = 340.0;
    final double topicX = (canvasWidth - topicWidth) / 2;
    const double topicY = 20.0;
    const double topicHeight = 150.0;
    final Offset topicBottomCenter =
        Offset(topicX + topicWidth / 2, topicY + topicHeight);

    // Topic Card Widget
    positionedWidgets.add(
      Positioned(
        left: topicX,
        top: topicY,
        width: topicWidth,
        height: topicHeight,
        child: GestureDetector(
          onTap: () => _showTopicDetailModal(context, _topicTitle),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOPIK RAPAT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 10, color: Color(0xFF64748B)),
                          SizedBox(width: 4),
                          Text(
                            'Detail',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _topicTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                  maxLines: _topicDescription.isEmpty ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_topicDescription.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      _topicDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );

    final opinionsList = List<RoomOpinion>.from(_opinions ?? []);
    // Sort descending by relevance score (null relevance defaults to 0.5)
    opinionsList.sort((a, b) => (b.relevanceScore ?? 0.5).compareTo(a.relevanceScore ?? 0.5));

    // Lay out opinions and comments sequentially
    for (int i = 0; i < opinionsList.length; i++) {
      final opinion = opinionsList[i];
      final bool isLeft = i % 2 == 0;
      const double cardWidth = 260.0;
      
      // Calculate horizontal position based on relevance
      // Higher relevance -> closer to center line
      // Lower relevance -> further from center line
      final double relevance = opinion.relevanceScore ?? 0.5;
      final double centerX = canvasWidth / 2;
      final double maxDistX = 100.0;
      final double distX = maxDistX * (1.0 - relevance);
      final double cardX = isLeft ? centerX - cardWidth - distX : centerX + distX;
      final double cardY = currentY;

      opinion.coordinateX = cardX;
      opinion.coordinateY = cardY;

      // Opinion node center top
      final Offset opinionTopCenter = Offset(cardX + cardWidth / 2, cardY);

      // Dashed line from topic to opinion
      connections.add(
          CanvasConnection(start: topicBottomCenter, end: opinionTopCenter));

      // Opinion Card Widget — show a red glow ring if this is the newly added card
      final bool isNew = opinion.id == _newlyAddedId;
      positionedWidgets.add(
        Positioned(
          left: cardX,
          top: cardY,
          width: cardWidth,
          child: GestureDetector(
            onTap: () => _showOpinionDetailModal(context, opinion),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isNew)
                    BoxShadow(
                      color: const Color(0xFFDC2626).withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(
                  color:
                      isNew ? const Color(0xFFDC2626) : const Color(0xFFF1F5F9),
                  width: isNew ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _likeOpinion(opinion),
                        child: Row(
                          children: [
                            const Icon(Icons.thumb_up_outlined,
                                size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              '${opinion.likes}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_down_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      if (opinion.comments.isNotEmpty) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline,
                                  size: 10, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                '${opinion.comments.length}',
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    opinion.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      const double estOpinionHeight = 100.0;
      double commentY = cardY + estOpinionHeight + 30.0;

      // Lay out comments
      for (int j = 0; j < opinion.comments.length; j++) {
        final commentObj = opinion.comments[j];
        final comment = commentObj.content;
        const double commentWidth = 200.0;
        final double commentX = isLeft ? cardX + 40.0 : cardX + 20.0;

        commentObj.coordinateX = commentX;
        commentObj.coordinateY = commentY;

        final Offset lineStart = Offset(
          isLeft ? cardX + 30.0 : cardX + cardWidth - 30.0,
          cardY + estOpinionHeight,
        );
        final Offset lineEnd = Offset(
          isLeft ? commentX : commentX + commentWidth,
          commentY + 25.0,
        );

        connections.add(
            CanvasConnection(start: lineStart, end: lineEnd, isLRoute: true));

        // Comment Card Widget
        positionedWidgets.add(
          Positioned(
            left: commentX,
            top: commentY,
            width: commentWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                comment,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ),
          ),
        );

        commentY += 65.0;
      }

      // Update currentY for next opinion block
      currentY = commentY + 40.0;
    }

    final double totalCanvasHeight = currentY + 120.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Kode Rapat: AKTIF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _topicTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_participantsCount + 42}', // dummy scaling
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Canvas Interactive Area (FigJam Style: Zoomable & Pannable)
          InteractiveViewer(
            transformationController: _transformationController,
            constrained:
                false, // Allows the child to exceed InteractiveViewer's boundaries
            boundaryMargin:
                const EdgeInsets.all(400.0), // Padding margins around canvas
            minScale: 0.5,
            maxScale: 2.0,
            scaleEnabled: true,
            panEnabled: true,
            child: CustomPaint(
              painter: GridBackgroundPainter(),
              child: CustomPaint(
                painter: DashedLinePainter(connections: connections),
                child: SizedBox(
                  width: canvasWidth,
                  height: totalCanvasHeight,
                  child: Stack(
                    children: positionedWidgets,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Input Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _opinionController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Tulis tanggapan atau ide baru...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _addOpinion,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _addOpinion(_opinionController.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOpinionDetailModal(BuildContext context, RoomOpinion opinion) {
    final TextEditingController commentFieldController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Pull Bar Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Opinion Title & Detail Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pendapat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            // Vote counters
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.thumb_up,
                                          size: 12, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${opinion.likes}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.thumb_down,
                                      size: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opinion.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comments Header Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        const Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF94A3B8),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${opinion.comments.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comments List Area
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: opinion.comments.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '-',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  opinion.comments[index].content,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Comment Input Section
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24.0,
                      8.0,
                      24.0,
                      MediaQuery.of(context).viewInsets.bottom + 16.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: commentFieldController,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Tambahkan komentar',
                                  hintStyle:
                                      TextStyle(color: Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final text = commentFieldController.text;
                              if (text.trim().isNotEmpty) {
                                commentFieldController.clear();
                                // Add comment in parent page state
                                final success = await _addComment(opinion, text);
                                if (success) {
                                  // Refresh current modal state
                                  setModalState(() {});
                                }
                                // Also trigger state rebuild on parent canvas page
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTopicDetailModal(BuildContext context, String topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'TOPIK AKTIF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                    _buildModalInfoRow(Icons.storefront_outlined,
                        'Penyelenggara', 'Koperasi Sukatani Mandiri'),
                    const SizedBox(height: 12),
                    _buildModalInfoRow(Icons.access_time, 'Waktu',
                        'Hari ini, 14:00 WIB - Selesai'),
                    const SizedBox(height: 12),
                    _buildModalInfoRow(Icons.description_outlined, 'Deskripsi',
                        'Rapat koordinasi warga desa untuk menampung ide, pendapat, dan usulan pemanfaatan serta peningkatan alokasi ketahanan pangan desa Sukatani.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.5)
      ..strokeWidth = 1.0;

    const double step = 24.0;
    for (double i = 0.0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0.0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) => false;
}
