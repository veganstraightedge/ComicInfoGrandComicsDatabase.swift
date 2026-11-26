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

  @Test func testMatchesAreTheNumberedIssuesOfTheYearsSeriesExactNamesFirst() async throws {
    let matches = try await grandComicsDatabase.matches(for: issue)

    #expect(matches.map(\.id) == ["911609", "1015888", "946634"])
    let match = try #require(matches.first)
    #expect(match.heading == "Saga (2012 series) #1 [1st Printing]")
    #expect(match.series == "Saga")
    #expect(match.number == "1 [1st Printing]")
    #expect(match.coverDate == nil)
    #expect(match.title == nil)
    #expect(match.details == "March 2012")
    #expect(match.siteURL?.absoluteString == "https://www.comics.org/issue/911609/")
  }

  @Test func testSeriesNamesLeaveOutTheGCDsYearSuffix() {
    #expect(GrandComicsDatabase.seriesName("Saga (2012 series)") == "Saga")
    #expect(
      GrandComicsDatabase.seriesName("Demi: Erotic Saga of a Demoness (1996 ? series)")
        == "Demi: Erotic Saga of a Demoness")
    #expect(GrandComicsDatabase.seriesName("No Year Suffix") == "No Year Suffix")
  }

  @Test func testASeriesNameIsOnePartOfThePath() async throws {
    let slashed = ComicInfo.Issue(number: "1", series: "Spider-Man/Deadpool", year: 2016)

    #expect(try await grandComicsDatabase.matches(for: slashed).isEmpty)
  }

  @Test func testAnHTTPErrorIsAnError() async {
    let unnamed = GrandComicsDatabase(userAgent: "", session: FixtureURLProtocol.session)
    await #expect(throws: GrandComicsDatabaseError.httpStatus(403)) {
      try await unnamed.matches(for: issue)
    }
  }
}
