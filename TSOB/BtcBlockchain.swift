//
//  BtcBlockchain.swift
//  TSOB
//
//  Created by Martin Gabriel on 18.07.18.
//  Copyright © 2018 Martin Gabriel. All rights reserved.
//

import Foundation

class BtcBlockchain : Blockchain {
    
    private var baseBlockUrl = ""
    public var actualTxBlockUrl = ""
    private var previousTxBlockUrl = ""
    private var blockHeight = 0
    
    struct Block: Decodable {
        let data: DataClass
    }
    
    struct DataClass: Decodable {
        let height: Int
    }
    
    override init(name: String, id: Int, url: String) {
        super.init(name: name, id: id, url: url)
        
        self.baseBlockUrl = blockUrl
        self.blockUrl = blockUrl + "latest"
        self.actualTxBlockUrl = blockUrl + "/tx"
        
        // get block height from block json
        if let height = getBlockHeight() {
            self.blockHeight = height
            print(height)
        }
    }
    
    private func getBlockHeight() -> Int? {
        var result: Int?
        
        guard let url = URL(string: blockUrl) else {
            return nil
        }
        
        do {
            // download data and parse JSON
            let data = try Data(contentsOf: url)
            let block = try JSONDecoder().decode(Block.self, from: data)
            
            // result from JSON
            result = block.data.height
        } catch let jsonErr {
            print(jsonErr)
            result = nil
        }
        
        return result
    }
    
    public override func GetAudioFileFromUrl() -> Data? {
        guard let url = URL(string: actualTxBlockUrl) else {
            return nil
        }
        
        do {
            print(self.actualTxBlockUrl)
            let dataFromUrl = try Data(contentsOf: url)
            let sound = createSound(data: dataFromUrl)
            
            self.previousTxBlockUrl = actualTxBlockUrl
            self.actualTxBlockUrl = getActualBlockUrl()
            return sound as Data
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    private func getActualBlockUrl() -> String {
        self.blockHeight = self.blockHeight - 1
        return baseBlockUrl + String(self.blockHeight) + "/tx"
    }
}
