import 'package:flutter/material.dart';

class Rank extends StatefulWidget {
  const Rank({super.key});

  @override
  State<StatefulWidget> createState() => RankState();
}

class RankState extends State<Rank> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
              width: 130,
              height: 130,
              child: Column(
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://resource.hsslive.cn/image/7e048083bb5dccde76018625b644c84b.webp'),
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Text('ddddd'),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: Color.fromRGBO(68, 214, 255, 1))),
                    child: Text('2'),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: 130,
              height: 130,
              child: Column(
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://resource.hsslive.cn/image/7e048083bb5dccde76018625b644c84b.webp'),
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Text('ddddd'),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: Color.fromRGBO(68, 214, 255, 1))),
                    child: Text('2'),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
              width: 130,
              height: 130,
              child: Column(
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://resource.hsslive.cn/image/7e048083bb5dccde76018625b644c84b.webp'),
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Text('ddddd'),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: Color.fromRGBO(68, 214, 255, 1))),
                    child: Text('2'),
                  )
                ],
              ),
            ),
          ]),
    );
  }
}
