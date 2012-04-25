# Change log

## v0.0.1 (2012-04-26)

Fixed (94929f0):

* Exception when tracking first time for day. Removed an erroneous call
  to sprintf instead of strftime. Also ensured use of integers when
  calculating current time in minutes.

## v0.0.0 (2012-04-25)

Tracker is now known as trak, and it's a RubyGem!

Changed:

* Trak has now been ported from Perl to Ruby. The main reason for this
  was for the ability to support the awesome gem Chronic for natural
  language date parsing in an upcoming release. But beyond that,
  RubyGems is fantastic for packaging and distribution and the plan is
  to make this code seriously more modular over the next little while
  (the code is a joke at the moment :O).

## v0.4 (2011-10-17)

Added:

* If the EDITOR environment variable is set, this is now used by default
  to edit a log file with `track -e`.

* The current time is displayed at the end of the report, like so:

        # Today's logged work
        ...
        Hours logged until 9:30 AM (since 9:15 AM). Currently 10:13 AM.

## v0.3

Added:

* Report now calculates the total time spent on each task throughout the
  day
* Time can now be logged as either minutes or hours. The time argument
  can take the format `##<denom>`, where `##` is the amount of time
  spent, and `<denom>` signifies hours (`h/hr/hour/hours`) or minutes
  (`m/min/minute/minutes`).

Changed:

* Report formatting improvements

Fixed:

* Time wrap-around bug where if time logged passed midnight AM/PM would
  display incorrectly.

## v0.2.1

Changed:

* Change log is now found in CHANGELOG.md rather than README.md.

Fixed:

* Fixed a bug where invoking with no arguments would create an entry in
  the log with no time or message. No arguments is a synonym for `-l` or
  `-r`.

## v0.2

Added:

* Tracker now automatically calculates the time you started your day
  based on your first log for that day. This is stored in the time log
  after the date, and used to calculate how far into the day you have
  tracked time.

Changed:

* Everything after the first argument (the amount of time) is now
  considered to be the task name (i.e., the task is no longer truncated
  to the first word).
* Formatting improvements

## v0.1

Added:

* Tracker.pl -l will now tell you what time you've logged time until.
  For example, if your start time is 8:00 AM and you've logged 3 hours,
  it will output the following:

        Hours logged until 11:00 AM (since 8:00 AM).

Changed:

* `-l` and `-r` switches are now synonyms
* Formatting improvements
