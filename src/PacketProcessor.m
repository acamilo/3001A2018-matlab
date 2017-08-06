classdef PacketProcessor
    properties
        hidDevice;
        hidService;
    end
    methods
        function  shutdown(packet)
            packet.hidDevice.close();
            packet.hidService.shutdown();

        end
        function packet = PacketProcessor(deviceID)
            javaaddpath('../lib/hid4java-0.5.1.jar');
            
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
                        packet.hidDevice.open();

                    end
                end
            end
        end
        function com = command(packet, idOfCommand, values)
            packetSize = 64;
            numFloats = (packetSize / 4) - 1;
            %tic
            objMessage = javaArray('java.lang.Byte', packetSize);
            tempArray = packet.single2bytes(idOfCommand, values);
            
            for i=1:size(tempArray)
                objMessage(i) = java.lang.Byte(tempArray(i));
            end
            %toc
            message = javaMethod('toPrimitive', 'org.apache.commons.lang.ArrayUtils', objMessage);
            %toc
            returnValues = zeros(numFloats, 1);
            
            if packet.hidDevice.isOpen()
                %toc
                %disp('Writing');
                %disp(message);

                val = packet.hidDevice.write(message, packetSize, 0);
                %toc
                if val > 0
                    ret = packet.hidDevice.read(int32(packetSize), int32(1000));
                    toc
                    %disp('Read')                 
                    %disp(length(ret))
                    %disp(length(returnValues))
                    %disp(ret)
                    reshapable = zeros(64,1,'uint8');
                    for i=1:64
                        if ret(i).byteValue()>=0
                            reshapable(i)=ret(i).byteValue();
                        else
                            reshapable(i)=ret(i).byteValue()+256;
                        end
                    end
%                     interArray = (ret).byteValue();
%                     thresholded_array = (interArray<0)+256;
%                     reshapable = random_array+thresholded_array;
                    toc
                    disp(reshapable);
                    
                    sm = reshape(reshapable,[4,16])
                    %toc
                    if length(ret) > 0
                           for i=1:length(returnValues)
                               %startIndex = (i*4);
                               %endIndex = startIndex+4;
                               %disp('Single from ');
                               %disp(startIndex);
                               %disp(' to ');
                               %disp(endIndex);
                               subMatrix = sm(:,i+1);
                               returnValues(i)=typecast(subMatrix,'single');
                               %disp( returnValues(i));
                           end
                           
                    else
                        disp("Read failed")
                    end
                    %toc
                else
                    disp("Writing failed")
                end
            else
                disp('Device closed!')
            end
            com = returnValues;
        end
        function thing = single2bytes(packet, code, val)
            returnArray=uint8(zeros((length(val)+1)*4));
            tmp1 = typecast(int32(code), 'uint8');
            for j=1:4
                 returnArray(j)=tmp1(j);
            end
            %disp('Code: ')

            %disp(code)
            %disp(tmp1)
            for i=1:length(val)
                tmp = typecast(single(val(i)), 'uint8');
                for j=1:4
                    returnArray((i*4)+j)=tmp(j);
                end
            end
            thing = returnArray;
        end
    end
end
