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

  /// One issue's full detail.
  ///
  /// Everything may be missing, so each field starts out `nil`.
  struct Issue: Decodable {
    /// The publisher named in the issue's indicia, such as "Image Comics Inc.".
    var indiciaPublisher: String? = nil
    /// The date the issue is filed under, such as "2012-03-00", where 00 means unknown.
    var keyDate: String? = nil
    /// The issue number, without its variant.
    var number: String? = nil
    /// The series' name and first year, such as "Saga (2012 series)".
    var seriesName: String? = nil
    /// The issue's sequences: its cover, comic stories, letters pages and so on.
    var storySet: [Story]? = nil
    /// The issue's own title, which most issues haven't got.
    var title: String? = nil
  }

  /// One sequence in an issue: a cover, a comic story, a letters page.
  ///
  /// Credits and characters are the GCD's strings, such as "Fiona Staples (credited) (signed as FS);
  /// Brian K. Vaughan", or "None".
  struct Story: Decodable {
    var characters: String? = nil
    var colors: String? = nil
    var editing: String? = nil
    /// The genres, separated by semicolons, such as "fantasy; science fiction".
    var genre: String? = nil
    var inks: String? = nil
    var letters: String? = nil
    var pencils: String? = nil
    var script: String? = nil
    var synopsis: String? = nil
    var title: String? = nil
    /// The kind of sequence, such as "cover" or "comic story".
    var type: String? = nil
  }
}
