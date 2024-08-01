import 'package:wonders/common_libs.dart';

class TimelineEvent {
  TimelineEvent(this.year,this.color, this.description);
  final int year;
  final Color color;
  final String description;
}

class GlobalEventsData {
  final globalEvents = [
    TimelineEvent(1899, $styles.colors.type1, $strings.event1899),
    TimelineEvent(1909, $styles.colors.type1, $strings.event1909),
    TimelineEvent(1918, $styles.colors.type1, $strings.event1918),
    TimelineEvent(1919, $styles.colors.type3, $strings.event1919),
    TimelineEvent(1922, $styles.colors.white, $strings.event1922),
    TimelineEvent(1927, $styles.colors.white, $strings.event1927),
    TimelineEvent(1928, $styles.colors.type1, $strings.event1928),
    TimelineEvent(1930, $styles.colors.white, $strings.event1930),
    TimelineEvent(1932, $styles.colors.type1, $strings.event1932),
    TimelineEvent(1934, $styles.colors.white, $strings.event1934),
    TimelineEvent(1937, $styles.colors.type1, $strings.event1937),
    TimelineEvent(1940, $styles.colors.white, $strings.event1940),
    TimelineEvent(1945, $styles.colors.type1, $strings.event1945),
    TimelineEvent(1949, $styles.colors.type1, $strings.event1949),
    TimelineEvent(1950, $styles.colors.white, $strings.event1950),
    TimelineEvent(1953, $styles.colors.type1, $strings.event1953),
    TimelineEvent(1954, $styles.colors.type4, $strings.event1954),
    TimelineEvent(1955, $styles.colors.white, $strings.event1955),
    TimelineEvent(1956, $styles.colors.type1, $strings.event1956),
    TimelineEvent(1957, $styles.colors.white, $strings.event1957),
    TimelineEvent(1958, $styles.colors.white, $strings.event1958),
    TimelineEvent(1959, $styles.colors.white, $strings.event1959),
    TimelineEvent(1960, $styles.colors.white, $strings.event1960),
    TimelineEvent(1964, $styles.colors.white, $strings.event1964),
    TimelineEvent(1965, $styles.colors.type1, $strings.event1965),
    TimelineEvent(1966, $styles.colors.type1, $strings.event1966),
    TimelineEvent(1970, $styles.colors.white, $strings.event1970),
    TimelineEvent(1976, $styles.colors.type1, $strings.event1976),
    TimelineEvent(1977, $styles.colors.type1, $strings.event1977),
    TimelineEvent(1978, $styles.colors.type1, $strings.event1978),
    TimelineEvent(1979, $styles.colors.type1, $strings.event1979),
    TimelineEvent(1980, $styles.colors.type4, $strings.event1980),
    TimelineEvent(1982, $styles.colors.type1, $strings.event1982),
    TimelineEvent(1983, $styles.colors.type1, $strings.event1983),
    TimelineEvent(1985, $styles.colors.type2, $strings.event1985),
    TimelineEvent(1986, $styles.colors.type2, $strings.event1986),
    TimelineEvent(1988, $styles.colors.type2, $strings.event1988),
    TimelineEvent(1989, $styles.colors.type1, $strings.event1989),
    TimelineEvent(1992, $styles.colors.type1, $strings.event1992),
    TimelineEvent(1994, $styles.colors.type2, $strings.event1994),
    TimelineEvent(1995, $styles.colors.white, $strings.event1995),
    TimelineEvent(1997, $styles.colors.type4, $strings.event1997),
    TimelineEvent(1999, $styles.colors.type4, $strings.event1999),
    TimelineEvent(2000, $styles.colors.type4, $strings.event2000),
    TimelineEvent(2002, $styles.colors.type4, $strings.event2002),
    TimelineEvent(2003, $styles.colors.type3, $strings.event2003),
    TimelineEvent(2006, $styles.colors.type3, $strings.event2006),
    TimelineEvent(2008, $styles.colors.white, $strings.event2008),
  ];
}

