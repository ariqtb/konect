import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/forum_topic.dart';
import '../../../data/repositories/forum_repository.dart';

// Events
abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class ForumLoadRequested extends ForumEvent {
  const ForumLoadRequested();
}

class ForumRefreshRequested extends ForumEvent {
  const ForumRefreshRequested();
}

class ForumTopicCreated extends ForumEvent {
  final String title;
  final String content;
  final String authorName;

  const ForumTopicCreated({
    required this.title,
    required this.content,
    required this.authorName,
  });

  @override
  List<Object?> get props => [title, content, authorName];
}

// States
abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumLoading extends ForumState {
  const ForumLoading();
}

class ForumLoaded extends ForumState {
  final List<ForumTopic> topics;

  const ForumLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

class ForumError extends ForumState {
  final String message;

  const ForumError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  ForumBloc() : super(const ForumInitial()) {
    on<ForumLoadRequested>(_onLoad);
    on<ForumRefreshRequested>(_onLoad);
    on<ForumTopicCreated>(_onCreate);
  }

  Future<void> _onLoad(ForumEvent event, Emitter<ForumState> emit) async {
    emit(const ForumLoading());
    try {
      final topics = await forumRepository.getTopics();
      emit(ForumLoaded(topics));
    } catch (e) {
      emit(ForumError(e.toString()));
    }
  }

  Future<void> _onCreate(
    ForumTopicCreated event,
    Emitter<ForumState> emit,
  ) async {
    try {
      await forumRepository.createTopic(
        title: event.title,
        content: event.content,
        authorName: event.authorName,
      );
      final topics = await forumRepository.getTopics();
      emit(ForumLoaded(topics));
    } catch (e) {
      emit(ForumError(e.toString()));
    }
  }
}