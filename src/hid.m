javaaddpath('../lib/hid4java-0.5.1.jar');

import org.hid4java.*;
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.*;
%
xDoc = xmlread('seaArm.xml');
allListitems = xDoc.getElementsByTagName('DHParameters');
appendages = xDoc.getElementsByTagName('appendage').item(0);
baseTransform = appendages.getElementsByTagName('baseToZframe').item(0);

printTag(baseTransform,'x');
printTag(baseTransform,'y');
printTag(baseTransform,'z');
printTag(baseTransform,'rotw');
printTag(baseTransform,'rotx');
printTag(baseTransform,'roty');
printTag(baseTransform,'rotz');

for k = 0:allListitems.getLength-1
   thisListitem = allListitems.item(k);
   fprintf('Link %i\n',k);
   % Get the label element. In this file, each
   % listitem contains only one label.
   printTag(thisListitem,'Delta');
   printTag(thisListitem,'Theta');
   printTag(thisListitem,'Radius');
   printTag(thisListitem,'Alpha');
end

pp = PacketProcessor(7);

%Create an array of 32 bit floaing point zeros to load an pass to the
%packet processor
values = zeros(15, 1, 'single');
sinWaveInc = 200.0;
range = 400.0;
%Iterate through a sine wave for joint values
 for k=1:sinWaveInc
     incremtal = (single(k) / sinWaveInc);
     for j=0:4
         %Send a new setpoint based on a since wave
         values((j * 3) + 1) = (sin(incremtal * pi *2.0 )*range)+(range);
         %Send junk data for velocity and force targets
         values((j * 3) + 2) = 0;
         values((j * 3) + 3) = 3;
     end
     tic
     %Process command and print the returning values
     returnValues = pp.command(37, values);
     toc
     disp('sent');
     disp(values);
     disp('got');
     disp(returnValues);
     %timeit(returnValues)
 end
pp.shutdown()
clear java;

function printTag(thisListitem,name)
   % listitem contains only one label.
   thisList = thisListitem.getElementsByTagName(name);
   thisElement = thisList.item(0);
   data  = thisElement.getFirstChild.getData;
   fprintf('%s %s\n',thisElement,data);
end