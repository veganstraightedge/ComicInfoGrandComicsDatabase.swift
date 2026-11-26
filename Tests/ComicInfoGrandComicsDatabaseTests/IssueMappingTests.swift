import ComicInfo
import Testing

@testable import ComicInfoGrandComicsDatabase

struct IssueMappingTests {
  @Test func testCreditNamesLeaveOutNotesNoneAndUncertainNames() {
    #expect(
      Credit.names("Fiona Staples (credited) (signed as FS); Brian K. Vaughan") == ["Fiona Staples", "Brian K. Vaughan"])
    #expect(Credit.names("Alana (featured) (first appearance of Alana); Lying Cat") == ["Alana", "Lying Cat"])
    #expect(Credit.names("Ted Adams [as Teddy] (credited)") == ["Ted Adams"])
    #expect(Credit.names("Jim Lee (pencils (layouts))") == ["Jim Lee"])
    #expect(Credit.names("Jim Lee ?; ?") == [])
    #expect(Credit.names("None") == [])
    #expect(Credit.names("") == [])
    #expect(Credit.names(nil) == [])
  }

  @Test func testTheSummaryIsTheComicStoriesSynopses() {
    let found = Responses.Issue(
      storySet: [
        Self.story(synopsis: "A cover.", type: "cover"),
        Self.story(synopsis: "Two deserters produce a child.", type: "comic story"),
        Self.story(synopsis: "They run.", type: "comic story"),
      ])

    let issue = IssueMapping(issue: found, id: 1).issue

    #expect(issue.summary == "Two deserters produce a child. They run.")
  }

  @Test func testTheTitleIsTheIssuesOwnBeforeItsFirstStorys() {
    let found = Responses.Issue(
      storySet: [Self.story(title: "Chapter One", type: "comic story")], title: "The Issue's Own")

    #expect(IssueMapping(issue: found, id: 1).issue.title == "The Issue's Own")
  }

  @Test func testAnUnknownMonthIsLeftOut() {
    let found = Responses.Issue(keyDate: "2012-00-00")
    let issue = IssueMapping(issue: found, id: 1).issue

    #expect(issue.year == 2012)
    #expect(issue.month == nil)
  }

  private static func story(synopsis: String? = nil, title: String? = nil, type: String) -> Responses.Story {
    Responses.Story(synopsis: synopsis, title: title, type: type)
  }
}
