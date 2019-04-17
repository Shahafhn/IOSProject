
import UIKit

class ImagesView:UIView,UITableViewDataSource,UITableViewDelegate{
    
    var wasSet:Bool = false
    var tableView:UITableView!
    var label:UILabel!
    var max:Int = 0
    var user:String = ""
    var images:[UIImage] = []
    
    func setUp(){
        label = UILabel(frame: CGRect(x: 5, y: 5, width: frame.width - 10, height: 30))
        label.text = user
        label.font = UIFont.boldSystemFont(ofSize: 25)
        
        tableView = UITableView(frame: CGRect(x: 5, y: 40, width: frame.width - 10, height: frame.height - 160), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "images")
        addSubview(label)
        addSubview(tableView)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "images")
        if cell == nil{
            cell = ImageTableViewCell(style: .subtitle, reuseIdentifier: "images")
        }
        if images.count != 0{
            (cell! as! ImageTableViewCell).mainImage.image = images[indexPath.row]
        }
        return cell!
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if images.count == 0{
            return frame.height
        }
        let currentImage = images[indexPath.row]
        let crop = currentImage.getRatio()
        return tableView.frame.width / crop
    }
    
    func reloadTable(name:String,num:Int){
        images.removeAll()
        max = num
        user = name
        DispatchQueue.main.async {
            self.label.text = self.user
        }
        if max > 0{
            ServerConnection.getImageData(name: user, num: 0, max: max, onComplete: onComplete(data:num:))
        }else{
            self.tableView.reloadData()
        }
    }
    
    func onComplete(data:Data,num:Int){
        images.append(UIImage(data:data)!)
        if num + 1 < max{
            ServerConnection.getImageData(name: user, num: num + 1, max: max, onComplete: onComplete(data:num:))
        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
}
    extension UIImage{
        func getRatio()->CGFloat{
            let ratio = CGFloat(self.size.width / self.size.height)
            return ratio
        }
    }
