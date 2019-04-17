
import UIKit

class SettingsView:UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var username:String = ""
    var wasSet:Bool = false
    var lblUser:UILabel!
    var btnLogout:UIButton!
    var mainController:UIViewController!
    var btnUpload:UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUsername(controller:UIViewController, name:String){
        mainController = controller
        wasSet = true
        username = name
        lblUser = UILabel(frame: CGRect(x: 20, y: 20, width: frame.maxX - 40, height: 35))
        lblUser.text = "Welcome, \(username)"
        lblUser.font = UIFont.boldSystemFont(ofSize: 20)
        
        btnLogout = UIButton(type: .system)
        btnLogout.frame = CGRect(x: 20, y: lblUser.frame.maxY + 10, width: 100, height: 30)
        btnLogout.setTitle("Logout", for: .normal)
        btnLogout.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btnLogout.addTarget(self, action: #selector(doLogout(sender:)), for: .touchUpInside)
        
        btnUpload = UIButton(type: .system)
        btnUpload.frame = CGRect(x: 120, y: btnLogout.frame.maxY + 30, width: 200, height: 30)
        btnUpload.setTitle("Upload Image", for: .normal)
        btnUpload.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        btnUpload.addTarget(self, action: #selector(uploadPic(sender:)), for: .touchUpInside)
        
        addSubview(btnUpload)
        addSubview(btnLogout)
        addSubview(lblUser)
    }
    
    @objc func uploadPic(sender:UIButton){
        let src = UIImagePickerController.SourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(src) else {
            return
        }
        guard let arr = UIImagePickerController.availableMediaTypes(for: src) else {
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = src
        imagePickerController.mediaTypes = arr
        imagePickerController.delegate = self
        mainController.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func doLogout(sender:UIButton){
        UserDefaults.standard.set(false, forKey: "remember")
        mainController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true) {
            let alertController = UIAlertController(title: "Upload Image", message: "Do you want to upload this picture?", preferredStyle: .alert)
            alertController.addImage(image: image)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Upload", style: .default, handler: { (alert) in
                ServerConnection.uploadImageData(name: UserDefaults.standard.string(forKey: "user")!, data: image!.jpegData(compressionQuality: 0.5)!, onComplete: self.successfulUpload)
            }))
            self.mainController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func successfulUpload(){
        let alertController = UIAlertController(title: "Success", message: "Successfuly uploaded.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.mainController.present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UIAlertController{
    func addImage(image: UIImage?){
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image!.size
        var ratio:CGFloat!
        if imgSize.width > imgSize.height{
            ratio = maxSize.width / imgSize.width
        }else{
            ratio = maxSize.height / imgSize.height
        }
        let scale = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        var resizedImage = image!.imageWithSize(scale)
        if imgSize.height > imgSize.width{
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left,bottom: 0,right: 0))
        }
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
    }
}
extension UIImage{
    func imageWithSize(_ theSize:CGSize) -> UIImage{
        var scaledImageRect = CGRect.zero
        let aspectWidth = theSize.width / self.size.width
        let aspectHeight = theSize.height / self.size.height
        let aspectRatio = min(aspectWidth,aspectHeight)
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (theSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (theSize.height - scaledImageRect.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(theSize, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

