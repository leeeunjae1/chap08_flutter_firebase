import 'package:chap08_flutter_firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase app 시작
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginPage() : HomePage(),
    );
  }
}

// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 로그인한 유저 객체 가져오기
        User? user = authService.currentUser();
        return Scaffold(
          appBar: AppBar(
            title: Text('로그인'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    user == null ? '로그인 해주세요' : '${user.email}님 안녕하세요',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: '이메일'),
                ),
                TextField(
                  controller: passwordController,
                  // 비밀번호 숨기기
                  obscureText: true,
                  decoration: InputDecoration(hintText: '비밀번호'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 로그인
                    authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('로그인 성공'),
                          ),
                        );

                        // 로그인 성공시 HomePage로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                        );
                      },
                      onError: (err) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    '로그인',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        print('성공');
                        // 회원가입 성공
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('회원가입 성공'),
                          ),
                        );
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoList'),
        actions: [
          TextButton(
            onPressed: () {
              // 로그아웃 버튼을 눌렀을 때 로그인 페이지로 이동
              context.read<AuthService>().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jobController,
                    decoration: InputDecoration(hintText: 'job을 입력해주세요'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // add 버튼을 눌렀을 때 job을 추가
                  },
                  child: Icon(
                    Icons.add,
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                String job = "$index";
                bool isDone = false;

                return ListTile(
                  title: Text(
                    job,
                    style: TextStyle(
                        fontSize: 24,
                        color: isDone ? Colors.grey : Colors.black,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // 삭제버튼을 눌렀을 때 동작
                    },
                    icon: Icon(
                      CupertinoIcons.delete,
                    ),
                  ),
                  onTap: () {
                    // 아이템을 클릭했을 때, isDone 상태 변경
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
