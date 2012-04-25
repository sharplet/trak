# Trak: track chunks of time from the command line

Trak, v0.0.0 (Apr 25, 2012)  
Written by Adam Sharp

## Notice

Trak was recently (i.e., last week) a Perl script. It has been ported to
Ruby, but the code really looks like it's taken a beating and is
definitely NOT what I want it to ultimately look like. Much more
ruby-fying to happen yet, as well as support for the excellent
[Chronic](https://github.com/mojombo/chronic) gem for natural language
date parsing in the pipeline.

It's now structured as a RubyGem and should hopefully be available on
RubyGems soon.

Stay tuned.

## Description

Trak is a utility for Mac OS X that allows you to quickly make a record
of how much time you've spent on various tasks throughout the day.

Work logs are stored in `/Users/yourusername/Documents/Tracker/` with
the format `YEAR-MONTH-DAY-time-log.txt`.

An example work log that trak will create:

    2011-09-01 9:00
    30: nap
    45: procrastinate
    30: uni
    120: trak

## Installation

Check out this repository and then create a symlink to bin/trak
somewhere in your path:

        $ ln -s <repo>/bin/trak /usr/bin/trak

## Usage

    trak [-d|--date DATE] ##<denom> <description>  # => data entry
    trak [-d|--date DATE] [-r|-l]                  # => reporting
    trak [-d|--date DATE] -e                       # => manually edit time log

Where:

* `##` is a decimal signifying how much time has been spent.
* `<denom>` is either hours (`h/hr/hour/hours`) or minutes
  (`m/min/minute/minutes`). `<denom>` is optional and if ommitted,
  Tracker will interpret the time entered as minutes.
* `<description>` is a string containing a brief description of the
  activity.
* `DATE` is a string of the format `YYYY-MM-DD` which represents any
  date. This effects any of Tracker's modes, i.e., insertion, editing or
  reporting.

### Descriptions

You can use either

    $ trak 30 "Foo bar"
    
or

    $ trak 30 Foo bar

as everything after the first argument is considered the name of the
task.

### Entering time

These are all valid commands:

    $ trak 1h Write trak documentation       # => 1 hour
    $ trak 30min Rewrite trak documentation  # => 30 minutes
    $ trak 4hours Refactor trak              # => 4 hours
    $ trak 15 Lunch                          # => 15 minutes

## To do

* Proper handling of incorrectly formatted dates
* Write a report that gives a weekly breakdown given a date in that week
* Add a `-h` usage/help switch
* Make the personal time search more configurable by putting keywords to
  search in an array
* Have the different types of reports, and keywords for those reports,
  completely stored in a configuration file. The last category in the
  file is the default report. Because keywords for custom reports would
  work on a whitelist system, everything that doesn't match goes into
  the default. For example:

        # Personal
        lunch
        uni
        news
        # Default
        Work

* Have the keywords in the configuration file actually be regexes. When
  reading the config file, any empty lines or whitespace are ignored.
* Give an estimate of completion time, with a configurable default for
  the length of the work day. Also take into account the default length
  of lunch break (configurable) if lunch hasn't yet been logged.
