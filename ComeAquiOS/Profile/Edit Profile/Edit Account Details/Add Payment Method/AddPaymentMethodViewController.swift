//
//  AddPaymentMethodViewController.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 11/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit
private class ResponseObject: Decodable {
    var error_message: String?
    var data: [PaymentMethodObject]?
}
class AddPaymentMethodViewController: LoadViewController {

    @IBOutlet weak var tableView: MyOwnTableView!
    
    var data: [PaymentMethodObject] = []
    var isChangeMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPaymentMethods()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardLookSegue" {
            let cardLookVC = segue.destination as? CardLookViewController
            cardLookVC?.paymentMethod = sender as? PaymentMethodObject
        }
    }
}
extension AddPaymentMethodViewController{
    func getPaymentMethods(){
        self.tableView.showActivityIndicator()
        Server.get("/my_payment_methods/"){ data, response, error in
            self.tableView.hideActivityIndicator()
            guard let data = data else {
                return
            }
            do {
                let responseO = try JSONDecoder().decode(ResponseObject.self, from: data)
                if responseO.error_message == nil {
                    self.data = responseO.data!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch _ {
                self.view.showToast(message: "Some error ocurred")
            }
        }
    }
    func selectAsDefaultPayment(_ paymentMethodId: String){
        
        Server.patch("/select_as_payment_method/" + paymentMethodId + "/",
            json: ["": ""]) { data, response, error in
            if let _ = error {
                self.view.showToast(message: "No internet connection")
            }
                        guard data != nil else {return}
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
        }
    }
}

extension AddPaymentMethodViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentMethodTableViewCell
        let paymentM = data[indexPath.row]
        cell.paymentType.text = paymentM.brand
        cell.paymentInfo.text = paymentM.last4
        if paymentM.chosen != nil && paymentM.chosen! {
            cell.checkImage.visibility = .visible
        } else {
            cell.checkImage.visibility = .gone
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let paymentM = data[indexPath.row]
        if isChangeMode {
            self.selectAsDefaultPayment(paymentM.id!)
        } else {
            performSegue(withIdentifier: "CardLookSegue", sender: paymentM)
        }
    }
}

