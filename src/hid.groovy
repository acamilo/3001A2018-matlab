@Grab(group = 'org.hid4java', module = 'hid4java', version = '0.5.0')

import org.hid4java.*
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

class PacketProcessor {
    HidDevice myHidDevice;
    ByteOrder be = ByteOrder.LITTLE_ENDIAN;
    int packetSize = 64
    int numFloats = (packetSize / 4) - 1
    byte[] message = new byte[packetSize];

    PacketProcessor(HidDevice hidDevice) {
        myHidDevice = hidDevice;

    }

    float[] command(int idOfCommand, float[] values) {
        ByteBuffer.wrap(message).order(be).putInt(0, idOfCommand).array();
        for (int i = 0; i < numFloats && i < values.length; i++) {
            int baseIndex = (4 * i) + 4;
            ByteBuffer.wrap(message).order(be).putFloat(baseIndex, values[i]).array();
        }
        float[] returnValues = new float[numFloats]
        //println "Writing packet"
        int val = myHidDevice.write(message, packetSize, (byte) 0);
        if (val > 0) {
            //println "Reading packet"
            int read = myHidDevice.read(message, 1000);
            if (read > 0) {
                //println "Parsing packet"
                for (int i = 0; i < numFloats; i++) {
                    int baseIndex = (4 * i) + 4;
                    returnValues[i] = ByteBuffer.wrap(message).order(be).getFloat(baseIndex)
                }
            } else {
                println "Read failed"
            }
        } else {
            println "Writing failed"
        }
        return returnValues
    }

}

HidServices hidServices = HidManager.getHidServices();
// Provide a list of attached devices
for (HidDevice hidDevice : hidServices.getAttachedHidDevices()) {

    if (hidDevice.isVidPidSerial(0x3742, 0x7, null)) {
        System.out.println("Found! " + hidDevice);
        hidDevice.open();

        //byte[] bytes;
        //float f = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN).getFloat();
        //byte[] data = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putFloat(value).array();

        // Send the Initialise message
        PacketProcessor processor = new PacketProcessor(hidDevice)
        // command index

        long sum
        int min = 100000;
        int max = 0;
        float[] values = new float[9]
        float sinWaveInc = 2000
        float seconds = 0.01;
        float range = 400
        for (int i = 1; i < sinWaveInc; i++) {
            for (int j = 0; j < 3; j++) {
                values[(j * 3) + 0] = (Math.sin(((float) i) / sinWaveInc * Math.PI * 2) * range) - range
                //values[(j*3)+1] = ((Math.cos(((float)i)/sinWaveInc*Math.PI*2)* range)/seconds)
                values[(j * 3) + 1] = 0
                values[(j * 3) + 2] = 3
            }
            //System.out.println("down data " + values );
            long start = System.currentTimeMillis()
            float[] returnValues = processor.command(37, values)
            long diff = System.currentTimeMillis() - start

            sum += diff
            if (diff > max)
                max = diff
            if (diff < min) {
                min = diff
            }
            //println "Time difference = "+diff +" average = "+(sum/i)+" min = "+min+" max = "+max
            System.out.println("sent data " + values + " returned " + returnValues);
            Thread.sleep((long) (1000.0 * seconds))
        }
        hidDevice.close();
    } else
        System.out.println("Other Device: " + hidDevice);
}

// Clean shutdown
hidServices.shutdown();