//
//  TableViewController.swift
//  ToDoList
//
//  Created by user on 14/06/22.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
   
    var tasks: [Task] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let objects = try? context.fetch(fetchRequest) {
            for obj in objects {
                context.delete(obj)
            }
        }
        
        do {
            try context.save()
            
        }catch let err as NSError {
            print(err.localizedDescription)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescr = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescr]
        do {
            tasks = try context.fetch(fetchRequest)
        }catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return tasks.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
  
    @IBAction func addTaskButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "please ad new task", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first // the first item on array
            if let newTask = tf?.text {
                self.saveTask(witTitle: newTask) //new task will always on first (Top) cell
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "cancel", style: .default, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    func saveTask(witTitle title: String) {
      
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
     
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.insert(taskObject, at: 0)
            
        }catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
      return appDelegate.persistentContainer.viewContext
    }
}
