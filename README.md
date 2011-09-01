# Tracker --- track blocks of time from the command line

Tracker.pl, v0.1 (Sep 1, 2011)  
Written by Adam Sharp  

## Description

Tracker is a utility for Mac OS X that allows you to quickly make a record of how much time you've spent on various tasks throughout the day.

Work logs are stored in `/Users/yourusername/Documents/Tracker/` with the format `YEAR-MONTH-DAY-time-log.txt`.

An example work log that Tracker will create:

    2011-09-01
    30: nap
    45: procrastinate
    30: uni
    120: tracker

## Installation

Either:

- Copy Tracker.pl to somewhere in your `PATH`

OR

- Copy Tracker.pl to the destination of your choice and create a symlink to tracker in your path, e.g.:

        $ ln -s /path/to/Tracker.pl /usr/bin/track

Adam recommends either creating a symlink called `track` or if you just put Tracker.pl in your `PATH` then create it as an alias like so:

    $ alias track=Tracker.pl

If you don't happen to have Tracker.pl you could also do this:

    $ alias track=/path/to/Tracker.pl

## Usage

    Tracker.pl <minutes> <description>   # => data entry
    Tracker.pl -r                        # => reporting
    Tracker.pl -l                        # => list today's work

Where `<minutes>` is an integer signifying how much time has been spent and `<description>` is a string containing a brief description of the activity (one word is best, but can be any length of string).

Make sure to use

    $ Tracker.pl 30 "Foo bar"
    
and not

    $ Tracker.pl 30 Foo bar

as the description will be truncated to "Foo".

## To do

- Make the personal time search more configurable by putting keywords to search in an array
- Reporting feature (calculate total work done for each task)
- Report on days other than today
- More robust command line args
- Add a `-h` usage/help switch
- More time formats than just minutes, e.g., handle `###<denom>` where `##` is a decimal number rounded to the nearest 15 minutes (1, 1.5, 0.25) and `<denom>` is some modifier such as `h/hr/hour`, `m/min/minute`. Also, no `<denom>` defaults to minutes.
- Offer support for an environment variable that defines the default start time (currently hard coded to 8:00 AM)

## Change log

### v0.1

Added:

- Tracker.pl -l will now tell you what time you've logged time until. For example, if your start time is 8:00 AM and you've logged 3 hours, it will output the following:
    
        Hours logged until 11:00 AM (since 8:00 AM).

Changed:

- `-l` and `-r` switches are now synonyms
- Formatting improvements
