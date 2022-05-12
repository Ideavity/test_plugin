//
//  eSIM.swift
//  OutSystemsDemoApp
//
//  Created by Andre Grillo on 12/05/2022.
//

import Foundation
import CoreTelephony

@objc(eSIM)
class eSIM: CDVPlugin {
    var pluginResult = CDVPluginResult()
    var pluginCommand = CDVInvokedUrlCommand()
    
    @objc (eSimAdd:)
    func eSimAdd (_ command: CDVInvokedUrlCommand) {
        self.pluginCommand = command
        self.pluginResult = nil
        self.pluginResult?.setKeepCallbackAs(true)
        
        if let smdpServerAddress = command.arguments[0] as? String, let esimMatchingID = command.arguments[1] as? String {
            if #available(iOS 12.0, *) {
                let ctcp = CTCellularPlanProvisioning()
                let supportsESIM = ctcp.supportsCellularPlan()
                
                if supportsESIM {
                    let ctpr = CTCellularPlanProvisioningRequest()
                    let ctcp = CTCellularPlanProvisioning()
                    ctpr.address = smdpServerAddress
                    ctpr.matchingID = esimMatchingID
                    if #available(iOS 15.0, *) {
                        Task {
                            let result = await ctcp.addPlan(with: ctpr)
                            switch result{
                            case .unknown:
                                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Unknown error")
                            case .fail:
                                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Failed to Add eSIM")
                            case .success:
                                sendPluginResult(status: CDVCommandStatus_OK, message: "eSIM installed successfully")
                            @unknown default:
                                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Failed to Add eSIM")
                            }
                        }
                    } else {
                        //iOS < 15
                        //MARK: TODO Ver como vai ficar o return! Provavelmente retornará Unknown
                        ctcp.addPlan(with: ctpr) { (result) in
                            switch result{
                            case .unknown:
                                self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Unknown error")
                            case .fail:
                                self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Failed to Add eSIM")
                            case .success:
                                self.sendPluginResult(status: CDVCommandStatus_OK, message: "eSIM installed successfully")
                            @unknown default:
                                self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Failed to Add eSIM")
                            }
                        }
                    }
                } else {
                    //eSIM not supported
                    sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: This device is not supported")
                }
            } else {
                //iOS < 12.0 (Not supported)
                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Device not supported. iOS version should be 12.0 or higher")
            }
        }   else {
            //Missing input parameters
            sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Missing input parameters")
        }
    }
    
    func sendPluginResult(status: CDVCommandStatus, message: String) {
        pluginResult = CDVPluginResult(status: status, messageAs: message)
        self.commandDelegate!.send(pluginResult, callbackId: pluginCommand.callbackId)
    }
}