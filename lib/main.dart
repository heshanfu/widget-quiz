import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/quiz.dart';
import 'model/quiz_generator.dart';
import 'model/w.dart';

main() => runApp(App());

class App extends StatefulWidget {
  @override
  createState() => AppState();
}

class AppState extends State<App> {
  final nKey = GlobalKey<NavigatorState>();
  List<Quiz> qs;
  Quiz get q => qs[i];
  int i = 0;
  final rs = <String, bool>{};

  @override
  initState() {
    super.initState();
    _reload();
  }

  _reload() async {
    final r = await generate();
    setState(() {
      qs = r;
      i = 0;
      rs.clear();
    });
  }

  @override
  build(BuildContext c) {
    const title = 'Widget Quiz!';
    return MaterialApp(
      title: title,
      navigatorKey: nKey,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (qs == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (i >= qs.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⭕️: ${rs.values.where((r) => r).length} / 10'),
            RaisedButton(
              child: Text('TRY AGAIN'),
              onPressed: _reload,
            )
          ],
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: qs.map((q) {
              final key = q.correct.name;
              return Text(rs.containsKey(key)
                  ? (rs[q.correct.name] ? '⭕️' : '❌')
                  : '▫️');
            }).toList(),
          ),
        ),
        Expanded(
          child: _Quiz(
            q,
            onTap: _handleResult,
          ),
        ),
      ],
    );
  }

  _handleResult(bool correct) async {
    {
      rs[q.correct.name] = correct;
      await showDialog(
          context: nKey.currentState.overlay.context,
          builder: (c) {
            return AlertDialog(
              title: correct ? Text('Correct ⭕️') : Text('Wrong ❌️'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                    minWidth: 0,
                    child: Text(
                      '📄 ${q.correct.name}',
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onPressed: () => launch(q.correct.link),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 8),
                  Text(q.correct.desc),
                ],
              ),
              actions: [
                FlatButton(
                  child: Text('NEXT'),
                  onPressed: () {
                    Navigator.of(c).pop();
                  },
                )
              ],
            );
          });
      setState(() {
        i++;
      });
    }
  }
}

class _Quiz extends StatelessWidget {
  _Quiz(this.q, {this.onTap});

  final Quiz q;
  final Function(bool correct) onTap;

  @override
  build(BuildContext c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              q.correct.desc,
              style: Theme.of(c).textTheme.title,
            ),
          ),
        ),
      ]..addAll(q.candidates.map(_buildAnswer)),
    );
  }

  Widget _buildAnswer(W w) => RaisedButton(
        child: Text(w.name),
        onPressed: () => onTap(w == q.correct),
      );
}
