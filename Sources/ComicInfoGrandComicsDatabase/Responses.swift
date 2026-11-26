//
// Responses.swift
// ComicInfoGrandComicsDatabase
//

import Foundation

/// The Grand Comics Database's API responses, as far as they are read.
/// See https://www.comics.org/api/
enum Responses {
  /// A list response's first page.
  struct Page<Result: Decodable>: Decodable {
    let results: [Result]
  }

  /// An issue as the issue search returns it.
  struct IssueSummary: Decodable {
    /// The issue's API address, such as "https://www.comics.org/api/issue/911609/?format=json".
    let apiUrl: String
    /// The issue number and variant, such as "1 [1st Printing]".
    let descriptor: String?
    /// The date on the issue, as written, such as "March 2012".
    let publicationDate: String?
    /// The series' name and first year, such as "Saga (2012 series)".
    let seriesName: String?

    /// The issue's ID, read from the end of its API address.
    var id: Int? {
      URL(string: apiUrl).flatMap { Int($0.lastPathComponent) }
    }
  }
}
