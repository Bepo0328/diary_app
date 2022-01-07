import 'package:diary_app/data/database.dart';
import 'package:diary_app/data/diary.dart';
import 'package:flutter/material.dart';

class DiaryWritePage extends StatefulWidget {
  const DiaryWritePage({Key? key, this.diary}) : super(key: key);

  final Diary? diary;

  @override
  _DiaryWritePageState createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  List<String> images = [
    'assets/img/b1.jpg',
    'assets/img/b2.jpg',
    'assets/img/b3.jpg',
    'assets/img/b4.jpg',
    'assets/img/b5.jpg',
    'assets/img/b6.jpg',
    'assets/img/b7.jpg',
    'assets/img/b8.jpg',
  ];
  List<String> statusImg = [
    'assets/img/ico-weather.png',
    'assets/img/ico-weather_2.png',
    'assets/img/ico-weather_3.png',
  ];
  int imgIndex = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.diary!.title!;
    memoController.text = widget.diary!.memo!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              widget.diary!.title = nameController.text;
              widget.diary!.memo = memoController.text;

              await dbHelper.insertDiary(widget.diary!);
              Navigator.pop(context);
            },
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return InkWell(
              onTap: () {
                setState(() {
                  widget.diary!.image = images[imgIndex];
                  imgIndex++;
                  imgIndex = imgIndex % images.length;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                width: 100.0,
                height: 100.0,
                child: Image.asset(
                  widget.diary!.image!,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else if (idx == 1) {
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 22.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(statusImg.length, (_idx) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        widget.diary!.status = _idx;
                      });
                    },
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        statusImg[_idx],
                        fit: BoxFit.contain,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _idx == widget.diary!.status
                                ? Colors.blue
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  );
                }),
              ),
            );
          } else if (idx == 2) {
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: const Text(
                '제목',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (idx == 3) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: TextField(
                controller: nameController,
              ),
            );
          } else if (idx == 4) {
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: const Text(
                '내용',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (idx == 5) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: TextField(
                controller: memoController,
                minLines: 10,
                maxLines: 20,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
        itemCount: 6,
      ),
    );
  }
}
