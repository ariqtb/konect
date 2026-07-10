import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/cooperative.dart';
import '../../../data/repositories/cooperative_repository.dart';

// Events
abstract class CooperativeEvent extends Equatable {
  const CooperativeEvent();

  @override
  List<Object?> get props => [];
}

class CooperativeLoadRequested extends CooperativeEvent {
  const CooperativeLoadRequested();
}

class CooperativeLoadMoreRequested extends CooperativeEvent {
  const CooperativeLoadMoreRequested();
}

class CooperativeFilterChanged extends CooperativeEvent {
  final String category;

  const CooperativeFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class CooperativeSearchQueryChanged extends CooperativeEvent {
  final String query;

  const CooperativeSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class CooperativeState extends Equatable {
  const CooperativeState();

  @override
  List<Object?> get props => [];
}

class CooperativeInitial extends CooperativeState {
  const CooperativeInitial();
}

class CooperativeLoading extends CooperativeState {
  const CooperativeLoading();
}

class CooperativeLoaded extends CooperativeState {
  final List<CooperativeItem> allCooperatives;
  final List<CooperativeItem> filteredCooperatives;
  final String selectedCategory; // 'Semua', 'Sembako', 'Simpan Pinjam', 'Pertanian'
  final String searchQuery;
  final int page;
  final bool hasReachedMax;

  const CooperativeLoaded({
    required this.allCooperatives,
    required this.filteredCooperatives,
    required this.selectedCategory,
    required this.searchQuery,
    this.page = 0,
    this.hasReachedMax = false,
  });

  CooperativeLoaded copyWith({
    List<CooperativeItem>? allCooperatives,
    List<CooperativeItem>? filteredCooperatives,
    String? selectedCategory,
    String? searchQuery,
    int? page,
    bool? hasReachedMax,
  }) {
    return CooperativeLoaded(
      allCooperatives: allCooperatives ?? this.allCooperatives,
      filteredCooperatives: filteredCooperatives ?? this.filteredCooperatives,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [allCooperatives, filteredCooperatives, selectedCategory, searchQuery, page, hasReachedMax];
}

class CooperativeError extends CooperativeState {
  final String message;

  const CooperativeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CooperativeBloc extends Bloc<CooperativeEvent, CooperativeState> {
  CooperativeBloc() : super(const CooperativeInitial()) {
    on<CooperativeLoadRequested>(_onLoad);
    on<CooperativeLoadMoreRequested>(_onLoadMore);
    on<CooperativeFilterChanged>(_onFilterChanged);
    on<CooperativeSearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onLoad(
    CooperativeLoadRequested event,
    Emitter<CooperativeState> emit,
  ) async {
    emit(const CooperativeLoading());
    try {
      final items = await cooperativeRepository.getCooperatives(page: 0, limit: 10);
      emit(CooperativeLoaded(
        allCooperatives: items,
        filteredCooperatives: items,
        selectedCategory: 'Semua',
        searchQuery: '',
        page: 0,
        hasReachedMax: items.length < 10,
      ));
    } catch (e) {
      emit(CooperativeError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    CooperativeLoadMoreRequested event,
    Emitter<CooperativeState> emit,
  ) async {
    if (state is CooperativeLoaded) {
      final currentState = state as CooperativeLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.page + 1;
        final newItems = await cooperativeRepository.getCooperatives(page: nextPage, limit: 10);
        
        final allItems = List<CooperativeItem>.from(currentState.allCooperatives)..addAll(newItems);
        final filtered = _applyFilterAndSearch(
          allItems,
          currentState.selectedCategory,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(
          allCooperatives: allItems,
          filteredCooperatives: filtered,
          page: nextPage,
          hasReachedMax: newItems.length < 10,
        ));
      } catch (e) {
        emit(CooperativeError(e.toString()));
      }
    }
  }

  void _onFilterChanged(
    CooperativeFilterChanged event,
    Emitter<CooperativeState> emit,
  ) {
    if (state is CooperativeLoaded) {
      final currentState = state as CooperativeLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allCooperatives,
        event.category,
        currentState.searchQuery,
      );
      emit(currentState.copyWith(
        selectedCategory: event.category,
        filteredCooperatives: filtered,
      ));
    }
  }

  void _onSearchQueryChanged(
    CooperativeSearchQueryChanged event,
    Emitter<CooperativeState> emit,
  ) {
    if (state is CooperativeLoaded) {
      final currentState = state as CooperativeLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allCooperatives,
        currentState.selectedCategory,
        event.query,
      );
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredCooperatives: filtered,
      ));
    }
  }

  List<CooperativeItem> _applyFilterAndSearch(
    List<CooperativeItem> list,
    String category,
    String query,
  ) {
    return list.where((item) {
      final matchesCategory = category == 'Semua' || item.category == category;
      final matchesSearch = item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.address.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
