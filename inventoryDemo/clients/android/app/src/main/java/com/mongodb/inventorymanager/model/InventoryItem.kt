package com.mongodb.inventorymanager.model

import io.realm.MutableRealmInteger
import io.realm.RealmObject
import io.realm.annotations.PrimaryKey
import io.realm.annotations.Required
import org.bson.types.ObjectId

open class InventoryItem(_name: String = "Task", _quantity: Long = 0, _price: Double = Double.NaN, store: String = "All Stores") : RealmObject() {
    @PrimaryKey var _id: ObjectId = ObjectId()
    var _partition: String = store
    var name: String = _name
    var price: Double = _price
    @Required
    val quantity: MutableRealmInteger = MutableRealmInteger.valueOf(_quantity)

    val quantityValue: Long
        get() = this.quantity.get()!!.toLong()
}
