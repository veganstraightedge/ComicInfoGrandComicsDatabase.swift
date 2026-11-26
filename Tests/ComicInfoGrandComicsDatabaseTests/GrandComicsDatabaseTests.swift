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

  @Test func testTheIssueHasEverythingTheGCDKnows() async throws {
    let match = try #require(try await grandComicsDatabase.matches(for: issue).first)
    let found = try await grandComicsDatabase.issue(for: match)

    #expect(found.series == "Saga")
    #expect(found.number == "1")
    #expect(found.title == "Chapter One")
    #expect(found.year == 2012)
    #expect(found.month == 3)
    #expect(found.day == nil)
    #expect(found.publisher == "Image Comics Inc.")
    #expect(found.genres == ["fantasy", "science fiction"])
    #expect(found.summary == nil)
    #expect(found.webLinks == ["https://www.comics.org/issue/911609/"])
  }

  @Test func testCreditsGoToTheirRoles() async throws {
    let match = try #require(try await grandComicsDatabase.matches(for: issue).first)
    let found = try await grandComicsDatabase.issue(for: match)

    #expect(found.writer == "Brian K. Vaughan")
    #expect(found.penciller == "Fiona Staples")
    #expect(found.inker == "Fiona Staples")
    #expect(found.colorist == "Fiona Staples")
    #expect(found.letterer == "Fonografiks, Fiona Staples")
    #expect(found.editor == nil)
    #expect(found.coverArtist == "Fiona Staples")
    #expect(found.characters == ["Alana", "Hazel", "Marko"])
  }

  @Test func testAMatchIDThatIsNotANumberIsAnError() async {
    let match = ComicInfo.Match(id: "saga-1", heading: "Saga #1", series: "Saga")
    await #expect(throws: GrandComicsDatabaseError.invalidIssueID("saga-1")) {
      try await grandComicsDatabase.issue(for: match)
    }
  }

  @Test func testAnUnknownIssueIsAnHTTPError() async {
    let match = ComicInfo.Match(id: "1", heading: "Nothing #1", series: "Nothing")
    await #expect(throws: GrandComicsDatabaseError.httpStatus(404)) {
      try await grandComicsDatabase.issue(for: match)
    }
  }

  @Test func testAnHTTPErrorIsAnError() async {
    let unnamed = GrandComicsDatabase(userAgent: "", session: FixtureURLProtocol.session)
    await #expect(throws: GrandComicsDatabaseError.httpStatus(403)) {
      try await unnamed.matches(for: issue)
    }
  }
}
