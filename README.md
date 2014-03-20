ggi
===

Global Genome Initiative Portal for EOL's data

NOTES:

- We're still not sure how the values will be represented. CP tell us we are generating the value using queries against public APIs; new numbers will appear
  with each harvest. EA may be creating the connectors to create the values. It's a subset of what's on the repositories subtab of the data tab. [For
  example] [9]  ...We don't need to explain the methodolgy in the UI, but it might be part of the "about" UX. We're not sure where in the UI we will explain
  what each of the values actually represent. Currently it looks like we'll want a single value from each provider. ...But that's not yet entirely clear.
- Still undecided whether we'll b e calculating these values in real-time, or on harvest, or on some other special schedule.
- Not sure which taxonomy we'll be using ultimately; we may want to "fake" it until we choose. We'll likely have a hierarchy with mappings between names and
  EOL ids, and store this in a JSON file.
- The GGI portal will not be public until released in June.
- Download will look like the FALO file, but have multiple attributes for one row, with one taxon per row. We'll have raw scores next to each weighted
  score, and composite score at the end.
- There will be missing data.
- LW has an incomplete list of attributes. We should have a more complete list soon.

[![Continuous Integration Status][1]][2]
[![Coverage Status][3]][4]
[![CodePolice][5]][6]
[![Dependency Status][7]][8]

We're just starting out, here. Give us a few weeks to at least set up some tents, maybe build a campfire...

[1]: https://secure.travis-ci.org/EOL/ggi.png
[2]: http://travis-ci.org/EOL/ggi
[3]: https://coveralls.io/repos/EOL/ggi/badge.png?branch=master
[4]: https://coveralls.io/r/EOL/ggi?branch=master
[5]: https://codeclimate.com/github/EOL/ggi.png
[6]: https://codeclimate.com/github/EOL/ggi
[7]: https://gemnasium.com/EOL/ggi.png
[8]: https://gemnasium.com/EOL/ggi
[9]: http://eol.org/pages/1653/data?toc_id=349
