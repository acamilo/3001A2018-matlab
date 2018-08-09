
classdef PacketProcessor
    properties
        %hidDevice;
        %hidService;
        myHIDSimplePacketComs
    end
    methods
	%The is a shutdown function to clear the HID hardware connection
        function  shutdown(packet)
	    %Close the device
            packet.myHIDSimplePacketComs.disconnect();
        end
        % Create a packet processor for an HID device with USB PID 0x007
        function packet = PacketProcessor(dev)
             packet.myHIDSimplePacketComs=dev;    
        end
        %Perform a command cycle. This function will take in a command ID
        %and a list of 32 bit floating point numbers and pass them over the
        %HID interface to the device, it will take the response and parse
        %them back into a list of 32 bit floating point numbers as well
        function com = command(packet, idOfCommand, values)
            ds = javaArray('java.lang.Double',length(values));
            for i=1:length(values)
               ds(i)= values(i);
            end
            % Default packet size for HID
            packet.writeFloats(idOfCommand,  ds);
            com = 	packet.readFloats(Integer(idOfCommand)) ;
        end
    end
end
