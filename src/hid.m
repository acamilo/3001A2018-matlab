javaaddpath('hid4java-0.5.0.jar');

import org.hid4java.*;
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.*;

hidServices = HidManager.getHidServices();
hidServices.start();
hidDevices = hidServices.getAttachedHidDevices();
dev=hidDevices.toArray;

for i=1:(dev.length)
    if dev(i).getVendorId() == 14146 && dev(i).getProductId() == 7
        dev(i).open()
        dev(i).isOpen()
    end
end

dev(i).close()
hidServices.shutdown();
 
clear java;