import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA61t9_Btf--llvtef4LBleFn7NwbXeLwo",
        authDomain: "midterm-529f6.firebaseapp.com",
        projectId: "midterm-529f6",
        storageBucket: "midterm-529f6.appspot.com",
        messagingSenderId: "238542454862",
        appId: "1:238542454862:web:15b5c33c8fc19eb94d431f",
        measurementId: "G-P986F4DG5N"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      hintColor: Colors.cyan
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String studentImage = '', studentName = '', studentID = '', studyProgramID = '';
  double studentGPA = 0.0;
  XFile? image;
  UploadTask? uploadTask;

  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController programIDController = TextEditingController();
  TextEditingController gpaController = TextEditingController();
    getStudentImage(image) {
    this.studentImage = image;
  }

  getStudentName(name) {
    this.studentName = name;
  }

  getStudentID(id) {
    this.studentID = id;
  }

  getStudyProgramID(programID) {
    this.studyProgramID = programID;
  }

  getStudentGPA(gpa) {
    try {
      this.studentGPA = double.parse(gpa);
    } catch (e) {
      print("Invalid GPA entered");
    }
  }

  buildProgress(){
    return StreamBuilder(stream: uploadTask?.snapshotEvents, builder: (context, snapshot){
      if(snapshot.hasData){
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: progress,color: Colors.green,backgroundColor: Colors.grey,
            ),
            Text("${progress *100.roundToDouble()}%")
          ],
        );
      }else{
        return const SizedBox.shrink();
      }
    },);
  }

  createData() async {
    DocumentReference documentReference = 
      FirebaseFirestore.instance.collection("MyStudents").doc(studentName);

    // create Map
    Map<String, dynamic> students = {
      "studentName": studentName,
      "studentID": studentID,
      "studentProgramID": studyProgramID,
      "studentGPA": studentGPA
    };

    await documentReference.set(students).whenComplete(() {
      print("$studentName created");

      nameController.clear();
      idController.clear();
      programIDController.clear();
      gpaController.clear();

      setState(() {
      studentName = '';
      studentID = '';
      studyProgramID = '';
      studentGPA = 0.0;
    });


    }).catchError((e) {
      print("Error creating student: $e"); 
    });
  }

