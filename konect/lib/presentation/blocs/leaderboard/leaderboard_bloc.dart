import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/leaderboard_user.dart';
import '../../../data/repositories/leaderboard_repository.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LeaderboardLoadRequested extends LeaderboardEvent {
  const LeaderboardLoadRequested();
}

class LeaderboardRedeemRewardRequested extends LeaderboardEvent {
  const LeaderboardRedeemRewardRequested();
}

// States
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardUser> rankings;
  final LeaderboardUser currentUser;
  final int currentPoints;
  final int targetPoints;
  final String rewardTitle;
  final bool isRedeeming;
  final bool? redeemSuccess;

  const LeaderboardLoaded({
    required this.rankings,
    required this.currentUser,
    required this.currentPoints,
    required this.targetPoints,
    required this.rewardTitle,
    this.isRedeeming = false,
    this.redeemSuccess,
  });

  LeaderboardLoaded copyWith({
    List<LeaderboardUser>? rankings,
    LeaderboardUser? currentUser,
    int? currentPoints,
    int? targetPoints,
    String? rewardTitle,
    bool? isRedeeming,
    bool? redeemSuccess,
    bool clearRedeemSuccess = false,
  }) {
    return LeaderboardLoaded(
      rankings: rankings ?? this.rankings,
      currentUser: currentUser ?? this.currentUser,
      currentPoints: currentPoints ?? this.currentPoints,
      targetPoints: targetPoints ?? this.targetPoints,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      redeemSuccess: clearRedeemSuccess ? null : (redeemSuccess ?? this.redeemSuccess),
    );
  }

  @override
  List<Object?> get props => [
        rankings,
        currentUser,
        currentPoints,
        targetPoints,
        rewardTitle,
        isRedeeming,
        redeemSuccess,
      ];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(const LeaderboardInitial()) {
    on<LeaderboardLoadRequested>(_onLoad);
    on<LeaderboardRedeemRewardRequested>(_onRedeem);
  }

  Future<void> _onLoad(
    LeaderboardLoadRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final rankings = await leaderboardRepository.getLeaderboard();
      final currentUser = rankings.firstWhere((u) => u.isCurrentUser);
      emit(LeaderboardLoaded(
        rankings: rankings,
        currentUser: currentUser,
        currentPoints: 8450,
        targetPoints: 10000,
        rewardTitle: 'Voucher Belanja Sembako',
      ));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onRedeem(
    LeaderboardRedeemRewardRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (state is LeaderboardLoaded) {
      final currentState = state as LeaderboardLoaded;
      emit(currentState.copyWith(isRedeeming: true, redeemSuccess: null));
      try {
        final success = await leaderboardRepository.claimReward();
        emit(currentState.copyWith(
          isRedeeming: false,
          redeemSuccess: success,
        ));
      } catch (e) {
        emit(currentState.copyWith(isRedeeming: false, redeemSuccess: false));
      }
    }
  }
}
