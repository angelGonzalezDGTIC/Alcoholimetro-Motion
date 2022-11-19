//
//  ViewController.swift
//  Alcoholimetro
//
//  Created by Ángel González on 03/06/22.
//

import UIKit
import CoreMotion
import Messages
import MessageUI

class ViewController: UIViewController {
    @IBOutlet weak var Cronometro: UILabel!
    
    @IBAction func btnCompartirTouch(_ sender: Any) {
            // PARA COMPARTIR A TODAS LAS APPS COMPATIBLES CON ActivityViewController
            let objetosParaCompartir:[Any] = ["Terminé el juego en \(self.count)"]
            // el argumento "applicationActivities se usa para especificar a que apps queremos compartir, o si preferimos usar la configuración actual del usuario, pasamos nil
            let ac = UIActivityViewController(activityItems:objetosParaCompartir, applicationActivities: nil)
            self.present(ac, animated: true)
    }
    
    
    
    var targetView:UIView?
    var movingView:UIView?
    var refX:CGFloat = 0.0
    var refY:CGFloat = 0.0
    let motionManager = CMMotionManager()
    
    var timer: Timer?
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let W = self.view.bounds.size.width / 6
        let H = self.view.bounds.size.height / 6
        self.targetView = UIView(frame:CGRect(x:0,
                                              y:0,
                                              width: W,
                                              height: H))
        self.targetView!.backgroundColor = UIColor.purple
        self.targetView?.center = self.view.center
        self.view.addSubview(self.targetView!)
        self.movingView = UIView(frame:CGRect(x:0,
                                              y:100,
                                              width: W,
                                              height: H))
        self.movingView!.backgroundColor = UIColor.green
        self.view.addSubview(self.movingView!)
        refX = trunc((self.targetView?.frame.minX)!)
        refY = trunc((self.targetView?.frame.minY)!)
        iniciaAcelerometro()
        start()
    }

    
    func iniciaAcelerometro () {
            let stepMoveFactor:Double = 50.0
            motionManager.startAccelerometerUpdates()
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main){
                (data, error) in
                var rect = self.movingView!.frame
                // obtenemos la nueva posicion x/y de la vista y mutiplicamos por el factor de desplazamiento para que sea mas visible que la subview se mueve
                let movetoX  = rect.origin.x + CGFloat((data?.acceleration.x)! * stepMoveFactor)
                let movetoY  = rect.origin.y - CGFloat((data?.acceleration.y)! * stepMoveFactor)
                // calculamos que no se vaya a salir de la pantalla
                let maxX = self.view.frame.width - rect.width
                let maxY = self.view.frame.height - rect.height
                if movetoX > 0 && movetoX < maxX {
                    rect.origin.x = movetoX
                }
                if ( movetoY > 0 && movetoY < maxY ) {
                    rect.origin.y = movetoY
                }
                // ajutamos la nueva posicion de la vista
                self.movingView!.frame = rect
                // comprobamos si ya quedó en la posiciòn deseada (sobre la vista objetivo)
                if ((trunc(rect.minX) == self.refX ||
                    trunc(rect.minX) == self.refX - 1 ||
                    trunc(rect.minX) == self.refX + 1) &&
                    (trunc(rect.minY) == self.refY ||
                        trunc(rect.minY) == self.refY - 1 ||
                        trunc(rect.minY) == self.refY + 1)) {
                    self.motionManager.stopAccelerometerUpdates()
                    self.endGame()
                    self.count = 0
                    self.Cronometro.text = "Timer"
                    }
                }
    }
    
    func endGame(){
        self.stop()
        let alert = UIAlertController(title: "Ganaste!", message: "Bien hecho! todavia puedes beber otra cerveza tiempo que tardaste \(self.count) quieres compartir tu score!!", preferredStyle: .alert)
        let ac1 = UIAlertAction(title: "OK", style: .default)
        // square.and.arrow.up
        let ac2 = UIAlertAction(title: "enviar mail", style: .default, handler: { action in
            let imagen = UIImage(named: "beeeeer")
            // PARA COMPARTIR USANDO EL CLIENTE DE CORREO
            if MFMailComposeViewController.canSendMail() {
                let mvc = MFMailComposeViewController()
                mvc.setToRecipients(["jan.zelaznog@gmail.com"])
                mvc.setMessageBody("Terminé el juego en \(self.count)", isHTML: false)
                let imgData = imagen!.pngData()
                mvc.addAttachmentData(imgData!, mimeType:"image/png", fileName:"beeeer.png")
                mvc.setSubject("Gane en BeerTesting!!")
                self.present(mvc, animated: true)
            }
        })
        alert.addAction(ac1)
        alert.addAction(ac2)
        self.present(alert, animated: true)
    }
    
    func start() {
            self.timer = Timer.scheduledTimer(withTimeInterval:1.0,repeats: true)
            {_ in
                self.count = self.count + 1
                self.Cronometro.text = "Time: \(self.count)"
                if self.count == 10 {
                    self.endGame()
                }
            }
        }
    
    func stop() -> Void {
            self.timer?.invalidate()
            self.timer = nil
        }


