import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class homescreen extends StatelessWidget {
   homescreen({Key? key}) : super(key: key){
     _streamemployeedetails = _referenceEmployeelist.snapshots();
   }

  CollectionReference _referenceEmployeelist = FirebaseFirestore.instance.collection("Employee List");    //taking instance of firebase

  late Stream<QuerySnapshot> _streamemployeedetails;
   String formatTimestamp(Timestamp timestamp) {
     var format = new DateFormat('M/y'); // <- use skeleton here
     return format.format(timestamp.toDate());
   }       //Conversion of timestamp to date format

   bool checktime(Timestamp timestamp ){
     final Timestamp endtime = new Timestamp.now();
     final DateTime jointime = timestamp.toDate() ;
     final DateTime enddate = endtime.toDate() ;
     final Duration diff = enddate.difference(jointime) ;

     if(diff.inDays >= 1826){
       return true ;
     }else{
       return false ;
     }
   }         //Function to check time from joining date to current date
   bool checkgender(String gender) {
     if (gender == 'Male') {
       return true;
       // }else if(gender == 'Female'){
       //   return false ;
       // }
     } else {
       return false;
     }
   }             // Function to check the gender


  @override
  Widget build(BuildContext context) {

   var size = MediaQuery.of(context).size ;
    return Scaffold(

      appBar:AppBar( brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      toolbarHeight: 70,
      title: Text("Employees List"),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
            gradient: LinearGradient(
                colors: [Colors.green,Colors.greenAccent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter
            )
        ),
      ),
      ) ,
      body: StreamBuilder<QuerySnapshot>(
          stream: _streamemployeedetails,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Some error occurred ${snapshot.error.toString()}'));
            }
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;
              List<Map> employee = documents
                  .map((e) =>
              {
                'id': e.id,
                'empid': e['empid'],
                'name': e['empname'],
                'jdate': e['joindate'] ,
                'gender': e['gender'] ,

              }).toList();
              return employeelist(employee, size);
            }                   //if firebase has the list data
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  ListView employeelist(List<Map<dynamic, dynamic>> employee, Size size) {
    return ListView.builder(
                itemCount: employee.length,
                itemBuilder: (BuildContext context, int index) {
                  Map thisEmp = employee[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 5.0 ,left: 5.0),
                    child: Container(
                      //height: ,
                      width: size.width/4.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 5.0,),
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: checkgender(thisEmp['gender'])?Image.asset('assets/male.jpg' , width: size.width*0.15,height: size.height*0.12,): Image.asset('assets/female.png',width: size.width*0.15,height: size.height*0.12)
                            ),
                            minVerticalPadding: 5.0,
                            contentPadding: EdgeInsets.all(3.0),
                            title: Text('${thisEmp['name']}' , style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),),
                            subtitle: Text('${formatTimestamp(thisEmp['jdate'])}' , style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15
                            ),),
                            trailing:checktime(thisEmp['jdate'])? Icon(Icons.bookmark_sharp , color: Colors.green,) : Icon(Icons.bookmark_outline ), //color: Colors.white, ),
                          ),
                          SizedBox(
                            height: 5.0,
                          )
                        ],
                      ),
                    ),
                  );
                });
  }           //Screen UI design
}
