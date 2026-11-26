//
// GrandComicsDatabase.swift
// ComicInfoGrandComicsDatabase
//

import ComicInfo
import Foundation

/// Looks up comic details in the [Grand Comics Database](https://www.comics.org/).
///
/// ```swift
/// let grandComicsDatabase = GrandComicsDatabase(userAgent: "MyApp/1.0")
/// let matches = try await grandComicsDatabase.matches(for: issue)
/// let found = try await grandComicsDatabase.issue(for: matches[0])
/// let updated = issue.fillingBlanks(from: found)
/// ```
///
/// The GCD's data is licensed CC BY-SA 4.0: whatever shows it credits and links to the GCD.
/// Its API needs no key.
public struct GrandComicsDatabase: ComicInfo.MetadataSource {
  public let name = "Grand Comics Database"
  public let homeURL = URL(string: "https://www.comics.org/")!

  private let client: Client

  /// - Parameters:
  ///   - userAgent: Names the app, such as "MyApp/1.0".
  ///   - session: The URL session requests are made with.
  public init(userAgent: String, session: URLSession = .shared) {
    client = Client(userAgent: userAgent, session: session)
  }

  /// A sentence asking for a series, a number and a year when any is blank.
  ///
  /// The GCD matches series names by substring and lists them alphabetically, so without the year
  /// the series wanted is rarely among the results.
  public func missingDetails(for issue: ComicInfo.Issue) -> String? {
    guard Self.isBlank(issue.series) || Self.isBlank(issue.number) || issue.year == nil else { return nil }
    return "The Grand Comics Database needs a Series, a Number and a Year to search for."
  }

  public func matches(for issue: ComicInfo.Issue) async throws -> [ComicInfo.Match] {
    []
  }

  public func issue(for match: ComicInfo.Match) async throws -> ComicInfo.Issue {
    ComicInfo.Issue()
  }

  static func nonBlank(_ text: String?) -> String? {
    guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
    return text
  }

  private static func isBlank(_ text: String?) -> Bool { nonBlank(text) == nil }
}
