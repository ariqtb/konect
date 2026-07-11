import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/constants.dart';
import '../../../data/repositories/room_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/cooperative_repository.dart';
import '../../../data/models/cooperative.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  List<CooperativeItem> _coops = [];
  CooperativeItem? _selectedCoop;
  bool _isLoadingCoops = true;
  bool _isCreatingRoom = false;

  // Koperasi yang sudah diketahui dari akun karyawan (auto-locked)
  String? _lockedKoperasiRef;
  String? _lockedKoperasiName;

  @override
  void initState() {
    super.initState();
    _loadCooperatives();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCooperatives() async {
    // Cek apakah user yang login sudah punya koperasiRef (karyawan koperasi)
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.koperasiRef != null) {
      final koperasiRef = authState.user.koperasiRef!;

      // Coba cari di daftar koperasi
      try {
        final coopList = await cooperativeRepository.getCooperatives(limit: 100);
        final matched = coopList.where((c) => c.id == koperasiRef).toList();
        if (matched.isNotEmpty) {
          if (mounted) {
            setState(() {
              _lockedKoperasiRef = koperasiRef;
              _lockedKoperasiName = matched.first.name;
              _selectedCoop = matched.first;
              _coops = coopList;
              _isLoadingCoops = false;
            });
          }
          return;
        }
      } catch (_) {}

      // Fallback: ambil langsung dari profil_koperasi
      try {
        final client = sp.Supabase.instance.client;
        final data = await client
            .from('profil_koperasi')
            .select('nama_koperasi')
            .eq('koperasi_ref', koperasiRef)
            .maybeSingle();
        final namaKoperasi = data?['nama_koperasi'] as String? ?? 'Koperasi Terkait';
        if (mounted) {
          setState(() {
            _lockedKoperasiRef = koperasiRef;
            _lockedKoperasiName = namaKoperasi;
            _isLoadingCoops = false;
          });
        }
        return;
      } catch (_) {}
    }

    // Tidak ada koperasi terkunci — load semua untuk dropdown
    try {
      final list = await cooperativeRepository.getCooperatives(limit: 100);
      if (mounted) {
        setState(() {
          _coops = list;
          if (list.isNotEmpty) _selectedCoop = list.first;
          _isLoadingCoops = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCoops = false);
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDC2626),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFDC2626),
                onPrimary: Colors.white,
                onSurface: Color(0xFF1E293B),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDate = newDateTime;
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDateTimePicker(String label, DateTime? dateTime, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(context, isStart),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTime == null ? 'Pilih Waktu' : _formatDateTime(dateTime),
                  style: TextStyle(
                    fontSize: 15,
                    color: dateTime == null
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoopSelector() {
    if (_isLoadingCoops) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
          ),
        ),
      );
    }

    // Jika koperasi sudah terkunci dari akun karyawan — tampil read-only
    if (_lockedKoperasiRef != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _lockedKoperasiName ?? _lockedKoperasiRef!,
                style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      );
    }

    // Dropdown jika koperasi belum terkunci
    return DropdownButtonFormField<CooperativeItem>(
      value: _selectedCoop,
      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
      items: _coops.map((CooperativeItem coop) {
        return DropdownMenuItem<CooperativeItem>(
          value: coop,
          child: Text(coop.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCoop = val);
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih waktu mulai dan selesai rapat')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai tidak boleh lebih awal dari waktu mulai')),
      );
      return;
    }

    // Tentukan koperasi yang dipakai
    final String? finalCoopRef = _lockedKoperasiRef ?? _selectedCoop?.id;
    if (finalCoopRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih koperasi penyelenggara')),
      );
      return;
    }

    setState(() => _isCreatingRoom = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memulai rapat baru...')),
    );

    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login kembali')),
        );
        setState(() => _isCreatingRoom = false);
      }
      return;
    }

    print('[CreateRoom] currentUser.id=${currentUser.id} | role=${currentUser.role}');
    print('[CreateRoom] koperasiRef=$finalCoopRef | karyawanRef=${currentUser.karyawanRef}');

    final roomId = await roomRepository.createRoom(
      coopRef: finalCoopRef,
      title: _topicController.text.trim(),
      description: _descController.text.trim(),
      createdBy: currentUser.id,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    if (!mounted) return;

    if (roomId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppConstants.roomDiscussionRoute,
        arguments: roomId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat room rapat. Silakan coba lagi.')),
      );
      setState(() => _isCreatingRoom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Room Rapat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _topicController,
                      labelText: 'Topik Rapat',
                      hintText: 'Contoh: Pembahasan Distribusi Sembako Tahap II',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Topik rapat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Penyelenggara',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCoopSelector(),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descController,
                      labelText: 'Deskripsi / Detail Bahasan',
                      hintText: 'Tulis pokok bahasan rapat di sini...',
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Waktu Mulai', _startDate, true),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Waktu Selesai', _endDate, false),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: CustomButton(
            text: _isCreatingRoom ? 'Memproses...' : 'Mulai Rapat Baru',
            icon: Icons.play_arrow_rounded,
            backgroundColor: const Color(0xFFDC2626),
            onPressed: _isCreatingRoom ? null : _handleSubmit,
          ),
        ),
      ),
    );
  }
}
