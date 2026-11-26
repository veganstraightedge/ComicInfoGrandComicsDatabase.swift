# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **`GrandComicsDatabase`**, a `ComicInfo.MetadataSource` for the [Grand Comics Database](https://www.comics.org/). `matches(for:)` needs a series, number and year, and finds the issue with the comic's number in every series from that year whose name contains the comic's series, exact series names first. `issue(for:)` reads the picked issue into a `ComicInfo.Issue`: series, number, title, year and month, indicia publisher, summary, credits by role, characters, genres, cover artist, and its GCD page.
- **`GrandComicsDatabaseError`**: an HTTP error status, or a match ID that isn't a GCD issue ID.
