javaaddpath('../lib/hid4java-0.5.1.jar');

import org.hid4java.*;
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.*;


pp = PacketProcessor(7);


values = zeros(15, 1, 'single');
sinWaveInc = 200.0;
range = 400.0;

 for k=1:sinWaveInc
     incremtal = (single(k) / sinWaveInc);
     for j=0:4
         values((j * 3) + 1) = sin(incremtal * pi *2.0 )*range;
         values((j * 3) + 2) = 0;
         values((j * 3) + 3) = 3;
     end

     returnValues = pp.command(37, values);
     disp('sent');
     disp(values);
     disp('got');
     disp(returnValues);
     %timeit(returnValues)
 end
pp.shutdown()
clear java;