//
//  Cache.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import RxSwift
import RxCocoa

protocol Identifiable {
    var uid: String { get }
}

protocol AbstractCache {
    associatedtype CachableObjectType
    func save(object: CachableObjectType) -> Completable
    func fetch(withId id: String) -> Maybe<CachableObjectType>
}

// Cache based on FileManager. I made it generic so it can be reused
// for all Codable structs that have uid property (conform to Identifiable protocol)
final class Cache<Cachable: Identifiable>: AbstractCache where Cachable: Codable {
    private enum Error: Swift.Error {
        case saveObject(Cachable)
        case fetchObject(Cachable.Type)
    }
    
    private enum FilePath {
        static var cacheDirectoryName: String {
            return "cache"
        }
        static var objectFileName: String {
            return "\(Cachable.self).dat"
        }
    }
    
    private enum Constants {
        static var queueName: String {
            return "com.pawel.CreditScore.cache"
        }
    }
    
    private let path: String
    private let scheduler: SerialDispatchQueueScheduler
    
    init(path: String = FilePath.cacheDirectoryName,
         cacheScheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: Constants.queueName)) {
        self.path = path
        self.scheduler = cacheScheduler
    }
    
    // I don't expect any values to be returned from this method so it just completes
    // or throws an error
    func save(object: Cachable) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let directoryPath = url.appendingPathComponent(self.path)
                .appendingPathComponent("\(object.uid)")
            
            self.createDirectoryIfNeeded(at: directoryPath)
            
            let filePath = directoryPath
                .appendingPathComponent(FilePath.objectFileName, isDirectory: false)
            
            do {
                let data = try PropertyListEncoder().encode(object)
                try data.write(to: filePath)
                observer(.completed)
            } catch {
                observer(.error(Error.saveObject(object)))
            }
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
    
    // At first I implemented return type as Result monad but
    // I believe Maybe is more descriptive and easier to use
    // (no unnecessary flatMaps in Result type etc.)
    func fetch(withId id: String) -> Maybe<Cachable> {
        return Maybe<Cachable>.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.path)
                .appendingPathComponent("\(id)")
                .appendingPathComponent(FilePath.objectFileName, isDirectory: false)
            
            do {
                let data = try Data(contentsOf: path)
                let object = try PropertyListDecoder().decode(Cachable.self, from: data)
                observer(MaybeEvent<Cachable>.success(object))
            } catch {
                observer(.completed)
            }
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
    
    private func createDirectoryIfNeeded(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Cache Error createDirectoryIfNeeded \(error)")
        }
    }
}
