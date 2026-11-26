import Foundation

/// Answers Grand Comics Database API requests with the recorded responses in `Fixtures/`, as the GCD would.
///
/// A request not asking for JSON is refused, and so is one without the test User-Agent, so a passing
/// test shows both are sent.
final class FixtureURLProtocol: URLProtocol, @unchecked Sendable {
  static let userAgent = "ComicInfoGrandComicsDatabaseTests/1.0"

  /// The fixture file each API path is answered with, by its path as sent, percent-encoding and all.
  private static let files = [
    "/api/issue/911609/": "issue_911609",
    "/api/series/name/Saga/issue/1/year/2012/": "issues_saga_1_2012",
    "/api/series/name/Spider-Man%2FDeadpool/issue/1/year/2016/": "issues_none",
  ]

  /// A URL session whose requests are all answered here.
  static var session: URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [FixtureURLProtocol.self]
    return URLSession(configuration: configuration)
  }

  override class func canInit(with request: URLRequest) -> Bool { true }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    let (status, file) = answer()
    let body = file.flatMap(Self.fixture) ?? Data()
    let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: body)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}

  private func answer() -> (status: Int, file: String?) {
    guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return (400, nil)
    }
    let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
    guard query["format"] == "json" else { return (400, nil) }
    guard request.value(forHTTPHeaderField: "User-Agent") == Self.userAgent else { return (403, nil) }
    guard let file = Self.files[components.percentEncodedPath] else { return (404, nil) }
    return (200, file)
  }

  private static func fixture(_ name: String) -> Data? {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
      return nil
    }
    return try? Data(contentsOf: url)
  }
}
