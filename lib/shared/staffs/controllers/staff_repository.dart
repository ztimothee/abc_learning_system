import 'package:abc_learning_system/shared/staffs/models/staff_profile_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffRepository {
  final SupabaseClient supabase;

  StaffRepository({required this.supabase});
  
  Future<StaffProfileDTO?> getStaffProfileByUserId(String userId) async {
    final response = await supabase
        .from('staffs')
        .select('''
          staff_id,
          position,
          display_id,
          profiles (
            user_id,
            first_name,
            middle_name,
            last_name,
            date_of_birth,
            gender,
            contact_number,
            address,
            civil_status,
            role
          )
        ''')
        .eq('user_id', userId)
        .single();

    return StaffProfileDTO.fromMap(response);
  }

  Future<StaffProfileDTO?> getStaffProfileByStaffId(String staffId) async {
    final response = await supabase
        .from('staffs')
        .select('''
          staff_id,
          position,
          display_id,
          profiles (
            user_id,
            first_name,
            middle_name,
            last_name,
            date_of_birth,
            gender,
            contact_number,
            address,
            civil_status,
            role
          )
        ''')
        .eq('staff_id', staffId)
        .single();

    return StaffProfileDTO.fromMap(response);
  }

  Future<StaffProfileDTO?> getStaffProfileByDisplayId(String displayId) async {
    final response = await supabase
        .from('staffs')
        .select('''
          staff_id,
          position,
          display_id,
          profiles (
            user_id,
            first_name,
            middle_name,
            last_name,
            date_of_birth,
            gender,
            contact_number,
            address,
            civil_status,
            role
          )
        ''')
        .eq('display_id', displayId)
        .single();

    return StaffProfileDTO.fromMap(response);
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final supabase = Supabase.instance.client;
  return StaffRepository(supabase: supabase);
});

final staffProfileByUserIdProvider = FutureProvider.family<StaffProfileDTO?, String>((ref, userId) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getStaffProfileByUserId(userId);
});

final staffProfileByStaffIdProvider = FutureProvider.family<StaffProfileDTO?, String>((ref, staffId) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getStaffProfileByStaffId(staffId);
});

final staffProfileByDisplayIdProvider = FutureProvider.family<StaffProfileDTO?, String>((ref, displayId) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getStaffProfileByDisplayId(displayId);
});