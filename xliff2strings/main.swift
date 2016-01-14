//
//  main.swift
//  xliff2strings
//
//  Created by Andrew Pleshkov on 12.01.16.
//  Copyright © 2016 Andrew Pleshkov. All rights reserved.
//

import Foundation


class Parser: NSObject {
    
    struct File {
        
        let name: String
        
        var units = [TransUnit]()
        
        init(name: String) {
            self.name = name
        }
        
    }
    
    struct TransUnit {
        
        let key: String
        var value: String {
            return (target ?? source ?? key)
        }
        
        var source: String?
        var target: String?
        
        init(key: String) {
            self.key = key
        }
        
    }
    
    private var parser: NSXMLParser!
    
    private var files = [File]()
    
    private var currentString = ""
    private var currentFile: File?
    private var currentTransUnit: TransUnit?
    
    init(data: NSData) {
        super.init()
        
        parser = NSXMLParser(data: data)
        parser.delegate = self
    }
    
    func parse() -> [File] {
        self.files.removeAll()
        parser.parse()
        return self.files
    }
    
}

extension Parser : NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "file": {
            if let path = attributeDict["original"] {
                let url = NSURL(fileURLWithPath: path)
                if url.pathExtension == "strings", let name = url.lastPathComponent {
                    self.currentFile = File(name: name)
                }
            }
        }()
        case "trans-unit": {
            if let key = attributeDict["id"] {
                self.currentTransUnit = TransUnit(key: key)
                
            }
        }()
        default: currentString = ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "file": {
            if let file = self.currentFile {
                self.files.append(file)
            }
            self.currentFile = nil
        }()
        case "trans-unit": {
            if let unit = self.currentTransUnit {
                self.currentFile?.units.append(unit)
            }
            self.currentTransUnit = nil
        }()
        case "source": currentTransUnit?.source = currentString
        case "target": currentTransUnit?.target = currentString
        default: currentString = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentString += string
    }
    
}

// MARK: main

if Process.argc < 3 {
    print("Usage: xliff2strings XLIFF_PATH OUTPUT_DIR")
    exit(1)
}

let xliffPath = Process.arguments[1]
let outputDir = Process.arguments[2]

guard let data = NSData(contentsOfFile: xliffPath) else {
    print("Cannot read file \(xliffPath)")
    exit(1)
}

let fileManager = NSFileManager.defaultManager()

if !fileManager.fileExistsAtPath(outputDir) {
    do {
        try fileManager.createDirectoryAtPath(outputDir, withIntermediateDirectories: false, attributes: nil)
    } catch {
        print("Unable to create \(outputDir)")
        exit(1)
    }
}

print("Ouput: \(outputDir)\n")
for file in Parser(data: data).parse() {
    let url = NSURL(fileURLWithPath: outputDir).URLByAppendingPathComponent(file.name)
    var lines = [String]()
    for unit in file.units {
        let line = "\"\(unit.key)\" = \"\(unit.value)\";"
        lines.append(line)
    }
    do {
        try lines.joinWithSeparator("\n").writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        print("\(file.name) saved")
    } catch {
        print("\(file.name) failed to save")
    }
}
