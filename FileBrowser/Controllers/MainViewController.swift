//
//  MainViewController.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewStylToggleButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Network Manager
    private let googleSSDownloader = GoogleSpreadSheetDownloader()
    
    //MARK: - File Manager
    private let fileManager = GSSFileManager()
    
    //MARK: - Properties
    private var isListView = false {
        didSet {
            collectionViewStylToggleButton.image = isListView ? AppImages.systemListImage : AppImages.systemGridImage
        }
    }
    
    //MARK: - IBActions
    @IBAction private func toogleBeetwenGridAndListStyle(_sender: UIBarButtonItem) {
        isListView.toggle()
    }
    
    @IBAction private func backToPreviousFolder(_ sender: UIBarButtonItem) {
        let folder = fileManager.currentFolder
        fileManager.showContentFolder(withUUID: folder.parentUUID)
    }
    
    @IBAction private func addItem(_ sender: UIBarButtonItem) {
        if sender.title == "File" {
            fileManager.addToFolderItem(type: .f)
        } else if sender.title == "Folder" {
            fileManager.addToFolderItem(type: .d)
        }
    }

    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fileManager.delegate = self
        fetchData()
    }
    
    //MARK: - Methods
    private func fetchData() {
        googleSSDownloader.fetchData() { [weak self] data in
            guard let spreadSheetData = data.values as? [[String]] else { return }
            self?.fileManager.generateFileSystems(from: spreadSheetData)
        }
    }
}

//MARK: - UICollectionViewDelegate
extension MainViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = fileManager.currentFolder.contents[indexPath.row]
        fileManager.showContentFolder(withUUID: item.uuid)
    }
}

//MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fileManager.currentFolder.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.identifier, for: indexPath) as? ItemCell else { return  UICollectionViewCell() }
                
        let folder = fileManager.currentFolder
        
        title = "\(folder.name)"
        
        let item = folder.contents[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
}


//MARK: - GSSFileManagerDelegate
extension MainViewController: GSSFileManagerDelegate {
    func addNewItem() {
        collectionView.reloadData()
    }
    
    func currentFolderChange() {
        collectionView.reloadData()
    }
    func fileSystemWasGenerated() {
        collectionView.reloadData()
        activityIndicator.stopAnimating()
    }
}
