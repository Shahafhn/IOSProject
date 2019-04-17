

import UIKit

class ProfilesView:UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var wasSet:Bool = false
    var lblTitle:UILabel!
    var txfSearchbar:UITextField!
    var tableView:UITableView!
    var lblInformation:UILabel!
    var informationView:UIView!
    var viewChanger:SegmentedViewChanger!
    var profiles:[(String,Int)]? = []
    var max:Int = 0
    
    
    func setFields(viewChanger: SegmentedViewChanger){
        wasSet = true
        self.viewChanger = viewChanger
        lblTitle = UILabel(frame: CGRect(x: 10, y: 10, width: frame.maxX - 20, height: 30))
        lblTitle.text = "Search for profiles:"
        
        txfSearchbar = UITextField(frame: CGRect(x: 10, y: lblTitle.frame.maxY + 20, width: frame.maxX - 20, height: 30))
        txfSearchbar.borderStyle = .roundedRect
        txfSearchbar.placeholder = "Type name..."
        txfSearchbar.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        
        let cgFrame = CGRect(x: frame.minX, y: txfSearchbar.frame.maxY + 10, width: frame.maxX, height: frame.maxY - txfSearchbar.frame.maxY - 180)
        informationView = UIView(frame: cgFrame)
        informationView.isHidden = true
        
        tableView = UITableView(frame: cgFrame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        
        lblInformation = UILabel(frame: CGRect(x: 10, y: informationView.frame.minY + 15, width: frame.maxX - 20, height: 40))
        lblInformation.font = UIFont.boldSystemFont(ofSize: 25)
        lblInformation.textColor = UIColor.black
        
        addSubview(tableView)
        addSubview(informationView)
        informationView.addSubview(lblInformation)
        addSubview(lblTitle)
        addSubview(txfSearchbar)
        textChanged(sender: txfSearchbar)
    }
    
    @objc func textChanged(sender:UITextField){
        if let text = sender.text{
            tableView.isHidden = true
            informationView.isHidden = false
            lblInformation.text = "Loading..."
            ServerConnection.searchNames(look: text,onComplete: refreshList)
        }
    }
    
    func refreshList(data:[(String,Int)]?, cap:Int){
        profiles = data
        max = cap
        if profiles != nil{
            tableView.reloadData()
            informationView.isHidden = true
            tableView.isHidden = false
        }else{
            informationView.isHidden = false
            tableView.isHidden = true
            lblInformation.text = "No Results."
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.viewChanger.changeSelectedView(name: self.profiles![indexPath.row].0, num: self.profiles![indexPath.row].1)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let checkProfile = UITableViewRowAction(style: .normal, title: "Profile") { (action, index) in
            DispatchQueue.main.async(execute: {
                self.viewChanger.changeSelectedView(name: self.profiles![indexPath.row].0, num: self.profiles![indexPath.row].1)
            })
        }
        checkProfile.backgroundColor = UIColor.blue
        return [checkProfile]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "profiles")
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "profiles")
        }
        cell!.textLabel?.text = profiles![indexPath.row].0
        cell!.detailTextLabel?.text = "images: \(profiles![indexPath.row].1)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
