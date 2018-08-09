
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
        function packet = PacketProcessor(vid,deviceID)

            javaclasspath
            import edu.wpi.SimplePacketComs.phy.HIDfactory;
            packet.myHIDSimplePacketComs=HIDfactory.get();
            packet.myHIDSimplePacketComs.setPid(deviceID);
            packet.myHIDSimplePacketComs.setVid(vid);
            packet.myHIDSimplePacketComs.connet();
            
        end
        %Perform a command cycle. This function will take in a command ID
        %and a list of 32 bit floating point numbers and pass them over the
        %HID interface to the device, it will take the response and parse
        %them back into a list of 32 bit floating point numbers as well
        function com = command(packet, idOfCommand, values)
            % Default packet size for HID
            packet.writeFloats(idOfCommand,  values);
            com = 	packet.readFloats(idOfCommand) ;
        end
    end
end
