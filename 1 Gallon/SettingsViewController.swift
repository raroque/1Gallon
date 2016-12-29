//
//  SettingsViewController.swift
//  1 Gallon
//
//  Created by Christian Raroque on 11/26/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var typeTableView: UITableView!
    @IBOutlet weak var noTypesLabel: UILabel!
    
    var goal = 128.0
    
    var metric = "oz"
    var names = ["Glass of water", "Google Water Bottle", "Wolf Water Bottle", "Rand Cup of Water"]
    var amounts = [8.0,22.0,35.0,15.0]
    
    var holders = [HolderType]()
    var holderObjects = [NSManagedObject]()
    var chosenHolder = HolderType()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.typeTableView.delegate = self
        self.typeTableView.dataSource = self
        
        loadSettings()
    }
    
    func loadGlassTypesFromCore() {
        
        self.holders.removeAll(keepingCapacity: false)
        self.holderObjects.removeAll(keepingCapacity: false)
        
        var managedContext: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            managedContext = appDelegate.managedObjectContext!
        }
        
        // Pull the last entry
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GlassType")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: NSError?
        
        do {
            let results =
                try managedContext?.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            for entry in entries {
                
                var item = HolderType()
                if let timestampTemp = entry.value(forKey: "timestamp") as? Date {
                    item.timestamp = timestampTemp as NSDate
                }
                
                if let weightTemp = entry.value(forKey: "amount") as? Double {
                    item.amount = weightTemp
                }
                
                
                if let typeTemp = entry.value(forKey: "name") as? String {
                    item.name = typeTemp as String
                }
                
                if let metricTemp = entry.value(forKey: "metric") as? String {
                    item.metric = metricTemp as String
                }
                
                if(item.name == chosenHolder.name && item.amount == chosenHolder.amount && item.metric == chosenHolder.metric) {
                    item.selected = true
                } else {
                    item.selected = false
                }
                
                self.holders.append(item)
                self.holderObjects.append(entry)
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if(holders.count == 0) {
            self.noTypesLabel.isHidden = false
        } else {
            self.noTypesLabel.isHidden = true
        }
        self.typeTableView.reloadData()
    }
/*
    func loadValues() {
        self.holders.removeAll(keepingCapacity: false)
        
        for i in stride(from: 0,to: names.count, by: 1) {
            var newHolder = HolderType()
            newHolder.name = names[i]
            newHolder.amount = amounts[i]
            newHolder.metric = metric
            
            if(newHolder.name == chosenHolder.name && newHolder.amount == chosenHolder.amount && newHolder.metric == chosenHolder.metric) {
                newHolder.selected = true
            } else {
                newHolder.selected = false
            }
            
            self.holders.append(newHolder)
        }
        
        self.typeTableView.reloadData()
    }*/
    
    func loadSettings() {
        // The day today (start of the day)
        let today = Date()
        var cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let startOfDay = cal!.startOfDay(for: today)
        
        var managedContext: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            managedContext = appDelegate.managedObjectContext!
        }
        
        // Pull the last entry
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
        let sortDescriptor = NSSortDescriptor(key: "datesaved", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        
        do {
            let results =
                try managedContext?.fetch(fetchRequest)
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
        
        self.loadGlassTypesFromCore()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.holders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var holderItem = self.holders[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell") as! TypeTableViewCell
        
        cell.typeLabel.text = "\(holderItem.name)"
        cell.amountLabel.text = "\(holderItem.amount) \(holderItem.metric)"
        
        if holderItem.selected {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var holderItem = self.holders[indexPath.row]
        
        var managedContext: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            managedContext = appDelegate.managedObjectContext!
        }
        
        let entity =  NSEntityDescription.entity(forEntityName: "Setting",
                                                 in:
            managedContext!)
        let settingEntry = NSManagedObject(entity: entity!,
                                         insertInto:managedContext)
        
        settingEntry.setValue(holderItem.amount, forKey: "amount")
        settingEntry.setValue(holderItem.name, forKey: "name")
        settingEntry.setValue(holderItem.metric, forKey: "metric")
        settingEntry.setValue(self.goal, forKey: "goal")
        settingEntry.setValue(NSDate(), forKey: "datesaved")
        
        do {
            try managedContext?.save()
            NSLog("saved it")
            self.typeTableView.deselectRow(at: indexPath, animated: true)
            self.loadSettings()
        } catch _ {
            NSLog("lol")
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addHolder(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        let name = alert.addTextField("Glass/Bottle name")
        let amount = alert.addTextField("Amount (\(metric))")
        
        
        
        alert.addButton("Add Glass/Bottle") {
            if (name.text?.isEmpty)! || (amount.text?.isEmpty)! {
                
            } else {
                var managedContext: NSManagedObjectContext?
                
                if #available(iOS 10.0, *) {
                    managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                } else {
                    // Fallback on earlier versions
                    let appDelegate =
                        UIApplication.shared.delegate as! AppDelegate
                    managedContext = appDelegate.managedObjectContext!
                }
                
                let entity =  NSEntityDescription.entity(forEntityName: "GlassType",
                                                         in:
                    managedContext!)
                let glassEntry = NSManagedObject(entity: entity!,
                                                 insertInto:managedContext)
                
                glassEntry.setValue(NSDate(), forKey: "timestamp")
                glassEntry.setValue(Double(amount.text!), forKey: "amount")
                glassEntry.setValue(name.text, forKey: "name")
                glassEntry.setValue(self.metric, forKey: "metric")
                
                do {
                    try managedContext?.save()
                    NSLog("saved glass type")
                    // begin save settings
                    var managedContext: NSManagedObjectContext?
                    
                    if #available(iOS 10.0, *) {
                        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    } else {
                        // Fallback on earlier versions
                        let appDelegate =
                            UIApplication.shared.delegate as! AppDelegate
                        managedContext = appDelegate.managedObjectContext!
                    }
                    
                    let entity =  NSEntityDescription.entity(forEntityName: "Setting",
                                                             in:
                        managedContext!)
                    let settingEntry = NSManagedObject(entity: entity!,
                                                       insertInto:managedContext)
                    
                    settingEntry.setValue(Double(amount.text!), forKey: "amount")
                    settingEntry.setValue(name.text, forKey: "name")
                    settingEntry.setValue(self.metric, forKey: "metric")
                    settingEntry.setValue(self.goal, forKey: "goal")
                    settingEntry.setValue(NSDate(), forKey: "datesaved")
                    
                    do {
                        try managedContext?.save()
                        NSLog("saved it")
                        self.loadSettings()
                    } catch _ {
                        NSLog("lol")
                    }
                    // end save settings
            //        self.loadGlassTypesFromCore()
                } catch _ {
                    NSLog("lol")
                }
            }
        }
        
        alert.addButton("Cancel") {
            
        }
        
        alert.showCustom("New Glass/Bottle", subTitle: "💧🌊🐳", color: colorWithHexString("00B0FF"), icon: UIImage(named: "drop")!)
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var managedContext: NSManagedObjectContext?
            
            if #available(iOS 10.0, *) {
                managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
                managedContext = appDelegate.managedObjectContext!
            }
            
            managedContext?.delete(self.holderObjects[indexPath.row])
            do {
                try managedContext?.save()
                NSLog("saved the delete")
                holders.remove(at: indexPath.row)
                holderObjects.remove(at: indexPath.row)
                typeTableView.deleteRows(at: [indexPath], with: .fade)
            } catch _ {
                NSLog("lol")
            }
        }
    }
    
    func colorWithHexString (_ hex:String) -> UIColor {
        //   var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercased()
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class HolderType: NSObject {
    var amount = 8.0
    var name = "Glass of water"
    var metric = "oz"
    var selected = false
    var timestamp = NSDate()
}
