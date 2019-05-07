import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// Counter Events
// 计数器执行过程抽象成事件：加事件、减事件
enum CounterEvent { increment, decrement }

// Counter Bloc
// 计数器逻辑：根据传递的事件和值，返回结果流
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}


// Counter App
void main() => runApp(MyApp());
// 程序启动创建 AppWidget
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

// AppWidget对应 AppWidgetState，管理创建和处理的小部件CounterBloc
class MyAppState extends State<MyApp> {
  // State由业务逻辑结果决定
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    // 返回容器模板，我们使用来自flutter_bloc的BlocProvider小部件，以便使CounterBloc的实例对整个子树(CounterPage)可用。
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        bloc: _counterBloc,
        child: CounterPage(),
      ),
    );
  }

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}


// Counter Page
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 将逻辑关联上UI
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        // bloc返回流，内部自动赋值？
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      // 右下角两个浮动按钮，执行加减操作（_counterBloc.dispatch(CounterEvent.increment)）
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/*
* 注意：我们能够访问CounterBloc实例，BlocProvider.of<CounterBloc>(context)因为我们将我们包装CounterPage在一个BlocProvider。

  注意：我们正在使用BlocBuilder窗口小部件flutter_bloc来重建我们的UI以响应状态更改（计数器值的更改）。

  我们已经将表示层与业务逻辑层分离。我们的CounterPage不知道当用户按下按钮时会发生什么;它只是发送一个事件来通知CounterBloc。
  此外，CounterBloc不知道计算器(值)发生了什么;它只是将事件结果转换为整数。
* */