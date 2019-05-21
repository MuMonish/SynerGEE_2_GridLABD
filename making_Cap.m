
function making_Cap(feeder_Section,feeder_Capacitor,FeederName,NominalVolt,glm_dir_name)

%[CapMatrix,CapText]=xlsread(strcat(dir_name,'\',FeederName,'_Capacitor.xlsx'));% Read capacitor data
%[SectionMatrix,SectionText]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));% Read section data


GlmFileName=strcat(glm_dir_name,'\','Capacitors_',FeederName,'.glm');
fid = fopen(GlmFileName,'wt');%Capacitors_3HT12F1    Capacitors_ROS12F2
fprintf(fid,strcat('//**Capacitors_',FeederName,':%s\n\n\n'),'');
CapIsOn=cell2mat(feeder_Capacitor(:,7));    % Capacitors status
%CapIsOn=CapMatrix(:,1);    % Capacitors status
CapKvar=cell2mat(feeder_Capacitor(:,9:11));
%CapKvar=CapMatrix(:,3:5);

CapSectionID=feeder_Capacitor(1:end,1);% Use to find From and To Node
%CapSectionID=CapText(2:end,1);% Use to find From and To Node
[SectionsN,~]=size(feeder_Section);
%[SectionsN,~]=size(SectionMatrix);
[CapN,~]=size(feeder_Capacitor);
%[CapN,~]=size(CapMatrix);
SectionPhaseIndex=5;         %5th Column for Phase
UniqID=feeder_Capacitor(1:end,2);
%UniqID=CapText(2:end,2);
% Get Capacitor SectionID-FromNode-ToNode-Phase

SectionID=feeder_Section(1:end,1);
FromNodeId=feeder_Section(1:end,3);
ToNodeId=feeder_Section(1:end,4);
SectionPhase=feeder_Section(1:end,SectionPhaseIndex);
% SectionID=SectionText(2:end,1);
% FromNodeId=SectionText(2:end,3);
% ToNodeId=SectionText(2:end,4);
% SectionPhase=SectionText(2:end,SectionPhaseIndex);
CapSect_Node=cell(CapN,4);
CapSect_Node(:,1)=CapSectionID;

for m=1:CapN
    for n=1:SectionsN
        if strcmp(CapSectionID(m),SectionID(n))
            CapSect_Node(m,2)=FromNodeId(n);
            CapSect_Node(m,3)=ToNodeId(n);
            CapSect_Node(m,4)=SectionPhase(n);
            break;
        end
    end
    
end

for i=1:CapN
    
    fprintf(fid,'object capacitor {\n');
    fprintf(fid,'\tparent %s;\n',char(CapSect_Node(i,3))); %Capacitor is connected to ToNode
    fprintf(fid,'\tname Cap_%s;\n',char(UniqID(i)));
    
    
    if strcmp(CapSect_Node(i,4),'ABCN')
        fprintf(fid,'\tphases ABCN;\n');
        fprintf(fid,'\tphases_connected ABCN;\n');
        fprintf(fid,'\tcontrol MANUAL;\n');
        fprintf(fid,'\tvoltage_set_high  %.2f;\n',NominalVolt*1.05);    %7967.43*1.05  Make more general
        fprintf(fid,'\tvoltage_set_low   %.2f;\n',NominalVolt*0.95);   %7967.43*0.95
        fprintf(fid,'\tcapacitor_A %3f MVAr;\n',CapKvar(i,1)/1000);
        fprintf(fid,'\tcapacitor_B %3f MVAr;\n',CapKvar(i,2)/1000);
        fprintf(fid,'\tcapacitor_C %3f MVAr;\n',CapKvar(i,3)/1000);
        
        if CapIsOn(i) == 0
            fprintf(fid,'\tswitchA OPEN;\n');
            fprintf(fid,'\tswitchB OPEN;\n');
            fprintf(fid,'\tswitchC OPEN;\n');
            
        else
            fprintf(fid,'\tswitchA CLOSED;\n');
            fprintf(fid,'\tswitchB CLOSED;\n');
            fprintf(fid,'\tswitchC CLOSED;\n');
            
            
        end
        fprintf(fid,'\tcontrol_level INDIVIDUAL;\n');
        fprintf(fid,'\tnominal_voltage %.2f;\n',NominalVolt);
        fprintf(fid,'}\n\n\n');
    end
end
fprintf(fid,strcat('//**End Capacitors_',FeederName,'** %s \n\n\n'));

% save Capacitor;

end