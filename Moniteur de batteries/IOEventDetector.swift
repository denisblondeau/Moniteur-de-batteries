//
//  IOEventDetector.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-27.
//
// Based on sample code provided by Mecki: https://stackoverflow.com/users/15809/mecki
// Sample code: https://stackoverflow.com/questions/34628464/how-to-implement-ioservicematchingcallback-in-swift

import Foundation

final class IOEventDetector {
    
    enum Event {
        case Matched
        case Terminated
    }
    
    var callbackQueue: DispatchQueue?
    
    var callback: (
        ( _ detector: IOEventDetector,
          _ event: Event,
          _ service: io_service_t
        ) -> Void
    )?
    
    private let internalQueue: DispatchQueue
    
    private let notifyPort: IONotificationPortRef
    
    private var matchedIterator: io_iterator_t = 0
    
    private var terminatedIterator: io_iterator_t = 0
    
    private func dispatchEvent (event: Event, iterator: io_iterator_t)
    {
        repeat {
            let nextService = IOIteratorNext(iterator)
            guard nextService != 0 else { break }
            
            if let cb = self.callback, let q = self.callbackQueue {
                q.async {
                    cb(self, event, nextService)
                    IOObjectRelease(nextService)
                }
            } else {
                IOObjectRelease(nextService)
            }
        } while (true)
    }
    
    init?() {
        
        self.internalQueue = DispatchQueue(label: "IOEventDetector")
        
        guard let notifyPort = IONotificationPortCreate(kIOMainPortDefault) else {
            return nil
        }
        
        self.notifyPort = notifyPort
        IONotificationPortSetDispatchQueue(notifyPort, self.internalQueue)
    }
    
    deinit {
        self.stopDetection()
    }
    
    func startDetection ( ) -> Bool {
        guard matchedIterator == 0 else { return true }

        let matchingDict = IOServiceMatching("AppleDeviceManagementHIDEventService")

        let matchCallback: IOServiceMatchingCallback = {(userData, iterator) in
            
                let detector = Unmanaged<IOEventDetector>.fromOpaque(userData!).takeUnretainedValue()
                detector.dispatchEvent(event: .Matched, iterator: iterator)
        };
        
        let termCallback: IOServiceMatchingCallback = {(userData, iterator) in
            
                let detector = Unmanaged<IOEventDetector>.fromOpaque(userData!).takeUnretainedValue()
                detector.dispatchEvent(event: .Terminated, iterator: iterator)
        };

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let addMatchError = IOServiceAddMatchingNotification(self.notifyPort, kIOFirstMatchNotification, matchingDict, matchCallback, selfPtr, &self.matchedIterator
        )
        
        let addTermError = IOServiceAddMatchingNotification(self.notifyPort, kIOTerminatedNotification, matchingDict, termCallback, selfPtr, &self.terminatedIterator)

        guard addMatchError == 0 && addTermError == 0 else {
            if self.matchedIterator != 0 {
                IOObjectRelease(self.matchedIterator)
                self.matchedIterator = 0
            }
            if self.terminatedIterator != 0 {
                IOObjectRelease(self.terminatedIterator)
                self.terminatedIterator = 0
            }
            return false
        }

        // This is required even if nothing was found to "arm" the callback
        self.dispatchEvent(event: .Matched, iterator: self.matchedIterator)
        self.dispatchEvent(event: .Terminated, iterator: self.terminatedIterator)

        return true
    }
    
    func stopDetection ( ) {
        guard self.matchedIterator != 0 else { return }
        IOObjectRelease(self.matchedIterator)
        IOObjectRelease(self.terminatedIterator)
        self.matchedIterator = 0
        self.terminatedIterator = 0
    }
    
}
