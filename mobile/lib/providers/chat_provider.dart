import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class ChatProvider extends GetxController {
  final api = Get.find<ApiService>();

  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final hasMore = true.obs;
  int currentPage = 1;

  Future<void> fetchMessages(String roomId, {bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        messages.clear();
        hasMore.value = true;
      }
      isLoading.value = true;
      final response = await api.get('messages/$roomId', query: {
        'page': currentPage.toString(),
        'limit': '50',
      });
      final newMessages = (response['messages'] as List)
          .map((m) => MessageModel.fromJson(m))
          .toList();
      if (refresh) {
        messages.value = newMessages;
      } else {
        messages.insertAll(0, newMessages);
      }
      hasMore.value = currentPage < (response['pages'] ?? 1);
      currentPage++;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void addMessage(MessageModel message) {
    messages.add(message);
  }

  void removeMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
  }
}
