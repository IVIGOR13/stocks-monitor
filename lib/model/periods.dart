import 'package:volga_1/model/period.dart';

class Periods {

  static final List<Period> values = [
    Period(
      name: 'D',
      resolution: '5',
      timeInterval: 86400 // one day
    ),
    Period(
      name: 'W',
      resolution: '15',
      timeInterval: 604800 // one week
    ),
    Period(
      name: 'M',
      resolution: '60',
      timeInterval: 2419200 // one month
    ),
    Period(
      name: 'Y',
      resolution: 'D',
      timeInterval: 31536000 // one year
    ),
  ];

}