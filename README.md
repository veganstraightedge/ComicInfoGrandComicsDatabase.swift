# ComicInfoGrandComicsDatabase.swift

Looks up comic details in the [Grand Comics Database](https://www.comics.org/) (GCD), for [ComicInfo.swift](https://github.com/veganstraightedge/ComicInfo.swift).

`GrandComicsDatabase` is a `ComicInfo.MetadataSource`: it searches the GCD for an issue, and returns what the GCD knows about the one picked as a `ComicInfo.Issue`. See [Looking Up Details in Online Databases](https://github.com/veganstraightedge/ComicInfo.swift/blob/main/doc/metadata-sources.md).

Its Ruby counterpart is [comicinfo-grand_comics_database](https://github.com/veganstraightedge/comicinfo-grand_comics_database).

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/veganstraightedge/ComicInfoGrandComicsDatabase.swift.git", from: "0.1.0")
]
```

## Usage

```swift
import ComicInfo
import ComicInfoGrandComicsDatabase

let grandComicsDatabase = GrandComicsDatabase(userAgent: "MyApp/1.0")

let issue = ComicInfo.Issue(number: "1", series: "Saga", year: 2012)
let matches = try await grandComicsDatabase.matches(for: issue)    // best first
let found = try await grandComicsDatabase.issue(for: matches[0])   // after a person picks one
let updated = issue.fillingBlanks(from: found)
```

- `matches(for:)` needs a Series, a Number and a Year; `missingDetails(for:)` says so when any is blank. The GCD matches series names by substring and lists them alphabetically, so the year, the year the series began, narrows them to the one wanted.
- It finds the issue with the comic's number in every series from that year whose name contains the comic's series, and ranks series named exactly as the comic's first. A match's `series` leaves out the GCD's " (2012 series)" suffix; its `heading` keeps it, and its `details` are the issue's publication date, such as "March 2012".
- `issue(for:)` reads the issue: series, number, title (its own, or its first comic story's), year and month, indicia publisher, summary (its comic stories' synopses), credits by role, characters and genres from its comic stories, the cover artist from its cover, and the issue's GCD page as its web link.
- A request the GCD refuses throws `GrandComicsDatabaseError.httpStatus`, and a match ID that isn't a GCD issue ID throws `GrandComicsDatabaseError.invalidIssueID`.

## Terms

- The GCD's API needs no key.
- The GCD's data is licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/): whatever shows it must credit and link to the Grand Comics Database (`grandComicsDatabase.name`, `grandComicsDatabase.homeURL`), and share what's made from it under the same license.
- `userAgent` names your app to the GCD.

## Requirements

- Swift 6.4+
- macOS 27+ or iOS 27+

## Development

```sh
script/test     # swift test
script/lint     # swift format lint --strict
script/format   # swift format --in-place
```

The tests answer every request with a recorded GCD response from `Tests/ComicInfoGrandComicsDatabaseTests/Fixtures/`, so they need no network.

## License

[MIT](LICENSE.md)
