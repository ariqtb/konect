import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/voting/voting_bloc.dart';
import '../../../data/models/voting_item.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  @override
  void initState() {
    super.initState();
    context.read<VotingBloc>().add(const VotingLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'E-Voting',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: BlocBuilder<VotingBloc, VotingState>(
        builder: (context, state) {
          if (state is VotingLoading || state is VotingInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE21E49)));
          }
          if (state is VotingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFFE21E49),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE21E49),
                      side: const BorderSide(color: Color(0xFFE21E49)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => context
                        .read<VotingBloc>()
                        .add(const VotingLoadRequested()),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is VotingLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.how_to_vote_outlined,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada voting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Voting yang dibuka akan tampil di sini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: const Color(0xFFE21E49),
              onRefresh: () async {
                context
                    .read<VotingBloc>()
                    .add(const VotingLoadRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, a) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VotingCard(item: state.items[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VotingCard extends StatelessWidget {
  final VotingItem item;

  const _VotingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final total = item.agreeCount + item.disagreeCount;
    final agreeRatio =
        total == 0 ? 0.0 : item.agreeCount / total.toDouble();
    final agreePercent = (agreeRatio * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.opinion,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            // Progress bar with percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: agreeRatio,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE21E49),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$agreePercent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _VoteButton(
                    label: 'Setuju',
                    icon: Icons.thumb_up_outlined,
                    count: item.agreeCount,
                    isActive: item.userReaction == 'agree',
                    activeColor: const Color(0xFFE21E49),
                    onTap: () => context.read<VotingBloc>().add(
                          VoteCast(id: item.id, reaction: 'agree'),
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VoteButton(
                    label: 'Tidak Setuju',
                    icon: Icons.thumb_down_outlined,
                    count: item.disagreeCount,
                    isActive: item.userReaction == 'disagree',
                    activeColor: const Color(0xFF64748B),
                    onTap: () => context.read<VotingBloc>().add(
                          VoteCast(id: item.id, reaction: 'disagree'),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.3) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeColor : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              '$label · $count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}