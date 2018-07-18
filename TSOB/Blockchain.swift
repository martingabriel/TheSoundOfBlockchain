//
//  Blockchain.swift
//  TSOB
//
//  Created by Martin Gabriel on 14.06.18.
//  Copyright © 2018 Martin Gabriel. All rights reserved.
//

import Foundation

class Blockchain {
    internal var name = ""
    internal var id = 0
    internal var blockUrl = ""
    
    public var Name: String {
        return self.name
    }
    
    init(name: String, id: Int, url: String) {
        self.name = name
        self.id = id
        self.blockUrl = url
    }
    
    public func GetAudioFileFromUrl() -> Data? {
        do {
            let dataFromUrl = try Data(contentsOf: URL(string: self.blockUrl)!)
            let sound = createSound(data: dataFromUrl)
            return sound as Data
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    public func getAudioFileFromUrl(url: String) -> Data? {
        do {
            let dataFromUrl = try Data(contentsOf: URL(string: url)!)
            let sound = createSound(data: dataFromUrl)
            return sound as Data
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    internal func createSound(data: Data) -> NSMutableData {
        let sampleRate: Int32 = 44100
        let chunkSize: Int32 = 36
        let subChunkSize: Int32 = 16
        let format: Int16 = 1
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate: Int32 = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign: Int16 = channels * 2
        let dataSize: Int32 = Int32(data.count)
        
        let sound = NSMutableData()
        
        // riff
        sound.append([UInt8]("RIFF".utf8), length: 4)
        sound.append(intToByteArray(chunkSize), length: 4)
        
        // wave
        sound.append([UInt8]("WAVE".utf8), length: 4)
        
        // fmt
        sound.append([UInt8]("fmt ".utf8), length: 4)
        sound.append(intToByteArray(subChunkSize), length: 4)
        sound.append(shortToByteArray(format), length: 2)
        sound.append(shortToByteArray(channels), length: 2)
        sound.append(intToByteArray(sampleRate), length: 4)
        sound.append(intToByteArray(byteRate), length: 4)
        sound.append(shortToByteArray(blockAlign), length: 2)
        sound.append(shortToByteArray(bitsPerSample), length: 2)
        
        // data
        sound.append([UInt8]("data".utf8), length: 4)
        sound.append(intToByteArray(dataSize), length: 4)
        sound.append(data)
        
        return sound
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
