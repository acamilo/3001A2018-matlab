%%
% RBE3001 - Laboratory 1 
% 
% Instructions
% ------------
% Welcome again! This MATLAB script is your starting point for Lab
% 1 of RBE3001. The sample code below demonstrates how to establish
% communication between this script and the Nucleo firmware, send
% setpoint commands and receive sensor data.
% 
% IMPORTANT - understanding the code below requires being familiar
% with the Nucleo firmware. Read that code first.
clear java;
%clear import;
clear classes;
vid = hex2dec('3742');
pid = hex2dec('0008');
disp (vid );
disp (pid);
javaaddpath ../lib/SimplePacketComsJavaFat-0.5.1.jar;
import edu.wpi.SimplePacketComs.*;
import edu.wpi.SimplePacketComs.device.*;
import edu.wpi.SimplePacketComs.phy.*;
import java.util.*;
import org.hid4java.*;
version -java;
myHIDSimplePacketComs=HIDfactory.get();
myHIDSimplePacketComs.setPid(pid);
myHIDSimplePacketComs.setVid(vid);
myHIDSimplePacketComs.connect();
% Create a PacketProcessor object to send data to the nucleo firmware
pp = PacketProcessor(myHIDSimplePacketComs); 
try
  SERV_ID = 37;            % we will be talking to server ID 37 on
                           % the Nucleo

  DEBUG   = true;          % enables/disables debug prints

  % Instantiate a packet - the following instruction allocates 64
  % bytes for this purpose. Recall that the HID interface supports
  % packet sizes up to 64 bytes.
  packet = zeros(15, 1, 'single');

  % The following code generates a sinusoidal trajectory to be
  % executed on joint 1 of the arm and iteratively sends the list of
  % setpoints to the Nucleo firmware. 
  viaPts = [0, -400, 400, -400, 400, 0];

  tic

  % Iterate through a sine wave for joint values
  for k = viaPts
      %incremtal = (single(k) / sinWaveInc);

      packet(1) = k;


      % Send packet to the server and get the response
      returnPacket = pp.command(SERV_ID, packet);
      toc

      if DEBUG
          disp('Sent Packet:');
          disp(packet);
          disp('Received Packet:');
          disp(returnPacket);
      end

      pause(1) %timeit(returnPacket) !FIXME why is this needed?
  end
catch exception
    getReport(exception)
    disp('Exited on error, clean shutdown');
end
% Clear up memory upon termination
pp.shutdown()


toc
