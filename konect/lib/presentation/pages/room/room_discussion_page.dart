import 'package:flutter/material.dart';
import '../../widgets/dashed_line.dart';

class RoomOpinion {
  final String id;
  final String text;
  int likes;
  final List<String> comments;

  RoomOpinion({
    required this.id,
    required this.text,
    this.likes = 0,
    required this.comments,
  });
}

class RoomDiscussionPage extends StatefulWidget {
  const RoomDiscussionPage({super.key});

  @override
  State<RoomDiscussionPage> createState() => _RoomDiscussionPageState();
}

class _RoomDiscussionPageState extends State<RoomDiscussionPage> {
  // We'll initialize the opinions based on the route argument topic
  List<RoomOpinion>? _opinions;
  String? _lastTopic;

  final TextEditingController _opinionController = TextEditingController();
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _opinionController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _initializeOpinions(String topic) {
    if (_lastTopic == topic && _opinions != null) return;
    _lastTopic = topic;

    if (topic.contains('Padi') || topic.contains('Pupuk')) {
      _opinions = [
        RoomOpinion(
          id: '1',
          text: 'Apakah subsidi pupuk bisa dibagikan langsung lewat Koperasi Tani?',
          likes: 14,
          comments: [
            'Setuju, biar tidak salah sasaran.',
            'Betul, lewat koperasi lebih transparan.',
          ],
        ),
        RoomOpinion(
          id: '2',
          text: 'Bibit Padi Q3 sangat tahan hama, sebaiknya segera didistribusikan.',
          likes: 8,
          comments: [
            'Bagaimana cara pembagian kuotanya?',
          ],
        ),
        RoomOpinion(
          id: '3',
          text: 'Kita butuh pelatihan cara tanam padi Q3 yang optimal.',
          likes: 5,
          comments: [],
        ),
      ];
    } else if (topic.contains('Jalan') || topic.contains('Jembatan')) {
      _opinions = [
        RoomOpinion(
          id: '1',
          text: 'Pelebaran jalan di pertigaan pasar sangat mendesak.',
          likes: 12,
          comments: [
            'Setuju banget, motor sering numpuk.',
            'Betul, parit sekarang sudah dangkal.',
          ],
        ),
        RoomOpinion(
          id: '2',
          text: 'Gunakan aspal kualitas premium agar awet.',
          likes: 8,
          comments: [
            'Sedang dikaji anggarannya.',
          ],
        ),
        RoomOpinion(
          id: '3',
          text: 'Perbaikan drainase samping jalan prioritas.',
          likes: 5,
          comments: [],
        ),
      ];
    } else {
      // Default / fallback opinions
      _opinions = [
        RoomOpinion(
          id: '1',
          text: 'Mari kita mulai pembahasan mengenai topik: $topic',
          likes: 3,
          comments: [
            'Siap mendukung hasil keputusan rapat.',
          ],
        ),
        RoomOpinion(
          id: '2',
          text: 'Ide awal dan usulan warga bisa ditambahkan di sini.',
          likes: 2,
          comments: [],
        ),
      ];
    }
  }

  void _addOpinion(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _opinions?.add(
        RoomOpinion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text.trim(),
          likes: 0,
          comments: [],
        ),
      );
    });
    _opinionController.clear();
  }

  void _addComment(RoomOpinion opinion, String commentText) {
    if (commentText.trim().isEmpty) return;
    setState(() {
      opinion.comments.add(commentText.trim());
    });
  }

  void _likeOpinion(RoomOpinion opinion) {
    setState(() {
      opinion.likes += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String topic = ModalRoute.of(context)?.settings.arguments as String? ??
        'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik';

    _initializeOpinions(topic);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double canvasWidth = screenWidth.clamp(320.0, 480.0);

    // Coordinate layout math
    double currentY = 180.0; // Y offset starting point
    final List<CanvasConnection> connections = [];
    final List<Widget> positionedWidgets = [];

    // Center Topic coordinates
    const double topicX = 40.0;
    const double topicY = 20.0;
    const double topicWidth = 280.0;
    const double topicHeight = 110.0;
    const Offset topicBottomCenter = Offset(topicX + topicWidth / 2, topicY + topicHeight);

    // Topic Card Widget
    positionedWidgets.add(
      Positioned(
        left: topicX,
        top: topicY,
        width: topicWidth,
        height: topicHeight,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Topik Rapat',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Color(0xFFE21E49),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                topic,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    final opinionsList = _opinions ?? [];

    // Lay out opinions and comments sequentially
    for (int i = 0; i < opinionsList.length; i++) {
      final opinion = opinionsList[i];
      final bool isLeft = i % 2 == 0;
      const double cardWidth = 260.0;
      final double cardX = isLeft ? 16.0 : (canvasWidth - cardWidth - 16.0);
      final double cardY = currentY;

      // Opinion node center top
      final Offset opinionTopCenter = Offset(cardX + cardWidth / 2, cardY);
      
      // Dashed line from topic to opinion
      connections.add(CanvasConnection(start: topicBottomCenter, end: opinionTopCenter));

      // Opinion Card Widget
      positionedWidgets.add(
        Positioned(
          left: cardX,
          top: cardY,
          width: cardWidth,
          child: GestureDetector(
            onTap: () => _showOpinionDetailModal(context, opinion),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
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
                            const Icon(Icons.thumb_up_outlined, size: 14, color: Color(0xFF94A3B8)),
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
                      const Icon(Icons.thumb_down_outlined, size: 14, color: Color(0xFF94A3B8)),
                      if (opinion.comments.isNotEmpty) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 10, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                '${opinion.comments.length}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
        final comment = opinion.comments[j];
        const double commentWidth = 200.0;
        final double commentX = isLeft ? cardX + 40.0 : cardX + 20.0;

        final Offset lineStart = Offset(
          isLeft ? cardX + 30.0 : cardX + cardWidth - 30.0,
          cardY + estOpinionHeight,
        );
        final Offset lineEnd = Offset(
          isLeft ? commentX : commentX + commentWidth,
          commentY + 25.0,
        );

        connections.add(CanvasConnection(start: lineStart, end: lineEnd, isLRoute: true));

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
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
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
                    topic,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        '${42 + opinionsList.length}',
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
            constrained: false, // Allows the child to exceed InteractiveViewer's boundaries
            boundaryMargin: const EdgeInsets.all(400.0), // Padding margins around canvas
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
                        color: Color(0xFFE21E49),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
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
    final TextEditingController commentFieldController = TextEditingController();

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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.thumb_up, size: 12, color: Color(0xFF64748B)),
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
                                  child: const Icon(Icons.thumb_down, size: 12, color: Color(0xFF64748B)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                  opinion.comments[index],
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: commentFieldController,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Tambahkan komentar',
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
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
                            onTap: () {
                              final text = commentFieldController.text;
                              if (text.trim().isNotEmpty) {
                                // Add comment in parent page state
                                _addComment(opinion, text);
                                // Refresh current modal state
                                setModalState(() {
                                  commentFieldController.clear();
                                });
                                // Also trigger state rebuild on parent canvas page
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE21E49),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
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
