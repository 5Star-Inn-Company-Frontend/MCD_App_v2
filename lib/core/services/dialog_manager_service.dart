import 'dart:async';
import 'package:get/get.dart';
import 'dart:developer' as dev;

enum DialogPriority {
  marketing, // priority 0, first
  news,      // priority 1, second
  clipboard  // priority 2, third
}

class DialogRequest {
  final DialogPriority priority;
  
  // the function that shows the dialog which must return a Future that completes when the dialog is dismissed
  final Future<void> Function() showDialog;

  DialogRequest({required this.priority, required this.showDialog});
}

class DialogManagerService extends GetxService {
  static DialogManagerService get to => Get.find();

  final List<DialogRequest> _queue = [];
  bool _isShowingDialog = false;

  void addDialog(DialogRequest request) {
    dev.log('Added dialog with priority ${request.priority.name}', name: 'DialogManager');
    _queue.add(request);
    // sort so that the lowest index that is the highest priority comes first
    _queue.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isShowingDialog || _queue.isEmpty) {
      return;
    }

    _isShowingDialog = true;
    final nextRequest = _queue.removeAt(0);
    
    dev.log('Showing dialog with priority ${nextRequest.priority.name}', name: 'DialogManager');

    try {
      await nextRequest.showDialog();
    } catch (e) {
      dev.log('Error showing dialog: $e', name: 'DialogManager');
    } finally {
      _isShowingDialog = false;
      dev.log('Dialog dismissed, checking queue...', name: 'DialogManager');
      _processQueue();
    }
  }
}