/*
    var targetView:UIView?
    var movingView:UIView?
    var refX:CGFloat = 0.0
    var refY:CGFloat = 0.0
    let motionManager = CMMotionManager()
    var timer:Timer!
    var tiempoTranscurrido = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let W = self.view.bounds.size.width / 6
        let H = self.view.bounds.size.height / 6
        self.targetView = UIView(frame:CGRect(x:0,
                                              y:0,
                                              width: W,
                                              height: H))
        self.targetView!.backgroundColor = UIColor.purple
        self.targetView?.center = self.view.center
        self.view.addSubview(self.targetView!)
        self.movingView = UIView(frame:CGRect(x:0,
                                              y:0,
                                              width: W,
                                              height: H))
        self.movingView!.backgroundColor = UIColor.green
        self.view.addSubview(self.movingView!)
        refX = trunc((self.targetView?.frame.minX)!)
        refY = trunc((self.targetView?.frame.minY)!)
        iniciaAcelerometro()
    }
    
    @objc func tiempo () {
        tiempo += 1
    }
    
    func iniciaAcelerometro () {
        tiempoTranscurrido = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(tiempo), userInfo: nil, repeats: true)
        let stepMoveFactor:Double = 50.0
        // iniciamos el motionmanager para estar recibiendo todas las lecturas de cambios de posición
        motionManager.startAccelerometerUpdates()
        // frecuencia de lecturas, en segundos
        motionManager.accelerometerUpdateInterval = 0.1
        //
        motionManager.startAccelerometerUpdates(to: OperationQueue.main){ data, error in
            var rect = self.movingView!.frame
            let movetoX  = rect.origin.x + CGFloat((data?.acceleration.x)! * stepMoveFactor)
            let movetoY  = rect.origin.y - CGFloat((data?.acceleration.y)! * stepMoveFactor)
            let maxX = self.view.frame.width - rect.width
            let maxY = self.view.frame.height - rect.height
            if movetoX > 0 && movetoX < maxX {
                rect.origin.x = movetoX
            }
            if ( movetoY > 0 && movetoY < maxY ) {
                rect.origin.y = movetoY
            }
            self.movingView!.frame = rect
            if ((trunc(rect.minX) == self.refX ||
                trunc(rect.minX) == self.refX - 1 ||
                trunc(rect.minX) == self.refX + 1) &&
                (trunc(rect.minY) == self.refY ||
                    trunc(rect.minY) == self.refY - 1 ||
                    trunc(rect.minY) == self.refY + 1)) {
                self.endGame()
                self.motionManager.stopAccelerometerUpdates()
            }
        }
    }
    
    func endGame() {
        print ("terminado en \(self.tiempoTranscurrido)")
        let alert = UIAlertController(title: "Ganaste!", message:"Bien hecho! todavía puedes beber otra cerveza!!", preferredStyle: .alert)
        let ac1 = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ac1)
        self.present(alert, animated: true)
    }*/
}

