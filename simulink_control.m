clc;
clear;
close all;
open_system('example')

sim_time_step = 0.01;

% start the simulation and pause the simulation, waiting for singal from python
set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');

% open a server, it will block until a client connect to it
s = tcpip('127.0.0.1', 54320,  'NetworkRole', 'server');
fopen(s);


count=0
% main loop
while  count<100 % can be changed      
    while(1) %loop, until read some data
        nBytes = get(s,'BytesAvailable');
        if nBytes>0
            break;
        end
    end
    command = fread(s,nBytes);
    data=str2num(char(command()'));
    if isempty(data)
        data=0;
    end

    % set a paramter in the simulink model using the data get from python
    set_param('example/K','Gain',num2str(data))
        
    % run the simulink model for a step
    set_param(gcs, 'SimulationCommand', 'step');  
    
    % puase the simulink model and send some data to python
    pause(0.1);
    u=states.data(end,:)
    fwrite(s, jsonencode(u));
    count=count+1;
end
fclose(s);

