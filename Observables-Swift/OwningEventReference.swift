//
//  OwningEventReference.swift
//  Observables-Swift
//
//  Created by Leszek Ślażyński on 28/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

/// A subclass of event reference allowing it to own other object[s].
/// Additionally, the reference makes added events own itself.
/// This retain cycle allows owned objects to live as long as valid subscriptions exist.
open class OwningEventReference<T>: EventReference<T> {
    
    internal var owned: AnyObject? = nil

    open override func add(_ subscription: SubscriptionType) -> SubscriptionType {
        let subscr = super.add(subscription)
        if owned != nil {
            subscr.addOwnedObject(self)
        }
        return subscr
    }
    
    open override func add(_ handler : @escaping (T) -> ()) -> EventSubscription<T> {
        let subscr = super.add(handler)
        if owned != nil {
            subscr.addOwnedObject(self)
        }
        return subscr
    }
    
    open override func remove(_ subscription : SubscriptionType) {
        subscription.removeOwnedObject(self)
        return event.remove(subscription)
    }
    
    open override func removeAll() {
        for subscription in event._subscriptions {
            subscription.removeOwnedObject(self)
        }
        event.removeAll()
    }
    
    open override func add(owner : AnyObject, _ handler : @escaping HandlerType) -> SubscriptionType {
        let subscr = event.add(owner: owner, handler)
        if owned != nil {
            subscr.addOwnedObject(self)
        }
        return subscr
    }

    public override init(event: Event<T>) {
        super.init(event: event)
    }
    
}
