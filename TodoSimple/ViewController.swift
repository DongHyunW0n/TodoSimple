//
//  ViewController.swift
//  TodoSimple
//
//  Created by WonDongHyun on 2022/12/04.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var doneButton: UIBarButtonItem?
    
    var tasks = [Task](){
        didSet{
            self.saveTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTab))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
    }

    
    @objc func doneButtonTab(){
        
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated:true)
        
    }
    
    
    
    
    @IBAction func tabAddButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "할 일 등록", message: "할 일을 입력하시오", preferredStyle: .alert)
        let registerbutton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?[0].text else {return}
            let task = Task(title: title, done: false)  // 아직 할 일이 끝나지 않았으므로, false
            self?.tasks.append(task) // 태스크 배열에 할 일 추가
            self?.tableView.reloadData() // 누를때마다 새로 재갱신
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerbutton)
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder =  "할 일을 입력하시오"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tabEditButton(_ sender: UIBarButtonItem) {
        
        guard !self.tasks.isEmpty else{return}
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    func saveTasks(){ 
        let data = self.tasks.map{
            [
                "title" : $0.title,
                "done" : $0.done
            ]
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    
    // taskloads
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = UserDefaults.standard.object(forKey: "tasks") as? [[String: Any]] else {return}
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)

        }
    }
    
    
    
}




extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic) //셀 삭제
        
        if self.tasks.isEmpty { //다 사라지면 초기화면으로
            self.doneButtonTab()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { //삭제하면 배열도 재정렬
        
        
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
    
    
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done  // 반대가 되게
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
