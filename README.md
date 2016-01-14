# xliff2strings

This tool generates `*.strings` files from `*.xliff`.

The main goal is to import a `xliff` file for _Development Language_ exported from Xcode. Import for non-development languages works as well.

Note: If the tool doesn't see a `<target/>` for a `<trans-unit/>` in a `xliff` file (it's very common for development language `xliff`s), it takes a string from a corresponding `<source/>`.

## Usage

```
xliff2strings XLIFF_PATH OUTPUT_DIR
```

## Installation

1. Clone the repository
2. Open project with Xcode
3. Build project
4. Select `Products/xliff2strings`, open a context menu and select "Show in Finder"
5. Move the binary to a proper directory
