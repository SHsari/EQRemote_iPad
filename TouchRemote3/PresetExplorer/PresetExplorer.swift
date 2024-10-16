//
//  PresetManager.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/13/24.
//

import Foundation
import UIKit

let defaultURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

enum FileExpMode {
    case save, load
}

protocol FileExplorerVCDelegate: AnyObject {
    func presetLoaded(_ preset: [OneBand])
}

class FileExplorerViewController: UIViewController {
    
    var filesTableView: UITableView!
    var mode: FileExpMode
    var currentDirectory: URL
    var directories: [URL] = []
    var files: [URL] = []
    var savePreset: [OneBand]
    weak var delegate: FileExplorerVCDelegate?
    
    var loadButton = UIBarButtonItem()
    
    var selectedIndex: IndexPath?
    
    init(startingDirectory: URL = defaultURL, mode: FileExpMode, savePreset: [OneBand] = [], delegate: FileExplorerVCDelegate?) {
        self.currentDirectory = startingDirectory
        self.mode = mode
        self.savePreset = savePreset
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 내비게이션바에 "폴더 추가" 버튼 추가
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filesTableView = UITableView()
        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "fc")
        
        // 테이블 뷰를 뷰에 추가
        view.addSubview(filesTableView)
        
        // Auto Layout을 사용할 것이므로 아래 코드를 추가
        filesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout Constraints 설정 (화면 전체에 테이블 뷰가 표시되도록)
        NSLayoutConstraint.activate([
            filesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filesTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            filesTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            filesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        configureNavigationBar()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        filesTableView.addGestureRecognizer(longPressGesture)
        loadContents()
    }
    
    func loadContents() {
        let contents = Explorer.contentsOfDirectory(at: currentDirectory) ?? []
        directories = contents.filter { $0.hasDirectoryPath }
        files = contents.filter { !$0.hasDirectoryPath && $0.pathExtension == "eqpst" }
        filesTableView.reloadData()
    }
    
    func configureNavigationBar() {
        if mode == .save {
            let addFolderBtn = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(addFolder))
            let saveBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveHere))
            navigationItem.rightBarButtonItems = [addFolderBtn, saveBtn]
        } else if mode == .load {
            loadButton = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(loadSelectedFile))
            loadButton.isEnabled = false
            navigationItem.rightBarButtonItems = [loadButton]
            
        }
    }
    
    // 폴더 추가 버튼 구현
    @objc func addFolder() {
        let alertController = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Folder Name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let folderName = alertController.textFields?.first?.text, !folderName.isEmpty {
                Explorer.createFolder(named: folderName, at: self.currentDirectory)
                self.loadContents()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func saveHere() {
        let count = savePreset.count
        guard count == 4 || count == 8 else { return }//에러처리하기(오류 Alert, dismiss)
        
        let alertController = UIAlertController(title: "Save Preset", message: "Enter File Name", preferredStyle: .alert)
        alertController.addTextField { textField in textField.placeholder = "File name" }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let fileName = alertController.textFields?.first?.text, !fileName.isEmpty else { return }
            Explorer.save(preset: savePreset, name: fileName, at: currentDirectory)
            dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func loadSelectedFile() {
        guard let selectedIndex = selectedIndex else { return }
        if let preset = Explorer.load(file: files[selectedIndex.row]) {
            dismiss(animated: true){ [weak self] in
                self?.delegate?.presetLoaded(preset)
            }
        }
    }

    

    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.filesTableView)
            if let indexPath = self.filesTableView.indexPathForRow(at: point) {
                var fileURL: URL
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                if indexPath.section == 0 { fileURL = directories[indexPath.row] }
                else { // file 선택시
                    fileURL = files[indexPath.row]
                    let fileName = fileURL.deletingPathExtension().lastPathComponent
                    if mode == .save {
                        let overwriteAction = UIAlertAction(title: "Overwrite", style: .destructive) { [weak self] _ in guard let self = self else { return }
                            showConfirmPrompt(title: "Overwirte", message: "Sure want to overwrite \"\(fileName)?\"") { confirmed in
                                if confirmed {
                                    Explorer.save(preset: self.savePreset, name: fileName, at: self.currentDirectory)
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                        alertController.addAction(overwriteAction)
                    } else if mode == .load {
                        let loadAction = UIAlertAction(title: "Load", style: .default) { [weak self] _ in
                            guard let self = self else { return }
                            if let preset = Explorer.load(file: fileURL){
                                dismiss(animated: true){
                                    self.delegate?.presetLoaded(preset)
                                }
                            }
                        }
                        alertController.addAction(loadAction)
                    }
                }

                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let fileName = fileURL.deletingPathExtension().lastPathComponent
                    showConfirmPrompt(title: "Delete EQPreset", message: "Sure want to delete preset \"\(fileName)?\"") { confirmed in
                        if confirmed {
                            Explorer.deleteItem(at: fileURL)
                            self.loadContents()
                        }
                    }
                }
                
                let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
                    self.showRenamePrompt(for: fileURL)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(deleteAction)
                alertController.addAction(renameAction)
                alertController.addAction(cancelAction)
                
                // iPad 대응 (iOS에서는 ActionSheet가 iPad에서 crash 방지용)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
                }
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func showConfirmPrompt(title: String, message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            completion(true)  // OK 선택됨
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)  // Cancel 선택됨
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showRenamePrompt(for fileURL: URL) {
        let alertController = UIAlertController(title: "Rename", message: "Enter a new name", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = fileURL.deletingPathExtension().lastPathComponent
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                Explorer.renameItem(at: fileURL, to: newName)
                self.loadContents()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(renameAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension FileExplorerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return directories.count }
        else { return files.count }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Folders"}
        else { return "Presets" }
    }
    
    // 테이블뷰에 셀을 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fc", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if indexPath.section == 0 {
            let directoryURL = directories[indexPath.row]
            content.text = directoryURL.lastPathComponent
            content.image = UIImage(named: "folder")
            cell.accessoryType = .disclosureIndicator
        } else {
            let fileURL = files[indexPath.row]
            content.text = fileURL.deletingPathExtension().lastPathComponent
            cell.accessoryType = .none
        }
        cell.contentConfiguration = content
        return cell
    }
    
    // 셀이 선택되었을 때 하위 폴더로 진입하거나 파일을 열도록 설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let dURL = directories[indexPath.row]
            let newExplorerVC = FileExplorerViewController(startingDirectory: dURL, mode: self.mode, savePreset: savePreset, delegate: delegate)
            navigationController?.pushViewController(newExplorerVC, animated: true)
        } else {
            if mode == .load {
                if selectedIndex == indexPath {
                    guard let cell = tableView.cellForRow(at: indexPath) else { return }
                    selectedIndex = nil
                    cell.accessoryType = .none
                    loadButton.isEnabled = false
                }
                else {
                    if let selectedIndex = selectedIndex {
                        if let cell = tableView.cellForRow(at: selectedIndex) {
                            cell.accessoryType = .none
                        }
                    }
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                        selectedIndex = indexPath
                        loadButton.isEnabled = true
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    
}


fileprivate struct Explorer {
    static func contentsOfDirectory(at path: URL) -> [URL]? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            return contents
        } catch {
            print("Failed to list contents of directory: \(error)")
            return nil
        }
    }
    
    
    static func createFolder(named folderName: String, at path: URL) {
        let newFolderURL = path.appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: false, attributes: nil)
            print("Folder created at: \(newFolderURL.path)")
        } catch {
            print("Failed to create folder: \(error.localizedDescription)")
        }
    }
    
    static func deleteItem(at path: URL) {
        do {
            try FileManager.default.removeItem(at: path)
            print("Deleted item at: \(path.path)")
        } catch {
            print("Failed to delete item: \(error.localizedDescription)")
        }
    }
    
    
    static func renameItem(at fileURL: URL, to newName: String) {
        let newURL = fileURL.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(fileURL.pathExtension)
        
        do {
            try FileManager.default.moveItem(at: fileURL, to: newURL)
            print("File renamed to \(newURL.lastPathComponent)")
        } catch {
            print("Failed to rename file: \(error)")
        }
    }
    
    
    static func save(preset: [OneBand], name: String, at dirURL: URL) {
        let fileURL = dirURL.appendingPathComponent("\(name).eqpst")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(preset)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save file: \(error)")
        }// 오류처리 로직
    }
    
    static func load(file: URL) -> [OneBand]? {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: file)
            let preset = try decoder.decode([OneBand].self, from: data)
            return preset
        } catch {
            print("Failed to load preset: \(error.localizedDescription)")
            return nil
        }
    }
}
