classdef PacketProcessor
    properties
        hidDevice;
        hidService;
    end
    methods
        function packet = PacketProcessor(deviceID)
            javaaddpath('../lib/hid4java-0.5.0.jar');
            
            import org.hid4java.*;
            import org.hid4java.event.*;
            import java.nio.ByteBuffer;
            import java.nio.ByteOrder;
            import java.lang.*;
            import org.apache.commons.lang.ArrayUtils.*;
            
            if nargin > 0
                packet.hidService = HidManager.getHidServices();
                packet.hidService.start();
                hidDevices = packet.hidService.getAttachedHidDevices();
                dev=hidDevices.toArray;
                
                for k=1:(dev.length)
                    if dev(k).getProductId() == deviceID
                        packet.hidDevice = dev(k);
                    end
                end
            end
        end
        function com = command(packet, idOfCommand, values)
            packetSize = 64;
            numFloats = (packetSize / 4) - 1;
            
            objMessage = javaArray('java.lang.Byte', packetSize);
            tempArray = packet.single2bytes(idOfCommand, values);
            
            for i=1:size(tempArray)
                objMessage(i) = java.lang.Byte(tempArray(i));
            end
            
            message = javaMethod('toPrimitive', 'org.apache.commons.lang.ArrayUtils', objMessage);
            
            returnValues = zeros(numFloats, 1);
            packet.hidDevice.open();
            if packet.hidDevice.isOpen()
                disp('Writing');
                disp(message);

                val = packet.hidDevice.write(message, packetSize, 0);
                if val > 0
                    read = packet.hidDevice.read(message, 1000);
                    if read > 0
                        for i=1:len(numFloats)
                            baseIndex = (4 * i) + 4;
                            returnValues(i) = java.nio.ByteBuffer.wrap(message).order(be).getFloat(baseIndex);
                        end
                    else
                        disp("Read failed")
                    end
                else
                    disp("Writing failed")
                end
            else
                disp('Device closed!')
            end
            
            packet.hidDevice.close()
            packet.hidService.shutdown();
            com = returnValues;
        end
        function thing = single2bytes(packet, code, val)
            returnArray=uint8(zeros((length(val)+1)*4));
            tmp1 = typecast(int32(code), 'uint8');
            for j=1:4
                 returnArray(j)=tmp1(j);
            end
            disp('Code: ')

            disp(code)
            disp(tmp1)
            for i=1:length(val)
                tmp = typecast(single(val(i)), 'uint8');
                for j=1:4
                    returnArray((i*4)+j+4)=tmp(j);
                end
            end
            thing = returnArray;
        end
    end
end
