/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import PublishVE
import Files

final class SiteMapGenerationTests: PublishTestCase {
    func testGeneratingSiteMap() throws {
        let folder = try Folder.createTemporary()

        try publishWebsite(in: folder, using: [
            .addItem(.stub(withPath: "item")),
            .addPage(.stub(withPath: "page")),
            .generateSiteMap()
        ])

        let file = try folder.file(at: "Output/sitemap.xml")
        let siteMap = try file.readAsString()

        let expectedLocations = [
            "https://swiftbysundell.com/one",
            "https://swiftbysundell.com/one/item",
            "https://swiftbysundell.com/page"
        ]

        for location in expectedLocations {
            XCTAssertTrue(siteMap.contains("<loc>\(location)</loc>"))
        }
    }

    func testExcludingPathsFromSiteMap() throws {
        let folder = try Folder.createTemporary()

        let site = try publishWebsite(in: folder, using: [
            .addItem(.stub(withPath: "itemA")),
            .addItem(.stub(withPath: "itemB")),
            .addItem(.stub(withPath: "itemC", sectionID: .two)),
            .addItem(.stub(withPath: "itemD", sectionID: .two)),
            .addItem(.stub(withPath: "itemE", sectionID: .three)),
            .addItem(.stub(withPath: "posts/itemF", sectionID: .three)),
            .addPage(.stub(withPath: "pageA")),
            .addPage(.stub(withPath: "pageB")),
            .generateSiteMap(excluding: [
                "one/itemB",
                "two",
                "three/posts/",
                "pageB"
            ])
        ])

        let file = try folder.file(at: "Output/sitemap.xml")
        let siteMap = try file.readAsString()

        let expectedLocations = [
            "https://swiftbysundell.com/one",
            "https://swiftbysundell.com/one/itemA",
            "https://swiftbysundell.com/three/itemE",
            "https://swiftbysundell.com/pageA"
        ]

        let unexpectedLocations = [
            "https://swiftbysundell.com/one/itemB",
            "https://swiftbysundell.com/two",
            "https://swiftbysundell.com/two/itemC",
            "https://swiftbysundell.com/two/itemD",
            "https://swiftbysundell.com/three/posts/itemF",
            "https://swiftbysundell.com/pageB"
        ]

        for location in expectedLocations {
            XCTAssertTrue(siteMap.contains("<loc>\(location)</loc>"))
        }

        for location in unexpectedLocations {
            XCTAssertFalse(siteMap.contains("<loc>\(location)</loc>"))
        }

        XCTAssertNotNil(site.sections[.one].item(at: "itemB"))
        XCTAssertNotNil(site.sections[.two].item(at: "itemC"))
        XCTAssertNotNil(site.sections[.two].item(at: "itemD"))
        XCTAssertNotNil(site.sections[.three].item(at: "itemE"))
        XCTAssertNotNil(site.pages["pageB"])
    }
}
