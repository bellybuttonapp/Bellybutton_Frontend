import 'dart:io';
import 'dart:isolate';
import 'package:photo_manager/photo_manager.dart';

/// ======================================================================
/// This function runs in a SEPARATE ISOLATE (background thread)
/// It receives a SendPort, waits for a list of asset IDs,
/// converts those assets into real File objects,
/// and sends them back to the main isolate.
/// ======================================================================
@pragma('vm:entry-point') // ⚠ required so Flutter doesn't remove it in release
void assetConvertIsolate(SendPort p) async {
  // Create a listener port for this isolate
  final port = ReceivePort();

  // Send back this isolate's listener port to MAIN isolate
  p.send(port.sendPort);

  // Listen forever for messages from main isolate
  await for (final msg in port) {
    // msg[0] = list of asset IDs
    final List<String> ids = msg[0];

    // msg[1] = response channel back to main isolate
    final SendPort reply = msg[1];

    // Will hold converted files
    final files = <File>[];

    // Loop each asset ID and get real file
    for (final id in ids) {
      // Convert ID → AssetEntity
      final entity = await AssetEntity.fromId(id);

      if (entity == null) continue;

      // Convert AssetEntity → File
      final file = await entity.file;

      if (file != null) {
        files.add(file);
      }
    }

    // Send list<File> back to main isolate
    reply.send(files);
  }
}
