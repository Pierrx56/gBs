package genourob.gbs_alternative;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.media.RingtoneManager;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.IBinder;
import android.provider.Settings;
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
import android.view.View;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
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

public class MainActivity extends FlutterActivity {

    private static final String SENSOR_CHANNEL = "samples.flutter.io/sensor";

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

    private final static int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_FINE_LOCATION = 1;

    String TAG = "BluetoothClass";
    String NAME_DEVICE = "";
    String macAdress = "";

    public String value = "1.0";
    public String voltageValue = "4.0";
    public String previousNumber = "0";

    boolean isConnected = false;
    boolean isScanning = false;

    UUID serviceUUID = UUID.fromString("0000dfb0-0000-1000-8000-00805f9b34fb");
    UUID characteristicUUID = UUID.fromString("0000dfb1-0000-1000-8000-00805f9b34fb");

    BluetoothManager btManager;
    BluetoothDevice mBluetoothDevice;
    BluetoothGatt mBluetoothGatt;
    BluetoothAdapter btAdapter;

    private static String resourceToUriString(Context context, int resId) {
        return
                ContentResolver.SCHEME_ANDROID_RESOURCE
                        + "://"
                        + context.getResources().getResourcePackageName(resId)
                        + "/"
                        + context.getResources().getResourceTypeName(resId)
                        + "/"
                        + context.getResources().getResourceEntryName(resId);
    }


    // Code to manage Service lifecycle.
    ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            System.out.println("mServiceConnection onServiceConnected");
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize()) {
                Log.e(TAG, "Unable to initialize Bluetooth");
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            System.out.println("mServiceConnection onServiceDisconnected");
            mBluetoothLeService = null;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        btManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        btAdapter = btManager.getAdapter();

        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, Context.BIND_AUTO_CREATE);

        if (btAdapter != null && !btAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        }

        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
