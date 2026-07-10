import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/voting_item.dart';
import '../../../data/repositories/voting_repository.dart';

// Events
abstract class VotingEvent extends Equatable {
  const VotingEvent();

  @override
  List<Object?> get props => [];
}

class VotingLoadRequested extends VotingEvent {
  const VotingLoadRequested();
}

class VoteCast extends VotingEvent {
  final String id;
  final String reaction; // 'agree' | 'disagree'

  const VoteCast({required this.id, required this.reaction});

  @override
  List<Object?> get props => [id, reaction];
}

// States
abstract class VotingState extends Equatable {
  const VotingState();

  @override
  List<Object?> get props => [];
}

class VotingInitial extends VotingState {
  const VotingInitial();
}

class VotingLoading extends VotingState {
  const VotingLoading();
}

class VotingLoaded extends VotingState {
  final List<VotingItem> items;

  const VotingLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class VotingError extends VotingState {
  final String message;

  const VotingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VotingBloc extends Bloc<VotingEvent, VotingState> {
  VotingBloc() : super(const VotingInitial()) {
    on<VotingLoadRequested>(_onLoad);
    on<VoteCast>(_onVote);
  }

  Future<void> _onLoad(
    VotingLoadRequested event,
    Emitter<VotingState> emit,
  ) async {
    emit(const VotingLoading());
    try {
      final items = await votingRepository.getPolls();
      emit(VotingLoaded(items));
    } catch (e) {
      emit(VotingError(e.toString()));
    }
  }

  Future<void> _onVote(VoteCast event, Emitter<VotingState> emit) async {
    try {
      await votingRepository.castVote(
        id: event.id,
        reaction: event.reaction,
      );
      final items = await votingRepository.getPolls();
      emit(VotingLoaded(items));
    } catch (e) {
      emit(VotingError(e.toString()));
    }
  }
}