//
// GrandComicsDatabaseError.swift
// ComicInfoGrandComicsDatabase
//

import Foundation

/// Why a Grand Comics Database request failed.
public enum GrandComicsDatabaseError: Error, Equatable, LocalizedError {
  /// The GCD answered with an HTTP error status, such as 404 or 503.
  case httpStatus(Int)
  /// A match's ID isn't a GCD issue ID, which is a number.
  case invalidIssueID(String)

  public var errorDescription: String? {
    switch self {
    case .httpStatus(let status): "The Grand Comics Database answered with HTTP status \(status)."
    case .invalidIssueID(let id): "The Grand Comics Database has no issue with the ID \(id)."
    }
  }
}
