import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/cooperative_detail.dart';
import '../../../data/repositories/cooperative_repository.dart';

// Events
abstract class CooperativeDetailEvent extends Equatable {
  const CooperativeDetailEvent();

  @override
  List<Object?> get props => [];
}

class CooperativeDetailLoadRequested extends CooperativeDetailEvent {
  final String id;

  const CooperativeDetailLoadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CooperativeDetailFilterRooms extends CooperativeDetailEvent {
  final String filter; // 'Semua' | 'Aktif' | 'Selesai'

  const CooperativeDetailFilterRooms(this.filter);

  @override
  List<Object?> get props => [filter];
}

// States
abstract class CooperativeDetailState extends Equatable {
  const CooperativeDetailState();

  @override
  List<Object?> get props => [];
}

class CooperativeDetailInitial extends CooperativeDetailState {
  const CooperativeDetailInitial();
}

class CooperativeDetailLoading extends CooperativeDetailState {
  const CooperativeDetailLoading();
}

class CooperativeDetailLoaded extends CooperativeDetailState {
  final CooperativeDetail details;
  final List<CoopDiscussionRoom> filteredRooms;
  final String selectedFilter;

  const CooperativeDetailLoaded({
    required this.details,
    required this.filteredRooms,
    required this.selectedFilter,
  });

  CooperativeDetailLoaded copyWith({
    CooperativeDetail? details,
    List<CoopDiscussionRoom>? filteredRooms,
    String? selectedFilter,
  }) {
    return CooperativeDetailLoaded(
      details: details ?? this.details,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [details, filteredRooms, selectedFilter];
}

class CooperativeDetailError extends CooperativeDetailState {
  final String message;

  const CooperativeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CooperativeDetailBloc extends Bloc<CooperativeDetailEvent, CooperativeDetailState> {
  CooperativeDetailBloc() : super(const CooperativeDetailInitial()) {
    on<CooperativeDetailLoadRequested>(_onLoad);
    on<CooperativeDetailFilterRooms>(_onFilterRooms);
  }

  Future<void> _onLoad(
    CooperativeDetailLoadRequested event,
    Emitter<CooperativeDetailState> emit,
  ) async {
    emit(const CooperativeDetailLoading());
    try {
      final details = await cooperativeRepository.getCooperativeDetail(event.id);
      emit(CooperativeDetailLoaded(
        details: details,
        filteredRooms: details.rooms,
        selectedFilter: 'Semua',
      ));
    } catch (e) {
      emit(CooperativeDetailError(e.toString()));
    }
  }

  void _onFilterRooms(
    CooperativeDetailFilterRooms event,
    Emitter<CooperativeDetailState> emit,
  ) {
    if (state is CooperativeDetailLoaded) {
      final currentState = state as CooperativeDetailLoaded;
      final rooms = currentState.details.rooms;
      
      final filtered = rooms.where((room) {
        if (event.filter == 'Semua') return true;
        return room.status == event.filter;
      }).toList();
      
      emit(currentState.copyWith(
        filteredRooms: filtered,
        selectedFilter: event.filter,
      ));
    }
  }
}
