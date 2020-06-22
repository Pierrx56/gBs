package genourob.gbs_alternative;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.util.Log;
import java.util.*;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.widget.AbsListView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String SENSOR_CHANNEL = "samples.flutter.io/sensor";
    private static final String CHARGING_CHANNEL = "samples.flutter.io/charging";

    public final static String ACTION_GATT_CONNECTED =
            "com.example.bluetooth.le.ACTION_GATT_CONNECTED";
    public final static String ACTION_GATT_DISCONNECTED =
            "com.example.bluetooth.le.ACTION_GATT_DISCONNECTED";
    public final static String ACTION_GATT_SERVICES_DISCOVERED =
            "com.example.bluetooth.le.ACTION_GATT_SERVICES_DISCOVERED";
    public final static String ACTION_DATA_AVAILABLE =
            "com.example.bluetooth.le.ACTION_DATA_AVAILABLE";
    public final static String EXTRA_DATA =
            "com.example.bluetooth.le.EXTRA_DATA";


    String TAG = "BluetoothClass";
    String NAME_DEVICE = "gBs_Bluetooth";
    String macAdress = "";

    public String value = "";

    boolean isConnected = false;

    UUID serviceUUID = UUID.fromString("0000dfb0-0000-1000-8000-00805f9b34fb");
    UUID characteristicUUID = UUID.fromString("0000dfb1-0000-1000-8000-00805f9b34fb");

    BluetoothDevice m_BTdevice;
    BluetoothDevice mBluetoothAdapter;
    BluetoothGatt bluetoothGatt;
    private BluetoothGattCallback nativeCallback;

    @Override
    public void onDestroy() {
        unregisterReceiver(mReceiver);

        super.onDestroy();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor(), SENSOR_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {

                        if (call.method.equals("connect")) {
                            String status = connect();

                            if (status == "Connected") {
                                result.success(status);
                            } else {
                                result.error("UNAVAILABLE", "Can not connect", null);
                            }
                        }
                        if (call.method.equals("getStatus")) {
                            boolean status = getStatus();

                            if (status) {
                                result.success(status);
                            } else {
                                result.success(status);
                                //result.error("UNAVAILABLE", "Can not connect", null);
                            }
                        }
                        if (call.method.equals("getBatteryLevel")) {
                            int batteryLevel = getBatteryLevel();

                            if (batteryLevel != -1) {
                                result.success(batteryLevel);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        }
                        if (call.method.equals("getPairedDevices")) {
                            String devices = getPairedDevices();

                            if (devices != "") {
                                result.success(devices);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        }
                        if (call.method.equals("getData")) {
                            String data = getValue(); //getData();

                            if (data != "") {
                                result.success(data);
                            } else {
                                result.success("ça ne marche pas");
                                //result.error("UNAVAILABLE", "No data available.", null);
                            }
                        }
                        if (call.method.equals("disconnect")) {
                            disconnectDeviceSelected();

                            result.success("Disconnected");
                        }
                        /* else {
                            result.error("Unavailable", "No method", null);
                        }*/
                    }
                }
        );
    }

    private int getBatteryLevel() {
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            return (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();

            if (BluetoothAdapter.ACTION_DISCOVERY_STARTED.equals(action)) {
                //discovery starts, we can show progress dialog or perform other tasks
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                //discovery finishes, dismis progress dialog
            } else if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                //bluetooth device found
                BluetoothDevice tempDevice = (BluetoothDevice) intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                System.out.println(tempDevice.getName());
                if(tempDevice.getName().equals(NAME_DEVICE))
                    m_BTdevice = tempDevice;
                    macAdress = m_BTdevice.getAddress();
            }
        }
    };

    private String getPairedDevices() {

        BluetoothAdapter m_BluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        Set<BluetoothDevice> pairedDevices = m_BluetoothAdapter.getBondedDevices();

        /*IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);

        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED);
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        filter.addAction(BluetoothDevice.ACTION_FOUND);

        registerReceiver(mReceiver, filter);

        if (m_BluetoothAdapter.isDiscovering()) {
            m_BluetoothAdapter.cancelDiscovery();
        }

        m_BluetoothAdapter.startDiscovery();
*/


        int response = 0;
        if (pairedDevices.size() > 0) {


            for (BluetoothDevice device : pairedDevices) {

                Log.v(TAG, "paired = " + device.getName());
                Log.v(TAG, "paired MAC = " + device.getAddress());

                if (device.getName().equals(NAME_DEVICE)) {
                    macAdress = device.getAddress();
                    Log.d(TAG, "FIND ARDUINO");
                    m_BTdevice = device;
                    response = 1;
                }
            }
        }
        return macAdress;
    }

    // New services discovered
    public String onServicesDiscovered(BluetoothGatt gatt, int status) {
        if (status == gatt.GATT_SUCCESS) {
            BluetoothGattService mBluetoothGattService = gatt.getService(serviceUUID);
            if (mBluetoothGattService != null) {
                Log.i(TAG, "Service characteristic UUID found: " + mBluetoothGattService.getUuid().toString());
                return mBluetoothGattService.getUuid().toString();
            } else {
                Log.i(TAG, "Service characteristic not found for UUID: " + serviceUUID);
                return "Not Found service UUID";
            }
        } else
            return "Bonjour from discoverd";
    }

    public boolean setCharacteristicNotification(BluetoothGatt bluetoothGatt, BluetoothGattCharacteristic characteristic, boolean enable) {
        Log.d("TAG", "setCharacteristicNotification");
        bluetoothGatt.setCharacteristicNotification(characteristic, enable);
        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
        descriptor.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : new byte[]{0x00, 0x00});
        return bluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?

    }

    public void readCustomCharacteristic() {
        if (m_BTdevice == null || bluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        /*check if the service is available on the device*/
        BluetoothGattService mCustomService = bluetoothGatt.getService(serviceUUID);
        if (mCustomService == null) {
            Log.w(TAG, "Custom BLE Service not found");
            return;
        }
        /*get the read characteristic from the service*/
        BluetoothGattCharacteristic mReadCharacteristic = mCustomService.getCharacteristic(characteristicUUID);
        if (bluetoothGatt.readCharacteristic(mReadCharacteristic) == false) {
            Log.w(TAG, "Failed to read characteristic");
        }
    }

    public void setValue(String _value){
        value = _value;
    }

    public String getValue(){
        return value;
    }

    public boolean getStatus(){
        return isConnected;
    }

    public String connect() {

        //String address = getPairedDevices();

        bluetoothGatt = m_BTdevice.connectGatt(this, false, btleGattCallback);

        if(isConnected != true)
            return "Connected";
        else {
            //connect();
            return "Disconnected";
        }
    }

    // Device connect call back
    private final BluetoothGattCallback btleGattCallback = new BluetoothGattCallback() {

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, final BluetoothGattCharacteristic characteristic) {
            // this will get called anytime you perform a read or write characteristic operation
            MainActivity.this.runOnUiThread(new Runnable() {
                public void run() {
                    byte[] value = characteristic.getValue();
                    String v = new String(value);
                    //VALEURS DU CAPTEUR ICI
                    setValue(v);
                    //peripheralTextView.append("Valeur du capteur: " + v + "\n");
                }
            });
        }

        @Override
        public void onConnectionStateChange(final BluetoothGatt gatt, final int status, final int newState) {
            // this will get called when a device connects or disconnects
            //System.out.println(newState);
            switch (newState) {
                case 0:
                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            System.out.println("device disconnected\n");
                            isConnected = false;
                            //connectToDevice.setVisibility(View.VISIBLE);
                            //disconnectDevice.setVisibility(View.INVISIBLE);
                        }
                    });
                    break;
                case 2:
                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            System.out.println("device connected\n");
                            isConnected = true;
                            //connectToDevice.setVisibility(View.INVISIBLE);
                            //disconnectDevice.setVisibility(View.VISIBLE);
                        }
                    });

                    // discover services and characteristics for this device
                    bluetoothGatt.discoverServices();

                    break;
                default:
                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            //peripheralTextView.append("we encounterned an unknown state, uh oh\n");
                        }
                    });
                    break;
            }
        }

        @Override
        public void onServicesDiscovered(final BluetoothGatt gatt, final int status) {
            // this will get called after the client initiates a 			BluetoothGatt.discoverServices() call
            MainActivity.this.runOnUiThread(new Runnable() {
                public void run() {
                    //peripheralTextView.append("device services have been discovered\n");
                }
            });
            displayGattServices(bluetoothGatt.getServices());
        }

        @Override
        // Result of a characteristic read operation
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic characteristic,
                                         int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
            }
        }

        public boolean setCharacteristicNotification(BluetoothGatt bluetoothGatt, BluetoothGattCharacteristic characteristic, boolean enable) {
            Log.d("DEBUG", "setCharacteristicNotification");
            bluetoothGatt.setCharacteristicNotification(characteristic, enable);
            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
            descriptor.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : new byte[]{0x00, 0x00});
            return bluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?

        }

    };

    private void displayGattServices(List<BluetoothGattService> gattServices) {
        if (gattServices == null) return;

        isConnected = true;

        // Loops through available GATT Services.
        for (BluetoothGattService gattService : gattServices) {

            final String uuid = gattService.getUuid().toString();
            if (uuid.equals("0000dfb0-0000-1000-8000-00805f9b34fb")) {
                System.out.println("Service discovered: " + uuid);
                MainActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        //peripheralTextView.append("Service disovered: " + uuid + "\n");
                    }
                });
                new ArrayList<HashMap<String, String>>();
                List<BluetoothGattCharacteristic> gattCharacteristics =
                        gattService.getCharacteristics();

                // Loops through available Characteristics.
                for (BluetoothGattCharacteristic gattCharacteristic :
                        gattCharacteristics) {

                    final String charUuid = gattCharacteristic.getUuid().toString();

                    System.out.println("Characteristic discovered for service: " + charUuid);

                    bluetoothGatt.setCharacteristicNotification(gattCharacteristic, true);
                    BluetoothGattDescriptor descriptor = gattCharacteristic.getDescriptor(gattCharacteristic.getUuid());
                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                    bluetoothGatt.writeDescriptor(descriptor);
                    System.out.println("NOTIFICATIONS ENABLED");

                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            //peripheralTextView.append("Characteristic discovered for service: " + charUuid + "\n");
                        }
                    });

                }
            }
        }
    }

    public void disconnectDeviceSelected() {
        //peripheralTextView.append("Disconnecting from device\n");
        isConnected = false;
        bluetoothGatt.disconnect();
        bluetoothGatt.close();
        //bluetoothGatt = null;
    }

    private void broadcastUpdate(final String action,
                                 final BluetoothGattCharacteristic characteristic) {

        System.out.println(characteristic.getUuid());

        bluetoothGatt.setCharacteristicNotification(characteristic, true);
        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
        descriptor.setValue(true ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : new byte[]{0x00, 0x00});
        bluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?
    }
}
