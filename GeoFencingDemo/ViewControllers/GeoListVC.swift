import UIKit
import CoreLocation
class GeoListVC: UITableViewController {
    //------------------------------------------------------------------------------
    // MARK:- Variables & IBOutlets
    //------------------------------------------------------------------------------
    var geotifications            = Locations.fetchGeotifications()
    
    //------------------------------------------------------------------------------
    // MARK:- View Life Cycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Tableview Datasource Methods
    //------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if geotifications != nil {
            return geotifications!.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if self.geotifications != nil || self.geotifications!.count != 0 {
            
            let data_dic = self.geotifications![indexPath.row]
            var strEntry =  ""
            if data_dic.isEntry {
                strEntry = "Entry"
            } else {
                strEntry = "Exit"
            }
            cell.textLabel?.text = "\(indexPath.row + 1). \(data_dic.note) (\(strEntry))"
            
            cell.detailTextLabel?.text = "\(data_dic.radius) meters"
            
        }
        cell.selectionStyle = .none
        return cell
    }
    
}
