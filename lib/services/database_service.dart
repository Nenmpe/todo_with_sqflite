import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService{
  //Singleton
  DatabaseService._();

  static final DatabaseService getInstance = DatabaseService._();

  static final String tasksTableName = "tasks";
  static final String tasksIdColumnName = "id";
  static final String tasksContentColumnName = "content";
  static final String tasksStatusColumnName = "status";

  Database? todos;

  Future<Database> getDB() async{
    // if(todos!=null){
    //   return todos!;
    // }
    // else{
    //   todos = await openDB();
    //   return todos!;
    // }
    return todos ?? await openDB(); // compact version of above if else
  }

  Future<Database> openDB() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "todo.db");
    return await openDatabase(dbPath, onCreate: (db, version){
      db.execute('''create table $tasksTableName(
       $tasksIdColumnName integer primary key,
       $tasksContentColumnName text not null,
       $tasksStatusColumnName integer not null
      )''');
    }, version: 1);
  }

  // Queries

  Future<bool> addTodo({required String content, required int status}) async{
    var db = await getDB();
    int rowsEffected = await db.insert(tasksTableName, {
      tasksContentColumnName: content,
      tasksStatusColumnName: status
    });

    return rowsEffected>0;
  }

  Future<List<Map<String, dynamic>>> getAllTodos() async{
    var db = await getDB();
    List<Map<String, dynamic>> mdata = await db.query(tasksTableName);

    return mdata;
  }

  Future<bool> updateTodo({required int id, required int status,String? content}) async{
    var db = await getDB();

    Map<String, dynamic> updateData = {
      tasksStatusColumnName: status,
    };

    if (content != null) {
      updateData[tasksContentColumnName] = content;
    }

    var rowsEffected = await db.update(
      tasksTableName,
      updateData,
      where: "$tasksIdColumnName = ?",
      whereArgs: [id],
    );

    return rowsEffected>0;
  }

  Future<bool> deleteTodo({required int id}) async{
    var db = await getDB();
    var rowsEffected = await db.delete(tasksTableName, where: "$tasksIdColumnName = $id");

    return rowsEffected>0;
  }
}