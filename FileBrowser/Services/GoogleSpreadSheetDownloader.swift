//
//  GS.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import Foundation

import GoogleAPIClientForREST
import GoogleSignIn

final class GoogleSpreadSheetDownloader {
    //MARK: - Properties
    private lazy var gtlrService: GTLRSheetsService  = {
        let s = GTLRSheetsService()
        s.apiKey = GoogleSpreadSheetInfo.apiKey
        return s
    }()
    
    private let spreadsheetId = GoogleSpreadSheetInfo.id
    
    //MARK: - Methods
    func fetchData(range: String = GoogleSpreadSheetInfo.range,
                   completionHandler: @escaping (GTLRSheets_ValueRange) -> Void ) {
        print("Started getCellQuery")
        
        let getQuery = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        
        gtlrService.executeQuery(getQuery) { ticket, data, error in
            guard  let sheetsData = data as? GTLRSheets_ValueRange else { return }
            print("ticket:", sheetsData.values!)
            completionHandler(sheetsData)
        }
        
        print("Finished getCellQuery")
    }
}
