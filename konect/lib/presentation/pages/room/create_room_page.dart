import 'package:flutter/material.dart';
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
  final _codeController = TextEditingController();
  final _topicController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  List<CooperativeItem> _coops = [];
  CooperativeItem? _selectedCoop;
  bool _isLoadingCoops = true;
  bool _isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _loadCooperatives();
  }

  Future<void> _loadCooperatives() async {
    try {
      final list = await cooperativeRepository.getCooperatives(limit: 100);
      setState(() {
        _coops = list;
        if (list.isNotEmpty) {
          _selectedCoop = list.first;
        }
        _isLoadingCoops = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingCoops = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _topicController.dispose();
    _descController.dispose();
    super.dispose();
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
              primary: Color(0xFFDC2626), // brandRed
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
                primary: Color(0xFFDC2626), // brandRed
                onPrimary: Colors.white,
                onSurface: Color(0xFF1E293B),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
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
                  dateTime == null
                      ? 'Pilih Waktu'
                      : '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
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
              // Fields Section
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
                      hintText:
                          'Contoh: Pembahasan Distribusi Sembako Tahap II',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Topik rapat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Coop Dropdown
                    const Text(
                      'Penyelenggara',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingCoops
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<CooperativeItem>(
                            value: _selectedCoop,
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              fillColor: const Color(0xFFF8FAFC),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDC2626), width: 2),
                              ),
                            ),
                            items: _coops.map((CooperativeItem coop) {
                              return DropdownMenuItem<CooperativeItem>(
                                value: coop,
                                child: Text(coop.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCoop = val;
                                });
                              }
                            },
                          ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descController,
                      labelText: 'Deskripsi / Detail Bahasan',
                      hintText: 'Tulis pokok bahasan rapat di sini...',
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Waktu Mulai', _startDate, true),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Waktu Selesai', _endDate, false),
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
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
            ),
          ),
          child: CustomButton(
            text: _isCreatingRoom ? 'Memproses...' : 'Mulai Rapat Baru',
            icon: Icons.play_arrow_rounded,
            backgroundColor: const Color(0xFFDC2626),
            onPressed: _isCreatingRoom
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      if (_startDate == null || _endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Silakan pilih waktu mulai dan selesai rapat')),
                        );
                        return;
                      }

                      if (_endDate!.isBefore(_startDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Waktu selesai tidak boleh lebih awal dari waktu mulai')),
                        );
                        return;
                      }

                      if (_selectedCoop == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Silakan pilih koperasi penyelenggara')),
                        );
                        return;
                      }

                      setState(() {
                        _isCreatingRoom = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Memulai rapat baru...')),
                      );

                      final currentUser = await authRepository.getCurrentUser();
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Silakan login kembali')),
                        );
                        setState(() {
                          _isCreatingRoom = false;
                        });
                        return;
                      }

                      final roomId = await roomRepository.createRoom(
                        coopRef: _selectedCoop!.id,
                        title: _topicController.text,
                        description: _descController.text,
                        createdBy: currentUser.id,
                        startDate: _startDate!,
                        endDate: _endDate!,
                      );

                      if (roomId != null) {
                        if (mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppConstants.roomDiscussionRoute,
                            arguments: roomId,
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Gagal membuat room rapat. Silakan coba lagi.')),
                          );
                          setState(() {
                            _isCreatingRoom = false;
                          });
                        }
                      }
                    }
                  },
          ),
        ),
      ),
    );
  }
}