/*        if (VERSION.SDK_INT >= VERSION_CODES.M) {
            if (this.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                final AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("This app needs location access");
                builder.setMessage("Please grant location access so this app can detect peripherals.");
                builder.setPositiveButton(android.R.string.ok, null);
                builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialog) {
                        requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
                    }
                });
                builder.show();
            }
        }*/
    }

    BluetoothLeService mBluetoothLeService;


    @Override
    public void onDestroy() {
        //unregisterReceiver(mReceiver);

        if (mBluetoothGatt != null)
            mBluetoothGatt.disconnect();

        mBluetoothDevice = null;
        super.onDestroy();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor(), SENSOR_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {

                        if (call.method.contains("connect")) {

                            String[] mac = call.method.split(",");

                            NAME_DEVICE = mac[1];

                            macAdress = mac[2];
                            String status = "";

                            if(!isScanning)
                                status = connect(macAdress);

                            if (status == "Connected") {
                                result.success(status);
                            } else {
                                result.success("Not connected");
                                //result.error("UNAVAILABLE", "Can not connect", null);
                            }
                        }
                        if (call.method.equals("disco")) {
                            disconnectDeviceSelected();

                            result.success("Disconnected");
                        }
                        if (call.method.equals("getBatteryLevel")) {
                            int batteryLevel = getBatteryLevel();

                            if (batteryLevel != -1) {
                                result.success(batteryLevel);
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
                        if (call.method.equals("getMacAddress")) {
                            String mac = getMacAddress();

                            if (mac != "") {
                                result.success(mac);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        }
                        if (call.method.contains("getPairedDevices")) {

                            String[] serial = call.method.split(",");

                            NAME_DEVICE = serial[1];

                            macAdress = "";

                            System.out.println("Looking for: " + NAME_DEVICE);

                            String devices = getPairedDevices();

                            if (devices != "") {
                                result.success(devices);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        }
                        if (call.method.contains("getScanStatus")) {
                            result.success(isScanning);
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
                        if (call.method.equals("getVolt")) {
                            String data = getVoltageValue(); //getData();

                            if (data != "") {
                                result.success(data);
                            } else {
                                result.success("ça ne marche pas");
                                //result.error("UNAVAILABLE", "No data available.", null);
                            }
                        }
                        if (call.method.equals("locationPermission")) {
                            boolean status = locationPermision();

                            if (status) {
                                result.success(status);
                            } else {
                                result.success(status);
                                //result.error("UNAVAILABLE", "Can not connect", null);
                            }
                        }
                        if (call.method.contains("sendData")) {

                            String[] serial = call.method.split(",");

                            boolean status = false;

                            if (serial.length > 1)
                                status = send(serial[1].getBytes());

                            if (status) {
                                result.success(status);
                            } else {
                                result.success(status);
                                //result.error("UNAVAILABLE", "Can not connect", null);
                            }
                        }

                        //TODO get scan state

                        /* else {
                            result.error("Unavailable", "No method", null);
                        }*/
                    }
                }
        );
        new MethodChannel(flutterEngine.getDartExecutor(), "dexterx.dev/flutter_local_notifications_example").setMethodCallHandler(
                (call, result) -> {
                    if ("drawableToUri".equals(call.method)) {
                        int resourceId = MainActivity.this.getResources().getIdentifier((String) call.arguments, "drawable", MainActivity.this.getPackageName());
                        result.success(resourceToUriString(MainActivity.this.getApplicationContext(), resourceId));
                    }
                    if ("getAlarmUri".equals(call.method)) {
                        result.success(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM).toString());
                    }
                    if ("getTimeZoneName".equals(call.method)) {
                        result.success(TimeZone.getDefault().getID());
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

    private String getMacAddress() {
        return macAdress;
    }

    private void setMacAddress(String _macAddress) {
        macAdress = _macAddress;
    }

    private String getPairedDevices() {

        System.out.println("start scanning");
        startScanning();

        macAdress = getMacAddress();

        if (macAdress == "")
            macAdress = "-1";

        //Set<BluetoothDevice> pairedDevices = m_BluetoothAdapter.getBondedDevices();
        int response = 0;


        return macAdress;
    }

    public void startScanning() {
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                isScanning = true;
                btAdapter.startLeScan(leScanCallback);
                if (isConnected)
                    stopScanning();
            }
        });
    }

    public void stopScanning() {
        System.out.println("stopping scanning");
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                isScanning = false;
                btAdapter.stopLeScan(leScanCallback);
            }
        });
    }

    // Device scan callback.
    private BluetoothAdapter.LeScanCallback leScanCallback = new BluetoothAdapter.LeScanCallback() {

        @Override
        public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {

            if (device.getName() != null) {
                System.out.println(device.getName());
                if (macAdress != null && macAdress != "-1" && macAdress != "") {
                    System.out.println(device.getAddress());
                    if (device.getAddress().contains(macAdress)) {
                        mBluetoothDevice = device;
                        stopScanning();
                        //System.out.print("distance: ");
                        //System.out.println(result.getRssi());
                        connect(device.getAddress());
                    }
                }
                if (device.getName().contains(NAME_DEVICE)) {
                    setMacAddress(device.getAddress());
                    mBluetoothDevice = device;
                    stopScanning();
                }
            }
        }

/*
        @Override
        public void onLeScan(int callbackType, ScanResult result) {
            //peripheralTextView.append("Device Name: " + result.getDevice().getName() + " rssi: " + result.getRssi() + "\n");

            if (result.getDevice().getName() != null) {
                System.out.println(result.getDevice().getName());
                if (macAdress != null && macAdress != "-1" && macAdress != "") {
                    System.out.println(result.getDevice().getAddress());
                    if (result.getDevice().getAddress().contains(macAdress)) {
                        mBluetoothDevice = result.getDevice();
                        stopScanning();
                        System.out.print("distance: ");
                        System.out.println(result.getRssi());
                        connect(result.getDevice().getAddress());
                    }
                }
                if (result.getDevice().getName().contains(NAME_DEVICE)) {
                    setMacAddress(result.getDevice().getAddress());
                    mBluetoothDevice = result.getDevice();
                    stopScanning();
                }
            }

            // auto scroll for text view
            //final int scrollAmount = peripheralTextView.getLayout().getLineTop(peripheralTextView.getLineCount()) - peripheralTextView.getHeight();
            // if there is no need to scroll, scrollAmount will be <=0
            //if (scrollAmount > 0)
            //    peripheralTextView.scrollTo(0, scrollAmount);
        }*/
    };

    // New services discovered
    public String onServicesDiscovered(BluetoothGatt gatt, int status) {
        if (status == BluetoothGatt.GATT_SUCCESS) {
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

    public boolean setCharacteristicNotification(BluetoothGatt mBluetoothGatt, BluetoothGattCharacteristic characteristic, boolean enable) {
        Log.d("TAG", "setCharacteristicNotification");
        mBluetoothGatt.setCharacteristicNotification(characteristic, enable);
        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
        descriptor.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : new byte[]{0x00, 0x00});
        return mBluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?

    }

    public void readCustomCharacteristic() {
        if (mBluetoothDevice == null || mBluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        /*check if the service is available on the device*/
        BluetoothGattService mCustomService = mBluetoothGatt.getService(serviceUUID);
        if (mCustomService == null) {
            Log.w(TAG, "Custom BLE Service not found");
            return;
        }
        /*get the read characteristic from the service*/
        BluetoothGattCharacteristic mReadCharacteristic = mCustomService.getCharacteristic(characteristicUUID);
        if (!mBluetoothGatt.readCharacteristic(mReadCharacteristic)) {
            Log.w(TAG, "Failed to read characteristic");
        }
    }

    public void setVoltageValue(String _value) {
        voltageValue = _value;
    }

    public String getVoltageValue() {
        if (voltageValue == null)
            voltageValue = "4.0";

        return voltageValue;
    }

    public void setValue(String _value) {
        value = _value;
    }

    public String getValue() {
        if (value == null)
            value = "1.0:1.0";

        return value;
    }

    public boolean getStatus() {
        return isConnected;
    }

    public boolean locationPermision() {

        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
        if (VERSION.SDK_INT >= VERSION_CODES.M) {

            if (this.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
/*
                final AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("This app needs location access");
                builder.setMessage("Please grant location access so this app can detect peripherals.");
                builder.setPositiveButton(android.R.string.ok, null);
                builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialog) {
                        requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
                    }
                });
*/
                requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_FINE_LOCATION);

                if (this.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED)
                    return false;
                else {
                    return true;
                }
//                builder.show();
            }
            else
                return true;
        }
        return false;

    }

    public String connect(String mac) {

        macAdress = mac;
        mBluetoothGatt = null;

        //Si null, on recherche l'adresse mac et on se connecte
        System.out.println(isConnected);

        if (mBluetoothDevice == null && !isConnected || !mBluetoothDevice.getAddress().contains(macAdress)) {
            if (!isScanning) {
                System.out.println("start scanning");
                startScanning();
            }
            //mBluetoothDevice = mac;
        } else {
            if (isScanning)
                stopScanning();

            mBluetoothGatt = mBluetoothDevice.connectGatt(this, false, btleGattCallback);
            if (mBluetoothGatt.connect()) {
                isConnected = true;
            } else
                connect(mac);
        }
        if (isConnected) {
            return "Connected";
        } else {
            //connect();
            return "Disconnected";
        }
    }

    public void disconnectDeviceSelected() {
        //peripheralTextView.append("Disconnecting from device\n");
        isConnected = false;

        stopScanning();
        if (btAdapter == null || mBluetoothGatt == null) {
            return;
        }
        macAdress = "";
        mBluetoothGatt.disconnect();
        mBluetoothGatt.close();

        //btAdapter.cancelDiscovery();
    }


    public boolean send(byte[] data) {

        BluetoothGattService mBluetoothGattService = mBluetoothGatt.getService(serviceUUID);

        if (mBluetoothGatt == null || mBluetoothGattService == null) {
            if(mBluetoothGattService == null)
                Log.w(TAG, "mBluetoothGattService not initialized");
            if(mBluetoothGatt == null)
                Log.w(TAG, "BluetoothGatt not initialized");
            return false;
        }

        BluetoothGattCharacteristic characteristic =
                mBluetoothGattService.getCharacteristic(characteristicUUID);

        if (characteristic == null) {
            Log.w(TAG, "Send characteristic not found");
            return false;
        }

        characteristic.setValue(data);
        characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
        return mBluetoothGatt.writeCharacteristic(characteristic);
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

                    setValue(v);

                    String[] values;
                    try {
                        values = v.split(";");

                        if(values.length >= 6){
                            if(values[values.length-1].equals(previousNumber)){
                                isConnected = false;
                            }else
                                isConnected = true;

                        }
                    }
                    catch(NumberFormatException e){
                        values = null;
                    }

                    /*
                    //VALEURS DU CAPTEUR ICI
                    //Valeur du voltage
                    try {
                        setValue(values[0]);
                    }
                    catch(NumberFormatException e){
                        setVoltageValue("4.0");
                    }
                    //Valeur du voltage
                    try {
                        setVoltageValue(values[1]);
                    }
                    catch(NumberFormatException e){
                        setVoltageValue("4.0");
                    }
                    */
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
                            System.out.println("Device disconnected\n");
                            isConnected = false;
                            mBluetoothDevice = null;
                            //btAdapter = null;
                            //disconnectDeviceSelected();
                            //connectToDevice.setVisibility(View.VISIBLE);
                            //disconnectDevice.setVisibility(View.INVISIBLE);
                        }
                    });
                    break;
                case 2:
                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            System.out.println("Device connected\n");
                            isConnected = true;
                            //connectToDevice.setVisibility(View.INVISIBLE);
                            //disconnectDevice.setVisibility(View.VISIBLE);
                        }
                    });

                    // discover services and characteristics for this device
                    mBluetoothGatt.discoverServices();

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
            displayGattServices(mBluetoothGatt.getServices());
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

        public boolean setCharacteristicNotification(BluetoothGatt mBluetoothGatt, BluetoothGattCharacteristic characteristic, boolean enable) {
            //Log.d("DEBUG", "setCharacteristicNotification");
            mBluetoothGatt.setCharacteristicNotification(characteristic, enable);
            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
            descriptor.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : new byte[]{0x00, 0x00});
            return mBluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?

        }

    };

    private void displayGattServices(List<BluetoothGattService> gattServices) {
        if (gattServices == null) return;

        isConnected = true;

        // Loops through available GATT Services.
        for (BluetoothGattService gattService : gattServices) {

            final String uuid = gattService.getUuid().toString();
            if (uuid.equals("0000dfb0-0000-1000-8000-00805f9b34fb")) {
                //System.out.println("Service discovered: " + uuid);
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

                    //System.out.println("Characteristic discovered for service: " + charUuid);

                    mBluetoothGatt.setCharacteristicNotification(gattCharacteristic, true);
                    BluetoothGattDescriptor descriptor = gattCharacteristic.getDescriptor(gattCharacteristic.getUuid());
                    try {
                        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        mBluetoothGatt.writeDescriptor(descriptor);
                        //System.out.println("NOTIFICATIONS ENABLED");
                    } catch (Exception e) {
                        //System.out.println(e);
                    }

                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            //peripheralTextView.append("Characteristic discovered for service: " + charUuid + "\n");
                        }
                    });

                }
            }
        }
    }

    private void broadcastUpdate(final String action,
                                 final BluetoothGattCharacteristic characteristic) {

        //System.out.println(characteristic.getUuid());

        mBluetoothGatt.setCharacteristicNotification(characteristic, true);
        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(characteristicUUID);
        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
        mBluetoothGatt.writeDescriptor(descriptor); //descriptor write operation successfully started?
    }

}
