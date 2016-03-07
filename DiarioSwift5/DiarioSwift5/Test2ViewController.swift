//
//  Test2ViewController.swift
//  DiarioSwift5
//
//  Created by Miguel López Álvarez on 5/3/16.
//  Copyright © 2016 donmik.com. All rights reserved.
//

import UIKit

class Test2ViewController: UIViewController {
    
    enum TextFieldTag: Int {
        case PrimerCampo = 0
        case SegundoCampo
    }
    
    weak var activeField: UITextField?
    
    @IBOutlet weak var primerCampo: UITextField!
    @IBOutlet weak var segundoCampo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension Test2ViewController: UITextFieldDelegate {
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let activeField = self.activeField else {
            // Si activeField es nil, no se hace nada.
            print("activeField es nil")
            return
        }
        
        // Recuperar el tamaño del teclado.
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            // Resetear el frame por si acaso.
            view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
            
            // Recuperar el frame actual de la view principal.
            var viewFrameActual = view.frame
            
            // Calcular la altura de la view principal restante al restarle la altura del teclado.
            viewFrameActual.size.height -= keyboardSize.height
            
            // Calcular el punto situado en la esquina izquierda inferior de activeField.
            // (x: x, y: origin.y + height)
            let puntoEsquinaIzquierdaInferiorActiveField = CGPoint(x: activeField.frame.origin.x, y: activeField.frame.origin.y + activeField.frame.height)
            
            // Comprobar si el punto de la esquina izquierda inferior de activeField está contenido
            // en la viewFrameActual visible (lo que se ve encima del teclado).
            if !CGRectContainsPoint(viewFrameActual, puntoEsquinaIzquierdaInferiorActiveField) {
                
                // El campo está oculto por el teclado.
                
                // Hay que mover la view principal hacia arriba.
                // Calcular el nuevo Y restando el punto inferior del campo Y a la viewFrameActual. 
                // Además resto 20 más para darle holgura y no dejarlo pegado al teclado.
                let newViewY = viewFrameActual.height - puntoEsquinaIzquierdaInferiorActiveField.y - 20
                
                // Crear nuevo frame con la nueva Y. El resto de datos seguirá sin cambiar.
                let newViewFrame = CGRectMake(viewFrameActual.origin.x, newViewY, viewFrameActual.width, viewFrameActual.height)
                
                // En conjunción con la duración de la animación del teclado.
                if let seconds = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(seconds) {
                        self.view.frame = newViewFrame
                    }
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let seconds = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            UIView.animateWithDuration(seconds) {
                self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let field = TextFieldTag(rawValue: textField.tag) else {
            print("No se conoce este texfield")
            return false
        }
        
        switch field {
        case .PrimerCampo:
            segundoCampo.becomeFirstResponder()
            
        case .SegundoCampo:
            segundoCampo.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}

