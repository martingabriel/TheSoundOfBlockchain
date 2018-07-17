//
//  Blockchain.swift
//  TSOB
//
//  Created by Martin Gabriel on 14.06.18.
//  Copyright © 2018 Martin Gabriel. All rights reserved.
//

import Foundation

class blockchain {
    var Name = ""
    var ID = 0
    var Url = ""
    
    init(name: String, id: Int, url: String) {
        self.Name = name
        self.ID = id
        self.Url = url
    }
    
    func getAudioFileFromUrl() -> Data? {
        do {
            let dataFromUrl = try Data(contentsOf: URL(string: self.Url)!)
            let sound = createSound(data: dataFromUrl)
            let data = sound as Data
            return data
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    private func createSound(data: Data) -> NSMutableData {
        let sampleRate: Int32 = 44100
        let chunkSize: Int32 = 36
        let subChunkSize: Int32 = 16
        let format: Int16 = 1
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate: Int32 = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign: Int16 = channels * 2
        let dataSize: Int32 = Int32(data.count)
        
        let header = NSMutableData()
        
        header.append([UInt8]("RIFF".utf8), length: 4)
        header.append(intToByteArray(chunkSize), length: 4)
        
        //WAVE
        header.append([UInt8]("WAVE".utf8), length: 4)
        
        //FMT
        header.append([UInt8]("fmt ".utf8), length: 4)
        
        header.append(intToByteArray(subChunkSize), length: 4)
        header.append(shortToByteArray(format), length: 2)
        header.append(shortToByteArray(channels), length: 2)
        header.append(intToByteArray(sampleRate), length: 4)
        header.append(intToByteArray(byteRate), length: 4)
        header.append(shortToByteArray(blockAlign), length: 2)
        header.append(shortToByteArray(bitsPerSample), length: 2)
        
        header.append([UInt8]("data".utf8), length: 4)
        header.append(intToByteArray(dataSize), length: 4)
        header.append(data)
        
        return header
    }
    
    private func intToByteArray(_ i: Int32) -> [UInt8] {
        return [
            //little endian
            UInt8(truncating: ((i     ) & 0xff) as NSNumber),
            UInt8(truncating: ((i >>  8) & 0xff) as NSNumber),
            UInt8(truncating: ((i >> 16) & 0xff) as NSNumber),
            UInt8(truncating: ((i >> 24) & 0xff) as NSNumber)
        ]
    }
    
    private func shortToByteArray(_ i: Int16) -> [UInt8] {
        return [
            //little endian
            UInt8(truncating: ((i      ) & 0xff) as NSNumber),
            UInt8(truncating: ((i >>  8) & 0xff) as NSNumber)
        ]
    }
}
