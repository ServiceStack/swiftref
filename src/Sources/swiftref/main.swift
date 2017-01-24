import Foundation

func printUsage() -> Int32 {
    print("\nUsage:")
    print("\nAdd a new ServiceStack Reference:")
    print("  swiftref {BaseUrl} {FileName}")
    print("\nUpdate an existing ServiceStack Reference:")
    print("  swiftref {FileName.dtos.swift}")
    print("")
    return 0
}

func withoutSlash(_ path:String) -> String {
    return path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
}

func currentDirPath() -> String {
    return "/" + withoutSlash(FileManager.default.currentDirectoryPath) + "/"
}

func urlEncode(_ val:String) -> String? {
    return val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
}

func saveReference(_ url:URL, _ fileName:String) {
    let filePath = currentDirPath() + fileName

    var dtos = ""
    do {
        dtos = try String(contentsOf: url)
    } catch {}

    if !dtos.contains("Options:") {
        print("ERROR: Invalid Response from \(url)")
        exit(-1)
    }

    do {
        let filePathExists = FileManager.default.fileExists(atPath: filePath)

        try dtos.write(toFile: filePath, atomically: false, encoding: .utf8)

        if !filePathExists {
            print("Saved to: \(fileName)")
        } else {
            print("Updated: \(fileName)")
        }
    } catch let e {
        print("ERROR: Could not write DTOs to \(filePath)\n\(e)")
        exit(-1)
    }

    let clientSrcPath = currentDirPath() + "JsonServiceClient.swift"
    if !FileManager.default.fileExists(atPath: clientSrcPath) {
        do {
            let clientSrcUrl = URL(string: "https://servicestack.net/dist/swiftref/JsonServiceClient.swift")!
            let clientSrc = try String(contentsOf: clientSrcUrl)
            if !clientSrc.contains("JsonServiceClient") {
                print("ERROR: Invalid Response from \(clientSrcUrl)")
                exit(-1)
            }

            try clientSrc.write(toFile: clientSrcPath, atomically: false, encoding: .utf8)
            print("Imported: JsonServiceClient.swift")
        } catch {
            print("ERROR: Could not save JsonServiceClient.swift")
            exit(-1)
        }
    }
}

if CommandLine.arguments.count <= 1 || CommandLine.arguments.count > 3 {
    exit(printUsage())
}

let target = CommandLine.arguments[1]

if target.contains("://") {

    var url = URL(string: target)!
    if !target.contains("/types/swift") {
        url = URL(string: withoutSlash(target) + "/types/swift")!
    }

    var fileName = "Reference.dtos.swift"

    if CommandLine.arguments.count > 2 && !CommandLine.arguments[2].isEmpty {
        fileName = CommandLine.arguments[2]
    } else {
        if let hostPart = url.host?.components(separatedBy: ".")[0] {
            fileName = hostPart
        }
    }

    if !fileName.hasSuffix(".dtos.swift") {
        fileName = fileName + ".dtos.swift"
    }

    saveReference(url, fileName)    

} else {

    let existingRefPath = currentDirPath() + target

    if !FileManager.default.fileExists(atPath: existingRefPath) {
        print("\(target) does not exist")
    }

    do {
        let existingRefSrc = try String(contentsOfFile: existingRefPath, encoding: .utf8)

        if !existingRefSrc.contains("Options:") {
            print("ERROR: \(target) is not an existing Swift ServiceStack Reference")
            exit(-1)
        }

        var options = [String:String]()
        var baseUrl: String?

        existingRefSrc.enumerateLines {
            (line, stop) in

            if (line.hasPrefix("BaseUrl: ")) {
                baseUrl = line.substring(from: line.index(line.startIndex, offsetBy: 9))
            } else if baseUrl != nil {
                if !line.isEmpty && !line.hasPrefix("//") {
                    if let sep = line.range(of: ":") {
                        let key = line.substring(to:line.index(before: sep.upperBound))
                        let val = line.substring(from:line.index(after: sep.upperBound))
                        options[key] = val
                    }
                }
            }

            if line.hasPrefix("*/") { stop = true }
        }

        if baseUrl == nil {
            print("ERROR: Could not find baseUrl in \(target)")
            exit(-1)
        }

        var qs = ""
        for (key,val) in options {
            qs += qs.characters.count == 0 ? "?" : "&"
            qs += "\(key)=\(urlEncode(val)!)"
        }

        let url = URL(string: withoutSlash(baseUrl!) + "/types/swift" + qs)!

        saveReference(url, target)    
                
    } catch var e {
        print("ERROR: Could not read \(target)")
        exit(-1)
    }
}


