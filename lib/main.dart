import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';


//C:\"Program Files"\Android\"Android Studio"\jre\bin\keytool -genkey -v -keystore C:\flutter_keys/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

void main() {
  runApp(
      MaterialApp(
          home:MyApp()
      )
  );  // runApp : app 시작해주세요(보통 app의 main 페이지 입력)
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  getPermission() async {
    // dart는 오래걸리는 코드는 제껴두고 다음꺼 실행
    var status = await Permission.contacts.status;  // 연락처 권한줬는지 여부 // await -> 이 줄 제끼면 안되니깐 기다려라(막 붙일 수 없음, future에 붙일 수 있음)
    if (status.isGranted) {
      print('허락됨');
      var contacts = await ContactsService.getContacts(); // 연락처 가지고 오기
      print(contacts[0].displayName);
      setState(() {
        data2 = contacts;
      });


      // 연락처 강제 추가
      var newPerson = Contact();  // Contact 앞에 new 생략 가능
      newPerson.givenName = '동환2';
      newPerson.familyName = '박';
      await ContactsService.addContact(newPerson);

    } else if (status.isDenied) {
      print('거절됨');
      Permission.contacts.request();  // 허락해 달라고 팝업 띄우기
      // openAppSettings();  // setting 들어가서 permission 설정해야함

    }
  }

  // @override
  // void initState() {  // 위젯 로드될 때 처음 실행
  //   super.initState();
  //   //getPermission();  // 처음에 권한 요구하면 사람들이 거절해서 망함
  //   // 앱 정책 상 android 11 이상 / ios 환경에서 거절 2번 하면 다시는 팝업 안뜸
  // }

  // 자주 바뀌는 것들이나 바로바로 변동사항을 확인 해야하는 것만 state로 만들어
  var total = 3;
  var data = [
    {'name' : '박동환', 'phoneNumber' : '01091419971'},
    {'name' :'강수진', 'phoneNumber' :'01054072003'},
    {'name' :'이민열', 'phoneNumber' : '01012345678'}
  ];
  List<Contact> data2 = []; // type : dynamic
  var like = [0, 0, 0];

  addTotal(){
    setState(() {
      total++;
    });
  }

  minusTotal(){
    setState(() {
      total--;
    });
  }

  addPerson(personData) {
    setState(() {
      data.add(personData);
      data.sort((a, b) {
        if (a['name'].toString().toString().substring(0, 1).codeUnits[0] !=
            b['name'].toString().substring(0, 1).codeUnits[0]) {
          return a['name'].toString()
              .substring(0, 1)
              .codeUnits[0]
              .compareTo(b['name'].toString().substring(0, 1).codeUnits[0]);
        } else if (a['name'].toString().substring(1, 2).codeUnits[0] !=
            b['name'].toString().substring(1, 2).codeUnits[0]) {
          return a['name'].toString()
              .substring(1, 2)
              .codeUnits[0]
              .compareTo(b['name'].toString().substring(1, 2).codeUnits[0]);
        } else {
          return a['name'].toString()
              .substring(2, 3)
              .codeUnits[0]
              .compareTo(b['name'].toString().substring(2, 3).codeUnits[0]);
        }
      });

    });
  }

  removePerson(index) {
    setState(() {
      data.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {  // 이 줄까지는 기본적으로 넣어야하는거임(없는척 해도됨, 코딩은 밑부터) // context : 부모위젯의 정보를 담고있는 인수

    // MaterialApp을 밖으로 뺴야 dialog가 잘 동작
    // showDialog의 context에는 무조건 MaterialApp이 들어가야하는데 materialApp을 넣어버리면
    // build의 context에는 아무것도 안들어가게 되고 그럼 showDialog의 context에는 materialApp이 들어가지 못해서 error 발생
    // builder : context 생성기

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(context: context, builder: (context){
              return DialogUI(total: total, addTotal : addTotal,addPerson: addPerson);  // 1. state 변수 보내기 : (작명 : 보낼 state)  // 2. 등록하기  // 3. 사용하기
            });
          },
        ),
        appBar: AppBar(
          title: Text(total.toString()),
          actions: [
            IconButton(
                onPressed: (){
                  getPermission();
                },
                icon: Icon(Icons.contacts))],
        ),
        body: ListView.builder( // 자동으로 반복
            itemCount: data2.length,
            itemBuilder: (context, index){

              // 내가 만든 list에꺼 출력
              // return ListTile(
              //     dense: true,
              //     horizontalTitleGap:10,
              //     contentPadding: EdgeInsets.all(10),
              //     leading: Image.asset('assets/profile.png'), // 안드로이드에 띄울떄는 폴더명까지
              //     title:Row(
              //         children:[
              //           Text(data[index]['name'].toString().toString()),
              //           Text(data[index]['phoneNumber'].toString()),
              //         ]
              //     )
              //     ,
              //     trailing: IconButton(icon: Icon(Icons.delete_forever_outlined), onPressed: (){
              //       removePerson(index);
              //       minusTotal();
              //     },)
              // );

              //연락처 받아와서 출력
              return ListTile(
                  dense: true,
                  horizontalTitleGap:10,
                  contentPadding: EdgeInsets.all(10),
                  leading: Image.asset('assets/profile.png'), // 안드로이드에 띄울떄는 폴더명까지
                  title:Row(
                      children:[
                        Text(data2[index].displayName ?? 'no name'), // String? : string 이기도 한데 null일 수도 있다 --> null check 필요 // ?? -> 왼쪽 변수가 null이면 오른쪽꺼 남겨라
                      ]
                  )
                  ,
                  trailing: IconButton(icon: Icon(Icons.delete_forever_outlined), onPressed: (){
                    removePerson(index);
                    minusTotal();
                  },)
              );
            }
        )
    );

    // return MaterialApp(
    //     home: Scaffold(
    //         appBar: AppBar(),
    //         body: ListView( // ListView안에 넣으면 스크롤바 생김, 스크롤 위치 감시도 쉬움, 메모리 절양 good
    //             children: [
    //               ListTile( // 그림 + 옆에 글 템플릿
    //                   leading: Image.asset('profile.png'),
    //                   title:Text('홍길동')
    //               ),
    //               ListTile( // 그림 + 옆에 글 템플릿
    //                   leading: Image.asset('profile.png'),
    //                   title:Text('박동환')
    //               ),
    //             ]
    //         )
    //     )
    // );

    // return MaterialApp(
    //     home: Scaffold(
    //       floatingActionButton: FloatingActionButton(
    //         child: Text(atoString()),
    //         onPressed: (){
    //           print(atoString());
    //          setState(() {
    //            a++;
    //          });
    //         },
    //       ),
    //         appBar: AppBar(),
    //         body: ListView.builder( // 자동으로 반복
    //             itemCount: 3,
    //             itemBuilder: (context, index){
    //               // print(index);
    //               return ListTile(
    //                   leading: Image.asset('profile.png'),
    //                   title:Text(name[index])
    //               );
    //             }
    //         )
    //     )
    // );

    // return MaterialApp(
    //     home: Scaffold(
    //         floatingActionButton: FloatingActionButton(
    //           child: Text(atoString()),
    //           onPressed: (){
    //             print(atoString());
    //             setState(() {
    //               a++;
    //             });
    //           },
    //         ),
    //         appBar: AppBar(),
    //         body: ListView.builder( // 자동으로 반복
    //             itemCount: 3,
    //             itemBuilder: (context, index){
    //               // print(index);
    //               return ListTile(
    //                 leading: Text(like[index].toString()),
    //                 title:Text(name[index]),
    //                 trailing: FloatingActionButton(
    //                   child: Text('like'),
    //                   onPressed: (){
    //                     setState(() {
    //                       like[index]++;
    //                     });
    //                   },
    //                 ),
    //               );
    //             }
    //         )
    //     )
    // );

    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(),
    //     body: Row(
    //       children: [
    //         // Flexible(child: Container(color: Colors.blue,), flex: 3), // Flexible --> 비율로 사용
    //         // Flexible(child: Container(color: Colors.green), flex: 7)
    //
    //         Expanded(child: Container(color:Colors.blue)),  // flex: 1 가진 Felxible 박스랑 같은 역할  // 원하는 크기의 하나를 채우고 나머지에 채우고 싶을 때 사용하면 good
    //         Expanded(child: Container(color:Colors.red)),
    //         Container(width: 100, color: Colors.green,)
    //       ],
    //     ),
    //   ),
    // );

    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(
    //       title: Text('금호동3가'),
    //       actions: [Icon(Icons.search, size: 35), Icon(Icons.menu_rounded, size: 35), Icon(Icons.add_alert_rounded, size: 35)],
    //     ),
    //     body: Container(
    //       padding: EdgeInsets.all(20),
    //       height: 200,
    //       child: Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Image.asset('dog.png', height: 100),
    //           Container(
    //             padding: EdgeInsets.fromLTRB(10, 0 , 0, 0),
    //             width: 180,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text('캐논 DSLR 100D (단렌즈, 충전기 16기가 SD 포함)'),
    //                 Text('성동구 행당동 끌올 10분 전', style: TextStyle(fontSize: 10, color: Colors.grey),),
    //                 Text('210,000원', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.end,
    //                   children: [
    //                     Icon(Icons.favorite),
    //                     Text('4')
    //                   ],
    //                 )
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //     )
    //   )
    // );

    // 레이아웃 혼자서도 잘 짜는법
    // 1. 예시 디자인 준비(없으면 베껴)
    // 2. 예시 화면에 네모 그리기
    // 3. 바깥 네모부터 하나하나 위젯으로
    // 4. 마무리 디자인
    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(actions: [Icon(Icons.star), Icon(Icons.shop)], leading: Icon(Icons.star), title: Text('앱임')), // leading : 왼쪽에 넣을 아이콘, title : 왼쪽 제목, actions: [우측아이콘들]
    //     body: SizedBox(
    //       child:Text('안녕하세요',
    //         style: TextStyle(color: Colors.red),  // 색 주는 법 1. Colors.컬러명 2. Color(0xffaaaaaa) 3. Color.fromRGBO()
    //       ),
    //     )
    //   )
    // );

    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(title: Text('앱임')),
    //     body: Align(
    //       alignment: Alignment.bottomCenter,
    //       child: Container(
    //         width: double.infinity, height: 100,  // 부모 박스를 넘지않는 선에서 무한하게
    //         padding: EdgeInsets.all(20),
    //         margin: EdgeInsets.fromLTRB(0, 30, 0, 0), // 개별 margin
    //         decoration: BoxDecoration(  // 나머지 찌끄레기 박스 스타일
    //           border:Border.all(color: Colors.black)
    //         ),
    //         child:Text('dddd'),
    //       ),
    //     ),
    //   )
    // );

    // return MaterialApp(
    //   // home: Text('안녕')  // 글자 위젯
    //   // home: Icon(Icons.shop)  // 아이콘 위젯
    //   // home: Image.asset('dog.png') // assets 파일에 img 넣고, pubspec.yaml에 등록하고 경로 입력
    //   //home : Center(  // 내 자식 위젯의 기준점을 중앙으로 설정
    //     //child: Container(width: 50, height: 50, color: Colors.blue) // box 만들기  // 단위 : LP(대충 1.2cm)  // 부모 위젯에서 위치 설정
    //
    //   home: Scaffold( // 상중하로 나누어 줌
    //     appBar: AppBar(
    //       title: Text('앱임'),
    //     ), // 파란막대 생성
    //     // body: Row(  // 여러 위젯 가로로 배치 // Column : 세로로 배치
    //     //   mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 가로축(row에서는 main이 가로라서) 정렬  // ctrl+space : 자동완성
    //     //   // crossAxisAlignment: CrossAxisAlignment.center, // 세로축 정렬
    //     //   children: [
    //     //     Icon(Icons.star),
    //     //     Icon(Icons.shop),
    //     //     Icon(Icons.map)
    //     //   ]
    //     body: Text('안녕'),
    //     bottomNavigationBar: BottomAppBar(
    //       child: SizedBox(  // width, height, child만 필요한 박스는 SizedBox() 사용(Container는 무겁다)
    //         height: 70,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             Icon(Icons.phone),
    //             Icon(Icons.message),
    //             Icon(Icons.contact_page)
    //           ],
    //         ),
    //       ),
    //     ),  // 하단에 들어갈 위젯
    //     ),  // 중단에 들어갈 위젯
    //   );

    // return MaterialApp(
    //     home: Scaffold(
    //       appBar: AppBar(),
    //       body: ShopItem(),
    //
    //     )
    // );
  }
}

// stless + tab키
// 객체지향으로 만들기
// 아무거나 다 custom 위젯으로 만들면 state 관리가 어려움
// 재사용이 많은 놈들을 만들어야 good
// class ShopItem extends StatelessWidget {
//   const ShopItem({Key? key}) : super(key: key); // parameter 설정
//
//   @override
//   Widget build(BuildContext context) {  // build 라는 이름의 함수 만들기
//
//     return SizedBox(
//     child: Text('안녕'),
//     );
//   }
// }

// 변수에 담기
// 안바뀌는 UI는 담아도 됨
// but 바뀌는 놈들은 성능상 이슈가 있을수 있어서 그냥 class로 만들어라
// var a = SizedBox(
//   child: Text('안녕')
// );

// staeful widget
// class Test extends StatefulWidget {
//   const Test({Key? key}) : super(key: key);
//
//   @override
//   State<Test> createState() => _TestState();
// }
//
// class _TestState extends State<Test> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();

//   }
// }

class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.total, this.addTotal, this.addPerson}) : super(key: key); // 중괄호 안에 넣으면 선택적 파라미터
  final total;  // 부모가 보낸 state는 read-only가 좋음
  final addTotal;
  final addPerson;
  //var inputData = TextEditingController();
  var inputName = '';
  var inputPhoneNumber = '';  // data가 많으면 list or map에 쓰면 됨

  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            TextField(onChanged: (text){inputName = text; },),  //
            TextField(onChanged: (text){inputPhoneNumber = text;},),  //
            //TextField(controller: inputData,),
            TextButton(child: Text('완료'), onPressed: (){
              if(inputName.toString() != '' || inputPhoneNumber.toString() != '') {
                addPerson({'name':inputName, 'phoneNumber':inputPhoneNumber});
                addTotal();
                Navigator.pop(context);
              }
            } ),
            TextButton(onPressed: (){
              Navigator.pop(context); // 현재 페이지 닫기
            }, child: Text('취소'))
          ],
        ),
      ),
    );
  }
}
