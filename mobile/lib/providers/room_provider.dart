import 'package:get/get.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

class RoomProvider extends GetxController {
  final api = Get.find<ApiService>();

  final rooms = <RoomModel>[].obs;
  final myRooms = <RoomModel>[].obs;
  final currentRoom = Rx<RoomModel?>(null);
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final totalPages = 1.obs;
  final currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Future<void> fetchRooms({int page = 1, String? category, String? country, String? search}) async {
    try {
      isLoading.value = true;
      final query = <String, String>{
        'page': page.toString(),
        'limit': '20',
      };
      if (category != null && category != 'all') query['category'] = category;
      if (country != null && country != 'all') query['country'] = country;
      if (search != null) query['search'] = search;

      final response = await api.get('rooms', query: query);
      rooms.value = (response['rooms'] as List).map((r) => RoomModel.fromJson(r)).toList();
      totalPages.value = response['pages'] ?? 1;
      currentPage.value = response['page'] ?? 1;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyRooms() async {
    try {
      final response = await api.get('rooms/my');
      myRooms.value = (response as List).map((r) => RoomModel.fromJson(r)).toList();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<RoomModel?> getRoom(String id) async {
    try {
      isLoading.value = true;
      final response = await api.get('rooms/$id');
      final room = RoomModel.fromJson(response);
      currentRoom.value = room;
      return room;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<RoomModel?> createRoom(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await api.post('rooms', body: data);
      final room = RoomModel.fromJson(response);
      rooms.insert(0, room);
      return room;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> joinRoom(String roomId, {String? password}) async {
    try {
      isLoading.value = true;
      await api.post('rooms/$roomId/join', body: password != null ? {'password': password} : {});
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await api.post('rooms/$roomId/leave');
      await fetchMyRooms();
    } catch (e) {
      error.value = e.toString();
    }
  }
}
