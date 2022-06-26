//
//  MainViewController.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: -IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewStylToggleButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Network Manager
    private let googleSSDownloader = GoogleSpreadSheetDownloader()
    
    //MARK: - Properties
    private var folders = [Folder(name: "Root", type: .d)]
    private var items = [Item]()
    
    private var isListView = false {
        didSet {
            collectionViewStylToggleButton.image = isListView ? AppImages.systemListImage : AppImages.systemGridImage
        }
    }
    
    private var isLoadingDataToFoldersArrayCompleted = false
    
    private var currentFolderIndexPosition = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - IBActions
    @IBAction private func toogleBeetwenGridAndListStyle(_sender: UIBarButtonItem) {
        isListView.toggle()
    }
    
    @IBAction private func backToPreviousFolder(_ sender: UIBarButtonItem) {
        let folder = folders[currentFolderIndexPosition]
        showContentFolder(withUUID: folder.parentUUID)
    }
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
    }
    
    private func showContentFolder(withUUID itemUUID: UUID?) {
        guard itemUUID != nil else  {
            currentFolderIndexPosition = 0
            return
        }
        
        for (i,folder) in folders.enumerated() {
            if itemUUID == folder.uuid {
                currentFolderIndexPosition = i
                return
            }
        }
    }
    
    private func fetchData() {
        googleSSDownloader.fetchData() { [weak self] data in
            guard let spreadSheetData = data.values as? [[String]] else { return }
            
            for row in spreadSheetData {
                let uuid = row[0].isEmpty ? nil : UUID(uuidString: row[0])
                let parentuuid = row[1].isEmpty ? nil : UUID(uuidString: row[1])
                let item = row[2] == "f" ? Item(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .f) : Folder(name: row[3], uuid: uuid, parentUUID: parentuuid, type: .d)
                
                self?.items.append(item)
            }
            
            self?.recursive(parentUUID: nil)
            
            self?.isLoadingDataToFoldersArrayCompleted = true
            self?.collectionView.reloadData()
            
            self?.folders.forEach({ item in
                print(item.name)
            })
        }
    }
    
    func recursive(parentUUID: UUID?) {
        let folderIndex = folders.firstIndex(where: { $0.uuid == parentUUID})!
        items.forEach { item in
            if item.parentUUID == parentUUID {
                folders[folderIndex].contents.append(item)
                if item.type == .d {
                    folders.append(item as! Folder)
                    print("Call recusrsive with \(item.name)")
                    recursive(parentUUID: item.uuid)
                    collectionView.reloadData()
                }
            }
        }
    }
}

//MARK: - UICollectionViewDelegate
extension MainViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = folders[currentFolderIndexPosition].contents[indexPath.row]
        showContentFolder(withUUID: item.uuid)
    }
}

//MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        folders[currentFolderIndexPosition].contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileListTypeCollectionViewCell.identifier, for: indexPath) as? FileListTypeCollectionViewCell else { return  UICollectionViewCell() }
        
        if !isLoadingDataToFoldersArrayCompleted  { return cell }
        
        activityIndicator.stopAnimating()
        
        let folder = folders[currentFolderIndexPosition]
        title = "\(folder.name)"
        let item = folder.contents[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
}

