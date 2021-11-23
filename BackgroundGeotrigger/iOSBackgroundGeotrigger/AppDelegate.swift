/*
 COPYRIGHT 1995-2021 ESRI
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 This material is licensed for use under the Esri Master License
 Agreement (MLA), and is bound by the terms of that agreement.
 You may redistribute and use this code without modification,
 provided you adhere to the terms of the MLA and include this
 copyright notice.
 
 See use restrictions at http://www.esri.com/legal/pdfs/mla_e204_e300/english
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, USA 92373
 
 email: contracts@esri.com
 */

import UIKit
import ArcGIS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #warning("Require user to sign in with an ArcGIS identity or set your developer API key")
        /*
         Use of Esri location services, including basemaps and geocoding, requires either an ArcGIS identity or an API Key. For more information see https://links.esri.com/arcgis-runtime-security-auth.
         
         1) ArcGIS identity: An ArcGIS named user account that is a member of an organization in ArcGIS Online or ArcGIS Enterprise.
         
         2) API key: A permanent key that gives your application access to Esri location services. Create a new API key or access existing API keys from your ArcGIS for Developers dashboard (https://links.esri.com/arcgis-api-keys).
         
         Production deployment of applications built with ArcGIS Runtime requires you to license ArcGIS Runtime functionality. For more information see https://links.esri.com/arcgis-runtime-license-and-deploy.
         */
        
        // Uncomment the following line to access Esri location services using an API key.
        // AGSArcGISRuntimeEnvironment.apiKey = "<#API Key#>"
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
