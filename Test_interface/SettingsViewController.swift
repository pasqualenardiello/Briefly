//
//  SettingsViewController.swift
//  Test_interface
//
//  Created by Pasquale Nardiello on 16/07/21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var switcher: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        slider.setValue(sumperc, animated: true)
        switcher.setOn(dosave, animated: true)
    }
    
    @IBAction func switcherToggled(_ sender: UISwitch) {
        dosave = sender.isOn
        defaults.set(dosave, forKey: "dosave")
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        slider.setValue(0.5, animated: true)
        sumperc = 0.5
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let t = Float(round(10*slider.value)/10)
        sumperc = t
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
