//
//  AppDelegate.swift
//  schematix
//
//  Created by Johan Sellström on 2019-05-08.
//  Copyright © 2019 Johan Sellström. All rights reserved.
//

import UIKit
import Textile
import SMART

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let textile = Textile.instance()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            let recoveryPhrase = try  Textile.initialize(withDebug: true,logToDisk: true)
            print("recoveryPhrase ", recoveryPhrase)
        } catch let error {
            
        }
        textile.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func putExamples(threadId: String) {
        var error: NSError?
        let examples:[String] = ["ClinicalImpression","ClinicalImpression","ClinicalImpression", "MedicationRequest","MedicationRequest"]
        for example in examples {
            if let path = Bundle.main.path(forResource: example, ofType: "json") , let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe), let json64: String = jsonData.base64EncodedString() {
                let files = textile.files.prepareSync(json64, threadId: threadId , error: &error)
                let block = self.textile.files.add(files.dir, threadId: threadId, caption: nil, error: &error)
                if let blockId = block.id_p, !blockId.isEmpty {
                    print(example, " OK")
                } else {
                    print(example, error)
                }
            }
        }
    }

    func getExamples(threadId: String) {
        var error: NSError?
        let filesList = textile.files.list(nil, limit: 10000, threadId: threadId, error: &error)

        if let filesArrays = Array(filesList.itemsArray) as? [Files] {
            for fileArray in filesArrays {
                if let user = fileArray.user, let timestamp = fileArray.date {
                    if let files = Array(fileArray.filesArray) as? [File] {
                        for file in files {
                            if let item = file.file {
                                let str = textile.files.data(item.hash_p, error: &error)
                                if let base64Encoded = str.base64URLToString(), let decodedData = Data(base64Encoded: base64Encoded), let json = try? JSONSerialization.jsonObject(with: decodedData, options: []) as? FHIRJSON {

                                    if let medicationRequest = try? MedicationRequest(json: json)  {
                                        print("medicationRequest ", medicationRequest.identifier)
                                    } else if let clinicalImpression = try? ClinicalImpression(json: json) {
                                        print("clinicalImpression ", clinicalImpression.identifier)
                                    }
                                    /*
                                    if let decodedString = String(data: decodedData, encoding: .utf8) {
                                        print(decodedString)
                                    }*/
                                }
                            }
                        }
                    }
                }
            }
        }

    }


}


extension AppDelegate: TextileDelegate {

    func nodeOnline() {
        print("nodeOnline")
        var error: NSError?
        if let path = Bundle.main.path(forResource: "fhir", ofType: "json") ,let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe), let jsonString = String(data: jsonData, encoding: .utf8) {
            let config = AddThreadConfig()
            config.key = UUID().uuidString
            config.name =  UUID().uuidString
            let schema = AddThreadConfig_Schema()
            schema.json = jsonString
            config.schema = schema
            config.type = .private
            config.sharing = .notShared
            config.force = false
            let thread = textile.threads.add(config, error: &error)
            if let error = error {
                print(error.localizedDescription)
            } else {
                putExamples(threadId: thread.id_p)
                getExamples(threadId: thread.id_p)
            }
        }
    }

    func nodeStarted() {
        print("nodeStarted")
    }

    func nodeStopped() {
        print("nodeStopped")
    }

    func nodeFailedToStopWithError(_ error: Error) {
        print(error)
    }

    func nodeFailedToStartWithError(_ error: Error) {
        print(error)
    }

    func notificationReceived(_ notification: TextileCore.Notification) {
        print("notificationReceived ", notification)

    }

    func threadAdded(_ threadId: String) {
        print("threadAdded ", threadId)
    }

    func threadRemoved(_ threadId: String) {
        print("threadRemoved ", threadId)
    }

    func threadUpdateReceived(_ feedItem: FeedItem) {
        //print("feedItem ", feedItem)
    }

    func accountPeerAdded(_ peerId: String) {
        print(peerId)
    }

    func accountPeerRemoved(_ peerId: String) {
        print(peerId)
    }

    func queryDone(_ queryId: String) {
        print(queryId)
    }

    func queryError(_ queryId: String, error: Error) {
        print(queryId,error)
    }

    func contactQueryResult(_ queryId: String, contact: Contact) {
        print(queryId, contact)
    }

    func clientThreadQueryResult(_ queryId: String, clientThread: CafeClientThread) {
        print(queryId, clientThread)
    }
}