readData() {
  String studentNameInput = nameController.text.trim();
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection("MyStudents")
      .doc(studentNameInput);

  documentReference.get().then((datasnapshot) {
    if (datasnapshot.exists) {
      Map<String, dynamic>? data = datasnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
            nameController.text = data["studentName"] ?? '';
            idController.text = data["studentID"] ?? '';
            programIDController.text = data["studentProgramID"] ?? '';
            gpaController.text = data["studentGPA"]?.toString() ?? '';
          });
      } else {
        print("No data found");
      }
    } else {
      print("Document does not exist.");
    }
  }).catchError((e) {
    print("Error getting document: $e");
  });
}


  Future<void> updateData() async {
  // Lấy giá trị từ các TextEditingController
  String updatedName = nameController.text;
  String updatedID = idController.text;
  String updatedProgramID = programIDController.text;
  double? updatedGPA;

  // Kiểm tra và chuyển đổi GPA từ string sang double
  try {
    updatedGPA = double.parse(gpaController.text);
  } catch (e) {
    print("Invalid GPA entered");
    return; // Thoát hàm nếu GPA không hợp lệ
  }

  DocumentReference documentReference = 
    FirebaseFirestore.instance.collection("MyStudents").doc(updatedName);

  // Tạo Map
  Map<String, dynamic> students = {
    "studentName": updatedName,
    "studentID": updatedID,
    "studentProgramID": updatedProgramID,
    "studentGPA": updatedGPA
  };

  await documentReference.set(students).whenComplete(() {
    print("$updatedName updated");

    // Xóa dữ liệu trong các TextEditingController
    nameController.clear();
    idController.clear();
    programIDController.clear();
    gpaController.clear();

    // Cập nhật lại các biến để tránh xung đột khi nhập lại
    setState(() {
      studentName = '';
      studentID = '';
      studyProgramID = '';
      studentGPA = 0.0;
    });
  }).catchError((e) {
    print("Error updating student: $e"); 
  });
}


  deleteData() {
    DocumentReference documentReference = FirebaseFirestore.instance.
    collection("MyStudents").doc(studentName);

    documentReference.delete().whenComplete((){
      print("$studentName is deleted");

      nameController.clear();
      idController.clear();
      programIDController.clear();
      gpaController.clear();

      setState(() {
      studentName = '';
      studentID = '';
      studyProgramID = '';
      studentGPA = 0.0;
    });
    
    });
  }

  clearData() {
    
      print("$studentName is deleted");

      nameController.clear();
      idController.clear();
      programIDController.clear();
      gpaController.clear();

      setState(() {
      studentName = '';
      studentID = '';
      studyProgramID = '';
      studentGPA = 0.0;
    });
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alienn704's Flutter App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 25),
            //   child: Column(
            //     children: [
            //       SizedBox(height: 50),
            //       Align(
            //         alignment: Alignment.center,
            //         child: InkWell(
            //           onTap: () async{
            //             // Pick Image
            //             final picture = 
            //             await ImagePicker().pickImage(source: ImageSource.gallery);

            //             if (picture!=null){
            //               image = image;
            //               setState(() {
                            
            //               });
            //             }



            //           } ,
            //           child: image == null?const CircleAvatar(
            //             radius: 100,
            //             child: Icon(
            //               Icons.camera_alt,
            //               size: 50,
            //             ),
            //           )
            //           : ClipOval(child: Image.file(
            //             File(image!.path), 
            //             height: 200,
            //             width: 200,
            //             fit: BoxFit.cover,
            //             )),
            //         ),
            //       ),
            //       const SizedBox(height: 30),
            //       uploadTask != null 
            //       ? buildProgress()

            //       :ElevatedButton(
            //         onPressed: () async {
            //           final ref = FirebaseStorage.instance
            //           .ref()
            //           .child("images/@${image!.name}");
                      
            //           uploadTask = ref.putFile(File(image!.path));

            //           setState(() {
                        
            //           });
            //           final snapshot = await uploadTask!.whenComplete(() => null);
            //           setState(() {
            //             uploadTask = null;
            //           });

            //           // final snapshot = uploadTask!.whenComplete(()=> null);

            //           final downloadURL = await ref.getDownloadURL();
            //           print("URL: $downloadURL");

            //         }, 
            //         child: const Text("Upload"),
      
            //         )
            //     ],
            //     // decoration: InputDecoration(
            //     //   labelText: "StudentImage",
            //     //   fillColor: Colors.white,
            //     //   focusedBorder: OutlineInputBorder(
            //     //     borderSide: BorderSide(color: Colors.blue, width: 2.0),
            //     //   ),
            //     // ),
            //     // onChanged: (String image) {
            //     //   getStudentImage(image);
            //     // },
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                onChanged: (String name) {
                  getStudentName(name);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: "Student ID",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                onChanged: (String id) {
                  getStudentID(id);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: programIDController,
                decoration: InputDecoration(
                  labelText: "Study Program ID",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                onChanged: (String programID) {
                  getStudyProgramID(programID);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: gpaController,
                decoration: InputDecoration(
                  labelText: "GPA",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (String gpa) {
                  getStudentGPA(gpa);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Create"),
                  onPressed: () {
                    print("Create button pressed");
                    createData();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Read"),
                  onPressed: () {
                    print("Read button pressed");
                    readData();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Update"),
                  onPressed: () {
                    print("Update button pressed");
                    updateData();
                  },
                ),
                 ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 247, 44, 8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Delete"),
                  onPressed: () {
                    print("Update button pressed");
                    deleteData();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 78, 137),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Clear"),
                  onPressed: () {
                    print("Clear button pressed");
                    clearData();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
