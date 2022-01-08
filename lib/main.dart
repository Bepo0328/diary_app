import 'package:diary_app/data/database.dart';
import 'package:diary_app/data/diary.dart';
import 'package:diary_app/data/utils.dart';
import 'package:diary_app/screen/write.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectIndex = 0;
  final dbHelper = DatabaseHelper.instance;
  Diary? todayDiary;
  Diary? historyDiary;
  List<Diary> allDiaries = [];
  List<String> statusImg = [
    'assets/img/ico-weather.png',
    'assets/img/ico-weather_2.png',
    'assets/img/ico-weather_3.png',
  ];
  DateTime _selectedDay = DateTime.now();

  void getTodayDiary() async {
    List<Diary> diary =
        await dbHelper.getDiaryByDate(Utils.getFormatTime(DateTime.now()));
    if (diary.isNotEmpty) {
      todayDiary = diary.first;
    }
    setState(() {});
  }

  void getAllDiary() async {
    allDiaries =
    await dbHelper.getAllDiary();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getTodayDiary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: getPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectIndex == 0) {
            Diary diary;
            if (todayDiary != null) {
              diary = todayDiary!;
            } else {
              diary = Diary(
                title: '',
                memo: '',
                image: 'assets/img/b1.jpg',
                date: Utils.getFormatTime(DateTime.now()),
                status: 0,
              );
            }
            await Navigator.push(context, MaterialPageRoute(builder: (ctx) {
              return DiaryWritePage(
                diary: diary,
              );
            }));
            getTodayDiary();
          } else {
            Diary diary;
            if (historyDiary != null) {
              diary = historyDiary!;
            } else {
              diary = Diary(
                title: '',
                memo: '',
                image: 'assets/img/b1.jpg',
                date: Utils.getFormatTime(_selectedDay),
                status: 0,
              );
            }
            await Navigator.push(context, MaterialPageRoute(builder: (ctx) {
              return DiaryWritePage(
                diary: diary,
              );
            }));
            getDiaryByDate(_selectedDay);
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          setState(() {
            selectIndex = idx;
          });
          if (selectIndex == 2) {
            getAllDiary();
          }
        },
          currentIndex: selectIndex,
          items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: '오늘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }

  Widget getPage() {
    if (selectIndex == 0) {
      return getTodayPage();
    } else if (selectIndex == 1) {
      return getHistoryPage();
    } else {
      return getChartPage();
    }
  }

  Widget getTodayPage() {
    if (todayDiary == null) {
      return Container(
        child: const Text('일기가 없습니다.'),
      );
    } else {
      return Container(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                todayDiary!.image!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Image.asset(
                          statusImg[todayDiary!.status!],
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayDiary!.title!,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          todayDiary!.memo!,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  void getDiaryByDate(DateTime date) async {
    List<Diary> _date =
        await dbHelper.getDiaryByDate(Utils.getFormatTime(date));
    setState(() {
      if (_date.isEmpty) {
        historyDiary = null;
      } else {
        historyDiary = _date.first;
      }
    });
  }

  Widget getHistoryPage() {
    return Container(
      child: ListView.builder(
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return Container(
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    getDiaryByDate(selectedDay);
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
              ),
            );
          } else if (idx == 1) {
            if (historyDiary == null) {
              return Container();
            } else {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDay.year}.${_selectedDay.month}.${_selectedDay.day}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Image.asset(
                          statusImg[historyDiary!.status!],
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historyDiary!.title!,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(height: 12.0),
                        Text(
                          historyDiary!.memo!,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          } else {
            return Container();
          }
        },
        itemCount: 2,
      ),
    );
  }

  Widget getChartPage() {
    return Container(
      child: ListView.builder(
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(statusImg.length, (_idx) {
                  return Container(
                    child: Column(
                      children: [
                        Image.asset(statusImg[_idx], fit: BoxFit.contain),
                        Text('${allDiaries.where((element) => element.status == _idx).length}개'),
                      ],
                    ),
                  );
                }),
              ),
            );
          } else if (idx == 1) {
            return Container(
              height: 120.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: List.generate(allDiaries.length, (_idx) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: 100.0,
                    width: 100.0,
                    child: Image.asset(allDiaries[_idx].image!, fit: BoxFit.cover),
                  );
                }),
              ),
            );
          } else {
            return Container();
          }
        },
        itemCount: 5,
      ),
    );
  }
}
