


import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    var loginView:UIView!
    var loadingView:UIView!
    var lblLoading:UILabel!
    var lblUsername:UILabel!
    var lblPassword:UILabel!
    var lblError:UILabel!
    var txfUsername:UITextField!
    var txfPassword:UITextField!
    var btnLogin:UIButton!
    var btnSignup:UIButton!
    var checkedBox:UIImage!
    var uncheckedBox:UIImage!
    var btnCheckbox:UIButton!
    var isChecked:Bool = false
    var lblRemember:UILabel!
    var homeController:HomeController!
    let prefs:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView = UIView(frame: view.frame)
        loadingView = UIView(frame: view.frame)
        loadingView.isHidden = true
        
        lblLoading = UILabel(frame: CGRect(x: 20, y: 120, width: view.frame.maxX - 40, height: 250))
        lblLoading.text = "Loading..."
        lblLoading.font = UIFont.boldSystemFont(ofSize: 50)
        
        lblUsername = UILabel(frame: CGRect(x: 60, y: 100, width: view.frame.maxX-100, height: 40))
        lblUsername.text = "Username:"
        lblUsername.font = UIFont.boldSystemFont(ofSize: 25)
        
        txfUsername = UITextField(frame: CGRect(x: 45, y: lblUsername.frame.maxY+20, width: view.frame.maxX/2, height: 25))
        txfUsername.placeholder = "username"
        txfUsername.font = UIFont.boldSystemFont(ofSize: 22)
        txfUsername.delegate = self
        
        lblError = UILabel(frame: CGRect(x: 60, y: txfUsername.frame.maxY + 10, width: view.frame.width - 100, height: 40))
        lblError.textColor = UIColor.red
        lblError.isHidden = true
        
        lblPassword = UILabel(frame: CGRect(x: 60, y: txfUsername.frame.maxY+60, width: view.frame.maxX-100, height: 40))
        lblPassword.text = "Password:"
        lblPassword.font = UIFont.boldSystemFont(ofSize: 25)
        
        txfPassword = UITextField(frame: CGRect(x: 45, y: lblPassword.frame.maxY+20, width: view.frame.maxX/2, height: 25))
        txfPassword.placeholder = "password"
        txfPassword.isSecureTextEntry = true
        txfPassword.font = UIFont.boldSystemFont(ofSize: 22)
        txfPassword.delegate = self
        
        checkedBox = UIImage(named: "checkedBox")
        uncheckedBox = UIImage(named: "uncheckedBox")
        btnCheckbox = UIButton(type: .system)
        btnCheckbox.frame = CGRect(x: 5, y: txfPassword.frame.maxY+20, width: 40, height: 40)
        btnCheckbox.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
        btnCheckbox.setImage(uncheckedBox, for: .normal)
        lblRemember = UILabel(frame: CGRect(x: btnCheckbox.frame.maxX+10, y: btnCheckbox.frame.minY, width: 250, height: 40))
        lblRemember.text = "Remember me!"
        lblRemember.font = UIFont.boldSystemFont(ofSize: 20)
        
        btnLogin = UIButton(type: .system)
        btnLogin.frame = CGRect(x: view.frame.maxX/2+10, y: txfPassword.frame.maxY+80, width: view.frame.maxX/2-20, height: 40)
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        btnLogin.tag = 1
        btnLogin.addTarget(self, action: #selector(login(sender:)), for: .touchUpInside)
        
        btnSignup = UIButton(type: .system)
        btnSignup.frame = CGRect(x: 10, y: txfPassword.frame.maxY+80, width: view.frame.maxX/2-20, height: 40)
        btnSignup.setTitle("Sign up", for: .normal)
        btnSignup.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        btnSignup.tag = 0
        btnSignup.addTarget(self, action: #selector(login(sender:)), for: .touchUpInside)
        
        loginView.addSubview(lblUsername)
        loginView.addSubview(lblPassword)
        loginView.addSubview(lblError)
        loginView.addSubview(txfUsername)
        loginView.addSubview(txfPassword)
        loginView.addSubview(btnLogin)
        loginView.addSubview(btnSignup)
        loginView.addSubview(btnCheckbox)
        loginView.addSubview(lblRemember)
        loadingView.addSubview(lblLoading)
        view.addSubview(loginView)
        view.addSubview(loadingView)
        
        let rem = prefs.bool(forKey: "remember")
        if rem{
            txfUsername.text = prefs.string(forKey: "user")
            txfPassword.text = prefs.string(forKey: "pass")
        }
    }
    
    @objc func onClick(sender:UIButton){
        isChecked = !isChecked
        if isChecked{
            sender.setImage(checkedBox, for: .normal)
        }else{
            sender.setImage(uncheckedBox, for: .normal)
        }
    }
    
    @objc func login(sender:UIButton){
        let count = txfUsername.text!.count
        let pCount = txfPassword.text!.count
        let isVerified:Bool = count > 3 && count < 15 && pCount > 3 && pCount < 15
        let remember:String = "remember"
        if isVerified{
            lblError.isHidden = true
            loginView.isHidden = true
            loadingView.isHidden = false
            txfUsername.resignFirstResponder()
            txfPassword.resignFirstResponder()
            ServerConnection.login(isNewUser: sender.tag == 0, username: txfUsername.text!, password: txfPassword.text!, onComplete: gotResponseCode)
            prefs.set(isChecked, forKey: "remember")
            prefs.set(txfUsername.text?.lowercased(), forKey: "user")
            prefs.set(txfPassword.text?.lowercased(), forKey: "pass")
        }else{
            prefs.set(false, forKey: remember)
            lblError.text = "Minimum: 4, Maximum: 14"
            lblError.isHidden = false
            prefs.set(false, forKey: "remember")
        }
        
    }
    
    func gotResponseCode(responseCode:Int){
        switch responseCode {
        case ServerConnection.USER_NOT_FOUND:
            lblError.text = "Username or Password incorrect"
            lblError.isHidden = false
            break
        case ServerConnection.USER_EXISTS:
            lblError.text = "Username already taken."
            lblError.isHidden = false
            break
        case ServerConnection.NO_INTERNET:
            lblError.text = "No internet connection"
            lblError.isHidden = false
            break
        default:
            homeController = HomeController()
            homeController.view.backgroundColor = view.backgroundColor
            txfUsername.text = nil
            txfPassword.text = nil
            if isChecked{
                onClick(sender: btnCheckbox)
            }
            homeController!.prefs = prefs
            present(homeController, animated: true, completion: nil)
            loadingView.isHidden = true
            loginView.isHidden = false
            return
        }
        loadingView.isHidden = true
        loginView.isHidden = false
        prefs.set(false, forKey: "remember")
    }
    
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txfUsername{
            if string.count == 1 {
                let current = string as NSString
                let c:CChar = CChar(current.character(at: 0))
                if c > 126 || c < 93 || c == 124{
                    if c > 91 || c < 64{
                        if c != 61 && c != 59{
                            if c > 57 || c < 48{
                                if c > 46 || c < 43{
                                    if c > 41 || c < 35{
                                        if c != 33{
                                            lblError.text = "No Hebrew, Spaces, or \\ / : * ? \" < > |"
                                            lblError.isHidden = false
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        lblError.isHidden = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if prefs.bool(forKey: "remember"){
            login(sender: btnLogin)
        }
    }
}
