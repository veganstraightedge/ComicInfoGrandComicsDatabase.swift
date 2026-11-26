//
// IssueMapping.swift
// ComicInfoGrandComicsDatabase
//

import ComicInfo
import Foundation

/// A Grand Comics Database issue, as a `ComicInfo.Issue`.
///
/// Credits, characters, genres and the summary come from the issue's comic stories; the cover artist
/// is whoever pencilled its cover.
struct IssueMapping {
  let issue: ComicInfo.Issue

  /// - Parameters:
  ///   - found: The GCD's detail for the issue.
  ///   - id: The GCD's ID for the issue, for its page on the GCD's site.
  init(issue found: Responses.Issue, id: Int) {
    let stories = (found.storySet ?? []).filter { $0.type == "comic story" }
    let covers = (found.storySet ?? []).filter { $0.type == "cover" }
    let keyDate = KeyDate(found.keyDate)
    // Most issues have no title of their own, only their stories have.
    let storyTitle = stories.lazy.compactMap { GrandComicsDatabase.nonBlank($0.title) }.first

    issue = ComicInfo.Issue(
      colorist: Credit.joined(stories.map(\.colors)),
      coverArtist: Credit.joined(covers.map(\.pencils)),
      editor: Credit.joined(stories.map(\.editing)),
      inker: Credit.joined(stories.map(\.inks)),
      letterer: Credit.joined(stories.map(\.letters)),
      month: keyDate.month,
      number: GrandComicsDatabase.nonBlank(found.number),
      penciller: Credit.joined(stories.map(\.pencils)),
      publisher: GrandComicsDatabase.nonBlank(found.indiciaPublisher),
      series: GrandComicsDatabase.nonBlank(found.seriesName.map(GrandComicsDatabase.seriesName)),
      summary: Self.synopses(stories),
      title: GrandComicsDatabase.nonBlank(found.title) ?? storyTitle,
      writer: Credit.joined(stories.map(\.script)),
      year: keyDate.year
    )
    .settingCharacters(Credit.everyone(stories.map(\.characters)))
    .settingGenres(Credit.names(stories.first?.genre))
    .settingWebLinks([GrandComicsDatabase.siteURL(issueID: id).absoluteString])
  }

  /// The comic stories' synopses, joined, or `nil` when none has one.
  private static func synopses(_ stories: [Responses.Story]) -> String? {
    GrandComicsDatabase.nonBlank(stories.compactMap { GrandComicsDatabase.nonBlank($0.synopsis) }.joined(separator: " "))
  }
}

/// A key date such as "2012-03-00", as a year and month.
///
/// The GCD writes 00 for a month or day it doesn't know. The day is left out.
private struct KeyDate {
  let year: Int?
  let month: Int?

  init(_ text: String?) {
    let parts = (text ?? "").split(separator: "-")
    year = parts.count >= 2 ? Int(parts[0]) : nil
    let month = parts.count >= 2 ? Int(parts[1]) : nil
    self.month = month.flatMap { (1...12).contains($0) ? $0 : nil }
  }
}

/// Reads the GCD's credit strings, such as "Fiona Staples (credited) (signed as FS); Brian K. Vaughan".
enum Credit {
  /// The names in a credit string.
  ///
  /// Notes in parentheses and brackets are left out, at any depth. So are "None" and names marked
  /// uncertain with "?".
  static func names(_ credit: String?) -> [String] {
    var outside = ""
    var depth = 0
    for character in credit ?? "" {
      switch character {
      case "(", "[": depth += 1
      case ")", "]": depth = max(0, depth - 1)
      default: if depth == 0 { outside.append(character) }
      }
    }

    return outside.split(separator: ";").compactMap { part in
      let name = part.trimmingCharacters(in: .whitespaces)
      guard !name.isEmpty, name != "None", !name.hasSuffix("?") else { return nil }
      return name
    }
  }

  /// Everyone the credit strings name, each once, in order.
  static func everyone(_ credits: [String?]) -> [String] {
    var people: [String] = []
    for person in credits.flatMap(names) where !people.contains(person) {
      people.append(person)
    }
    return people
  }

  /// Everyone the credit strings name, each once, joined with commas, or `nil` when no one is.
  static func joined(_ credits: [String?]) -> String? {
    let people = everyone(credits)
    return people.isEmpty ? nil : people.joined(separator: ", ")
  }
}
