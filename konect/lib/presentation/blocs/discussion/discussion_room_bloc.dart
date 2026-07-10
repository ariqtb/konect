import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/discussion_room.dart';
import '../../../data/repositories/discussion_room_repository.dart';

// =============================================================
// Events
// =============================================================

abstract class DiscussionRoomEvent extends Equatable {
  const DiscussionRoomEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger saat user submit form "Buat Room".
/// BLoC akan memvalidasi lalu memanggil repository.
class DiscussionRoomCreateRequested extends DiscussionRoomEvent {
  final String cooperativeId;
  final String createdBy;
  final String title;
  final String? description;
  final bool isAnonymous;

  const DiscussionRoomCreateRequested({
    required this.cooperativeId,
    required this.createdBy,
    required this.title,
    this.description,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props =>
      [cooperativeId, createdBy, title, description, isAnonymous];
}

/// Reset state ke Initial (misal saat user keluar dari form).
class DiscussionRoomResetRequested extends DiscussionRoomEvent {
  const DiscussionRoomResetRequested();
}

// =============================================================
// States
// =============================================================

abstract class DiscussionRoomState extends Equatable {
  const DiscussionRoomState();

  @override
  List<Object?> get props => [];
}

class DiscussionRoomInitial extends DiscussionRoomState {
  const DiscussionRoomInitial();
}

/// Sedang proses insert ke DB / simulasi network.
class DiscussionRoomCreating extends DiscussionRoomState {
  const DiscussionRoomCreating();
}

/// Room berhasil dibuat. UI bisa navigasi ke room detail.
class DiscussionRoomCreated extends DiscussionRoomState {
  final DiscussionRoom room;

  const DiscussionRoomCreated(this.room);

  @override
  List<Object?> get props => [room];
}

/// Validasi gagal / network error / exception lain.
class DiscussionRoomError extends DiscussionRoomState {
  final String message;

  const DiscussionRoomError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================
// BLoC
// =============================================================

class DiscussionRoomBloc
    extends Bloc<DiscussionRoomEvent, DiscussionRoomState> {
  DiscussionRoomBloc() : super(const DiscussionRoomInitial()) {
    on<DiscussionRoomCreateRequested>(_onCreate);
    on<DiscussionRoomResetRequested>(_onReset);
  }

  Future<void> _onCreate(
    DiscussionRoomCreateRequested event,
    Emitter<DiscussionRoomState> emit,
  ) async {
    // ---- Validasi input (sesuai constraint schema) ----
    // title: VARCHAR(255) NOT NULL
    if (event.title.trim().isEmpty) {
      emit(const DiscussionRoomError('Judul room tidak boleh kosong'));
      return;
    }
    if (event.title.trim().length > 255) {
      emit(
        const DiscussionRoomError(
          'Judul room maksimal 255 karakter',
        ),
      );
      return;
    }

    // cooperative_id: FK NOT NULL
    if (event.cooperativeId.trim().isEmpty) {
      emit(
        const DiscussionRoomError('Koperasi penyelenggara harus dipilih'),
      );
      return;
    }

    // created_by: FK NOT NULL (dari session user)
    if (event.createdBy.trim().isEmpty) {
      emit(
        const DiscussionRoomError(
          'User tidak terautentikasi. Silakan login ulang.',
        ),
      );
      return;
    }

    emit(const DiscussionRoomCreating());
    try {
      final room = await discussionRoomRepository.createRoom(
        cooperativeId: event.cooperativeId,
        createdBy: event.createdBy,
        title: event.title.trim(),
        description: event.description?.trim().isEmpty == true
            ? null
            : event.description?.trim(),
        isAnonymous: event.isAnonymous,
      );
      emit(DiscussionRoomCreated(room));
    } catch (e) {
      emit(DiscussionRoomError('Gagal membuat room: ${e.toString()}'));
    }
  }

  void _onReset(
    DiscussionRoomResetRequested event,
    Emitter<DiscussionRoomState> emit,
  ) {
    emit(const DiscussionRoomInitial());
  }
}
