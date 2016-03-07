//
//  Test1ViewController.swift
//  DiarioSwift5
//
//  Created by Miguel López Álvarez on 5/3/16.
//  Copyright © 2016 donmik.com. All rights reserved.
//

import UIKit

class Test1ViewController: UIViewController {
    
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
        
        // 1. Escuchar las notificaciones del teclado.
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Siempre hay que dejar de escuchar las notificaciones.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension Test1ViewController: UITextFieldDelegate {
    
    // Registro notificaciones teclado.
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Cuando el teclado se va a mostrar.
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
                // Además resto 8 más para darle holgura y no dejarlo pegado al teclado.
                let newViewY = viewFrameActual.height - puntoEsquinaIzquierdaInferiorActiveField.y - 8.0
                
                // Crear nuevo frame con la nueva Y. El resto de datos seguirá sin cambiar.
                let newViewFrame = CGRectMake(view.frame.origin.x, newViewY, view.frame.width, view.frame.height)
                
                // En conjunción con la duración de la animación del teclado.
                if let seconds = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(seconds) {
                        self.view.frame = newViewFrame
                    }
                }
            }
        }
    }
    
    // Cuando el teclado se va a ocultar.
    func keyboardWillHide(notification: NSNotification) {
        if let seconds = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            UIView.animateWithDuration(seconds) {
                self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
            }
        }
    }
    
    // Cuando un campo va a ser editado.
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    // Cuando un campo deja de ser editado.
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    // Método que controla el botón Siguiente e Ir.
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
    
    // Método que oculta el teclado cuando se toca en cualquier lugar de la vista.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}

