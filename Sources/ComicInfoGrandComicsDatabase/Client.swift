//
// Client.swift
// ComicInfoGrandComicsDatabase
//

import Foundation

/// Calls the Grand Comics Database API, which needs no key.
struct Client: Sendable {
  static let baseURL = URL(string: "https://www.comics.org/api/")!

  /// The characters kept as they are in one part of a path, which leaves out the slash.
  private static let pathSegmentAllowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))

  let userAgent: String
  let session: URLSession

  /// The issues numbered `number`, in series whose names contain `series`, from series that began in `year`.
  ///
  /// Only the first page of results is read.
  func findIssues(series: String, number: String, year: Int) async throws -> [Responses.IssueSummary] {
    let page: Responses.Page<Responses.IssueSummary> = try await get([
      "series", "name", series, "issue", number, "year", String(year),
    ])
    return page.results
  }

  /// One issue, stories and all.
  func issue(_ id: Int) async throws -> Responses.Issue {
    try await get(["issue", String(id)])
  }

  /// Calls one API resource, its path in `segments`, and decodes it.
  private func get<Resource: Decodable>(_ segments: [String]) async throws -> Resource {
    let escaped = segments.map { $0.addingPercentEncoding(withAllowedCharacters: Self.pathSegmentAllowed) ?? $0 }
    var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)!
    components.percentEncodedPath += escaped.joined(separator: "/") + "/"
    components.queryItems = [URLQueryItem(name: "format", value: "json")]

    var request = URLRequest(url: components.url!)
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    let (data, response) = try await session.data(for: request)

    if let response = response as? HTTPURLResponse, response.statusCode != 200 {
      throw GrandComicsDatabaseError.httpStatus(response.statusCode)
    }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Resource.self, from: data)
  }
}
