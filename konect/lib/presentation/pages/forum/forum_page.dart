import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/forum/forum_bloc.dart';
import '../../../data/models/forum_topic.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load once
    context.read<ForumBloc>().add(const ForumLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
      ),
      body: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state is ForumLoading || state is ForumInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ForumError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<ForumBloc>()
                  .add(const ForumLoadRequested()),
            );
          }
          if (state is ForumLoaded) {
            if (state.topics.isEmpty) {
              return const Center(
                child: Text('Belum ada topik. Buat topik pertama!'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ForumBloc>()
                    .add(const ForumRefreshRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.topics.length,
                separatorBuilder: (_, a) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TopicCard(topic: state.topics[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTopicSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Topik Baru'),
      ),
    );
  }

  void _showCreateTopicSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Buat Topik Baru',
                  style: Theme.of(sheetCtx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Judul tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Isi'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Isi tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<ForumBloc>().add(
                            ForumTopicCreated(
                              title: titleCtrl.text,
                              content: contentCtrl.text,
                              authorName: 'Saya',
                            ),
                          );
                      Navigator.pop(sheetCtx);
                    }
                  },
                  child: const Text('Posting'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ForumTopic topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: navigate to topic detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Buka: ${topic.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                topic.preview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    topic.authorName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.commentCount} komentar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}