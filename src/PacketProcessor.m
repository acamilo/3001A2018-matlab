
classdef PacketProcessor
    properties
        hidDevice;
        hidService;
    end
    methods
	%The is a shutdown function to clear the HID hardware connection
        function  shutdown(packet)
	    %Close the device
            packet.hidDevice.close();
	    %Close the HID services
            packet.hidService.shutdown();

        end
        % Create a packet processor for an HID device with USB PID 0x007
        function packet = PacketProcessor(deviceID)
            % Load the dependant Jar file
            javaaddpath('../lib/hid4java-0.5.1.jar');
            % Import Java classes 
            import org.hid4java.*;
            import org.hid4java.event.*;
            import java.nio.ByteBuffer;
            import java.nio.ByteOrder;
            import java.lang.*;
            import org.apache.commons.lang.ArrayUtils.*;
            % check for missing arguments
            if nargin > 0
                % Load the HID services an search for devices
                packet.hidService = HidManager.getHidServices();
                packet.hidService.start();
                hidDevices = packet.hidService.getAttachedHidDevices();
                dev=hidDevices.toArray;
                %Search the devices list for one with out PID
                for k=1:(dev.length)
                    if dev(k).getProductId() == deviceID
                        packet.hidDevice = dev(k);
                        % Open the device to begin communication
                        packet.hidDevice.open();

                    end
                end
            end
        end
        % Perform a threshhold function for signed bytes to convert to
        % unsigned ints.
        function threshVal = mythreshhold(~,incoming)
            if incoming<0
                threshVal=uint8(incoming+256);
            else
                 threshVal=uint8(incoming);
            end
        end
        %Perform a command cycle. This function will take in a command ID
        %and a list of 32 bit floating point numbers and pass them over the
        %HID interface to the device, it will take the response and parse
        %them back into a list of 32 bit floating point numbers as well
        function com = command(packet, idOfCommand, values)
            % Default packet size for HID
            packetSize = 64;
            %Subtract the first 4 bytes as command id, remainder is data to
            %be transmitted
            numFloats = (packetSize / 4) - 1;
            %tic
            %Create the java datatype for the downstream arguments
            objMessage = javaArray('java.lang.Byte', packetSize);
            %Parse the downstream arguments
            tempArray = packet.single2bytes(idOfCommand, values);
            %convert the parsed byte data to Java datatypes
            for i=1:size(tempArray)
                objMessage(i) = java.lang.Byte(tempArray(i));
            end
            %Convert the array of Java Bytes[] to and array of byte[] to
            %match the incoming datatype of the send function
            message = javaMethod('toPrimitive', 'org.apache.commons.lang.ArrayUtils', objMessage);
            returnValues = zeros(numFloats, 1);
            %Check to see if the device is open
            if packet.hidDevice.isOpen()
                % send the parsed data over the HID interface
                val = packet.hidDevice.write(message, packetSize, 0);
                % Check to see if the data was sent
                if val > 0
                    %Read back a packet of data from the HID interface
                    ret = packet.hidDevice.read(int32(packetSize), int32(1000));
                    disp('Read from hardware');
                    toc
                    disp('Convert to bytes');
                    %Use a Lambda to convert all Bytes to signed integers
                    %in Matlab datatypes
                    byteArray = arrayfun(@(x)  x.byteValue(), ret);
                    toc
                    disp('Reshape');
                    %Reshape the threshholded array. The flat array of
                    %bytes is reshaped to 4x16 so each column contains all
                    %the bytes for a given value
                    sm = reshape(arrayfun(@(x)  mythreshhold(packet,x), byteArray),[4,16]);
                    toc;
                    disp('parse');
                    if ~isempty(ret)
                           
                           for i=1:length(returnValues)
                               % Strip a column to process 
                               subMatrix = sm(:,i+1);
                               % Use teh typecast to convert 4 bytes to the
                               % 32bit datatype
                               returnValues(i)=typecast(subMatrix,'single');
                           end
                           
                    else
                        disp('Read failed')
                    end
                else
                    disp('Writing failed')
                end
            else
                disp('Device closed!')
            end
            com = returnValues;
        end
        function thing = single2bytes(~, code, val)
            % Create the array of bytes
            returnArray=uint8(zeros((length(val)+1)*4));
            %Create the 4 byte control code
            tmp1 = typecast(int32(code), 'uint8');
            for j=1:4
                 returnArray(j)=tmp1(j);
            end
            %disp('Code: ')

            %disp(code)
            %disp(tmp1)
            for i=1:length(val)
                %Convert value to a 4 byte array
                tmp = typecast(single(val(i)), 'uint8');
                %Copy 4 byte data to the main array
                for j=1:4
                    returnArray((i*4)+j)=tmp(j);
                end
            end
            thing = returnArray;
        end
    end
end
