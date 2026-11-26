import ComicInfo
import Foundation
import Testing

@testable import ComicInfoGrandComicsDatabase

struct GrandComicsDatabaseTests {
  private let grandComicsDatabase = GrandComicsDatabase(
    userAgent: FixtureURLProtocol.userAgent, session: FixtureURLProtocol.session)
  private let issue = ComicInfo.Issue(number: "1", series: "Saga", year: 2012)

  @Test func testItIsCreditedAsTheGrandComicsDatabase() {
    #expect(grandComicsDatabase.name == "Grand Comics Database")
    #expect(grandComicsDatabase.homeURL.absoluteString == "https://www.comics.org/")
  }

  @Test func testItNeedsASeriesANumberAndAYear() {
    let sentence = "The Grand Comics Database needs a Series, a Number and a Year to search for."

    #expect(grandComicsDatabase.missingDetails(for: issue) == nil)
    #expect(grandComicsDatabase.missingDetails(for: ComicInfo.Issue(number: "1", year: 2012)) == sentence)
    #expect(grandComicsDatabase.missingDetails(for: ComicInfo.Issue(series: "Saga", year: 2012)) == sentence)
    #expect(grandComicsDatabase.missingDetails(for: ComicInfo.Issue(number: "1", series: "Saga")) == sentence)
    #expect(grandComicsDatabase.missingDetails(for: ComicInfo.Issue(number: " ", series: "Saga", year: 2012)) == sentence)
  }
}
