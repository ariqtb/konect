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
      appBar: AppBar(title: const Text('E-Voting')),
      body: BlocBuilder<VotingBloc, VotingState>(
        builder: (context, state) {
          if (state is VotingLoading || state is VotingInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VotingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
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
              return const Center(child: Text('Belum ada voting yang dibuka.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<VotingBloc>()
                    .add(const VotingLoadRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.items.length,
                separatorBuilder: (_, a) => const SizedBox(height: 8),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.opinion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: agreeRatio,
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.errorContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _VoteButton(
                    label: 'Setuju',
                    icon: Icons.thumb_up_outlined,
                    count: item.agreeCount,
                    isActive: item.userReaction == 'agree',
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
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text('$label · $count'),
          ],
        ),
      ),
    );
  }
}