class DBQueries {
  static const createDownloadItem = "CREATE TABLE IF NOT EXISTS download_item ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "uid TEXT NOT NULL UNIQUE,"
      "file_name TEXT NOT NULL,"
      "download_url TEXT NOT NULL,"
      "start_date TEXT NOT NULL,"
      "finish_date TEXT,"
      "progress REAL,"
      "queue_order INTEGER,"
      "content_length INTEGER,"
      "file_path TEXT,"
      "file_type TEXT,"
      "supports_pause TEXT,"
      "status TEXT"
      ");";

  // static const createDownloadQueue =
  //     "CREATE TABLE IF NOT EXISTS download_queue ("
  //     "id INTEGER PRIMARY KEY,"
  //     "queue_name TEXT NOT NULL"
  //     ");";

  // static const createDownloadItemQueue =
  //     "CREATE TABLE IF NOT EXISTS download_item_queue ("
  //     "download_item_id INTEGER NOT NULL,"
  //     "download_queue_id INTEGER NOT NULL,"
  //     "FOREIGN KEY (download_item_id) REFERENCES download_item(id)"
  //     " ON DELETE CASCADE "
  //     "ON UPDATE NO ACTION,"
  //     "FOREIGN KEY (download_queue_id) REFERENCES download_queue(id) "
  //     "ON DELETE CASCADE "
  //     "ON UPDATE NO ACTION"
  //     ");";

  static const createSetting = "CREATE TABLE IF NOT EXISTS setting ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "name TEXT NOT NULL,"
      "value TEXT NOT NULL,"
      "type TEXT NOT NULL"
      ");";

  static const insertDefaultSettings = "";

  static const createAllTables = createDownloadItem +
      // createDownloadQueue +
      // createDownloadItemQueue +
      createSetting;
}
