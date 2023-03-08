// import 'package:brisk/dao/download_item_dao.dart';
// import 'package:brisk/model/download_queue.dart';
//
// import '../model/download_item.dart';
// import 'abstract_many_to_many_dao.dart';
//
// class DownloadQueueDao extends AbstractManyToManyDao<DownloadQueue> {
//   DownloadQueueDao._();
//
//   static final DownloadQueueDao instance = DownloadQueueDao._();
//
//   @override
//   List<DownloadQueue> multiMapToEntity(List<Map<String, Object?>> map) {
//     throw UnimplementedError();
//   }
//
//   @override
//   DownloadQueue mapToEntity(List<Map<String, Object?>> result) {
//     print(result);
//     return DownloadQueue(
//       id: result.first["download_queue_id"] as int,
//       queueName: result.first["queue_name"] as String,
//       queue: getDownloadItemList(result),
//     );
//   }
//
//   List<DownloadQueue> mapToEntityList(List<Map<String, Object?>> result) {
//     // for (final map in result) {
//     //
//     // }
//     return [];
//   }
//
//   List<DownloadItem> getDownloadItemList(List<Map<String, Object?>> result) {
//     List<DownloadItem> downloadItems = [];
//     result.forEach(
//       (map) => downloadItems.add(DownloadItemDao.instance.mapToEntity(map)),
//     );
//     return downloadItems;
//   }
//
//   void addDownloadItemsToQueue(int downloadItemId, int queueId) async {
//     (await database).insert(
//         "download_item_queue",
//         {"download_item_id": downloadItemId, "download_queue_id": queueId},
//       );
//   }
//
//   Future<List<DownloadQueue>> getAll() async {
//     final db = await database;
//     final result = await db.rawQuery("SELECT * FROM $tableName");
//     List<DownloadQueue> downloadQueues = [];
//     for (final map in result) {
//       final queue = DownloadQueue(
//         id: map["id"] as int,
//         queueName: map["queue_name"] as String,
//       );
//       downloadQueues.add(queue);
//     }
//     return downloadQueues;
//   }
//
//   Future<void> save(DownloadQueue queue) async {
//     final db = await database;
//     queue.id = await getNewId();
//     final batch = db.batch();
//     batch.insert(tableName, {"queue_name": queue.queueName});
//     for (final downloadItem in queue.queue) {
//       batch.insert(junctionTableName, {
//         "download_item_id": downloadItem.id,
//         "download_queue_id": queue.id,
//       });
//     }
//     await batch.commit(noResult: true);
//   }
//
//   @override
//   String get joinedTableName => "download_item";
//
//   @override
//   String get junctionTableEntityIdColumnName => "download_queue_id";
//
//   @override
//   String get junctionTableJoinedEntityColumnName => "download_item_id";
//
//   @override
//   String get junctionTableName => "download_item_queue";
//
//   @override
//   String get tableName => "download_queue";
//
//   static const String baseSeleactQuery = "select * from download_queue dq "
//       "join download_item_queue diq "
//       "on dq.id = diq.download_queue_id "
//       "join download_item di "
//       "on di.id = diq.download_item_id ";
// }
