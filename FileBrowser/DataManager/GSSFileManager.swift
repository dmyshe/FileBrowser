//
//  GSSFileManager.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import Foundation

protocol GSSFileManagerDelegate: AnyObject {
    func currentFolderChange()
    func fileSystemWasGenerated()
    func addNewItem()
}

class GSSFileManager {
    //MARK: - Properties
    var currentFolder: Folder {
        folders[currentFolderIndexPosition]
    }
    
    //MARK: - Delegate
    weak var delegate: GSSFileManagerDelegate?
    
    private var folders = [Folder(name: "Root", type: .d)]
    private var items = [Item]()
    
    private var currentFolderIndexPosition = 0 {
        didSet {
            delegate?.currentFolderChange()
        }
    }
    
    //MARK: - Methods
    public func generateFileSystems(from spreadSheetData: [[String]]) {
        spreadSheetData.forEach { row in
            let uuid = row[0].isEmpty ? nil : UUID(uuidString: row[0])
            let parentuuid = row[1].isEmpty ? nil : UUID(uuidString: row[1])
            
            let file = Item(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .f)
            let folder = Folder(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .d)
            
            let newItem = row[2] == "f" ?  file  : folder
            
            items.append(newItem)
        }
                
        recursive(parentUUID: nil)
        delegate?.fileSystemWasGenerated()
    }
    
     public func showContentFolder(withUUID itemUUID: UUID?) {
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
    
    public func addToFolderItem(type: ItemType) {
        let folderUUID = currentFolder.uuid
        currentFolder.contents.append(Item(name: "New doc", uuid: UUID(uuidString: "A0986487"), parentUUID: folderUUID , type: type))
        delegate?.addNewItem()
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
}
