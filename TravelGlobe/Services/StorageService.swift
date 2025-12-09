import Foundation
import UIKit
import AWSS3

class StorageService {
    
    static let shared = StorageService()
    private let bucketName = "travelglobe-media-qosai"
    
    init() {
        configureAWS()
    }
    
    private func configureAWS() {
        // hämtar nycklarna från Secrets.plist
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let accessKey = dict["AWSAccessKey"] as? String,
              let secretKey = dict["AWSSecretKey"] as? String else {
            print("StorageService: Kunde inte hitta Secrets.plist eller nycklar!")
            return
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        
        //region (Stockholm)
        let configuration = AWSServiceConfiguration(region: .EUNorth1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        print("StorageService: AWS Konfigurerat mot \(bucketName)!")
    }
    
    // Funktion för att ladda upp en bild
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Komprimera bilden lite så det går snabbare
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("StorageService: Kunde inte konvertera bild till data.")
            completion(nil)
            return
        }
        
        let fileName = "trip_images/\(UUID().uuidString).jpg"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            print("Uploading... \(Int(progress.fractionCompleted * 100))%")
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(
            data,
            bucket: bucketName,
            key: fileName,
            contentType: "image/jpeg",
            expression: expression
        ) { (task, error) in
            if let error = error {
                print("AWS Upload Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // URL:en för eu-north-1
            let urlString = "https://\(self.bucketName).s3.eu-north-1.amazonaws.com/\(fileName)"
            print("✅ Upload Success! URL: \(urlString)")
            completion(urlString)
        }
    }
}
