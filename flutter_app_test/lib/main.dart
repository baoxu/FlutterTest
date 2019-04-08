import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
    );
  }

}


/*
* 添加有状态的 RandomWords widget 到 main.dart。
* 它也可以在MyApp之外的文件的任何位置使用，但是本示例将它放到了文件的底部。
* RandomWords widget除了创建State类之外几乎没有其他任何东西
* */
class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

/*
添加 RandomWordsState 类.该应用程序的大部分代码都在该类中， 该类持有RandomWords widget的状态。
这个类将保存随着用户滚动而无限增长的生成的单词对，
以及喜欢的单词对，用户通过重复点击心形 ❤️ 图标来将它们从列表中添加或删除。
* */
class RandomWordsState extends State<RandomWords> {

  // 向RandomWordsState类中添加一个_suggestions列表以保存建议的单词对。 该变量以下划线（_）开头，在Dart语言中使用下划线前缀标识符，会强制其变成私有的。
  final _suggestions = <WordPair>[];
  // 添加一个biggerFont变量来增大字体大小
  final _biggerFont = const TextStyle(fontSize: 18.0);
  // 添加一个 _saved Set(集合) 到RandomWordsState。这个集合存储用户喜欢（收藏）的单词对。 在这里，Set比List更合适，因为Set中不允许重复的值。
  final _saved = new Set<WordPair>();


  // 向RandomWordsState类添加一个 _buildSuggestions() 函数. 此方法构建显示建议单词对的ListView。
  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
        // 在偶数行，该函数会为单词对添加一个ListTile row.
        // 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
        // 注意，在小屏幕上，分割线看起来可能比较吃力。
        itemBuilder: (context, i) {
          // 在每一列之前，添加一个1像素高的分隔线widget
          if (i.isOdd) return new Divider();
          // 语法 "i ~/ 2" 表示i除以2，但返回值是整形（向下取整），比如i为：1, 2, 3, 4, 5
          // 时，结果为0, 1, 1, 2, 2， 这可以计算出ListView中减去分隔线后的实际单词对数量
          final index = i ~/ 2;
          // 如果是建议列表中最后一个单词对
          if (index >= _suggestions.length) {
            // ...接着再生成10个单词对，然后添加到建议列表
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }

  // 对于每一个单词对，_buildSuggestions函数都会调用一次_buildRow
  Widget _buildRow(WordPair pair) {
    // 在 _buildRow 方法中添加 alreadySaved来检查确保单词对还没有添加到收藏夹中。
    final alreadySaved = _saved.contains(pair);

    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      // 同时在 _buildRow()中， 添加一个心形 ❤️ 图标到 ListTiles以启用收藏功能
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      // 在 _buildRow中让心形❤️图标变得可以点击。如果单词条目已经添加到收藏夹中， 再次点击它将其从收藏夹中删除。
      // 当心形❤️图标被点击时，函数调用setState()通知框架状态已经改变。
      onTap: () {
        // 提示: 在Flutter的响应式风格的框架中，调用setState() 会为State对象触发build()方法，从而导致对UI的更新
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },

    );
  }

  void _pushSaved() {
    // 添加Navigator.push调用，这会使路由入栈（以后路由入栈均指推入到导航管理器的栈）
    Navigator.of(context).push(
      // 新页面的内容在在MaterialPageRoute的builder属性中构建，builder是一个匿名函数。
      new MaterialPageRoute(builder: (context) {
          // 添加生成ListTile行的代码。
          final tiles = _saved.map(
                  (pair) {
                return new ListTile(
                  title: new Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                );
              }
          );
          // ListTile的divideTiles()方法在每个ListTile之间添加1像素的分割线。 该 divided 变量持有最终的列表项。
          final divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          // builder返回一个Scaffold，其中包含名为“Saved Suggestions”的新路由的应用栏。
          // 新路由的body由包含ListTiles行的ListView组成; 每行之间通过一个分隔线分隔。
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    final wordPair = new WordPair.random();
//    return new Text(wordPair.asPascalCase);

    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Startup Name Generator'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  // 提示: 某些widget属性需要单个widget（child），而其它一些属性，如action，需要一组widgets(children），用方括号[]表示。
  }
}