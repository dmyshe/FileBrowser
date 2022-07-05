//
//  GSSFileManager.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import Foundation

protocol GSSFileManagerDelegate: AnyObject {
    func currentFolderChange()
}

class GSSFileManager {
    var folders = [Folder(name: "Root", type: .d)]
    var items = [Item]()
    
    var currentFolderIndexPosition = 0 {
        didSet {
            delegate?.currentFolderChange()
        }
    }
    
    var currentFolder: Folder {
        folders[currentFolderIndexPosition]
    }
    
    
    weak var delegate: GSSFileManagerDelegate?
    
     func showContentFolder(withUUID itemUUID: UUID?) {
        guard itemUUID != nil else  {
            currentFolderIndexPosition = 0
            return
        }
        
        folders.enumerated().forEach { i,folder in
            if itemUUID == folder.uuid {
                currentFolderIndexPosition = i
            }
        }
    }
    
    private func recursive(parentUUID: UUID?) {
        let folderIndex = folders.firstIndex(where: { $0.uuid == parentUUID})!
        items.forEach { item in
            if item.parentUUID == parentUUID {
                folders[folderIndex].contents.append(item)
                if item.type == .d {
                    folders.append(item as! Folder)
                    print("Call recusrsive with \(item.name)")
                    recursive(parentUUID: item.uuid)
                }
            }
        }
    }
    
    
    func generateFileSystems(from spreadSheetData: [[String]]) {
        for row in spreadSheetData {
            let uuid = row[0].isEmpty ? nil : UUID(uuidString: row[0])
            let parentuuid = row[1].isEmpty ? nil : UUID(uuidString: row[1])
            
            let item = row[2] == "f" ? Item(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .f) : Folder(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .d)
            
            items.append(item)
        }
        
        recursive(parentUUID: nil)
    }
    
}
