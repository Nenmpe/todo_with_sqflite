import 'package:flutter/material.dart';
import '../services/database_service.dart';


class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  List<Map<String, dynamic>> allTodos = [];
  DatabaseService? dbref;
  TextEditingController todoController = TextEditingController();

  @override
  void initState(){
    super.initState();
    dbref = DatabaseService.getInstance;
    getTodos();
  }

  void getTodos() async{
    allTodos = await dbref!.getAllTodos();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("ToDo Lists", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),),
      ),
      body: allTodos.isNotEmpty ? ListView.builder(
        itemCount: allTodos.length,
        itemBuilder: (_, index) {
          bool isCompleted = allTodos[index][DatabaseService.tasksStatusColumnName] == 1;
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: isCompleted ? Colors.green : Colors.red,
                child: Icon(
                  isCompleted ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
              ),
              title: Text(
                allTodos[index][DatabaseService.tasksContentColumnName] ?? "No Content",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                isCompleted ? "Completed" : "Incomplete",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.green : Colors.red,
                ),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                    icon: Icon(Icons.edit, color: Colors.greenAccent[700]),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          todoController.text = allTodos[index][DatabaseService.tasksContentColumnName];
                          return getBottomSheetWidget(isUpdate: true, tid: allTodos[index][DatabaseService.tasksIdColumnName]);
                        },
                      );
                    },),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey[700]),
                      onPressed: () async{
                        bool check = await dbref!.deleteTodo(id: allTodos[index][DatabaseService.tasksIdColumnName]);
                        if(check){
                          getTodos();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ): Center(
        child: Text("No ToDos yet!"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              todoController.clear();
              return getBottomSheetWidget();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }


  Widget getBottomSheetWidget({bool isUpdate = false, int tid = 0}){
   int selectedStatus = 0;
   return StatefulBuilder(builder: (content, setState){
     double screenHeight = MediaQuery.of(context).size.height;
     double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
     return Container(
       padding: EdgeInsets.all(10),
       width: double.infinity,
       child: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text(isUpdate?
             "Update ToDo":"Add ToDo",
               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
             ),
             SizedBox(height: 21),
             TextField(
               controller: todoController,
               maxLines: 2,
               decoration: InputDecoration(
                 hintText: "Enter Your Todo",
                 labelText: "ToDo *",
                 focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(11),
                 ),
                 enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(11),
                 ),
               ),
             ),
             SizedBox(height: 11),
             isUpdate?
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Row(
                   children: [
                     RadioMenuButton(value: 0, groupValue: selectedStatus, onChanged: (value){
                       setState(()=>selectedStatus = value!);
                     }, child: Text("Incomplete", style: TextStyle(color: Colors.red),)),
                     SizedBox(width: 20),
                     RadioMenuButton(value: 1, groupValue: selectedStatus, onChanged: (value){
                       setState(()=>selectedStatus = value!);
                     }, child: Text("Complete", style: TextStyle(color: Colors.green),))
                   ],
                 ),
               ],
             ):SizedBox.shrink(),
             SizedBox(height: 11),
             SizedBox(
               width: double.infinity,
               child: OutlinedButton(
                 style: OutlinedButton.styleFrom(
                   backgroundColor: Colors.blue
                 ),
                 onPressed: () async{
                   var todoContent = todoController.text;
                   if(todoContent.isNotEmpty){
                     bool check = isUpdate
                         ?await dbref!.updateTodo(id: tid, status: selectedStatus, content: todoContent)
                         :await dbref!.addTodo(content: todoContent, status: 0);
         
                     if (check) {
                       getTodos();
                     }
                   }else{
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ToDo cannot be empty!!!")));
                   }
                   todoController.clear();
                   Navigator.pop(context);
                 },
                 child: Text(isUpdate?
                 "Update ToDo":"Add ToDo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),),
               ),
             ),
             SizedBox(height: 11),
             Center(
               child: InkWell(
                 onTap: (){
                   Navigator.pop(context);
                 },
                 child: CircleAvatar(
                     backgroundColor: Colors.red,
                     child: Icon(
                       Icons.close,
                       color: Colors.white,
                     ),
                 ),
               ),
             ),
             SizedBox(height: keyboardHeight > 0 ? isUpdate?keyboardHeight*2:keyboardHeight : 0),
           ],
         ),
       ),
     );
   });
  }
}