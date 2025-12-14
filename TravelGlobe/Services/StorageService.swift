import Foundation
import SwiftUI
import AWSS3

class StorageService {
    
    static let shared = StorageService()
    let bucketName = "travelglobe-media-qosai"
    let identityPoolId = "eu-north-1:ce26d600-05e6-430f-8cf1-ea7add18bdd8"
    
    private init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .EUNorth1,
            identityPoolId: identityPoolId
        )

        let configuration = AWSServiceConfiguration(
            region: .EUNorth1,
            credentialsProvider: credentialsProvider
        )

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        print("⚙️ AWS Service konfigurerad säkert med Cognito Identity Pool")
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Kunde inte konvertera bild till data")
            completion(nil)
            return
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let key = "trip_images/\(filename)"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(
            imageData,
            bucket: bucketName,
            key: key,
            contentType: "image/jpeg",
            expression: expression
        ) { (task, error) in
            if let error = error {
                print("Uppladdning misslyckades: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let region = "eu-north-1"
            let urlString = "https://\(self.bucketName).s3.\(region).amazonaws.com/\(key)"
            
            print("Upload Success! URL: \(urlString)")
            completion(urlString)
        }
    }
    
    func deleteImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let path = url.path
        let key = String(path.dropFirst())
        
        print("Försöker radera från S3: \(key)")
        
        guard let deleteRequest = AWSS3DeleteObjectRequest() else { return }
        deleteRequest.bucket = bucketName
        deleteRequest.key = key
        
        let s3 = AWSS3.default()
        s3.deleteObject(deleteRequest).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Misslyckades att radera från S3: \(error.localizedDescription)")
            } else {
                print("Bild raderad från S3: \(key)")
            }
            return nil
        }
    }
}
