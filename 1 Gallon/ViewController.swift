//
//  ViewController.swift
//  1 Gallon
//
//  Created by Christian Raroque on 11/10/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit
import CoreData
import Timepiece
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var waterLog = [waterEntry]()
    var waterLogObjects = [NSManagedObject]()
    var chosenHolder = HolderType()
    
    var goal = 128.0
    var goalMetric = "oz"
    
    @IBOutlet weak var drinkLogTableView: UITableView!
    @IBOutlet weak var talkingBottleTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.drinkLogTableView.delegate = self
        self.drinkLogTableView.dataSource = self
        
        loadData()
        updateMessage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUserSettings()
        updateMessage()
    }
    
    func updateMessage() {
        var amountDrank = 0.0
        var amountLeft = 0.0
        
        for entry in waterLog {
            amountDrank = amountDrank + entry.amount
        }
        
        amountLeft = goal - amountDrank
        
        let numberOfHoldersLeft = Int(ceil(amountLeft / self.chosenHolder.amount))
        
        if amountLeft > 0 {
            self.talkingBottleTextView.text = "You drank \(amountDrank) \(goalMetric) today (\(amountLeft) \(goalMetric) to hit a gallon). Just drink \(numberOfHoldersLeft) \(self.chosenHolder.name) and you'll be good to go!"
        } else {
            self.talkingBottleTextView.text = "Congrats you drank a gallon of water today! You drank \(amountDrank) \(goalMetric) total"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserSettings() {
        // The day today (start of the day)
        let today = Date()
        let cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        _ = cal!.startOfDay(for: today)
        
        var context: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.managedObjectContext!
        }
        
        // Pull the last entry
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
        let sortDescriptor = NSSortDescriptor(key: "datesaved", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        
        do {
            let results =
                try context?.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            for entry in entries {
                
                var item = HolderType()
                
                
                if let weightTemp = entry.value(forKey: "amount") as? Double {
                    item.amount = weightTemp
                }
                
                if let typeTemp = entry.value(forKey: "name") as? String {
                    item.name = typeTemp as String
                }
                
                if let metricTemp = entry.value(forKey: "metric") as? String {
                    item.metric = metricTemp as String
                }
                
                self.chosenHolder = item
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func loadData() {
        NSLog("load Data")
        
        self.waterLog.removeAll(keepingCapacity: false)
        self.waterLogObjects.removeAll(keepingCapacity: false)
        // The day today (start of the day)
        var today = Date()
        var cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let startOfDay = cal!.startOfDay(for: today)
        
        var context: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.managedObjectContext!
        }
        
        // Pull the last entry
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        fetchRequest.predicate = NSPredicate(format: "startofday == %@", startOfDay as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: NSError?
        
        do {
            let results =
                try context?.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            for entry in entries {
                
                var item = waterEntry()
                if let timestampTemp = entry.value(forKey: "timestamp") as? Date {
                    item.timestamp = timestampTemp as NSDate
                }
                
                if let weightTemp = entry.value(forKey: "amount") as? Double {
                    item.amount = weightTemp
                }
                
                if let startOfDayTemp = entry.value(forKey: "startofday") as? Date {
                    item.startOfDay = startOfDayTemp as NSDate
                }
                
                
                if let typeTemp = entry.value(forKey: "type") as? String {
                    item.type = typeTemp as String
                }
                
                if let metricTemp = entry.value(forKey: "metric") as? String {
                    item.metric = metricTemp as String
                }
                
                self.waterLog.append(item)
                self.waterLogObjects.append(entry)
                self.drinkLogTableView.reloadData()
                NSLog("there is \(self.waterLog.count) items")
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func LogDrinkAction(_ sender: Any) {
        var today = Date()
        var cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let startOfDay = cal!.startOfDay(for: today)
        
        // Done posting
        var context: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.managedObjectContext!
        }
        
        let entity =  NSEntityDescription.entity(forEntityName: "Entry",
                                                 in:
            context!)
        let waterEntry = NSManagedObject(entity: entity!,
                                          insertInto:context)
        
        waterEntry.setValue(NSDate(), forKey: "timestamp")
        waterEntry.setValue(chosenHolder.amount, forKey: "amount")
        waterEntry.setValue(chosenHolder.name, forKey: "type")
        waterEntry.setValue(chosenHolder.metric, forKey: "metric")
        waterEntry.setValue(startOfDay, forKey: "startofday")
        
        do {
            try context?.save()
            NSLog("saved it")
            loadData()
            updateMessage()
        } catch _ {
            NSLog("lol")
        }
    }
    
    // TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waterLog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item = waterLog[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell") as! DrinkLogTableViewCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        let dateString = formatter.string(from: item.timestamp as Date)
        
        cell.descLabel.text = "You had 1 \(item.type) (\(item.amount) \(item.metric))"
        cell.timeLabel.text = "\(dateString)"
        
        if(indexPath.row == 0) {
            cell.topBarLine.isHidden = true
        } else {
            cell.topBarLine.isHidden = false
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var context: NSManagedObjectContext?
            
            if #available(iOS 10.0, *) {
                context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
                context = appDelegate.managedObjectContext!
            }
            
            context?.delete(waterLogObjects[indexPath.row])
            do {
                try context?.save()
                NSLog("saved the delete")
                waterLog.remove(at: indexPath.row)
                waterLogObjects.remove(at: indexPath.row)
                drinkLogTableView.deleteRows(at: [indexPath], with: .fade)
                updateMessage()
            } catch _ {
                NSLog("lol")
            }
        }
    }

}

class waterEntry: NSObject {
    var amount = 0.0
    var timestamp = NSDate()
    var metric = "ml"
    var startOfDay = NSDate()
    var type = "Glass of water"
}

/// NSPersistentStoreCoordinator extension
extension NSPersistentStoreCoordinator {
    
    /// NSPersistentStoreCoordinator error types
    public enum CoordinatorError: Error {
        /// .momd file not found
        case modelFileNotFound
        /// NSManagedObjectModel creation fail
        case modelCreationError
        /// Gettings document directory fail
        case storePathNotFound
    }
    
    /// Return NSPersistentStoreCoordinator object
    static func coordinator(name: String) throws -> NSPersistentStoreCoordinator? {
        
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            throw CoordinatorError.modelFileNotFound
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoordinatorError.modelCreationError
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            throw CoordinatorError.storePathNotFound
        }
        
        do {
            let url = documents.appendingPathComponent("\(name).sqlite")
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true,
                            NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            throw error
        }
        
        return coordinator
    }
}

struct Storage {
    
    static var shared = Storage()
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            print("CoreData: Inited \(storeDescription)")
            guard error == nil else {
                print("CoreData: Unresolved error \(error)")
                return
            }
        }
        return container
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(name: "Model")
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: Public methods
    
    enum SaveStatus {
        case saved, rolledBack, hasNoChanges
    }
    
    var context: NSManagedObjectContext {
        mutating get {
            if #available(iOS 10.0, *) {
                return persistentContainer.viewContext
            } else {
                return managedObjectContext
            }
        }
    }
    
    mutating func save() -> SaveStatus {
        if context.hasChanges {
            do {
                try context.save()
                return .saved
            } catch {
                context.rollback()
                return .rolledBack
            }
        }
        return .hasNoChanges
    }
    
}

