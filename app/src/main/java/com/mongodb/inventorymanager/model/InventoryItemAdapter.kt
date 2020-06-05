package com.mongodb.inventorymanager.model

import android.app.AlertDialog
import android.util.Log
import android.view.*
import android.widget.EditText
import android.widget.PopupMenu
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.mongodb.inventorymanager.R
import com.mongodb.inventorymanager.TAG
import io.realm.OrderedRealmCollection
import io.realm.Realm
import io.realm.RealmRecyclerViewAdapter
import io.realm.kotlin.where
import org.bson.types.ObjectId

/*
 * ListAdapter: extends the Realm-provided RealmRecyclerViewAdapter to provide data for a RecyclerView to display
 * Realm objects on screen to a user.
 */
internal class InventoryItemAdapter(data: OrderedRealmCollection<InventoryItem>) : RealmRecyclerViewAdapter<InventoryItem, InventoryItemAdapter.TaskViewHolder?>(data, true) {
    lateinit var _parent: ViewGroup
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TaskViewHolder {
        val itemView: View = LayoutInflater.from(parent.context).inflate(R.layout.item_view, parent, false)
        _parent = parent
        return TaskViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: TaskViewHolder, position: Int) {
        val obj: InventoryItem? = getItem(position)
        holder.data = obj
        holder.name.text = obj?.name
        holder.price.text = obj?.price.toString()
        holder.quantity.text = obj?.quantityValue.toString()

        // multiselect popup to control status
        holder.itemView.setOnClickListener {
            run {
                val popup = PopupMenu(holder.itemView.context, holder.menu)
                val menu = popup.menu

                // add a delete button to the menu, identified by the delete code
                val deleteCode = -1
                menu.add(0, deleteCode, Menu.NONE, "Delete Item")

                // add an increment button to the menu, identified by the add code
                val addCode = -2
                menu.add(0, addCode, Menu.NONE, "Add Quantity")

                // add an decrement button to the menu, identified by the subtract code
                val subtractCode = -3
                menu.add(0, subtractCode, Menu.NONE, "Subtract Quantity")

                // add an increment button to the menu, identified by the subtract code
                val changePriceCode = -4
                menu.add(0, changePriceCode, Menu.NONE, "Change Price")

                // handle clicks for each button based on the code the button passes the listener
                popup.setOnMenuItemClickListener { item: MenuItem? ->
                    var status: String? = null
                    when (item!!.itemId) {
                        addCode -> {
                            addQuantity(1, holder.data?._id)
                        }
                        subtractCode -> {
                            subtractQuantity(1, holder.data?._id)
                        }
                        changePriceCode -> {
                            val input = EditText(_parent.context)
                            val dialogBuilder = AlertDialog.Builder(_parent.context)
                            dialogBuilder.setMessage("Enter new price:")
                                .setCancelable(true)
                                .setPositiveButton("Change Price") { dialog, _ -> run {
                                    dialog.dismiss()
                                    // all realm writes need to occur inside of a transaction
                                    changePrice(input.text.toString().toDouble(), holder.data?._id)
                                }
                                }
                                .setNegativeButton("Cancel") { dialog, _ -> dialog.cancel()
                                }

                            val dialog = dialogBuilder.create()
                            dialog.setView(input)
                            dialog.setTitle("Create New Task")
                            dialog.show()
                        }
                        deleteCode -> {
                            removeAt(holder.data?._id!!)
                        }
                    }

                    // if the status variable has a new value, update the status of the task in realm
                    if (status != null) {
                        Log.v(TAG(), "Changing status of ${holder.data?.name} (${holder.data?._id}) to $status")
                        changeStatus(status, holder.data?._id)
                    }
                    true
                }
                popup.show()
            }}
    }

    fun addQuantity(delta: Long, _id: ObjectId?) {
        // need to create a separate instance of realm to issue an update, since this event is
        // handled by a background thread and realm instances cannot be shared across threads
        val bgRealm = Realm.getDefaultInstance()
        // execute Transaction (not async) because changeStatus should execute on a background thread
        bgRealm!!.executeTransaction {
            // using our thread-local new realm instance, query for and update the task status
            val item = it.where<InventoryItem>().equalTo("_id", _id).findFirst()
            item?.quantity?.increment(delta)
        }
        // always close realms when you are done with them!
        bgRealm.close()
    }

    fun subtractQuantity(delta: Long, _id: ObjectId?) {
        // need to create a separate instance of realm to issue an update, since this event is
        // handled by a background thread and realm instances cannot be shared across threads
        val bgRealm = Realm.getDefaultInstance()
        // execute Transaction (not async) because changeStatus should execute on a background thread
        bgRealm!!.executeTransaction {
            // using our thread-local new realm instance, query for and update the task status
            val item = it.where<InventoryItem>().equalTo("_id", _id).findFirst()
            item?.quantity?.decrement(delta)
        }
        // always close realms when you are done with them!
        bgRealm.close()
    }

    fun changePrice(newPrice: Double, _id: ObjectId?) {
        // need to create a separate instance of realm to issue an update, since this event is
        // handled by a background thread and realm instances cannot be shared across threads
        val bgRealm = Realm.getDefaultInstance()
        // execute Transaction (not async) because changeStatus should execute on a background thread
        bgRealm!!.executeTransaction {
            // using our thread-local new realm instance, query for and update the task status
            val item = it.where<InventoryItem>().equalTo("_id", _id).findFirst()
            item?.price = newPrice
        }
        // always close realms when you are done with them!
        bgRealm.close()
    }


    private fun changeStatus(_status: String, _id: ObjectId?) {
        // need to create a separate instance of realm to issue an update, since this event is
        // handled by a background thread and realm instances cannot be shared across threads
        val bgRealm = Realm.getDefaultInstance()
        // execute Transaction (not async) because changeStatus should execute on a background thread
        bgRealm!!.executeTransaction {
            // using our thread-local new realm instance, query for and update the task status
            val item = it.where<InventoryItem>().equalTo("_id", _id).findFirst()
            // TODO item?.status = _status
        }
        // always close realms when you are done with them!
        bgRealm.close()
    }

    private fun removeAt(id: ObjectId) {
        // need to create a separate instance of realm to issue an update, since this event is
        // handled by a background thread and realm instances cannot be shared across threads
        val bgRealm = Realm.getDefaultInstance()
        // execute Transaction (not async) because remoteAt should execute on a background thread
        bgRealm!!.executeTransaction {
            // using our thread-local new realm instance, query for and delete the task
            val item = it.where<InventoryItem>().equalTo("_id", id).findFirst()
            item?.deleteFromRealm()
        }
        // always close realms when you are done with them!
        bgRealm.close()
    }

    internal inner class TaskViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        var name: TextView = view.findViewById(R.id.name)
        var quantity: TextView = view.findViewById(R.id.quantity)
        var price: TextView = view.findViewById(R.id.price)
        var data: InventoryItem? = null
        var menu: TextView = view.findViewById(R.id.menu)

    }
}
