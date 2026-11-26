//
// Client.swift
// ComicInfoGrandComicsDatabase
//

import Foundation

/// Calls the Grand Comics Database API, which needs no key.
struct Client: Sendable {
  static let baseURL = URL(string: "https://www.comics.org/api/")!

  let userAgent: String
  let session: URLSession
}
