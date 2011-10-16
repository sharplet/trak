# Tracker --- track blocks of time from the command line

Tracker.pl, v0.3 (Sep 3, 2011)  
Written by Adam Sharp  

## Description

Tracker is a utility for Mac OS X that allows you to quickly make a record of
how much time you've spent on various tasks throughout the day.

Work logs are stored in `/Users/yourusername/Documents/Tracker/` with the format
`YEAR-MONTH-DAY-time-log.txt`.

An example work log that Tracker will create:

    2011-09-01 9:00
    30: nap
    45: procrastinate
    30: uni
    120: tracker

## Installation

Either:

- Copy Tracker.pl to somewhere in your `PATH`

OR

- Copy Tracker.pl to the destination of your choice and create a symlink to
  tracker in your path, e.g.:

        $ ln -s /path/to/Tracker.pl /usr/bin/track

Adam recommends either creating a symlink called `track` or if you just put
Tracker.pl in your `PATH` then create it as an alias like so:

    $ alias track=Tracker.pl

If you don't happen to have Tracker.pl you could also do this:

    $ alias track=/path/to/Tracker.pl

## Usage

    Tracker.pl ##<denom> <description>   # => data entry
    Tracker.pl [-r|-l]                   # => reporting

Where:

- `##` is a decimal signifying how much time has been spent.
- `<denom>` is either hours (`h/hr/hour/hours`) or minutes
  (`m/min/minute/minutes`). `<denom>` is optional and if ommitted, Tracker
  will interpret the time entered as minutes.
- `<description>` is a string containing a brief description of the activity.

### Descriptions

You can use either

    $ Tracker.pl 30 "Foo bar"
    
or

    $ Tracker.pl 30 Foo bar

as everything after the first argument is considered the name of the task.

### Entering time

These are all valid commands:

    $ Tracker.pl 1h Write Tracker documentation       # => 1 hour
    $ Tracker.pl 30min Rewrite Tracker documentation  # => 30 minutes
    $ Tracker.pl 4hours Refactor Tracker              # => 4 hours
    $ Tracker.pl 15 Lunch                             # => 15 minutes

## To do

- Report on days other than today
- More robust command line args
- Add a `-h` usage/help switch
- Make the personal time search more configurable by putting keywords to
  search in an array
- Have the different types of reports, and keywords for those reports,
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

- Have the keywords in the configuration file actually be regexes. When
  reading the config file, any empty lines or whitespace are ignored.
- Give an estimate of completion time, with a configurable default for
  the length of the work day. Also take into account the default length
  of lunch break (configurable) if lunch hasn't yet been logged.
